#
# Copyright 2018 StreamSets Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

######################################
## Dockerfile to build a standalone instance of SDC pre-configured 
## with the Cloudera's hadoop-client libs
##
## This project borrowed heavily from the project here (thanks Adam!):
## https://github.com/streamsets/datacollector-docker
######################################
FROM centos:7
LABEL maintainer="Mark Brooks <mark@streamsets.com>"


######################################
## SDC version and download locations
######################################
ENV SDC_VERSION=3.1.0.0
ENV SDC_BASE_URL=http://nightly.streamsets.com.s3-us-west-2.amazonaws.com/datacollector/3.1/3.1.0.0/tarball/
ENV SDC_CORE=streamsets-datacollector-core-3.1.0.0.tgz
ENV SDC_URL=${SDC_BASE_URL}${SDC_CORE}
ENV SDC_CDH_514_STAGE_LIB_TGZ=streamsets-datacollector-cdh_5_14-lib-3.1.0.0.tgz



######################################
## Install OpenJDK8 and wget
##
## Note that OpenJDK 1.8.0.161 allows strong crypto by default
######################################
RUN  yum -y update && yum -y install \
 java-1.8.0-openjdk \
 wget



######################################
## Install Cloudera hadoop-client
######################################  
COPY resources/cdh.repo /etc/yum.repos.d/
RUN yum -y update && yum -y install hadoop-client




######################################
## Set the SDC User
## We set a UID/GID for the SDC user because certain  environments 
## require these to be consistent throughout the cluster. 
## We use 20159 because it's above the default value of YARN's min.user.id property.
######################################
ARG SDC_USER=sdc
ARG SDC_UID=20159


######################################
## The paths below should generally be attached to a VOLUME for persistence.
## See the project's README.md for example use of VOLUMEs
##
## SDC_CONF is where configuration files are stored. This can be shared.
## SDC_DATA is a volume for storing collector state. Do not share this between containers.
## SDC_LOG is an optional volume for file based logs.
## SDC_RESOURCES is where resource files such as runtime:conf resources and Hadoop configuration can be placed.
## STREAMSETS_LIBRARIES_EXTRA_DIR is where extra libraries such as JDBC drivers should go.
## USER_LIBRARIES_DIR is where custom stage libraries are installed.
######################################
ENV SDC_DIST="/opt/streamsets-datacollector-${SDC_VERSION}"
ENV SDC_CONF=/etc/sdc \
    SDC_DATA=/data \
    SDC_LOG=/logs \
    SDC_RESOURCES=/resources \
    USER_LIBRARIES_DIR=/sdc-user-libs \
    STAGE_LIBRARIES_DIR="${SDC_DIST}/streamsets-libs" \
    STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/streamsets-libs-extras"


######################################
## Run the SDC configuration script
######################################
COPY scripts/sdc-configure.sh /
RUN /sdc-configure.sh && rm /sdc-configure.sh


######################################
## Install the SDC CDH 5.14 stage lib
######################################
ENV WORKDIR=/tmp
RUN wget ${SDC_BASE_URL}${SDC_CDH_514_STAGE_LIB_TGZ} \
 && tar -xvf ${SDC_CDH_514_STAGE_LIB_TGZ} \
 && mv streamsets*/streamsets-libs/* ${STAGE_LIBRARIES_DIR}
 && rm -rf streamsets*




######################################
## Load the CDH Hadoop configs into /etc
######################################
RUN rm -rf /etc/hadoop/conf && mkdir -p /etc/hadoop/conf
RUN rm -rf /etc/hive/conf && mkdir -p /etc/hive/conf
COPY resources/yarn-conf/* /etc/hadoop/conf/
COPY resources/hive-conf/* /etc/hive/conf/


######################################
## Load the CDH Hadoop configs into SDC Resources
######################################
COPY resources/yarn-conf ${SDC_RESOURCES}/hadoop-conf
COPY resources/hive-conf ${SDC_RESOURCES}/hive-conf




######################################
## Launch SDC
######################################
USER ${SDC_USER}
EXPOSE 18630
COPY scripts/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]





