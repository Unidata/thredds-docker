###
# Dockerfile for TDS
###

FROM unidata/tomcat-docker:8

MAINTAINER Unidata

###
# Usual maintenance
###

USER root

RUN \
    apt-get update && \
    apt-get install -y unzip vim build-essential m4 libpthread-stubs0-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /downloads

WORKDIR /downloads

###
# Installing netcdf-c library according to:
# http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/reference/netcdf4Clibrary.html 
###

ENV LD_LIBRARY_PATH /usr/local/lib:${LD_LIBRARY_PATH}

ENV HDF5_VERSION 1.8.17

ENV ZLIB_VERSION 1.2.8

ENV NETCDF_VERSION 4.4.1

ENV ZDIR /usr/local

ENV H5DIR /usr/local

ENV PDIR /usr

#zlib dependency
RUN curl ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4/zlib-${ZLIB_VERSION}.tar.gz | tar xz && \
    cd zlib-${ZLIB_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && make install

ENV HDF5_VER hdf5-${HDF5_VERSION}
ENV HDF5_FILE ${HDF5_VER}.tar.gz

#hdf5 dependency
RUN curl https://support.hdfgroup.org/ftp/HDF5/releases/${HDF5_VER}/src/${HDF5_FILE} | tar xz && \
    cd hdf5-${HDF5_VERSION} && \
    ./configure --with-zlib=${ZDIR} --prefix=${H5DIR} --enable-threadsafe --with-pthread=${PDIR} --enable-unsupported --prefix=/usr/local && \
    make && make check && make install && make check-install && ldconfig

#netCDF4-c
RUN export CPPFLAGS=-I/usr/local/include \
    LDFLAGS=-L/usr/local/lib && \
    curl ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-${NETCDF_VERSION}.tar.gz | tar xz && \
    cd netcdf-${NETCDF_VERSION} && \
    ./configure --prefix=/usr/local && \
    make check && make install && ldconfig

###
# Grab and unzip the TDS
###

ENV TDS_VERSION 5.0.0
ENV TDS_SNAPSHOT_VERSION ${TDS_VERSION}-20161026.011301-32
ENV THREDDS_WAR_URL https://artifacts.unidata.ucar.edu/content/repositories/unidata-snapshots/edu/ucar/tds/${TDS_VERSION}-SNAPSHOT/tds-${TDS_SNAPSHOT_VERSION}.war

RUN curl -fSL "${THREDDS_WAR_URL}" -o thredds.war

RUN unzip thredds.war -d ${CATALINA_HOME}/webapps/thredds/

###
# Install ncSOS
###

COPY files/ncsos.jar ${CATALINA_HOME}/webapps/thredds/WEB-INF/lib/ncsos.jar

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
# Cleanup
###

WORKDIR ${CATALINA_HOME}

RUN rm -rf /downloads

###
# Inherited from parent container
###

ENTRYPOINT ["/entrypoint.sh"]

###
# Start container
###

CMD ["catalina.sh", "run"]
