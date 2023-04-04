###
# Dockerfile for TDS
###

FROM unidata/tomcat-docker:8.5-jdk11

MAINTAINER Unidata

###
# Usual maintenance
###

USER root

RUN \
    apt-get update && \
    apt-get install -y unzip vim build-essential m4 \
    libpthread-stubs0-dev libcurl4-openssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###
# Installing netcdf-c library according to:
# http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/reference/netcdf4Clibrary.html
###

ENV LD_LIBRARY_PATH /usr/local/lib:${LD_LIBRARY_PATH}

ENV HDF5_VERSION 1.10.5

ENV ZLIB_VERSION 1.2.9

ENV NETCDF_VERSION 4.7.2

ENV ZDIR /usr/local

ENV H5DIR /usr/local

ENV PDIR /usr

#zlib dependency
RUN curl https://zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz | tar xz && \
    cd zlib-${ZLIB_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    cd .. && rm -rf zlib-${ZLIB_VERSION}

ENV HDF5_VER hdf5-${HDF5_VERSION}
ENV HDF5_FILE ${HDF5_VER}.tar.gz

#hdf5 dependency
RUN curl https://support.hdfgroup.org/ftp/HDF5/releases/${HDF5_VER%.*}/${HDF5_VER}/src/${HDF5_FILE} | tar xz && \
    cd hdf5-${HDF5_VERSION} && \
    ./configure --with-zlib=${ZDIR} --prefix=${H5DIR} --enable-threadsafe --with-pthread=${PDIR} --enable-unsupported --prefix=/usr/local && \
    make && make check && make install && make check-install && ldconfig && \
    cd .. && rm -rf hdf5-${HDF5_VERSION}

#netCDF4-c
RUN export CPPFLAGS=-I/usr/local/include \
    LDFLAGS=-L/usr/local/lib && \
    curl ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-${NETCDF_VERSION}.tar.gz | tar xz && \
    cd netcdf-c-${NETCDF_VERSION} && \
    ./configure --disable-dap-remote-tests --prefix=/usr/local && \
    make check && make install && ldconfig && \
    cd .. && rm -rf netcdf-c-${NETCDF_VERSION}

###
# Grab and unzip the TDS
###

ENV TDS_CONTENT_ROOT_PATH /usr/local/tomcat/content

# The amount of Xmx and Xms memory Java args to allocate to THREDDS

ENV THREDDS_XMX_SIZE 4G

ENV THREDDS_XMS_SIZE 4G

ENV THREDDS_WAR_URL https://downloads.unidata.ucar.edu/tds/5.5/thredds-5.5-SNAPSHOT.war

RUN curl -fSL "${THREDDS_WAR_URL}" -o thredds.war && \
    unzip thredds.war -d ${CATALINA_HOME}/webapps/thredds/ && \
    rm -f thredds.war

###
# Default thredds config
###

RUN mkdir -p ${CATALINA_HOME}/content/thredds

COPY files/threddsConfig.xml ${CATALINA_HOME}/content/thredds/threddsConfig.xml

###
# Tomcat users
###

COPY files/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml

###
# Tomcat Java Options
###

COPY files/setenv.sh $CATALINA_HOME/bin/setenv.sh

COPY files/javaopts.sh $CATALINA_HOME/bin/javaopts.sh

RUN chmod 755 $CATALINA_HOME/bin/*.sh

###
# Creating .systemPrefs directory according to
# http://www.unidata.ucar.edu/software/thredds/current/tds/faq.html#javaUtilPrefs
# and as defined in the files/javaopts.sh file
###

RUN mkdir -p ${CATALINA_HOME}/javaUtilPrefs/.systemPrefs

###
# Expose ports
###

EXPOSE 8080 8443

###
# Set working directory
###

WORKDIR ${CATALINA_HOME}

###
# Inherited from parent container
###

ENTRYPOINT ["/entrypoint.sh"]

###
# Start container
###

CMD ["catalina.sh", "run"]

HEALTHCHECK --interval=10s --timeout=3s \
	CMD curl --fail 'http://localhost:8080/thredds/catalog.html' || exit 1
