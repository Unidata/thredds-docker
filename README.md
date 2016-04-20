# THREDDS on Docker

A feature full Tomcat (SSL over APR, etc.) running [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/)

Available versions:

* `axiom/docker-thredds` (currently `4.6.5`)
* `axiom/docker-thredds:4.6` (currently `4.6.5`)
* `axiom/docker-thredds:5.0` (currently `5.0.0`)

### tl;dr

**Quickstart**

```bash
$ docker run \
    -d \
    -p 80:8080 \
    -p 443:8443 \
    axiom/docker-thredds
```

**Production**


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

### Tomcat

See [these instructions](https://github.com/axiom-data-science/docker-tomcat) for configuring Tomcat


### THREDDS


Mount your own `content/thredds` directory:

```bash
$ docker run \
    -v /path/to/your/thredds/directory:/opt/tomcat/content/thredds \
    ... \
    axiom/docker-thredds
```

If you just want to change a few files, you can mount them individually. Please
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


### Users

By default, Tomcat will start with [two user accounts](https://github.com/axiom-data-science/docker-thredds/blob/master/files/tomcat-users.xml). The passwords are equal to the user name.

* `tdm` - used by the THREDDS Data Manager for connecting to THREDDS
* `admin` - can be used by everything else (has full privileges)
