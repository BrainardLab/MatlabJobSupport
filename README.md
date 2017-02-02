# MatlabJobSupport
Scripts and Docker images to support Matlab jobs including batch, distributed, and test jobs.

This is a work in progress.

# Overview
The goal of this project is to make it easier to pack up Matlab work as a "job", and to support job executions in several environments, like:
 - locally in a Docker container
 - remotely in a Docker container, via SSH
 - remotely in a Docker container, on a short-lived AWS EC2 instance
 - Others?  Kubernetes?  AWS ECS?  Docker Swarm?
 
We can do this with a combination of Matlab functions and Docker images.  The functions will help us declare jobs to be executed and resources needed.  They will also generate the complicated syntax required to invoke Docker, SSH, and AWS.

The Docker images will provide portable, isolated execution environments where jobs can run, and conventions for organzing files and configuring Matlab toolboxes.

# Jobs
We have some Matlab functions for working with [jobs](matlab/jobs) in Matlab.  These help do things like:
 - Declare a job of work as a Matlab struct.
 - Save/load jobs to/from JSON.
 - Execute the job in Matlab and exit with a status code that indicates job success.
 
# Environments
We have some separate Matlab functions for getting jobs to be executed in various [environments](matlab/environments), like locally, via SSH, or on a short-lived AWS EC2 instance.

Each of these functions takes in a job and writes out a shell script that includes an embedded job definition plus commands for launching Matlab to execute the job.  Since the scripts embed their job definitions, they are portable and complete.

# Examples
We have several [examples](matlab/examples) of working with jobs and execution environments.  Some of these demonstrate a simple calculation which can be carried out locally, via SSH, or on a short-lived AWS EC2 instance.

Others demonstrate how to generate jobs and job scripts that can be used to run tests on Matlab toolboxes, locally, or on a Jenkins server.

# Docker
In order to execute jobs, we need to know things like where Matlab is installed, how to obtain Matlab toolbox dependencies, and where to find for input and output files.  We use Docker images to establish conventions for these things, and write job execution scripts against the Docker images.  So far we have three:
 - [mjs-base](docker/mjs-base) -- this image establishes lots of conventions, like how to mount Matlab into a running container and where to look find input and output files.  It includes the ToolboxToolbox to manage Matlab toolbox dependencies.
 - [mjs-docker](docker/mjs-docker) -- this extends the mjs-base image to include the Docker client, which can be connected to the Docker daemon running on the Docker host.  This allows jobs that rely on Docker to keep using Docker, even though they are themselves running insice a container.
 - [mjs-rtb](docker/mjs-rtb) - this extends the mjs-docker image with native system dependencies required the RenderToolbox4.  This image is purpose-built for RenderToolbox4 and less general than mjs-base or mjs-docker.  It may be a useful example of how to extend the general-purpose images for jobs that have special requirements.
