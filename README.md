# THREDDS Docker

[![Travis Status](https://travis-ci.org/Unidata/thredds-docker.svg?branch=master)](https://travis-ci.org/Unidata/thredds-docker)

A containerized [THREDDS Data Server](http://www.unidata.ucar.edu/software/thredds/current/tds/) built on top a [security hardened Tomcat container maintained by Unidata](https://github.com/Unidata/tomcat-docker). This project was initially developed by [Axiom Data Science](http://www.axiomdatascience.com/) and now lives at Unidata.

**TDM Update**: If you are looking for the TDM Docker container, it has [moved into its own repository](https://github.com/Unidata/tdm-docker).

## Versions

* `unidata/thredds-docker:4.6.10`
* `unidata/thredds-docker:4.6.8`
* `unidata/thredds-docker:4.6.6`
* `unidata/thredds-docker:5.0-SNAPSHOT`

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

## `docker-swarm`

There is a Docker Compose file included that is specific to setting up THREDDS as
part of a THREDDS cluster. To do so, you will need the latest Docker engine installed
(17.06.0 as of this writing). You will also need the latest Docker Compose installed
(1.15.0 as of this writing). For this demonstration, you also need Docker Machine
installed. However, this is also applicable to deploying in the cloud, on VMWare,
etc.

In this documentation, I set up a single manager node and a single worker node.
This demonstrates a very simple cluster. In your development and especially production,
you will want a quorum of managers and however many worker nodes you need for the
amount of THREDDS instances you wish to serve.

This demonstration uses VirtualBox

Here I set the name of the manager to use throughout the demonstration.
```
# Set the manager name
$ MANAGER_NAME="manager"
```

I create the first VM which is to be my manager node. I set the VM to have 1GB of RAM, use a single CPU and use the `Am79C973` network interface type which performs best on MacOS. Your results may vary. I also specify the storage driver to be set to `overlay2`. AUFS storage is the default but [overlay2 is preferred](https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/). The manager node will not run any containers. Its only job is to deploy, update and remove services from the swarm.
```
# Create the manager machine
docker-machine create -d virtualbox --engine-storage-driver overlay2 --virtualbox-memory "1024" --virtualbox-hostonly-nictype Am79C973 --virtualbox-cpu-count "1" $MANAGER_NAME
```

Once the manager machine is created, I then create 1..n worker machines. These machines will actually be the ones hosting the THREDDS services. For this demonstration, I only create one machine. If you have the spare RAM and wish to experiment, just set the `WORKER_COUNT` variable to the amount of machines you'd like to spawn. These machines will each have 6GB of RAM.
```
# Create 1..n worker machines
WORKER_COUNT=1
for ((n=1;n<=WORKER_COUNT;n++)); do \
  docker-machine create -d virtualbox --engine-storage-driver overlay2 --virtualbox-memory "6144" --virtualbox-hostonly-nictype Am79C973 --virtualbox-cpu-count "1" "worker${n}"; \
done
```

Because I will be accessing the machines directly later, I get the pysical IP addresses of the VMs for the manager node as well as the first worker node.
```
# Get the IP address of the Manager and first worker node
MANAGER_IP="$(docker-machine ip $MANAGER_NAME)"
WORKER_IP="$(docker-machine ip worker1)"
```

The first order of business is to initiate the swarm on the manager. This command creates a Docker swarm that any other machine can join to as long as they have the join token to do so. I set the availability on the manager to `drain` which means that any docker containers deployed in the swarm will not be deployed onto this machine. I also set the advertise address to the IP of the VM. Other nodes in the swarm will then use that address to connect to the manager.
```
# Initiate the swarm on the manager node, don't let services run on this node
docker-machine ssh $MANAGER_NAME docker swarm init --availability drain --advertise-addr $MANAGER_IP:2377
```

When I initiate the swarm, the manager does spit out some information which includes a worker token. However, the information provided is not easily programmatically parseable. Here I perform a query to the manager to give me just the join token for worker nodes.
```
# Get the worker join token
WORKER_JOIN_TOKEN="$(docker-machine ssh $MANAGER_NAME docker swarm join-token worker -q)"
```

Now that I have the worker token, I can have each worker join the swarm as well.
```
# Join the workers to the manager
for ((n=1;n<=WORKER_COUNT;n++)); do \
  docker-machine ssh worker$n docker swarm join --token $WORKER_JOIN_TOKEN $MANAGER_IP:2377; \
done
```

I also want to be able to use the docker client on my workstation against the manager node's Docker engine. After this command, any docker command I issue will be run against the Docker engine on the manager node.
```
# Prepare local docker client to work with the manager node
eval $(docker-machine env $MANAGER_NAME)
```

Here I deploy the THREDDS stack by issuing the stack deploy command against the Docker Compose configuration included specific for Docker Swarm. The name of the stack will be `thredds`.
```
# Deploy the stack
docker stack deploy -c docker-compose-swarm.yml thredds
```

Checking the logs of the stack service is easy. The swarm service will have a dynamically created ID but the name of the service will be &lt;stack name>\_&lt;service name>. Here you can see that each log entry is prepended by `<stack name>_<service name>.<service replica count>.<service process name>@<swarm node name>`

At the very end you can see that the THREDDS server has started up and it took about 18 seconds.
```
$ docker service logs thredds_thredds
thredds_thredds.1.rwjs0zrc8cux@worker1    | chown: changing ownership of ‘/usr/local/tomcat/conf/tomcat-users.xml’: Read-only file system
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.406 WARNING [main] org.apache.catalina.startup.SetAllPropertiesRule.begin [SetAllPropertiesRule]{Server/Service/Connector} Setting property 'server' to 'Apache' did not find a matching property.
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.440 WARNING [main] org.apache.tomcat.util.digester.SetPropertiesRule.begin [SetPropertiesRule]{Server/Service/Engine/Realm/Realm} Setting property 'digest' to 'SHA' did not find a matching property.
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.492 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server version:        Apache Tomcat
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.493 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server built:          May 5 2017 11:03:04 UTC
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.493 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server number:         8.5.15.0
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.493 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log OS Name:               Linux
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.493 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log OS Version:            4.4.74-boot2docker
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.494 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Architecture:          amd64
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.494 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Java Home:             /usr/lib/jvm/java-8-openjdk-amd64/jre
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:21:42.494 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log JVM Version:           1.8.0_131-8u131-b11-1~bpo8+1-b11
[...]
thredds_thredds.1.rwjs0zrc8cux@worker1    | 28-Jul-2017 15:22:00.980 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in 18269 ms
```

You can scale the amount of THREDDS servers in the swarm by issuing the `dockr service scale` command
```
# Scaling the service to 2
docker service scale thredds_thredds=2
```

Once the THREDDS server is up and running, you can access it in a browser or via CURL or any HTTP client.
```
# Accessing the service via a browser
# The service can be accessed through any machine in the swarm, including machines
# that do not host the actual container. The Swarm overlay network takes care of
# routing for you:
$ curl 'http://$MANAGER_IP/thredds/catalog.html' -I
HTTP/1.1 200
Access-Control-Allow-Origin: *
Content-Type: text/html;charset=UTF-8
Content-Length: 2154
Date: Fri, 28 Jul 2017 15:32:13 GMT
Server: Apache

$ curl 'http://$WORKER_IP/thredds/catalog.html' -I
HTTP/1.1 200
Access-Control-Allow-Origin: *
Content-Type: text/html;charset=UTF-8
Content-Length: 2154
Date: Fri, 28 Jul 2017 15:32:24 GMT
Server: Apache
```

Removing THREDDS out of the swarm is as easy as issuingthe `docker stack rm` command
```
# Removing the service stack
docker stack rm thredds
```

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

The [THREDDS Data Manager](http://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) or TDM is an application that works in close conjunction with the TDS and is referenced in the [docker-compose.yml](https://github.com/Unidata/thredds-docker/blob/master/docker-compose.yml) in this repository. The TDM Docker container [is now its own repository ](https://github.com/Unidata/tdm-docker) where you can find instructions on how to run it.

## Citation

In order to cite this project, please simply make use of the [Unidata THREDDS Data Server DOI](https://data.datacite.org/10.5065/D6N014KG).
