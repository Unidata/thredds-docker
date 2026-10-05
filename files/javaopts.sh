#!/bin/sh

###
# Java options
###
# Ensure CATALINA_BASE is set
export CATALINA_BASE="$CATALINA_HOME"

# Ensure TDS_CONTENT_ROOT_PATH is defined
if [ -z "$TDS_CONTENT_ROOT_PATH" ]; then
  echo "Error: TDS_CONTENT_ROOT_PATH is not set. The server will not start."
  exit 1
fi

# OpenJDK requires the configured system preferences directory to exist.
# Create it at runtime so this also works when the content tree is bind-mounted.
JAVA_PREFS_ROOT="${TDS_CONTENT_ROOT_PATH}/thredds/javaUtilPrefs"
if ! mkdir -p "${JAVA_PREFS_ROOT}/.systemPrefs"; then
  echo "Error: Could not create Java system preferences directory at ${JAVA_PREFS_ROOT}/.systemPrefs."
  exit 1
fi

# do not put -d64 and -server options here. They are no longer needed.
NORMAL="-Xms${THREDDS_XMS_SIZE} -Xmx${THREDDS_XMX_SIZE}"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"
CONTENT_ROOT="-Dtds.content.root.path=${TDS_CONTENT_ROOT_PATH}"
JAVA_PREFS_SYSTEM_ROOT="-Djava.util.prefs.systemRoot=${JAVA_PREFS_ROOT} -Djava.util.prefs.userRoot=${JAVA_PREFS_ROOT}"
JNA_DIR="-Djna.tmpdir=/tmp/"

# Propagate optional AWS_REGION environment variable to Java system property
[ -z "${AWS_REGION}" ] && AWS_REGION_PROP="" || AWS_REGION_PROP="-Daws.region=${AWS_REGION}"

CHRONICLE_CACHE="--add-exports java.base/jdk.internal.ref=ALL-UNNAMED --add-exports java.base/sun.nio.ch=ALL-UNNAMED --add-exports jdk.unsupported/sun.misc=ALL-UNNAMED --add-exports jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --add-opens jdk.compiler/com.sun.tools.javac=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED"

JAVA_OPTS="$JAVA_OPTS $CONTENT_ROOT $JAVA_PREFS_SYSTEM_ROOT $NORMAL $HEAP_DUMP $HEADLESS $JNA_DIR $CHRONICLE_CACHE $AWS_REGION_PROP"
export JAVA_OPTS
