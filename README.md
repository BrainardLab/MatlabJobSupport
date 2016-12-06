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
This will be the base image for all MatlabJobSupport jobs.  It will establish a minimal executation environment and most of the conventions for how to arrange files and invoke jobs.

This image will be responsible for:
 - installing system dependencies required for Matlab execution
 - installing the ToolboxToolbox for managing Matlab toolbox dependencies
 - convention for "mounting in" the Matlab installation from the Docker host
 - convention for invoking the container with "host" netowrking, to satsfy the Matlab license
 - convention for "mounting in" a folder to receive the Matlab execution logs
 - convention for where toolboxes live in the container file system
 - convention for "mounting in" shared toolboxes from the host
 - convention for "mounting in" an additional working folder to share with the host and add to the Matlab path
 - including a startup.m to configure the ToolboxToolbox, shared toolboxes, and working folder
 - convention for how to invoke and pass args to the container, including:
   - toolbox configuration command
   - Matlab command for the job itself

## Matlab Support, plus Docker
This will extend the base image and add support for running Docker containers inside the job container.  This will be useful for toolboxes like RenderToolbox4, which use Docker to distrubute native binaries that can be called from Matlab.

This image will be responsible for:
 - installing Docker client
 - convention for invoking the container with "monted in" socket to talk to host Docker daemon

## Matlab Support, plus Docker and native system libs
This will extend the "plus Docker" image and add support for native system libraries used by RenderToolbox4, like Assimp and OpenEXR.

This image will be an example of how to extend the "Matlab Support" base image or "plus Docker" image, to suit a particular application like RenderToolbox4.

This image will be responsible for:
  - installing Assimp system library
  - installing OpenEXR system library
  - setting the LD_PRELOAD environment variable to make sure that Matlab runs with up-to-date C/C++ libs

# Out of Scope
I hope that this project will help with wrangling dependencies and syntax required to run batch, distributed, and test jobs!  But this project can't do it all.  Somethings will still be out of scope for this project.

## AWS learning and account config

## Kubernetes learning and account config
