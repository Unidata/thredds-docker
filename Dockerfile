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
    apt-get install -y unzip vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###
# Grab and unzip the TDS
###

ENV TDS_VERSION 4.6.6
ENV THREDDS_WAR_URL https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/${TDS_VERSION}/tds-${TDS_VERSION}.war

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
# Expose ports
###

EXPOSE 8080 8443

###
# Java options
###

# http://www.unidata.ucar.edu/software/thredds/current/tds/faq.html#javaUtilPrefs
# Choosing a JAVA_PREFS_SYSTEM_ROOT directory location that will likely live
# inside the container.

RUN mkdir -p ${CATALINA_HOME}/javaUtilPrefs/.systemPrefs

ENV JAVA_OPTS -server -d64 -Xms4G -Xmx4G \
   -XX:+HeapDumpOnOutOfMemoryError \
   -Djava.awt.headless=true \
   -Dtds.content.root.path=${CATALINA_HOME}/content \
   -Djava.util.prefs.systemRoot=${CATALINA_HOME}/javaUtilPrefs \
   -Djava.util.prefs.userRoot=${CATALINA_HOME}/javaUtilPrefs

###
# Reasserting ownership and permissions from parent container
# https://github.com/docker/docker/issues/6119
# https://github.com/docker/docker/issues/7390
###

RUN chown -R tomcat:tomcat ${CATALINA_HOME} && \
    chmod 400 ${CATALINA_HOME}/conf/* && \
    chmod 300 ${CATALINA_HOME}/logs/.

USER tomcat

###
# Start container
###

CMD ["catalina.sh", "run"]
