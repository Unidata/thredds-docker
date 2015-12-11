# THREDDS on Docker

A feature full Tomcat (SSL over APR, etc.) running [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/)

Available versions:

* `axiom/docker-thredds` (latest stable release)
* `axiom/docker-thredds:4.6` (currently `4.6.3`)
* `axiom/docker-thredds:5.0` (currently `5.0.0`)

#### tl;dr
```bash
$ docker run \
    -d \
    -p 80:8080 \
    -p 443:8443 \
    -v /path/to/your/ssl.crt:/opt/tomcat/conf/ssl.crt \
    -v /path/to/your/ssl.key:/opt/tomcat/conf/ssl.key \
    -v /path/to/your/tomcat-users.xml:/opt/tomcat/conf/tomcat-users.xml \
    -v /path/to/your/thredds/directory:/opt/tomcat/content/thredds \
    --name thredds \
    axiom/docker-thredds
```

## Configuration

### Ports

Tomcat runs with two ports open

* 8080 - HTTP
* 8443 - HTTPS

Map the ports to local ports to access outside of the Docker ecosystem:
```bash
$ docker run \
    -p 80:8080 \
    -p 443:8443 \
    ... \
    axiom/docker-thredds
```


### JVM

By default, the JVM is run with the following options:

* `-server` - server optimized jvm
* `-d64` - 64-bit jvm
* `-Xms4G` - reserve 4g of RAM
* `-Xmx4G` - use a max of 4g of RAM
* `-XX:MaxPermSize=256m` - increase perm size
* `-XX:+HeapDumpOnOutOfMemoryError` -  nice log dumps on out of memory errors
* `-Djava.awt.headless=true` - headless (no monitor)

A custom JVM options file may be used but must `export JAVA_OPTS` at the end
and include any already defined `JAVA_OPTS`, like so:

```bash
#!/bin/sh
NORMAL="-server -d64 -Xms16G -Xmx16G"  # More memory
MAX_PERM_GEN="-XX:MaxPermSize=128m"    # Less Perm
HEADLESS="-Djava.awt.headless=true"    # Still headless
JAVA_OPTS="$JAVA_OPTS $NORMAL $MAX_PERM_GEN $HEADLESS"
export JAVA_OPTS
```

Mount your own `javaopts.sh`:

```bash
$ docker run \
    -v /path/to/your/javaopts.sh:/opt/tomcat/bin/javaopts.sh \
    ... \
    axiom/docker-thredds
```


### THREDDS


Mount your own `content/thredds` directory:

```bash
$ docker run \
    -v /path/to/your/thredds/directory:/opt/tomcat/content/thredds \
    ... \
    axiom/docker-thredds
```

If you just want to change a few files, you can mount them individually. PLease
note that the **THREDDS cache is stored in the content directory**. If you choose
to mount individual files, you should also mount a cache directory.

```bash
$ docker run \
    -v /path/to/your/threddsConfig.xml:/opt/tomcat/content/thredds/threddsConfig.xml \
    -v /path/to/your/wmsConfig.xml:/opt/tomcat/content/thredds/wmsConfig.xml \
    -v /path/to/your/catalog.xml:/opt/tomcat/content/thredds/catalog.xml \
    -v /path/to/your/cache:/opt/tomcat/content/thredds/cache \
    ... \
    axiom/docker-thredds
```

* `threddsConfig.xml` - the THREDDS configuration file (comments are in-line in the file)
* `wmsConfig.xml` - the ncWMS configuration file
* `catalog.xml` - the root catalog THREDDS loads


### Tomcat Users

By default, Tomcat will start with two user accounts. The passwords are equal to the user name.

* `tdm` - used by the THREDDS Data Manager for connecting to THREDDS
* `admin` - can be used by everything else (has full privileges

```xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

  <role rolename="tdsConfig" description="can change THREDDS configuration files"/>
  <role rolename="tdsMonitor" description="can monitor log files with tdsMonitor program"/>
  <role rolename="tdsTrigger" description="can trigger feature collections, eg from tdm"/>
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>

  <user username="tdm"
        password="1a8755ca18bea68fa43e2fa2d5d89fde446d3151"
        roles="tdsTrigger"/>
  <user username="admin"
        password="d033e22ae348aeb5660fc2140aec35850c4da997"
        roles="tdsConfig,tdsMonitor,manager-gui,manager-script,manager-jmx,manager-status,admin-script,admin-gui"/>

</tomcat-users>
```

**You need to mount your own `tomcat-users.xml` file with different SHA1 digested passwords**.
If not, anyone who reads this document and knows your server address will have admin Tomcat privileges.

Mount your own `tomcat-users.xml`:

```bash
$ docker run \
    -v /path/to/your/tomcat-users.xml:/opt/tomcat/conf/tomcat-users.xml \
    ... \
    axiom/docker-thredds
```


### SSL

By default, Tomcat will start with a self-signed certificate valid for 3650 days.
This certificate **does not change on run**, so if you are serious about SSL, you
should mount your own private key and certificate files.

Mount your own `ssl.crt` and `ssl.key`:

```bash
$ docker run \
    -v /path/to/your/ssl.crt:/opt/tomcat/conf/ssl.crt \
    -v /path/to/your/ssl.key:/opt/tomcat/conf/ssl.key \
    ... \
    axiom/docker-thredds
```
