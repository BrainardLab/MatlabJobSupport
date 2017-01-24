% Create a job and Docker run script for validating IBIOColorDetect.
%
% This script will produce a job struct suitable for running all the
% UnitTestToolbox validations for IBIOColorDetect.
%
% It will produce a shell script suitable for running the tests locally,
% and another script suitable for running the tests on Jenkins.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   just invoke the test runner function

job = mjsJob( ...
    'name', 'validateIBIOColorDetect', ...
    'toolboxCommand', 'tbUseProject(''IBIOColorDetect'')', ...
    'jobCommand', 'IBIOCDValidateFullAllAssert');


%% Run the job in a Docker container on this machine.
%   "projectsDir" to mount the local project into the container
%   "dockerImage" "...:latest" to auto-update the mjs docker image
%   "javaDir" to set up Java/gradle/RemoteDataToolbox in the container
%   "dryRun" in case you don't want to run the tests yet

[~, ~, projectsDir] = tbLocateProject('IBIOColorDetect');
[status, result, localScript] = mjsExecuteLocal(job, ...
    'profile', 'local', ...
    'projectsDir', projectsDir, ...
    'dockerImage', 'ninjaben/mjs-base:latest', ...
    'javaDir', 'bundled', ...
    'dryRun', true);

fprintf('Local shell script:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%   "projectsDir" to mount the version of IBIOColorDetect that Jenkins is
%   trying to test into the container

jenkinsScript = mjsWriteDockerRunScript(job, ...
    'profile', 'jenkins', ...
    'dockerImage', 'ninjaben/mjs-base:latest', ...
    'javaDir', 'bundled', ...
    'dryRun', true);

fprintf('Jenkins shell script:\n');
system(sprintf('cat "%s"', jenkinsScript));
