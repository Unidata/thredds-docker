#/bin/bash

java -d64 -Xmx6g -DbbTdm=1 -Dtds.content.root.path=/opt/tomcat/content \
     -jar tdm-$TDM_VERSION.jar -nthreads 1 -cred tdm:$TDM_PW -tds $TDS_HOST
