# README

This project provides a Centos-based Docker image for a standalone StreamSets Data 
Collector (SDC) preconfigured with the CDH 5.14 stage lib and Cloudera's hadoop-client libraries

Info on StreamSets Data Collector is [here](https://streamsets.com/products/sdc)

## Required Resources

In order to connect to a specific Cloudera cluster, copy the Cloudera client config files 
to this project's resources directory before creating the image, as described below: 

####  Hadoop Config Files

Copy the contents of the cluster's YARN Client Configs to this project's
 `resources/hadoop-conf` directory

#### Hive Config Files

Copy the contents of the cluster's Hive Client Configs to this project's
 `resources/hive-conf` directory

## Environment Variables

Set the SDC Version:

	$ export SDC_VERSION=3.1.0.0


## Build

Build the Docker Container:

	$ docker build -t mbrooks/datacollector-cdh:$SDC_VERSION .


## Run the container
Run the container with the following command which exposes the SDC port:
 
	$ docker run \
	 -p 18630:18630  \
	 -d mbrooks/datacollector-cdh:$SDC_VERSION dc 
 
 ## Connect to SDC
 Connect to SDC at `http://<docker-host>:18630`
 
 ## Note regarding persistence
 
 This Docker image is stateless and is intended to be used with StreamSets Control Hub (SCH)
 
 When used with SCH and launched using [SCH's Kubernetes Support](https://streamsets.com/blog/streamsets-control-hub-kubernetes/) 
 SCH manages all persistence for the SDC container
 
 Info on StreamSets Control Hub is [here](https://streamsets.com/products/sch)
 
 If this Docker image is used without SCH, state can be maintained using a data container
 for persistence and by using these commands to create and to run the container:
 
 ## Create a data container (only needed when running outside of SCH)

This command creates a Docker data container named "sdc-volumes" 
with multiple data volumes so that important SDC data and configs 
persist across container restarts and upgrades

	$ docker create \
	 -v /etc/sdc \
	 -v /data \
	 -v /opt/streamsets-datacollector-$SDC_VERSION/streamsets-libs \
	 -v /resources \
	 -v /opt/streamsets-datacollector-user-libs \
	 -v $SDC_DIST/streamsets-libs-extras \
	 -v /logs \
	 -v /usr/lib/hdinsight-common/certs \
	 --name sdc-volumes \
	mbrooks/datacollector-cdh:$SDC_VERSION



## Run the container (only when running outside of SCH)
Run the container with the following command which references the data container and 
exposes the SDC port:

 
	$ docker run \
	 --volumes-from sdc-volumes \
	 -p 18630:18630  \
	 -d mbrooks/datacollector-cdh:$SDC_VERSION dc 
 
 
 
