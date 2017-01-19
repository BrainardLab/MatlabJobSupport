% Create a job and Docker run script for testing the IBIOColorDetect.
%
% This script will produce a job struct suitable for running all the full
% validations for the IBIOColorDetect project.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   First, deploy IBIOColorDetect using the ToolboxToolbox.
%   Then invoke the test runner function.

job = mjsJob( ...
    'name', 'validateIBIOColorDetect', ...
    'toolboxCommand', 'tbUseProject(''IBIOColorDetect'')', ...
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
%   Since IBIOColorDetect is a projet, not a toolbox, ToolboxToolbox won't
%   download it for us.  Instead, we need to mount in the projects folder
%   so that ToolboxToolbox can access IBIOColorDetect from inside the
%   container.

[~, ~, projectsDir] = tbLocateProject('IBIOColorDetect');
[status, result, localScript] = mjsExecuteLocal(job, ...
    'projectsDir', projectsDir, ...
    'javaDir', 'bundled', ...
    'dockerNetwork', '--mac-address="e8:06:88:cb:c5:fe"', ...
    'matlabDir', '/Users/ben/Desktop/linux-matlab/MatlabTree/MATLAB/R2016b');

fprintf('Docker execution had status %d (0 is good.).\n', status);
fprintf('\n');
fprintf('Shell script generated for local machine:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%   We have a Jenkins test server, where we'd like to run this same job for
%   continuous testing of the IBIOColorDetect code.
%
%   The Jenkins server knows how to check out branches of the
%   IBIOColorDetect code from GitHub, into a pre-defined workspace folder.
%
%   We need to mount in the workspace as the projects folder so that
%   ToolboxToolbox can access IBIOColorDetect from inside the container.

jenkinsWorkspace = '/var/lib/jenkins/workspace';
jenkinsScript = mjsWriteDockerRunScript(job, ...
    'javaDir', 'bundled', ...
    'projectsDir', jenkinsWorkspace);

fprintf('Shell script for remote Jenkins server:\n');
system(sprintf('cat "%s"', jenkinsScript));
fprintf('The special line for Jenkins is the one with "-v "/var/lib/jenkins/workspace".\n');


%% Install in Jenkins.
%   The next step would be to copy the Jenkins shell script into a new
%   project on our Jenkins server.  Since the server has Matlab and Docker
%   installed, this script is able to take care of the rest.
