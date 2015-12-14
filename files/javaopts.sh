#!/bin/sh

NORMAL="-server -d64 -Xms4G -Xmx4G"
MAX_PERM_GEN="-XX:MaxPermSize=256m"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"

CONTENT_ROOT="-Dtds.content.root.path=$CATALINA_HOME/content"
JAVA_PREFS_SYSTEM_ROOT="-Djava.util.prefs.systemRoot=$CATALINA_HOME/content/thredds/javaUtilPrefs -Djava.util.prefs.userRoot=$CATALINA_HOME/content/thredds/javaUtilPrefs"

JAVA_OPTS="$JAVA_OPTS $CONTENT_ROOT/ $JAVA_PREFS_SYSTEM_ROOT $NORMAL $MAX_PERM_GEN $HEAP_DUMP $HEADLESS"
export JAVA_OPTS
