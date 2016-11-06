#!/bin/sh

curl -o ./.travis/actual.html http://127.0.0.1:8080/thredds/catalog.html && \
echo toplevel catalog.html OK && \
grep 'THREDDS Data Server' ./.travis/expected.html && \
echo toplevel catalog.html string content OK

