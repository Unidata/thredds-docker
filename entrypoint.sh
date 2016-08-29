#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then
    chown -R tomcat:tomcat .
    sync
    exec gosu tomcat "$@"
fi

exec "$@"
