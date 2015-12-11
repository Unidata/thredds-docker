#!/bin/sh

CATALINA_HOME="/opt/tomcat"
export CATALINA_HOME

CATALINA_BASE=$CATALINA_HOME
export CATALINA_BASE

JAVA_HOME="/usr/lib/jvm/java-8-oracle"
export JAVA_HOME

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jni
export LD_LIBRARY_PATH

CONTENT_ROOT="-Dtds.content.root.path=$CATALINA_HOME/content"
JAVA_PREFS_SYSTEM_ROOT="-Djava.util.prefs.systemRoot=$CONTENT_ROOT/thredds/javaUtilPrefs -Djava.util.prefs.userRoot=$CONTENT_ROOT/thredds/javaUtilPrefs"

JAVA_OPTS="$CONTENT_ROOT/ $JAVA_PREFS_SYSTEM_ROOT"
export JAVA_OPTS

. $CATALINA_HOME/bin/javaopts.sh
