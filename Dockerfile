###
# Dockerfile for TDS
###

FROM axiom/docker-tomcat:8.0.36

MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com> and Unidata Cloud Team

###
# Usual maintenance
###

RUN \
    apt-get update && \
    apt-get install -y \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENV TDS_VERSION 4.6.6

###
# Grab and unzip the TDS
###

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

COPY files/threddsConfig.xml ${CATALINA_HOME}/content/thredds/threddsConfig.xml

###
# Tomcat users
###

COPY files/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml

###
# Java options
###

COPY files/javaopts.sh ${CATALINA_HOME}/bin/javaopts.sh

###
# chown
###

RUN chown -R tomcat:tomcat "${CATALINA_HOME}"

# USER tomcat
