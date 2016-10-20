# THREDDS Docker

[![Travis Status](https://travis-ci.org/Unidata/thredds-docker.svg?branch=master)](https://travis-ci.org/Unidata/thredds-docker)

A containerized [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/) built on top a [security hardened Tomcat container maintained by Unidata](https://github.com/Unidata/tomcat-docker). This project was initially developed by [Axiom Data Science](http://www.axiomdatascience.com/) and now lives at Unidata.

## Versions

* `unidata/thredds-docker:4.6.6`
* `unidata/thredds-docker:5.0-SNAPSHOT`

## tl;dr

**Quickstart**

    docker run -d -p 80:8080 unidata/thredds-docker

## `docker-compose`

To run the THREDDS Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). `docker-compose` serves two purposes:

1. Reduce headaches involving unwieldy `docker` command lines where you are running `docker` with multiple volume mountings and port forwards. In situations like these, `docker` commands become difficult to issue and read. Instead, the lengthy `docker` command is captured in a `docker-compose.yml` that is easy to read, maintain, and can be committed to version control.
2. Coordinate the running of two or more containers to, for example, orchestrate the TDS and TDM. This can be useful for taking into account the same volume mountings, for example.

However, `docker-compose` use is not mandatory. For example, this container can be started with

    docker run -d -p 80:8080 unidata/thredds-docker

There is an example [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) in this repository.

## Production

### Configuration

First, define directory and file paths for log files, Tomcat, THREDDS, and data in [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) for the `thredds-production` image. Then:

### Memory

Tomcat web applications and the TDS can require large amounts of memory to run. This container is setup to run Tomcat with a [4 gigabyte memory allocation](files/javaopts.sh). When running this container, ensure your VM or hardware can accommodate this memory requirement.


### Running the TDS

Once you have completed your setup you can run the container with:

    docker-compose up -d thredds-production

The output of such command should be something like:

    Creating thredds

### Stopping the TDS

To stop this container:

    docker-compose stop thredds-production

### Delete TDS Container

To clean the slate and remove the container (not the image, the container):

    docker-compose rm -f thredds-production

## More on Configuration
### Tomcat

THREDDS container is based off of the [canonical Tomcat container (tomcat:jre8)](https://hub.docker.com/_/tomcat/) with [some additional security hardening measures](https://hub.docker.com/r/unidata/tomcat-docker/). Tomcat configurability can be done by mounting over the appropriate directories in `CATALINA_HOME` (`/usr/local/tomcat`).

### Java Configuration Options

The Java (`JAVA_OPTS`) are configured in `${CATALINA_HOME}/bin/javaopts.sh` (see [javaopts.sh](files/javaopts.sh))

This file can be mounted over with `docker-compose.yml` which can be useful if, for instance, you wish to change the maximum Java heap space available to the TDS or other JVM options.

### THREDDS

To mount your own `content/thredds` directory with `docker-compose.yml`:

```
  volumes:
    - /path/to/your/thredds/directory:/usr/local/tomcat/content/thredds
```

If you just want to change a few files, you can mount them individually. Please
note that the **THREDDS cache is stored in the content directory**. If you choose
to mount individual files, you should also mount a cache directory.

```
  volumes:
    - /path/to/your/tomcat/logs/:/usr/local/tomcat/logs/
    - /path/to/your/thredds/logs/:/usr/local/tomcat/content/thredds/logs/
    - /path/to/your/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml
    - /path/to/your/thredds/directory:/usr/local/tomcat/content/thredds
    - /path/to/your/data/directory1:/path/to/your/data/directory1 
    - /path/to/your/data/directory2:/path/to/your/data/directory2
```

* `threddsConfig.xml` - the THREDDS configuration file (comments are in-line in the file)
* `wmsConfig.xml` - the ncWMS configuration file
* `catalog.xml` - the root catalog THREDDS loads

### HTTP Over SSL

Please see Tomcat [parent container repository](https://github.com/Unidata/tomcat-docker#http-over-ssl) for HTTP over SSL instructions.

### Users

By default, Tomcat will start with [two user accounts](https://github.com/Unidata/thredds-docker/blob/master/files/tomcat-users.xml). The passwords are equal to the user name.

* `tdm` - used by the THREDDS Data Manager for connecting to THREDDS
* `admin` - can be used by everything else (has full privileges)

### Use Case

 Let's say you want to upgrade to the Docker THREDDS Container, and you already have a TDS configured with
 * Directory containing TDS configuration files (e.g. `threddsConfig.xml`, `wmsConfig.xml` and THREDDS catalog `.xml` files) in `/usr/local/tomcat/content/thredds`
 * Folders containing NetCDF and other data files read by the TDS in `/data1` and `/data2`
 * Tomcat users configured in `/usr/local/tomcat/conf/tomcat-users.xml`
 
Then you could issue this command to fire up the new Docker TDS container (remember to stop the old TDS first):

    docker-compose stop thredds-production
    docker-compose up -d thredds-production

## Check What is Running

### curl

At this point you should be able to do:

    curl localhost:80/thredds/catalog.html
    # or whatever port you mapped to outside the container in the docker-compose.yml

and get back a response that looks something like

    <!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'
            'http://www.w3.org/TR/html4/loose.dtd'>
    <html>
    <head>
    <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>TdsStaticCatalog http://localhost/thredds/catalog.html</title>
    <link rel='stylesheet' href='/thredds/tdsCat.css' type='text/css' >
    </head>
    ...
    </html>

### docker ps

If you encounter a problem there, you can also:

    docker ps

which should give you output that looks something like this:

    CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                                                 NAMES
    6c256c50a6cf        unidata/thredds-docker:latest   "/entrypoint.sh catal"   6 minutes ago       Up 6 minutes        0.0.0.0:8443->8443/tcp, 0.0.0.0:80->8080/tcp, 0.0.0.0:443->8443/tcp   threddsdocker_thredds-quickstart_1

to obtain the ID of the running TDS container. Now you can enter the container with:

    docker exec -it <ID> bash

Now use `curl` **inside** the container to verify the TDS is running:

    curl localhost:8080/thredds/catalog.html

you should get a response that looks something like:

    <!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'
            'http://www.w3.org/TR/html4/loose.dtd'>
    <html>
    <head>
    <meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>TdsStaticCatalog http://localhost/thredds/catalog.html</title>
    <link rel='stylesheet' href='/thredds/tdsCat.css' type='text/css' >
    </head>
    ...
    </html>

## Connecting to TDS with a Web Browser

At this point we are done setting up the TDS with docker. To navigate to this instance of TDS from the web, you will have to ensure your docker host (e.g., a cloud VM at Amazon or Microsoft Azure) allows Internet traffic through port 80 at whatever IP or domain name your docker host is located.

## TDM

The THREDDS Data Manager or TDM is an application that works in conjunction with the TDS. It creates indexes for GRIB data in a background process, and notifies the TDS via port `8443` when data have been updated or changed. See [here](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) to learn more about the TDM. 

### Versions

* `unidata/thredds-docker:tdm-4.6`
* `unidata/thredds-docker:tdm-5.0-SNAPSHOT`

* `unidata/thredds-docker:tdm-5.0-SNAPSHOT`

### Configuration

The TDM will notify the TDS of data changes via an HTTPS port `8443` triggering mechanism. It is important the TDM password (`TDM_PW` environment variable) defined in the [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) file corresponds to the SHA **digested** password in the [tomcat-users.xml](https://github.com/Unidata/thredds-docker/blob/master/files/tomcat-users.xml) file. [See the parent container](https://hub.docker.com/r/unidata/tomcat-docker/) for how to create a SHA digested password. Also, because this mechanism works via port `8443`, you will have to get your HTTPS certificates in place. Again [see the parent container](https://hub.docker.com/r/unidata/tomcat-docker/) on how to install certificates, self-signed or otherwise.

Not having the Tomcat `tdm` user password and digested password in sync can be a big source of frustration. One way to diagnose this problem is to look at the TDM logs and `grep` for `trigger`. You will find something like:

```sh
fc.NAM-CONUS_80km.log:2016-11-02T16:09:54.305 +0000 WARN  - FAIL send trigger to http://unicloud.westus.cloudapp.azure.com/thredds/admin/collection/trigger?trigger=never&collection=NAM-CONUS_80km status = 401
```

Enter the trigger URL in your browser:

```sh
http://unicloud.westus.cloudapp.azure.com/thredds/admin/collection/trigger?trigger=never&collection=NAM-CONUS_80km
```

At this point the browser will prompt you for a `tdm` login and password you defined in the `docker-compose.yml`. If the triggering mechanism is successful, you see a `TRIGGER SENT` message. Otherwise, make sure your HTTPS certificate is present, and ensure the `tdm` password in the `docker-compose.yml`, and digested password in the `tomcat-users.xml` are in sync.

### Running the TDM

    docker-compose up -d tdm

### Capturing TDM Log Files Outside the Container

Until `5.0`, the TDM lacks configurability with respect to the location of log files and the TDM simply logs locally to where the TDM is invoked. In the meantime, to capture TDM log files outside the container, do the usual volume mounting outside the container:

    /path/to/your/tdm/logs:/usr/local/tomcat/content/tdm/

*and* put the `tdm.jar` and `tdm.sh` run script in `/path/to/your/tdm/logs`.

For example, you can get the `tdm.jar`:

    curl -SL  https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/4.6.6/tdmFat-4.6.6.jar -o tdm.jar

The `tdm.sh` script can be found within this repository. Make sure the `tdm.sh` script is executable by the container.
