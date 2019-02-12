# THREDDS Docker

[![Travis Status](https://travis-ci.org/Unidata/thredds-docker.svg?branch=master)](https://travis-ci.org/Unidata/thredds-docker)

A containerized [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/) built on top a [security hardened Tomcat container maintained by Unidata](https://github.com/Unidata/tomcat-docker). This project was initially developed by [Axiom Data Science](http://www.axiomdatascience.com/) and now lives at Unidata.

**TDM Update**: If you are looking for the TDM Docker container, it has [moved into its own repository](https://github.com/Unidata/tdm-docker).

## Versions

* `unidata/thredds-docker:latest`
* `unidata/thredds-docker:4.6.13`
* `unidata/thredds-docker:4.6.12`
* `unidata/thredds-docker:4.6.11`
* `unidata/thredds-docker:4.6.10`
* `unidata/thredds-docker:4.6.8`
* `unidata/thredds-docker:4.6.6`
* `unidata/thredds-docker:5.0-SNAPSHOT`
* `unidata/thredds-docker:5.0-beta5`


## tl;dr

**Quickstart**

    docker run -d -p 80:8080 unidata/thredds-docker


## `docker-machine`

One way to run Docker containers is with [docker-machine](https://docs.docker.com/machine/overview/). This is a common scenario if you are running Docker on your local OS X or Windows development system. You can use `docker-machine` to run the `thredds-docker` container. You will need to allocate at least 4GBs of RAM to the VM that will run this container. For example, here we are creating a VirtualBox Docker machine instance with 6GBs of RAM:

```
$ docker-machine create --virtualbox-memory "6144" thredds
Running pre-create checks...
Creating machine...
...
...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env thredds
```

At this point, you can issue the following command to connect to your new `thredds` Docker client.

```
$ eval $(docker-machine env thredds)
```

In the next section, we use `docker-compose` to start the `thredds-docker` container.

Note that if you are running the TDS with `docker-machine`, you will have to find the local IP address of that TDS with `docker-machine ip thredds` which may return something like `192.168.99.100`. So connecting to that TDS will entail navigating to `http://192.168.99.100/thredds/catalog.html` in your browser.

## `docker-compose`

To run the THREDDS Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). `docker-compose` serves two purposes:

1. Reduce headaches involving unwieldy `docker` command lines where you are running `docker` with multiple volume mountings and port forwards. In situations like these, `docker` commands become difficult to issue and read. Instead, the lengthy `docker` command is captured in a `docker-compose.yml` that is easy to read, maintain, and can be committed to version control.
2. Coordinate the running of two or more containers to, for example, orchestrate the TDS and TDM. This can be useful for taking into account the same volume mountings, for example.

However, `docker-compose` use is not mandatory. For example, this container can be started with

    docker run -d -p 80:8080 unidata/thredds-docker

There is an example [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) in this repository.

### Configuring `docker-compose` With Environment Variables

This project contains a `docker-compose` [environment file](https://docs.docker.com/compose/compose-file/#envfile) named `compose.env`. This file contains default values for `docker-compose` to launch the TDS and [TDM](#tdm). You can configure these parameters:

    | Parameter                   | Environment Variable  | Default Value                |
    |-----------------------------+-----------------------+------------------------------|
    | TDS Content Root            | TDS_CONTENT_ROOT_PATH | /usr/local/tomcat/content    |
    | TDS JVM Max Heap Size (xmx) | THREDDS_XMX_SIZE      | 4G                           |
    | TDS JVM Min Heap Size (xms) | THREDDS_XMS_SIZE      | 4G                           |
    | TDM Password                | TDM_PW                | CHANGEME!                    |
    | TDS HOST                    | TDS_HOST              | http://thredds.yourhost.net/ |
    | TDM JVM Max Heap Size (xmx) | TDM_XMX_SIZE          | 6G                           |
    | TDM JVM Min Heap Size (xms) | TDM_XMS_SIZE          | 1G                           |

If you wish to update your configuration, you can either update the `compose.env` file or create your own environments file by copying `compose.env`. If using your own file, you can export the suffix of the file name into an environment variable named `THREDDS_COMPOSE_ENV_LOCAL`.

For example:

```shell
cp compose.env compose_local.env
export THREDDS_COMPOSE_ENV_LOCAL=_local
< edit compose_local.env >
docker-compose up thredds-production
```

## `docker-swarm`

Configuration information may be found in the [Docker Swarm readme](README_SWARM.md).

## Production

### Memory

Tomcat web applications and the TDS can require large amounts of memory to run. This container is setup to run Tomcat with a default [4 gigabyte memory allocation](files/javaopts.sh). When running this container, ensure your VM or hardware can accommodate this memory requirement.

### Configuration

Define directory and file paths for log files, Tomcat, THREDDS, and data in [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) for the `thredds-production` image.


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

The Java (`JAVA_OPTS`) are configured in `${CATALINA_HOME}/bin/javaopts.sh` (see [javaopts.sh](files/javaopts.sh)). See the `docker-compose` section above for configuring some of the environment variables of this file.


### Configurable Tomcat UID and GID

[See parent container](https://github.com/Unidata/tomcat-docker#configurable-tomcat-uid-and-gid).

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

### Remote Management

[TDS Remote Management](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/RemoteManagement.html#RemoteDebugging) is enabled for the `admin` user by default, and can be accessed via `http(s)://<your server>/thredds/admin/debug`.

### ncSOS

To enable to ncSOS

```xml
  <NCSOS>
    <allow>false</allow>
  </NCSOS>
```

to `true` in `threddsConfig.xml`.

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

The [THREDDS Data Manager](http://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) or TDM is an application that works in close conjunction with the TDS and is referenced in the [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) in this repository. The TDM Docker container [is now its own repository ](https://github.com/Unidata/tdm-docker) where you can find instructions on how to run it.

## Citation

In order to cite this project, please simply make use of the Unidata THREDDS Data Server DOI: doi:10.5065/D6N014KG https://doi.org/10.5065/D6N014KG

## Support

If you have a question or would like support for this THREDDS Docker container, consider [submitting a GitHub issue](https://github.com/Unidata/thredds-docker/issues). Alternatively, you may wish to start a discussion on the THREDDS Community mailing list: <thredds@unidata.ucar.edu>.

For general TDS questions, please see the [THREDDS support page](https://www.unidata.ucar.edu/software/thredds/current/tds/#help).
