FROM java:8-jre
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>

# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
    05AB33110949707C93A279E3D3EFE6B686867BA6 \
    07E48665A34DCAFAE522E5E6266191C37C037D42 \
    47309207D818FFD8DCD3F83F1931D684307A10A5 \
    541FBE7D8F78B25E055DDEE13C370389288584E7 \
    61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
    79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
    9BA44C2621385CB966EBA586F72C284D731FABEE \
    A27677289986DB50844682F8ACB77FC2E86E29AC \
    A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
    DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
    F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
    F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23

ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.28
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# Tomcat
RUN set -x \
    && curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
    && curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
    && gpg --verify tomcat.tar.gz.asc \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm tomcat.tar.gz*

# Apache native libraries (apr)
RUN set -x \
    && apt-get update \
    && apt-get install -yq gcc make openssl libssl-dev libapr1 libapr1-dev openjdk-8-jdk="$JAVA_DEBIAN_VERSION"
    && tar zxf /usr/local/tomcat/bin/tomcat-native.tar.gz -C /tmp \
    && cd /tmp/tomcat-native*-src/jni/native/ \
    && ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=/usr/lib/jvm/java-8-openjdk-amd64/ --with-ssl=yes --libdir=/usr/lib/jni \
    && make \
    && make install \
    && apt-get purge -y openjdk-8-jdk="$JAVA_DEBIAN_VERSION" gcc make libssl-dev libapr1-dev \
    && apt-get -y autoremove \
    && rm -rf /tmp/tomcat-native* \
    && rm -rf /var/lib/apt/lists/*

# THREDDS
ENV THREDDS_VERSION 4.6.2
ENV THREDDS_WAR_URL https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/$THREDDS_WAR_URL/tds-$THREDDS_WAR_URL.war

RUN set -x \
    && curl -fSL "$THREDDS_WAR_URL" -o $CATALINA_HOME/webapps/thredds.war

# Run Tomcat as the 'tomcat' user
RUN groupadd -r tomcat -g 1000
RUN useradd -u 1000 -r -g tomcat -d $CATALINA_HOME -s /bin/bash tomcat

# Tomcat helpers
COPY files/.bash_profile $CATALINA_HOME/.bash_profile
COPY files/.bash_logout $CATALINA_HOME/.bash_logout

# Tomcat config
COPY files/setenv.sh $CATALINA_HOME/bin/setenv.sh
COPY files/server.xml $CATALINA_HOME/conf/server.xml
COPY files/tomcat-users.xml $CATALINA_HOME/conf/tomcat-users.xml

RUN chown -R tomcat:tomcat "$CATALINA_HOME"
USER tomcat
EXPOSE 8080
CMD ["catalina.sh", "run"]




#
# Install netcdf and some basic command line tools
#
#RUN apt-get update && apt-get install -y \
#  less \
#  libnetcdf-dev \
#  vim

#
# Create the user and group tomcat and change ownershiup of the tomcat
#   directory to user and group tomcat
#


#
# Copy over modified tomcat files
#
COPY tomcat-files/bin/setenv.sh /usr/local/tomcat/bin/setenv.sh
COPY tomcat-files/conf/server.xml /usr/local/tomcat/conf/server.xml
COPY tomcat-files/conf/tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml
COPY tomcat-files/conf/keystore /usr/local/tomcat/conf/keystore

#
# Copy over bash_profile file that sets correct umask for sharing
#
# Copy over bash_logout file that nicely closes java processes for
#  shutting down
#
COPY tomcat-files/bash_profile /usr/local/tomcat/.bash_profile
COPY tomcat-files/bash_logout /usr/local/tomcat/.bash_logout

#
# get the latest stable THREDDS Data Server (TDS)
#
#RUN wget -O /usr/local/tomcat/webapps/thredds##04.06.02.war https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/4.6.2/tds-4.6.2.war

#
# Copy thredds.war
#
COPY thredds.war /usr/local/tomcat/webapps/thredds##04.06.04-SNAPSHOT.war

#
# Change owner of tomcat directory to user and group tomcat
#
RUN chown -R tomcat:tomcat /usr/local/tomcat

#
# Switch to user tomcat
#
USER tomcat

EXPOSE 8080 8443
