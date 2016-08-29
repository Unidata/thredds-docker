#!/bin/bash

java -jar -d64 -Xmx6g -DbbTdm=1 -Dtds.content.root.path=$HOME/content \
      $TDM_HOME/tdm-$TDM_VERSION.jar -nthreads 1 -cred \
      tdm:$TDM_PW -tds $TDS_HOST
