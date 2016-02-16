FROM axiom/docker-tomcat:8.0
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>

RUN \
    apt-get update && \
    apt-get install -y unzip

# THREDDS
ENV THREDDS_VERSION 4.6.4
ENV THREDDS_WAR_URL https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/$THREDDS_VERSION/tds-$THREDDS_VERSION.war

RUN curl -fSL "$THREDDS_WAR_URL" -o thredds.war
RUN unzip thredds.war -d $CATALINA_HOME/webapps/thredds/

# Install ncSOS
COPY files/ncsos.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/ncsos.jar
# Default thredds config
COPY files/threddsConfig.xml $CATALINA_HOME/content/thredds/threddsConfig.xml

# Tomcat users
COPY files/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml
# Java options
COPY files/javaopts.sh $CATALINA_HOME/bin/javaopts.sh

RUN chown -R tomcat:tomcat "$CATALINA_HOME"

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080 8443
CMD ["catalina.sh", "run"]
