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
    -v /path/to/your/data/directory1:/path/to/your/data/directory1 \
    -v /path/to/your/data/directory2:/path/to/your/data/directory2 \
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
    -v /path/to/your/data/directory1:/path/to/your/data/directory1 \
    -v /path/to/your/data/directory2:/path/to/your/data/directory2 \
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

### Use Case

 Let's say you want to upgrade to the Docker THREDDS Container, and you already have a TDS configured with
 * Directory containing TDS configuration files (e.g. threddsConfig.xml, wmsConfig.xml and THREDDS catalog .xml files) in `/usr/local/tomcat/content/thredds`
 * Folders containing NetCDF and other data files read by the TDS in `/data1` and `/data2`
 * Tomcat users configured in `/usr/local/tomcat/conf/tomcat-users.xml`
 * SSL certificate at `/usr/local/tomcat/ssl.crt` and SSL key at `/usr/local/tomcat/ssl.key`
 * Running on ports 8090 and 8453 (ssl)
 
Then you could issue this command to fire up the new Docker TDS container (remember to stop the old TDS first):
```bash
$ docker run \
    -d \
    -p 8090:8080 \
    -p 8453:8443 \
    -v /usr/local/tomcat/ssl.crt:/opt/tomcat/conf/ssl.crt \
    -v /usr/local/tomcat/ssl.key:/opt/tomcat/conf/ssl.key \
    -v /usr/local/tomcat/conf/tomcat-users.xml:/opt/tomcat/conf/tomcat-users.xml \
    -v /usr/local/tomcat/content/thredds:/opt/tomcat/content/thredds \
    -v /data1:/data1 \
    -v /data2:/data2 \
    ... \
    axiom/docker-thredds
```

