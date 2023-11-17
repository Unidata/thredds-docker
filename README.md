- [Unidata THREDDS Docker](#h-D1C45A11)
  - [Introduction](#h-F96AB5F8)
    - [Quickstart](#h-C733CD96)
  - [Versions](#h-AF015058)
  - [Prerequisites](#h-1EB18866)
  - [Installation](#h-A767C942)
  - [Usage](#h-58EC333B)
    - [Memory](#h-069B9D1E)
    - [Docker compose](#h-1C0CB7E8)
      - [Running the TDS](#h-E18F7CAE)
      - [Stopping the TDS](#h-82936877)
      - [Delete TDS Container](#h-63682079)
    - [Upgrading](#h-73D8E285)
    - [Check What is Running](#h-E74AFAFF)
      - [curl](#h-B9BDE649)
      - [docker ps](#h-F9E31E12)
  - [Configuration](#h-817EB413)
    - [Docker compose](#h-F95DCC06)
      - [Basic](#h-0351DF56)
      - [Environment Variables](#h-D856FFF9)
    - [Tomcat](#h-A82C8590)
    - [Java Configuration Options](#h-609AFE2D)
    - [Configurable Tomcat UID and GID](#h-350BEF91)
    - [THREDDS](#h-D046D64C)
    - [HTTP Over SSL](#h-5A4BABB7)
    - [Users](#h-E20C4A41)
    - [Remote Management](#h-0E28D2EE)
    - [ncSOS](#h-F2383FF5)
  - [TDM](#h-A8309C14)
  - [netCDF](#h-90623D0B)
  - [Maintainers](#h-1559ED59)
  - [Citation](#h-0BAA13E6)
  - [Support](#h-7D1176D3)



<a id="h-D1C45A11"></a>

# Unidata THREDDS Docker

Dockerized [THREDDS](https://www.unidata.ucar.edu/software/tds/).


<a id="h-F96AB5F8"></a>

## Introduction

This repository contains files necessary to build and run a THREDDS Docker container. The Unidata THREDDS Docker images associated with this repository are [available on DockerHub](https://hub.docker.com/r/unidata/thredds-docker/).


<a id="h-C733CD96"></a>

### Quickstart

```sh
docker run -d -p 80:8080 unidata/thredds-docker:<version>
```


<a id="h-AF015058"></a>

## Versions

See tags listed [on dockerhub](https://hub.docker.com/r/unidata/thredds-docker/tags). Our security protocols have become stricter, and older images must be removed due to potential links with high profile CVEs. We strive to maintain the security of this project's DockerHub images by updating them with the latest upstream improvements. If you have any concerns in this area, please email us at [security@unidata.ucar.edu](mailto:security@unidata.ucar.edu) to bring them to our attention.


<a id="h-1EB18866"></a>

## Prerequisites

Before you begin using this Docker container project, make sure your system has Docker installed. Docker Compose is optional but recommended.


<a id="h-A767C942"></a>

## Installation

You can either pull the image from DockerHub with:

```sh
docker pull unidata/thredds-docker:<version>
```

Or you can build it yourself with:

1.  ****Clone the repository****: `git clone https://github.com/Unidata/thredds-docker.git`
2.  ****Navigate to the project directory****: `cd thredds-docker`
3.  ****Build the Docker image****: `docker build -t thredds-docker:<version> .`


<a id="h-58EC333B"></a>

## Usage


<a id="h-069B9D1E"></a>

### Memory

Tomcat web applications and the TDS can require large amounts of memory to run. This container is setup to run Tomcat with a default [4 gigabyte memory allocation](files/javaopts.sh). When running this container, ensure your VM or hardware can accommodate this memory requirement.


<a id="h-1C0CB7E8"></a>

### Docker compose

To run the THREDDS Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). `docker-compose` serves two purposes:

1.  Reduce headaches involving unwieldy `docker` command lines where you are running `docker` with multiple volume mounts and port forwards. In situations like these, `docker` commands become difficult to issue and read. Instead, the lengthy `docker` command is captured in a `docker-compose.yml` that is easy to read, maintain, and can be committed to version control.

2.  Coordinate the running of two or more containers to, for example, orchestrate the TDS and TDM. This can be useful for taking into account the same volume mountings, for example.

However, `docker-compose` use is not mandatory. There is an example [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) in this repository.


<a id="h-E18F7CAE"></a>

#### Running the TDS

Once you have completed your setup you can run the container with:

```sh
docker-compose up -d thredds-production
```

The output of such command should be something like:

```
Creating thredds
```


<a id="h-82936877"></a>

#### Stopping the TDS

To stop this container:

```sh
docker-compose stop thredds-production
```


<a id="h-63682079"></a>

#### Delete TDS Container

To clean the slate and remove the container (not the image, the container):

```sh
docker-compose rm -f thredds-production
```


<a id="h-73D8E285"></a>

### Upgrading

Upgrading to a newer version of the container is easy. Simply stop the container via `docker` or `docker-compose`, followed by

```sh
docker pull unidata/thredds-docker:<version>
```

and restart the container. Refer to the new version from the command line or in the `docker-compose.yml`.


<a id="h-E74AFAFF"></a>

### Check What is Running


<a id="h-B9BDE649"></a>

#### curl

At this point you should be able to do:

```sh
curl localhost:80/thredds/catalog/catalog.html
# or whatever port you mapped to outside the container in the docker-compose.yml
```

and get back a response that looks something like

```
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>TDS Catalog</title>
  <!-- Common metadata and styles. -->
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <!-- if webcrawler finds this page (say, from sitemap.xml), tell it to not follow the links -->
  <meta name="robots" content="nofollow" />

  <link rel="stylesheet" href="/thredds/tds.css" type="text/css"><link rel="stylesheet" href="/thredds/tds.css" type="text/css"><link rel="stylesheet" href="/thredds/tdsCat.css" type="text/css">

  <script type="text/javascript">
  document.getElementById("header-buffer").style.height = document.getElementById("header").clientHeight + "px";
  document.getElementById("footer-buffer").style.height = document.getElementById("footer").clientHeight + "px";
</script>
</head>
...
</html>
```


<a id="h-F9E31E12"></a>

#### docker ps

If you encounter a problem there, you can also:

```sh
docker ps
```

which should give you output that looks something like this:

```
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                                                 NAMES
6c256c50a6cf        unidata/thredds-docker:<version>  "/entrypoint.sh catal"   6 minutes ago       Up 6 minutes        0.0.0.0:8443->8443/tcp, 0.0.0.0:80->8080/tcp, 0.0.0.0:443->8443/tcp   threddsdocker_thredds-quickstart_1
```

to obtain the ID of the running TDS container. You can enter the container with:

```sh
docker exec -it <ID> bash
```

Use `curl` **inside** the container to verify the TDS is running:

```sh
curl localhost:8080/thredds/catalog/catalog.html
```

you should get a response that looks something like:

```
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>TDS Catalog</title>
  <!-- Common metadata and styles. -->
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <!-- if webcrawler finds this page (say, from sitemap.xml), tell it to not follow the links -->
  <meta name="robots" content="nofollow" />

  <link rel="stylesheet" href="/thredds/tds.css" type="text/css"><link rel="stylesheet" href="/thredds/tds.css" type="text/css"><link rel="stylesheet" href="/thredds/tdsCat.css" type="text/css">

  <script type="text/javascript">
  document.getElementById("header-buffer").style.height = document.getElementById("header").clientHeight + "px";
  document.getElementById("footer-buffer").style.height = document.getElementById("footer").clientHeight + "px";
</script>
</head>
...
</html>
```


<a id="h-817EB413"></a>

## Configuration


<a id="h-F95DCC06"></a>

### Docker compose


<a id="h-0351DF56"></a>

#### Basic

Define directory and file paths for log files, Tomcat, THREDDS, and data in [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) for the `thredds-production` image.


<a id="h-D856FFF9"></a>

#### Environment Variables

This project contains a `docker-compose` [environment file](https://docs.docker.com/compose/compose-file/#envfile) named `compose.env`. This file contains default values for `docker-compose` to launch the TDS and [TDM](#h-A8309C14). You can configure these parameters:

```
| Parameter                   | Environment Variable  | Default Value                |
|-----------------------------+-----------------------+------------------------------|
| TDS Content Root            | TDS_CONTENT_ROOT_PATH | /usr/local/tomcat/content    |
| TDS JVM Max Heap Size (xmx) | THREDDS_XMX_SIZE      | 4G                           |
| TDS JVM Min Heap Size (xms) | THREDDS_XMS_SIZE      | 4G                           |
| TDM Password                | TDM_PW                | CHANGEME!                    |
| TDS HOST                    | TDS_HOST              | http://thredds.yourhost.net/ |
| TDM JVM Max Heap Size (xmx) | TDM_XMX_SIZE          | 6G                           |
| TDM JVM Min Heap Size (xms) | TDM_XMS_SIZE          | 1G                           |
| Tomcat User ID              | TOMCAT_USER_ID        | 1000                         |
| Tomcat Group ID             | TOMCAT_GROUP_ID       | 1000                         |
```

If you wish to update your configuration, you can either update the `compose.env` file or create your own environments file by copying `compose.env`. If using your own file, you can export the suffix of the file name into an environment variable named `THREDDS_COMPOSE_ENV_LOCAL`. Also see the `env_file` key in [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml).

For example:

```sh
cp compose.env compose_local.env
export THREDDS_COMPOSE_ENV_LOCAL=_local
< edit compose_local.env >
docker-compose up thredds-production
```


<a id="h-A82C8590"></a>

### Tomcat

THREDDS container is based off of the [canonical Tomcat container](https://hub.docker.com/_/tomcat/) with [some additional security hardening measures](https://hub.docker.com/r/unidata/tomcat-docker/). Tomcat configuration can be done by mounting over the appropriate directories in `CATALINA_HOME` (`/usr/local/tomcat`).


<a id="h-609AFE2D"></a>

### Java Configuration Options

The Java configuration options (`JAVA_OPTS`) are configured in `${CATALINA_HOME}/bin/javaopts.sh` (see [javaopts.sh](files/javaopts.sh)) inside the container. Note this file is copied inside the container during the Docker build. See the `docker-compose` section above for configuring some of the environment variables of this file.


<a id="h-350BEF91"></a>

### Configurable Tomcat UID and GID

[See parent container](https://github.com/Unidata/tomcat-docker#configurable-tomcat-uid-and-gid).


<a id="h-D046D64C"></a>

### THREDDS

To mount your own `content/thredds` directory with `docker-compose.yml`:

```yaml
volumes:
  - /path/to/your/thredds/directory:/usr/local/tomcat/content/thredds
```

If you just want to change a few files, you can mount them individually. Please note that the **THREDDS cache is stored in the content directory**. If you choose to mount individual files, you should also mount a cache directory.

```yaml
volumes:
  - /path/to/your/tomcat/logs/:/usr/local/tomcat/logs/
  - /path/to/your/thredds/logs/:/usr/local/tomcat/content/thredds/logs/
  - /path/to/your/tomcat-users.xml:/usr/local/tomcat/conf/tomcat-users.xml
  - /path/to/your/thredds/directory:/usr/local/tomcat/content/thredds
  - /path/to/your/data/directory1:/path/to/your/data/directory1
  - /path/to/your/data/directory2:/path/to/your/data/directory2
  - /path/to/your/server.xml:/usr/local/tomcat/conf/server.xml
  - /path/to/your/web.xml:/usr/local/tomcat/conf/web.xml
  - /path/to/your/keystore.jks:/usr/local/tomcat/conf/keystore.jks
```


<a id="h-5A4BABB7"></a>

### HTTP Over SSL

Please see Tomcat [parent container repository](https://github.com/Unidata/tomcat-docker#http-over-ssl) for HTTP over SSL instructions.


<a id="h-E20C4A41"></a>

### Users

By default, Tomcat will start with [two user accounts](https://github.com/Unidata/thredds-docker/blob/master/files/tomcat-users.xml).

-   `tdm` - used by the THREDDS Data Manager for connecting to THREDDS
-   `admin` - can be used by everything else (has full privileges)

See the [parent Tomcat container](https://github.com/Unidata/tomcat-docker#digested-passwords) for information about creating passwords for these users.


<a id="h-0E28D2EE"></a>

### Remote Management

[TDS Remote Management](https://docs.unidata.ucar.edu/tds/current/userguide/remote_management_ref.html#tds-remote-debugging) is enabled for the `admin` user by default, and can be accessed via `http(s)://<your server>/thredds/admin/debug`.


<a id="h-F2383FF5"></a>

### ncSOS

To enable to ncSOS, change

```xml
<NCSOS>
  <allow>false</allow>
</NCSOS>
```

to `true` in `threddsConfig.xml`.


<a id="h-A8309C14"></a>

## TDM

The [THREDDS Data Manager](https://docs.unidata.ucar.edu/tds/5.4/userguide/tdm_ref.html) (TDM) creates indexes for GRIB featureCollections, in a process separate from the TDS. It is a specialized utility typically employed in scenarios where the TDS is serving real-time data from the Unidata IDD (e.g., GFS Quarter Degree Analysis) and is referenced in the [docker-compose.yml](docker-compose.yml) in this repository. In most scenarios, you can comment out the TDM section. The TDM Docker container [is in its own repository](https://github.com/Unidata/tdm-docker) where you can find instructions on how to run it.


<a id="h-90623D0B"></a>

## netCDF

This Docker project includes the installation of the netCDF-c project to allow for the downloading of netCDF files using the [NetCDF Subset Service](https://docs.unidata.ucar.edu/tds/current/userguide/netcdf_subset_service_ref.html).


<a id="h-1559ED59"></a>

## Maintainers

What to do when a version of the THREDDS data server is released?

-   Update the `Dockerfile` with the `war` file corresponding to the new version of the TDS. E.g.,

```shell
ENV THREDDS_WAR_URL https://downloads.unidata.ucar.edu/tds/5.4/thredds-5.4.war
```

-   Check with the netCDF group if versions of HDF5, zlib, and netCDF referenced in the `Dockerfile` need to be updated.
-   Update TDS versions in `docker-compose.yml` and `docker-compose-swarm.yml`.
-   Update the `CHANGELOG.md` documenting updates to this project (not the TDS) since the last release.
-   Create a new git branch corresponding to this version of the TDS (e.g., `5.4`).
-   Push the new branch out to the `Unidata/thredds-docker` GitHub repository. This branch will remain frozen in time going forward. Any subsequent updates to this project should happen on the the `latest` branch. The only exception to this convention is if there is a critical (e.g., security related) update that needs to be applied to the `Dockerfile` and associated files and eventually to the image (see below)
-   Build a docker image corresponding to the new version of the TDS (e.g., on the Docker build machine on Jetstream). E.g., `docker build -t unidata/thredds-docker:5.4`.
-   Test to ensure the image works.
-   Push it out DockerHub e.g., `docker push unidata/thredds-docker:5.4`.
-   Note that this image **does not** remain frozen in time for two reasons.
    1.  It can get rebuilt time and again as upstream image updates need to be incorporated into this THREDDS image. It may be confusing for a versioned image to evolve, but it is the convention in Dockerland.
    2.  It can get rebuilt in the rare case the Dockerfile or associated files are updated on the branch as mentioned earlier.


<a id="h-0BAA13E6"></a>

## Citation

In order to cite this project, please simply make use of the Unidata THREDDS Data Server DOI: https://doi.org/10.5065/D6N014KG <https://doi.org/10.5065/D6N014KG>


<a id="h-7D1176D3"></a>

## Support

If you have a question or would like support for this THREDDS Docker container, consider [submitting a GitHub issue](https://github.com/Unidata/thredds-docker/issues). Alternatively, you may wish to start a discussion on the THREDDS Community mailing list: [thredds@unidata.ucar.edu](mailto:thredds@unidata.ucar.edu).

For general TDS questions, please see the [THREDDS support page](https://www.unidata.ucar.edu/software/tds/#help).
