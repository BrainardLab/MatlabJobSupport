% Create a job and Docker run script for testing the Toolbox Toolbox.
%
% This script will produce a job JSON-file for invoking all of the Matlab
% Unit Tests in the current folder (pwd() when the job is executed).  We
% will use this for running through the ToolboxToolbox unit test suite.
%
% This script will also produce a shell script that invokes the job inside
% the Matlab Job Support base docker image (ninjaben/mjs-base).  This
% allows the tests to run in an isolated and predictable container
% environment.
%
% For the moment, this script is aimed at a Jenkins test server, where a
% version of the ToolboxToolbox will be located in a directory given by the
% WORKSPACE environment variable.  We want to test this version of the
% ToolboxToolbox, not the version included by default in the mjs-base
% image.  So we pass in a value for "toolboxToolboxDir" to replace the
% container version with the host version of the ToolboxToolbox.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
job = mjsJob( ...
    'name', 'testToolboxToolbox', ...
    'jobCommand', {@tbAssertTestsPass});


%% Try it locally.
toolboxToolboxDir = fileparts(fileparts(which('tbUse')));
mjsExecuteLocalJob(job, ...
    'workingDir', toolboxToolboxDir);


%% Make one for our Jenkins server.
toolboxToolboxDir = '$WORKSPACE';
workingDir = '$WORKSPACE';
workingJobFile = fullfile(pwd(), [job.name '.json']);
scriptFile = mjsWriteDockerRunScript( ...
    'job', job, ...
    'jobFile', workingJobFile);
    
