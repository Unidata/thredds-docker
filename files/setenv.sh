#!/bin/sh

CATALINA_HOME="/opt/tomcat"
export CATALINA_HOME

CATALINA_BASE="/opt/tomcat"
export CATALINA_BASE

JAVA_HOME="/usr"
export JAVA_HOME

CONTENT_ROOT="-Dtds.content.root.path=$CATALINA_HOME/content"
NORMAL="-d64 -Xmx4090m -Xmx4090m -server -ea"
MAX_PERM_GEN="-XX:MaxPermSize=256m"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"
JAVA_PREFS_SYSTEM_ROOT="-Djava.util.prefs.systemRoot=$CATALINA_HOME/content/thredds/javaUtilPrefs -Djava.util.prefs.userRoot=$CATALINA_HOME/content/thredds/javaUtilPrefs"

JAVA_OPTS="$CONTENT_ROOT $NORMAL $MAX_PERM_GEN $HEAP_DUMP $HEADLESS $JAVA_PREFS_SYSTEM_ROOT"

export JAVA_OPTS
