#!/bin/sh

# Wait and listen for TDS to fire up
nc -z -w300 127.0.0.1 8080
for i in {1..5}; do curl -o /dev/null http://127.0.0.1:8080/thredds/catalog.html && break || \
	(echo sleeping 15... && sleep 15); done

# The following curl and resulting grep works for TDS v5 and v4
curl --no-progress-meter \
-o ./.github/testScripts/actual.html http://127.0.0.1:8080/thredds/catalog/catalog.html && \
echo toplevel catalog.html OK && \
grep 'THREDDS' ./.github/testScripts/actual.html && \
echo toplevel catalog.html string content OK
