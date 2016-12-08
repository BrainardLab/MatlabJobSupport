# ninjaben/mjs-base
#
# This is the base image for the MatlabJobSupport project.
#   https://github.com/BrainardLab/MatlabJobSupport
#
# It sets up the minimum necessary environment for running MatlabJobSupport jobs.
#
# It establishes conventions for directories inside the contianer
# and directores to map in from the Docker host.
#
# Directories inside the container:
#  - /mjs -- startup.m, initial dir for container startup
#  - /mjs/ToolboxToolbox -- the ToolboxToolbox
#  - /mjs/toolboxes -- toolboxes installed by the ToolboxToolbox
#  - /mjs/toolboxes/ToolboxRegistry -- registry of toolboxes known to ToolboxToolbox
#  - /mjs/toolboxes/MatlabJobSupport -- MatlabJobSupport itself
#  - /mjs/toolboxHooks -- local toolbox hooks created by the ToolboxToolbox
#
# Container directores that should map to directories on the Docker host:
#  - /usr/local/MATLAB/from-host -- a real matlab installation (eg /usr/local/MATLAB/R2016a)
#  - /var/log/matlab -- where to write matlab logs
#  - /opt/toolboxes -- where ToolboxToolbox can look for shared/pre-installed toolboxes
#  - /var/mjs/working -- additional files to share with the host, initial dir for job execution
#
# It establishes conventions for how to run job containers.  For example, they
# should be run with "host" networking to satisfy the Matlab license.
#
# Here is a sample "docker run" command:
#
# docker run \
#  --rm \
#  --net="host" \
#  -v /usr/local/MATLAB/R2016a:/usr/local/MATLAB/from-host \
#  -v /var/log/matlab:/var/log/matlab \
#  -v /home/ben/Documents/MATLAB/toolboxes:/opt/toolboxes \
#  -v /home/ben/Documents/MATLAB/working:/var/mjs/working \
#  ninjaben/mjs-base 
#
# Same on one line:
# docker run --rm --net="host" -v /usr/local/MATLAB/R2016a:/usr/local/MATLAB/from-host -v /var/log/matlab:/var/log/matlab -v /home/ben/Documents/MATLAB/toolboxes:/opt/toolboxes -v /home/ben/Documents/MATLAB/working:/var/mjs/working ninjaben/mjs-base

FROM ubuntu:14.04

MAINTAINER Ben Heasly <benjamin.heasly@gmail.com>

### Minimum environment including Matlab dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    gfortran \
    git \
    libpng12-dev \
    libfreetype6-dev \
    libblas-dev \
    liblapack-dev \
    xorg

### ToolboxToolbox
WORKDIR /mjs
RUN git clone https://github.com/ToolboxHub/ToolboxToolbox.git
WORKDIR /mjs/toolboxes
RUN git clone https://github.com/ToolboxHub/ToolboxRegistry.git
RUN git clone https://github.com/BrainardLab/MatlabJobSupport.git


### Matlab startup.m and dirs it expects to exist
WORKDIR /usr/local/MATLAB/from-host
WORKDIR /var/log/matlab
WORKDIR /opt/toolboxes
WORKDIR /var/mjs/working
COPY startup.m /mjs/startup.m

### start in known dir so that Matlab can find startup.m
WORKDIR /mjs
ENV PATH="/usr/local/MATLAB/from-host/bin:${PATH}"
ENTRYPOINT ["matlab", "-logfile /var/log/matlab/matlab.log"]
CMD ["-h"]

