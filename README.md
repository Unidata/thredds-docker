# THREDDS on Docker

[![Travis Status](https://travis-ci.org/Unidata/thredds-docker.svg?branch=master)](https://travis-ci.org/Unidata/thredds-docker)

A containerized [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/) containing a full-featured Tomcat (SSL over APR, etc.). This project was initially developed by [Axiom Data Science](http://www.axiomdatascience.com/) and now lives at Unidata.

Available major versions:

* `unidata/tds` (currently `4.6.6`)
* `unidata/tds:latest` (currently `4.6.6`)
* `unidata/tds:4.6` (currently `4.6.6`)
* `unidata/tds:5.0` (currently `5.0.0`)

Specific releases:

* `unidata/tds:5.0.0`
* `unidata/tds:4.6.6`
* `unidata/tds:4.6.5`

## tl;dr

**Quickstart**

```bash
$ docker-compose up -d thredds-quickstart
```
## Building the THREDDS Container

To build the THREDDS Docker container:

    docker build -t unidata/tds:<version> .

It is best to be on a fast network when building containers as there can be many intermediate layers to download.

## `docker-compose`

To run the THREDDS Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/).


**Production**

First, define directory and file paths for SSL, Tomcat, THREDDS, and data in [docker-compose.yml](docker-compose.yml) for the `thredds-production` image. Then:

```bash
$ docker-compose up -d thredds-production
```

## Configuration

### Tomcat

See [these instructions](https://github.com/axiom-data-science/docker-tomcat) for configuring Tomcat


### THREDDS


To mount your own `content/thredds` directory with `docker-compose.yml`:

```
  volumes:
    /path/to/your/thredds/directory:/opt/tomcat/content/thredds
```

If you just want to change a few files, you can mount them individually. Please
note that the **THREDDS cache is stored in the content directory**. If you choose
to mount individual files, you should also mount a cache directory.

```
  volumes:
    /path/to/your/ssl.crt:/opt/tomcat/conf/ssl.crt
    /path/to/your/ssl.key:/opt/tomcat/conf/ssl.key
    /path/to/your/tomcat-users.xml:/opt/tomcat/conf/tomcat-users.xml
    /path/to/your/thredds/directory:/opt/tomcat/content/thredds
    /path/to/your/data/directory1:/path/to/your/data/directory1 
    /path/to/your/data/directory2:/path/to/your/data/directory2
```

* `threddsConfig.xml` - the THREDDS configuration file (comments are in-line in the file)
* `wmsConfig.xml` - the ncWMS configuration file
* `catalog.xml` - the root catalog THREDDS loads


### Users

By default, Tomcat will start with [two user accounts](https://github.com/Unidata/thredds-docker/blob/master/files/tomcat-users.xml). The passwords are equal to the user name.

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
$ docker-compose stop thredds-production
$ docker-compose up -d thredds-production
```

## TDM

The TDM is an application that works in conjunction with the TDS. It creates indexes for GRIB data in a background process, and notifies the TDS via port 8443 when data have been updated or changed. See [here](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) to learn more about the TDM. 

When the TDM informs TDS concerning data changes, it will communicate via the `tdm` tomcat user. Edit the `docker-compose.yml` file and change the `TDM_PW` to [TDM password](https://github.com/axiom-data-science/docker-tomcat#users). Also ensure `TDS_HOST` is pointing to the correct THREDDS host.

Available versions:

* `unidata/tdm` (currently `4.6`)
* `unidata/tdm:latest` (currently `4.6`)
* `unidata/tdm:4.6`

```bash
$ docker-compose up -d tdm
```

### Building the TDM Container

To build the TDM Docker container:

    docker build -f Dockerfile.tdm -t unidata/tdm:<version> .
