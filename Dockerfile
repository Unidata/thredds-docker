FROM unidata/tomcat-docker:11-jdk17

# netcdf envs
ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
ENV HDF5_VERSION=1.14.6
ENV ZLIB_VERSION=1.3.2
ENV NETCDF_VERSION=4.10.1
ENV ZDIR=/usr/local
ENV PDIR=/usr
ENV HDF5_VER=hdf5-${HDF5_VERSION}
ENV HDF5_FILE=${HDF5_VER}.tar.gz
# tds envs
ENV TDS_CONTENT_ROOT_PATH=/usr/local/tomcat/content
ENV TOMCAT_ADDITIONAL_WRITABLE_DIRS=content
ENV THREDDS_XMX_SIZE=4G
ENV THREDDS_XMS_SIZE=4G
ENV THREDDS_WAR_URL=https://downloads.unidata.ucar.edu/tds/5.10/thredds-5.10-SNAPSHOT.war

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends  vim build-essential m4 \
        libpthread-stubs0-dev libcurl4-openssl-dev zip unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Native libraries
ARG SKIP_NATIVE_BUILD=false
RUN if [ "${SKIP_NATIVE_BUILD}" = "true" ]; then \
        echo "WARNING: native libraries skipped for development build"; \
    else \
        curl -fSL "https://zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz" -o zlib-${ZLIB_VERSION}.tar.gz && \
        tar xzf zlib-${ZLIB_VERSION}.tar.gz && \
        rm zlib-${ZLIB_VERSION}.tar.gz && \
        cd zlib-${ZLIB_VERSION} && \
        ./configure --prefix=/usr/local && \
        make && make install && \
        cd .. && rm -rf zlib-${ZLIB_VERSION} && \
        curl -fSL "https://github.com/HDFGroup/hdf5/releases/download/hdf5_${HDF5_VERSION}/${HDF5_FILE}" -o ${HDF5_FILE} && \
        tar xzf ${HDF5_FILE} && \
        rm ${HDF5_FILE} && \
        cd hdf5-${HDF5_VERSION} && \
        ./configure --with-zlib=${ZDIR} --enable-threadsafe --with-pthread=${PDIR} --enable-unsupported --prefix=/usr/local && \
        make && make check && make install && make check-install && ldconfig && \
        cd .. && rm -rf hdf5-${HDF5_VERSION} && \
        export CPPFLAGS=-I/usr/local/include \
        LDFLAGS=-L/usr/local/lib && \
        curl -fSL "https://downloads.unidata.ucar.edu/netcdf-c/${NETCDF_VERSION}/netcdf-c-${NETCDF_VERSION}.tar.gz" -o netcdf-c-${NETCDF_VERSION}.tar.gz && \
        tar xzf netcdf-c-${NETCDF_VERSION}.tar.gz && \
        rm netcdf-c-${NETCDF_VERSION}.tar.gz && \
        cd netcdf-c-${NETCDF_VERSION} && \
        ./configure --disable-dap-remote-tests --disable-libxml2 --prefix=/usr/local && \
        make check && make install && ldconfig && \
        cd .. && rm -rf netcdf-c-${NETCDF_VERSION}; \
    fi

COPY files/threddsConfig.xml ${CATALINA_HOME}/content/thredds/threddsConfig.xml
COPY files/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml
COPY files/setenv.sh ${CATALINA_HOME}/bin/setenv.sh
COPY files/javaopts.sh ${CATALINA_HOME}/bin/javaopts.sh

# Install TDS
RUN curl -fSL "${THREDDS_WAR_URL}" -o thredds.war && \
    unzip thredds.war -d ${CATALINA_HOME}/webapps/thredds/ && \
    rm -f thredds.war && \
    mkdir -p ${CATALINA_HOME}/content/thredds

EXPOSE 8080 8443

WORKDIR ${CATALINA_HOME}

HEALTHCHECK --interval=10s --timeout=3s \
	CMD curl --fail 'http://localhost:8080/thredds/catalog.html' || exit 1
