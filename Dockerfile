FROM unidata/tomcat-docker:9.0-jdk11

MAINTAINER Unidata

USER root

# netcdf envs
ENV LD_LIBRARY_PATH /usr/local/lib:${LD_LIBRARY_PATH}
ENV HDF5_VERSION 1.12.2
ENV ZLIB_VERSION 1.2.9
ENV NETCDF_VERSION 4.9.2
ENV ZDIR /usr/local
ENV H5DIR /usr/local
ENV PDIR /usr
ENV HDF5_VER hdf5-${HDF5_VERSION}
ENV HDF5_FILE ${HDF5_VER}.tar.gz
# tds envs
ENV TDS_CONTENT_ROOT_PATH /usr/local/tomcat/content
ENV THREDDS_XMX_SIZE 4G
ENV THREDDS_XMS_SIZE 4G
ENV THREDDS_WAR_URL https://downloads.unidata.ucar.edu/tds/5.5/thredds-5.5.war
ENV THREDDS_ISO_JAR_URL https://downloads.unidata.ucar.edu/tds/5.5/tds-plugin-2.4.6-jar-with-dependencies.jar

COPY files/threddsConfig.xml ${CATALINA_HOME}/content/thredds/threddsConfig.xml
COPY files/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml
COPY files/setenv.sh ${CATALINA_HOME}/bin/setenv.sh
COPY files/javaopts.sh ${CATALINA_HOME}/bin/javaopts.sh

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends  vim build-essential m4 \
        libpthread-stubs0-dev libcurl4-openssl-dev gosu zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # zlib
    curl https://zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz | tar xz && \
    cd zlib-${ZLIB_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    cd .. && rm -rf zlib-${ZLIB_VERSION} && \
    # hdf
    curl https://support.hdfgroup.org/ftp/HDF5/releases/${HDF5_VER%.*}/${HDF5_VER}/src/${HDF5_FILE} | tar xz && \
    cd hdf5-${HDF5_VERSION} && \
    ./configure --with-zlib=${ZDIR} --prefix=${H5DIR} --enable-threadsafe --with-pthread=${PDIR} --enable-unsupported --prefix=/usr/local && \
    make && make check && make install && make check-install && ldconfig && \
    cd .. && rm -rf hdf5-${HDF5_VERSION} && \
    # netcdf
    export CPPFLAGS=-I/usr/local/include \
    LDFLAGS=-L/usr/local/lib && \
    curl https://downloads.unidata.ucar.edu/netcdf-c/${NETCDF_VERSION}/netcdf-c-${NETCDF_VERSION}.tar.gz | tar xz && \
    cd netcdf-c-${NETCDF_VERSION} && \
    ./configure --disable-dap-remote-tests --disable-libxml2 --prefix=/usr/local && \
    make check && make install && ldconfig && \
    cd .. && rm -rf netcdf-c-${NETCDF_VERSION} && \
    # thredds
    curl -fSL "${THREDDS_WAR_URL}" -o thredds.war && \
    unzip thredds.war -d ${CATALINA_HOME}/webapps/thredds/ && \
    rm -f thredds.war && \
    mkdir -p ${CATALINA_HOME}/content/thredds && \
    chmod 755 ${CATALINA_HOME}/bin/*.sh && \
    mkdir -p ${CATALINA_HOME}/javaUtilPrefs/.systemPrefs && \
    # threddsIso
    curl -fsL "${THREDDS_ISO_JAR_URL}" -o ${CATALINA_HOME}/webapps/thredds/WEB-INF/lib/tds-plugin-jar-with-dependencies.jar

EXPOSE 8080 8443

WORKDIR ${CATALINA_HOME}

# Inherited from parent container
ENTRYPOINT ["/entrypoint.sh"]

# Start container
CMD ["catalina.sh", "run"]

HEALTHCHECK --interval=10s --timeout=3s \
	CMD curl --fail 'http://localhost:8080/thredds/catalog.html' || exit 1
