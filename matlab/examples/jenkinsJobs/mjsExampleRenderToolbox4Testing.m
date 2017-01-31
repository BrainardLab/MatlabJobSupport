% Create a job and Docker run script for testing RenderToolbox4.
%
% This script will produce a job struct suitable for running all the
% RenderToolbox4 unit tests.
%
% It will produce a shell script suitable for running the tests locally,
% and another script suitable for running the tests on Jenkins.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   deploy RenderToolbox4
%   invoke the test runner function

job = mjsJob( ...
    'name', 'testRenderToolbox4', ...
    'toolboxCommand', 'tbUse(''RenderToolbox4'');', ...
    'setupCommand', 'cd(fullfile(tbLocateToolbox(''RenderToolbox4''), ''Test'', ''Automated''));', ...
    'jobCommand', 'tbAssertTestsPass()');


%% Run the job in a Docker container on this machine.
%   "mountDockerSocket" to use docker from inside the docker container
%   dataDir to shared between host, job container, rendering containers
%   "outputOwner" so that outputs won't be owned by root
%   "dryRun" in case you don't want to run the tests yet

dataDir = fullfile(tempdir(), job.name);
[status, result, localScript] = mjsExecuteLocal(job, ...
    'profile', 'local', ...
    'dockerImage', 'ninjaben/mjs-rtb:latest', ...
    'mountDockerSocket', true, ...
    'outputDir', dataDir, ...
    'workingDir', dataDir, ...
    'outputOwner', 'current', ...
    'dryRun', true);

fprintf('Local shell script:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%   "mountDockerSocket" to use docker from inside the docker container

dataDir = fullfile('$WORKSPACE', job.name);
jenkinsScript = mjsWriteDockerRunScript(job, ...
    'profile', 'jenkins', ...
    'dockerImage', 'ninjaben/mjs-rtb:latest', ...
    'mountDockerSocket', true, ...
    'outputDir', dataDir, ...
    'workingDir', dataDir, ...
    'dryRun', true);

fprintf('Jenkins shell script:\n');
system(sprintf('cat "%s"', jenkinsScript));
