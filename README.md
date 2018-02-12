# README

This project provides a Centos-based Docker image for a standalone StreamSets Data 
Collector (SDC) preconfigured with Cloudera's hadoop-client libraries

Info on StreamSets Data Collector is [here](https://streamsets.com/products/sdc)


## Environment Variables

Set the SDC Version:

	$ export SDC_VERSION=3.1.0.0


## Build

Build the Docker Container:

	$ docker build -t mbrooks/datacollector:$SDC_VERSION .


## Pre-load the CDH 5.14 Stage Lib 

docker run --rm mbrooks/datacollector:3.1.0.0 stagelibs -install=streamsets-datacollector-cdh_5_14-lib

	mbrooks/datacollector:$SDC_VERSION



## Run the container
Run the container with the following command which references the data container and the 
headnodehost IP address and exposes the SDC port:

 
	$ docker run \
	 -p 18630:18630  \
	 -d mbrooks/datacollector:$SDC_VERSION dc 
 
 ## Connect to SDC
 You should be able to connect to SDC at `http://<docker-host>:18630`
 
 
 ## Post-install steps 
 The image does not yet come preloaded with the HDI Stage Libs installed, so after SDC is
 up and running and you can connect to it in a browser, go to the package manager and 
 install the HDP 2.6.2.1-1 Stage Lib
  
 I hope to add that feature sometime soon
 
 
 

