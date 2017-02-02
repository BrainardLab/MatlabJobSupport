% Create a job and Docker run script for building and testing mexximp.
%
% This script will produce a job struct suitable for building mexximp and
% running all of its unit tests.
%
% It will produce a shell script suitable for running the tests locally,
% and another script suitable for running the tests on Jenkins.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   deploy mexximp
%   build mexximp
%   invoke the test runner function

job = mjsJob( ...
    'name', 'testMexximp', ...
    'toolboxCommand', 'tbUse(''mexximp'');', ...
    'jobCommand', ...
    {'makeMexximp(''outputFolder'', ''~/mexximp'');', ...
    'cd(fullfile(tbLocateToolbox(''mexximp''), ''test''));', ...
    'tbAssertTestsPass();'});


%% Run the job in a Docker container on this machine.
%   "mountDockerSocket" to use docker from inside the docker container
%   "testDir" to make sure tests can find fixture files
%   "dockerImage" to get Assimp library
%   "dryRun" in case you don't want to run the tests yet

testDir = fullfile(tbLocateToolbox('mexximp'), 'test');
[status, result, localScript] = mjsExecuteLocal(job, ...
    'mountDockerSocket', true, ...
    'inputDir', testDir, ...
    'profile', 'local', ...
    'dockerImage', 'ninjaben/mjs-rtb:latest', ...
    'dryRun', true);

fprintf('Local shell script:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%   "dockerImage" to get Assimp library

testDir = fullfile('$WORKSPACE', 'mexximp', 'test');
jenkinsScript = mjsWriteDockerRunScript(job, ...
    'profile', 'jenkins', ...
    'mountDockerSocket', true, ...
    'inputDir', testDir, ...
    'dockerImage', 'ninjaben/mjs-rtb:latest', ...
    'dryRun', true);

fprintf('Jenkins shell script:\n');
system(sprintf('cat "%s"', jenkinsScript));
