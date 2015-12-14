FROM axiom/docker-tomcat:8.0
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>

# THREDDS
ENV THREDDS_VERSION 4.6.3
ENV THREDDS_WAR_URL https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/$THREDDS_VERSION/tds-$THREDDS_VERSION.war

RUN curl -fSL "$THREDDS_WAR_URL" -o $CATALINA_HOME/webapps/tds-$THREDDS_VERSION.war
RUN mv $CATALINA_HOME/webapps/tds-$THREDDS_VERSION.war $CATALINA_HOME/webapps/thredds.war

# Tomcat users
COPY files/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml
# Java options
COPY files/javaopts.sh $CATALINA_HOME/bin/javaopts.sh

RUN chown -R tomcat:tomcat "$CATALINA_HOME"

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080 8443
CMD ["catalina.sh", "run"]
