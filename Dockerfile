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
    apt-get install -y unzip vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# THREDDS
ENV THREDDS_VERSION 5.0.0-SNAPSHOT

ENV THREDDS_WAR_NAME 5.0.0-20160808.141712-14

###
# Grab and unzip the TDS
###

ENV THREDDS_WAR_URL https://artifacts.unidata.ucar.edu/content/repositories/unidata-snapshots/edu/ucar/tds/$THREDDS_VERSION/tds-$THREDDS_WAR_NAME.war

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
# Entry point
###

COPY entrypoint.sh ${CATALINA_HOME}/

###
# chown
###

RUN chown -R tomcat:tomcat "${CATALINA_HOME}"

###
# Start container
###

ENTRYPOINT ["/opt/tomcat/entrypoint.sh"]

EXPOSE 8080 8443

CMD ["catalina.sh", "run"]
