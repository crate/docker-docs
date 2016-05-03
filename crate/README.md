# Supported tags and respective `Dockerfile` links

-	[`latest`, `0.54`, `0.54.8` (*Dockerfile*)](https://github.com/crate/docker-crate/blob/c9cbce8e2bbde68cdb06f3fa4feccaaf8ec4c542/Dockerfile)
-	[`0.52`, `0.52.4` (*Dockerfile*)](https://github.com/crate/docker-crate/blob/cce8f796ba8936250eb380235cde47be494d1e95/Dockerfile)

[![](https://badge.imagelayers.io/crate:latest.svg)](https://imagelayers.io/?images=crate:latest,crate:0.52)

For more information about this image and its history, please see [the relevant manifest file (`library/crate`)](https://github.com/docker-library/official-images/blob/master/library/crate). This image is updated via [pull requests to the `docker-library/official-images` GitHub repo](https://github.com/docker-library/official-images/pulls?q=label%3Alibrary%2Fcrate).

For detailed information about the virtual/transfer sizes and individual layers of each of the above supported tags, please see [the `crate/tag-details.md` file](https://github.com/docker-library/docs/blob/master/crate/tag-details.md) in [the `docker-library/docs` GitHub repo](https://github.com/docker-library/docs).

# What Is Crate?

Crate is a fast, scalable, easy to use SQL database that plays nicely
with containers like Docker. It feels like the SQL databases you know,
however makes scaling and operating your database ridiculously easy --
regardless of the volume, complexity, or type of data. Crate is open
source. It ingests millions of records per second for time series
setups and delivers analytics results in subsecond real time.

It comes with a distributed sort and aggregation engine, fast multi
index queries, native full-text search and super simple scalability
with sharding and partitioning builtin already. Preconfigured
replication takes care of data resiliency. The cluster management can
easily supervised with its builtin admin UI. Crate's masterless
architecture and simplicity make the data part of Docker environments
easy and elegant.

Crate provides several installation packages, including a supported
Docker image. It fits perfectly in an orchestrated microservices
environment. It acts like an ether, an omnipresent, persistent layer
for data. This way, application containers access their data
regardless on which host the data nodes run.

[Crate](https://crate.io/)

![logo](https://raw.githubusercontent.com/docker-library/docs/2517900006ae5f4c03c1d43235930c59f4614394/crate/logo.png)

## How To Use This Image

To form a cluster, just start the Crate container a few times in the
background. This starts a Crate container on your machine:

```console
# docker run -d crate
```

To access the admin UI, map port 4200 and point your browser to port tcp/4200 of a
node of your choice while you start it or look up its IP later on:

```console
# firefox "http://$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $(docker run -d crate)):4200/admin"
```

For production use it's strongly recommended to use only one container
per physical machine. Therefore mapping Crate's (default) ports 4200 (HTTP) and
4300 (Transport protocol) is a good way to provide access.

```console
# docker run -d -p 4200:4200 -p 4300:4300 crate
```

## Attach Persistent Data Directory

Crate stores all important data in `/data`. To attach it to a backup
service, map the directory to the host:

```console
# docker run -d -v <data-dir>:/data crate
```

Note, that there are way more sophisticated ways to [backup data with
builtin commands like `CREATE SNAPSHOT`](https://crate.io/a/backing-up-and-restoring-crate/).

## Use Custom Crate Configuration

Crate is basically controlled by a single configuration file which has
sensible defaults already. If you derive your container from the Crate
container and place your file inside it and let Crate know where to
find it:

```console
# docker run -d crate -Des.config=</path/to>/crate.yml
```

Other configuration settings may be specified upon startup using the
`-D` option prefix. For example, configuring the cluster name by using
system properties will work this way:

```console
# docker run -d crate -Des.cluster.name=<my-cluster-name>
```

For further configuration options please refer to the
[Configuration](https://crate.io/docs/stable/configuration.html)
section of the online documentation.

## Environment

Crate recognizes a few environment variables like `CRATE_HEAP_SIZE`
that need to be set with the `--env` option before the actual Crate
core starts. You may want to [assign about half of your memory
it](https://crate.io/docs/reference/en/latest/configuration.html#crate-heap-size)
as a rule of thumb to Crate like this:

```console
# docker run -d --env CRATE_HEAP_SIZE=32g crate
```

## Open Files

Depending on the size of your installation Crate opens a lot of
files. You can check the number of open files with `ulimit -n`. It
depends on your host operation system. To increase the number start
containers with the option `--ulimit nofile=65535:65535`:

## Multicast

Crate uses multicast for node discovery by default. This means nodes
started in the same multicast zone will discover each other
automatically. However, Docker multicast support between containers on
different hosts depends on the overlay network driver. If that does
not support multicast, you have to [enable unicast in your custom
`crate.yml`](https://crate.io/docs/reference/best_practice/multi_node_setup.html).

Crate publishes the hostname it runs on for discovery within the
cluster. If the address of the docker container differs from the
actual host the docker image is running on -- this is the case if you
do port mapping to the host via the `-p` option, you need to tell
Crate to publish the address of the docker host instead:

```console
# docker run -d -p 4200:4200 -p 4300:4300 crate \
    crate -Des.network.publish_host=host1.example.com
```

If you change the transport port from the default `4300` to something
else, you also need to pass the publish port to Crate by adding
`-Des.transport.publish_port=4321` to your command.

## Example Usage in a Multihost Setup

To start a Crate cluster in containers distributed to three hosts
without multicast enabled, run this command on the first node and
adapt container and node names on the two other nodes:

```console
# HOSTS="crate1.example.com:4300,crate2.example.com:4300,crate3.example.com:4300"
# HOST="crate1.example.com"
# docker run -d -p 4200:4200 -p 4300:4300 \
    --name crate1-container \
    --volume /mnt/data:/data \
    --env CRATE_HEAP_SIZE=8g \
        crate:latest \
	crate -Des.cluster.name=crate-cluster \
              -Des.node.name=crate1 \
              -Des.transport.publish_port=4300 \
              -Des.network.publish_host="$HOST" \
              -Des.multicast.enabled=false \
              -Des.discovery.zen.ping.unicast.hosts="$HOSTS" \
              -Des.discovery.zen.minimum_master_nodes=2
```

## Crate Shell

The Crate Shell `crash` is bundled with the Docker image. Since the
`crash` executable is already in the `$PATH` environment variable,
simply run:

```console
# docker run --rm -ti crate crash --hosts [host1, host2, ...]
```

# License

View [license information](https://github.com/crate/crate/blob/master/LICENSE.txt) for the software contained in this image.

# Supported Docker versions

This image is officially supported on Docker version 1.11.1.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

# User Feedback

## Documentation

Documentation for this image is stored in the [`crate/` directory](https://github.com/docker-library/docs/tree/master/crate) of the [`docker-library/docs` GitHub repo](https://github.com/docker-library/docs). Be sure to familiarize yourself with the [repository's `REAMDE.md` file](https://github.com/docker-library/docs/blob/master/README.md) before attempting a pull request.

Visit [Crate on Docker](https://crate.io/docs/install/containers/docker/) and get further documentation about how to get started with Crate.

## Issues

If you have any problems with or questions about this image, please
contact us through a [GitHub issue](https://github.com/crate/docker-crate/issues).


If you have any questions or suggestions, we are happy to help! Feel
free to join our [public Crate community on Slack](https://crate.io/docs/support/slackin/).

For further information and official contact visit
[https://crate.io](https://crate.io).

## Contributing

You are very welcome to contribute features or fixes! Before we can accept any pull requests to Crate Data we need you to agree to our [CLA](https://crate.io/community/contribute/). For further information please refer to [CONTRIBUTING.rst](https://github.com/crate/crate/blob/master/CONTRIBUTING.rst).
