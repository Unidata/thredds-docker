FROM java:8

MAINTAINER Unidata Cloud Team

###
# Usual maintenance
###

USER root

RUN apt-get update

RUN apt-get install -y curl

###
# Create the user and group tomcat and change ownership of the tomcat directory
# to user and group tomcat. Note that we are not running a Java web application
# or Tomcat. We are simply creating a non-root user, and tomcat is a convenient
# choice especially when working with the TDS and its Tomcat web application
# directory structure.
###

ENV CATALINA_HOME /usr/local/tomcat

ENV TDM_HOME ${CATALINA_HOME}/content/tdm

RUN mkdir -p $TDM_HOME

RUN groupadd -r tomcat && \
	useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin \
  -c "Tomcat user" tomcat

###
# Create content/tdm directory
###

WORKDIR $TDM_HOME

ENV TDM_VERSION 5.0.0
ENV TDM_SNAPSHOT_VERSION ${TDM_VERSION}-20161026.124250-33

###
# Grab the TDM
###

RUN curl -SL \
    https://artifacts.unidata.ucar.edu/content/repositories/unidata-snapshots/edu/ucar/tdmFat/${TDM_VERSION}-SNAPSHOT/tdmFat-${TDM_SNAPSHOT_VERSION}.jar \
    -o tdm.jar

###
# Copy the TDM executable inside the container
###

COPY tdm.sh $TDM_HOME

RUN chmod +x tdm.sh

###
# Change owner of tomcat directory to user and group tomcat
###

RUN chown -R tomcat:tomcat $CATALINA_HOME

###
# Switch to user tomcat
###

USER tomcat

###
# TDS Command
###

CMD $TDM_HOME/tdm.sh
