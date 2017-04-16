% Create a job and Docker run script for testing the ToolboxToolbox.
%
% This script will produce a job struct suitable for running all the unit
% tests for the ToolboxToolbox.
%
% It will produce a shell script suitable for running the tests locally,
% and another script suitable for running the tests on Jenkins.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   cd to the folder that contains the ToolboxToolbox tests
%   invoke the test runner function

job = mjsJob( ...
    'name', 'testToolboxToolbox', ...
    'setupCommand', 'cd(fileparts(which(''tbAssertTestsPass'')))', ...
    'jobCommand', 'tbAssertTestsPass');


%% Run the job in a Docker container on this machine.
%   "dockerImage" "...:latest" to auto-update the mjs docker image
%   "mountDockerSocket" to use docker from inside the docker container
%   "dryRun" in case you don't want to run the tests yet

[status, result, localScript] = mjsExecuteLocal(job, ...
    'profile', 'local', ...
    'dockerImage', 'brainardlab/mjs-docker:latest', ...
    'mountDockerSocket', true, ...
    'dryRun', true);

fprintf('Local shell script:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%	"toolboxToolboxDir" to use the version of ToolboxToolbox that Jenkins
%	is trying to test, instead of the default version in the docker image

jenkinsScript = mjsWriteDockerRunScript(job, ...
    'profile', 'jenkins', ...
    'toolboxToolboxDir', '$WORKSPACE', ...
    'dockerImage', 'brainardlab/mjs-docker:latest', ...
    'mountDockerSocket', true, ...
    'dryRun', true);

fprintf('Jenkins shell script:\n');
system(sprintf('cat "%s"', jenkinsScript));
