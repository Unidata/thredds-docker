- [THREDDS Docker](#h92CD77E8)
  - [Versions](#h8766A6B1)
  - [Quickstart](#h887A6923)
  - [`docker-compose`](#h5ECB1ADD)
    - [Configuring `docker-compose` With Environment Variables](#h57D41CDA)
  - [`docker-swarm`](#hCF2A92DF)
  - [Production](#h961818A2)
    - [Memory](#h2EE86560)
    - [Configuration](#h00614C28)
    - [Running the TDS](#h9E9FAD1E)
    - [Stopping the TDS](#h90131459)
    - [Delete TDS Container](#hA16AECDD)
  - [More on Configuration](#h61DD5309)
    - [Tomcat](#hA4455141)
    - [Java Configuration Options](#h88D23DC0)
    - [Configurable Tomcat UID and GID](#hDC6A774F)
    - [THREDDS](#hCDB6BE94)
    - [HTTP Over SSL](#h2BBFF30F)
    - [Users](#h20B33C74)
    - [Remote Management](#hE56DF4AE)
    - [ncSOS](#h859BE8DF)
  - [Upgrading](#h22FC6827)
  - [Check What is Running](#h72D06CCC)
    - [curl](#h92EFC0CB)
    - [docker ps](#hAC68440F)
  - [Connecting to TDS with a Web Browser](#hDF2E084D)
  - [TDM](#h46102A0D)
  - [Citation](#h760FDE8A)
  - [Support](#h5CC30EC0)



<a id="h92CD77E8"></a>

# THREDDS Docker

A containerized [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/) built on top a [security hardened Tomcat container maintained by Unidata](https://github.com/Unidata/tomcat-docker).


<a id="h8766A6B1"></a>

## Versions

-   `unidata/thredds-docker:latest`
-   `unidata/thredds-docker:5.3`
-   `unidata/thredds-docker:5.2`
-   `unidata/thredds-docker:5.1`
-   `unidata/thredds-docker:5.0`
-   `unidata/thredds-docker:4.6.17`
-   `unidata/thredds-docker:4.6.16.1`
-   `unidata/thredds-docker:4.6.15`
-   `unidata/thredds-docker:4.6.14`
-   `unidata/thredds-docker:4.6.13`
-   `unidata/thredds-docker:4.6.12`
-   `unidata/thredds-docker:4.6.11`
-   `unidata/thredds-docker:4.6.10`
-   `unidata/thredds-docker:4.6.8`
-   `unidata/thredds-docker:4.6.6`

<a id="h887A6923"></a>

## Quickstart

```sh
docker run -d -p 80:8080 unidata/thredds-docker
```


<a id="h5ECB1ADD"></a>

## `docker-compose`

To run the THREDDS Docker container, beyond a basic Docker setup, we recommend installing [docker-compose](https://docs.docker.com/compose/). `docker-compose` serves two purposes:

1.  Reduce headaches involving unwieldy `docker` command lines where you are running `docker` with multiple volume mountings and port forwards. In situations like these, `docker` commands become difficult to issue and read. Instead, the lengthy `docker` command is captured in a `docker-compose.yml` that is easy to read, maintain, and can be committed to version control.

2.  Coordinate the running of two or more containers to, for example, orchestrate the TDS and TDM. This can be useful for taking into account the same volume mountings, for example.

However, `docker-compose` use is not mandatory. For example, this container can be started with

```sh
docker run -d -p 80:8080 unidata/thredds-docker
```

There is an example [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) in this repository.


<a id="h57D41CDA"></a>

### Configuring `docker-compose` With Environment Variables

This project contains a `docker-compose` [environment file](https://docs.docker.com/compose/compose-file/#envfile) named `compose.env`. This file contains default values for `docker-compose` to launch the TDS and [TDM](#h46102A0D). You can configure these parameters:

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

```sh
cp compose.env compose_local.env
export THREDDS_COMPOSE_ENV_LOCAL=_local
< edit compose_local.env >
docker-compose up thredds-production
```


<a id="hCF2A92DF"></a>

## `docker-swarm`

Configuration information may be found in the [Docker Swarm readme](README_SWARM.md).


<a id="h961818A2"></a>

## Production


<a id="h2EE86560"></a>

### Memory

Tomcat web applications and the TDS can require large amounts of memory to run. This container is setup to run Tomcat with a default [4 gigabyte memory allocation](files/javaopts.sh). When running this container, ensure your VM or hardware can accommodate this memory requirement.


<a id="h00614C28"></a>

### Configuration

Define directory and file paths for log files, Tomcat, THREDDS, and data in [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) for the `thredds-production` image.


<a id="h9E9FAD1E"></a>

### Running the TDS

Once you have completed your setup you can run the container with:

```sh
docker-compose up -d thredds-production
```

The output of such command should be something like:

    Creating thredds


<a id="h90131459"></a>

### Stopping the TDS

To stop this container:

```sh
docker-compose stop thredds-production
```


<a id="hA16AECDD"></a>

### Delete TDS Container

To clean the slate and remove the container (not the image, the container):

```sh
docker-compose rm -f thredds-production
```


<a id="h61DD5309"></a>

## More on Configuration


<a id="hA4455141"></a>

### Tomcat

THREDDS container is based off of the [canonical Tomcat container (tomcat:jre8)](https://hub.docker.com/_/tomcat/) with [some additional security hardening measures](https://hub.docker.com/r/unidata/tomcat-docker/). Tomcat configuration can be done by mounting over the appropriate directories in `CATALINA_HOME` (`/usr/local/tomcat`).


<a id="h88D23DC0"></a>

### Java Configuration Options

The Java (`JAVA_OPTS`) are configured in `${CATALINA_HOME}/bin/javaopts.sh` (see [javaopts.sh](files/javaopts.sh)) inside the container. See the `docker-compose` section above for configuring some of the environment variables of this file.


<a id="hDC6A774F"></a>

### Configurable Tomcat UID and GID

[See parent container](https://github.com/Unidata/tomcat-docker#configurable-tomcat-uid-and-gid).


<a id="hCDB6BE94"></a>

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
```

-   `threddsConfig.xml` - the THREDDS configuration file (comments are in-line in the file)
-   `wmsConfig.xml` - the ncWMS configuration file
-   `catalog.xml` - the root catalog THREDDS loads


<a id="h2BBFF30F"></a>

### HTTP Over SSL

Please see Tomcat [parent container repository](https://github.com/Unidata/tomcat-docker#http-over-ssl) for HTTP over SSL instructions.


<a id="h20B33C74"></a>

### Users

By default, Tomcat will start with [two user accounts](https://github.com/Unidata/thredds-docker/blob/master/files/tomcat-users.xml).

-   `tdm` - used by the THREDDS Data Manager for connecting to THREDDS
-   `admin` - can be used by everything else (has full privileges)

See the [parent Tomcat container](https://github.com/Unidata/tomcat-docker#digested-passwords) for information about creating passwords for these users.


<a id="hE56DF4AE"></a>

### Remote Management

[TDS Remote Management](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/RemoteManagement.html#RemoteDebugging) is enabled for the `admin` user by default, and can be accessed via `http(s)://<your server>/thredds/admin/debug`.


<a id="h859BE8DF"></a>

### ncSOS

To enable to ncSOS, change

```xml
<NCSOS>
  <allow>false</allow>
</NCSOS>
```

to `true` in `threddsConfig.xml`.


<a id="h22FC6827"></a>

## Upgrading

Upgrading to a newer version of the container is easy. Simply stop the container via `docker` or `docker-compose`, followed by

```sh
docker pull unidata/thredds-docker:<version>
```

and restart the container.


<a id="h72D06CCC"></a>

## Check What is Running


<a id="h92EFC0CB"></a>

### curl

At this point you should be able to do:

```sh
curl localhost:80/thredds/catalog.html
# or whatever port you mapped to outside the container in the docker-compose.yml
```

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


<a id="hAC68440F"></a>

### docker ps

If you encounter a problem there, you can also:

```sh
docker ps
```

which should give you output that looks something like this:

    CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                                                                 NAMES
    6c256c50a6cf        unidata/thredds-docker:latest   "/entrypoint.sh catal"   6 minutes ago       Up 6 minutes        0.0.0.0:8443->8443/tcp, 0.0.0.0:80->8080/tcp, 0.0.0.0:443->8443/tcp   threddsdocker_thredds-quickstart_1

to obtain the ID of the running TDS container. Now you can enter the container with:

```sh
docker exec -it <ID> bash
```

Now use `curl` **inside** the container to verify the TDS is running:

```sh
curl localhost:8080/thredds/catalog.html
```

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


<a id="hDF2E084D"></a>

## Connecting to TDS with a Web Browser

At this point, we are done setting up the TDS with docker. To navigate to this instance of the TDS from the web, you will have to ensure your docker host (e.g., a cloud VM at Amazon or Microsoft Azure) allows Internet traffic through port `80` at whatever IP or domain name your docker host is located.


<a id="h46102A0D"></a>

## TDM

The [THREDDS Data Manager](http://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) or TDM is an application that works in close conjunction with the TDS and is referenced in the [docker-compose.yml](docker-compose.yml) in this repository. The TDM Docker container [is in its own repository](https://github.com/Unidata/tdm-docker) where you can find instructions on how to run it.


<a id="h760FDE8A"></a>

## Citation

In order to cite this project, please simply make use of the Unidata THREDDS Data Server DOI: <10.5065/D6N014KG> <https://doi.org/10.5065/D6N014KG>


<a id="h5CC30EC0"></a>

## Support

If you have a question or would like support for this THREDDS Docker container, consider [submitting a GitHub issue](https://github.com/Unidata/thredds-docker/issues). Alternatively, you may wish to start a discussion on the THREDDS Community mailing list: [thredds@unidata.ucar.edu](mailto:thredds@unidata.ucar.edu).

For general TDS questions, please see the [THREDDS support page](https://www.unidata.ucar.edu/software/thredds/current/tds/#help).
