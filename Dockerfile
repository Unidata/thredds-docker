# Use the official Unidata THREDDS base image
FROM unidata/thredds-docker:5.6

# Set build-time environment variable for convenience (already defined in base image, but safe to reference)
ENV CATALINA_HOME=/usr/local/tomcat

# Copy your local config files into the THREDDS content directory
COPY config/threddsConfig.xml ${CATALINA_HOME}/content/thredds/threddsConfig.xml
COPY config/catalog.xml ${CATALINA_HOME}/content/thredds/catalog.xml
COPY config/wmsConfig.xml ${CATALINA_HOME}/content/thredds/wmsConfig.xml

CMD ["catalina.sh", "run"]