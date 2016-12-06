# MatlabJobSupport
Scripts and Docker images to support Matlab jobs including batch, distributed, and test jobs.

This is a work in progress.  I'm starting with design notes.  More to come.

# Overview
The goal of this project is to make it easier to pack up Matlab work as a "job", and to support job executions in several environments, like:
 - locally in a Docker container
 - remotely in a Docker container
 - remotely in a Kubernetes pod
 
We can do this with a combination of Matlab scripts and Docker images.  The scripts will help us declare jobs to be executed and resources needed.  The scripts will also encapsulate the complicated syntax required to invoke Docker and Kubernetes.  The Docker images will provide portable, isolated execution environments where jobs can run.

# Scripts
Here are some scripts that I think we'll want.  I'll try to point out what they do, and conventions they establish for working together.

## Matlab Job Declaration
This will make jobs declarative.  We need to be able to define each job in terms of arguments passed to this function.  This will let us create a portable job data structure that includes everything we need to know.  This is how we will defer execution until the job is scheduled to run somewhere.  It is also the thing that we will transform into complicated syntax suitable for execution in a partiular environment.

## Matlab Job Running
Each job running script will start with a job data structure, transform it into syntax appropriate for a particular execution environment, and possibly try to invoke the syntax to make the job to run.

I imagine we will have several of these, each aimed at a specific execution environment.  For starters:
 - run in a Docker container on the local host
 - run in a Docker container on a remote host, via SSH (assumes host and credentials have been configured)
 - run in a Docker container on a temporary AWS instance, via AEWS CLI and SSH (assumes AWS CLI has been configured)
 - run in a Kubernetes pod (assumes kubectl has been configured)

# Docker Images
I think all jobs should run inside Docker containers.  This will give us the chance to establish a portable, consistent execution environment.  It will also give us the chance to choose conventions for things like how the file system should be arranged and where Matlab should look for job-specefic scripts and resource files.

## Matlab Support
This will be the base image for all MatlabJobSupport jobs.  It will establish a minimal executation environment and conventions for how to arrange files and invoke jobs.

This image is responsible for:
 - installing system dependencies required for Matlab execution
 - convention for "mounting in" the Matlab installation from the Docker host
 - convention for invoking the container with "host" netowrking, because of Matlab license
 - convention for "mounting in" a folder to receive the Matlab execution logs
 - installing the ToolboxToolbox for managing Matlab toolbox dependencies
 - convention for toolboxes live in the container file system
 - convention for "mounting in" shared toolboxes from the host
 - convention for "mounting in" extra files from host and added to Matlab path
 - including a startup.m to configure the ToolboxToolbox, shared toolboxes, and extra files

## Matlab Support, plus Docker

## Matlab Support, plus Docker and RenderToolbox libs

## More

# Out of Scope

## AWS learning and account config

## Kubernetes learning and account config
