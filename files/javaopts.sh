#!/bin/sh

NORMAL="-server -d64 -Xms4G -Xmx4G"
MAX_PERM_GEN="-XX:MaxPermSize=256m"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"

JAVA_OPTS="$JAVA_OPTS $NORMAL $MAX_PERM_GEN $HEAP_DUMP $HEADLESS"
export JAVA_OPTS
