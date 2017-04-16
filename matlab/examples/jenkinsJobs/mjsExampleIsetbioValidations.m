% Create a job and Docker run script for validating isetbio.
%
% This script will produce a job struct suitable for running all the
% UnitTestToolbox validations for isetbio.
%
% It will produce a shell script suitable for running the tests locally,
% and another script suitable for running the tests on Jenkins.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   deploy isetbio
%   invoke the test runner function

job = mjsJob( ...
    'name', 'validateIsetbio', ...
    'toolboxCommand', 'tbUse(''isetbio'')', ...
    'jobCommand', 'ieValidateFullAll(''asAssertion'', true)');


%% Run the job in a Docker container on this machine.
%   "dockerImage" "...:latest" to auto-update the mjs docker image
%   "javaDir" to set up Java/gradle/RemoteDataToolbox in the container
%   "dryRun" in case you don't want to run the tests yet

[status, result, localScript] = mjsExecuteLocal(job, ...
    'profile', 'local', ...
    'dockerImage', 'brainardlab/mjs-brainard:latest', ...
    'javaDir', 'bundled', ...
    'dryRun', true);

fprintf('Local shell script:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.

jenkinsScript = mjsWriteDockerRunScript(job, ...
    'profile', 'jenkins', ...
    'dockerImage', 'brainardlab/mjs-brainard:latest', ...
    'javaDir', 'bundled', ...
    'dryRun', true);

fprintf('Jenkins shell script:\n');
system(sprintf('cat "%s"', jenkinsScript));
