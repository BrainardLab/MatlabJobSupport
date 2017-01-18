% Create a job and Docker run script for testing the IBIOColorDetect.
%
% This script will produce a job struct suitable for running all the full
% validations for the IBIOColorDetect project.
%
% It will demonstrate how to execute the job (ie run all the
% tests) in three different environments:
%   - directly, right here in Matlab
%   - inside a Docker container on the local machine
%   - inside a Docker container on a remote Jenkins test server
%
% In all three cases, the job will be the same.  For the two Docker
% cases, we will generate a shell script that takes care of packing up the
% job struct and invoking Docker with lots of arguments.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   First, deploy IBIOColorDetect using the ToolboxToolbox.
%   Then invoke the test runner function.

job = mjsJob( ...
    'name', 'validateIBIOColorDetect', ...
    'toolboxCommand', 'tbUse(''IBIOColorDetect'')', ...
    'jobCommand', 'IBIOCDValidateFullAll');

fprintf('Here''s the job we just created:\n');
disp(job);


%% Run the job directly here in this Matlab process.
%   For local execution, we assume IBIOColorDetect was already installed.
%       https://github.com/isetbio/IBIOColorDetect/wiki/Installation

mjsRunJob(job);


%% Run the job in a Docker container on this machine.
%   This will generate a shell script to invoke Matlab with this job, in a
%   separate Docker process.
%
%   For Docker execution, we need install IBIOColorDetect inside the
%   contianer.  This has two unusual steps for IBIOColorDetect:
%
%       - manually supply IBIOColorDetect repo, instead of letting
%       ToolboxToolbox clone it automatically
%           - do this by mounting in the host's toolbox folder as 'toolboxesDir'
%
%       - manually copy the localHook, instead of letting ToolboxToolbox
%       clone it automatically.
%           - do this by adding a job setupCommand.
%
%   After these two steps, we can  do tbUse('IBIOColorDetect') inside the
%   container.

% job will "insatll" the local hook template to the expected folder
%   folder conventions are established by mjs-base Docker image
job.setupCommand = {@copyfile, ...
    '/mjs/toolboxes/IBIOColorDetect/configuration/IBIOColorDetectLocalHookTemplate.m', ...
    '/mjs/toolboxHooks/IBIOColorDetect.m'};

% run the job with IBIOColorDetect supplied from the host toolbox dir
toolboxRoot = getpref('ToolboxToolbox', 'toolboxRoot');
[status, result, localScript] = mjsExecuteLocal(job, ...
    'toolboxesDir', toolboxRoot);

fprintf('Docker execution had status %d (0 is good.).\n', status);
fprintf('Shell script generated for local machine:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%   We have a Jenkins test server, where we'd like to run this same job for
%   continuous testing of the IBIOColorDetect code.
%
%   The Jenkins server knows how to check out branches of the
%   IBIOColorDetect code from GitHub, into a folder called the WORKSPACE.
%
%   We want to run the tests on the WORKSPACE version of IBIOColorDetect.
%   So we need to generate a shell script that mounts the WORKSPACE into
%   the Docker container at the right place.  We can do this by specifying
%   a value for the container's 'toolboxesDir'.

% run the job with IBIOColorDetect supplied from the Jenkins WORKSPACE
toolboxRoot = '$WORKSPACE';
jenkinsScript = mjsWriteDockerRunScript(job, ...
    'toolboxesDir', toolboxRoot);

fprintf('Shell script for remote Jenkins server:\n');
system(sprintf('cat "%s"', jenkinsScript));
fprintf('The special line for Jenkins is the one with "-v "$WORKSPACE".\n');


%% Install in Jenkins.
%   The next step would be to copy the Jenkins shell script into a new
%   project on our Jenkins server.  Since the server has matlab and Docker
%   installed, this script is able to take care of the rest.
