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

ENV TDM_VERSION 4.6.10

###
# Grab the TDM
###

RUN curl -SL \
    https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/${TDM_VERSION}/tdmFat-${TDM_VERSION}.jar \
    -o tdm.jar

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

ENV TDM_XMX_SIZE 6g
ENV TDM_CONTENT_ROOT_PATH /usr/local/tomcat/content
ENV TDM_USER tdm
ENV TDS_HOST http://thredds/
ENV LOG_LEVEL info

CMD java -jar -d64 -Xmx${TDM_XMX_SIZE} -DbbTdm=1 -Dtds.content.root.path=$TDM_CONTENT_ROOT_PATH \
      $TDM_HOME/tdm.jar -nthreads 1 -cred $TDM_USER:$TDM_PW -tds "$TDS_HOST" \
			-log $LOG_LEVEL
