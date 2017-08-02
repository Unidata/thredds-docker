# THREDDS Docker Swarm Configuration

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

Because I will be accessing the machines directly later, I get the physical IP addresses of the VMs for the manager node as well as the first worker node.
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

You can scale the amount of THREDDS servers in the swarm by issuing the `docker service scale` command
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

Removing THREDDS out of the swarm is as easy as issuing the `docker stack rm` command
```
# Removing the service stack
docker stack rm thredds
```
