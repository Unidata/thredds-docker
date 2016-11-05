#!/bin/sh

###
# Java options
###

# http://www.unidata.ucar.edu/software/thredds/current/tds/faq.html#javaUtilPrefs
# Choosing a JAVA_PREFS_SYSTEM_ROOT directory location that will likely live
# inside the container.

NORMAL="-server -d64 -Xms4G -Xmx4G"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"
CONTENT_ROOT="-Dtds.content.root.path=$CATALINA_HOME/content"
JAVA_PREFS_SYSTEM_ROOT="-Djava.util.prefs.systemRoot=$CATALINA_HOME/javaUtilPrefs -Djava.util.prefs.userRoot=$CATALINA_HOME/javaUtilPrefs"
mkdir -p $CATALINA_HOME/javaUtilPrefs/.systemPrefs

JAVA_OPTS="$JAVA_OPTS $CONTENT_ROOT/ $JAVA_PREFS_SYSTEM_ROOT $NORMAL $HEAP_DUMP $HEADLESS"
export JAVA_OPTS
