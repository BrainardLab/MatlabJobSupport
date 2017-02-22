% Create a job and Docker run script for a simple calculation, via AWS CLI.
%
% This script will produce a job struct suitable for doing a simple
% calculation.  It will try to execute the job remotely using the Amazon
% Web Services Command Line Interface (aka AWS CLI).
%  https://github.com/BrainardLab/MatlabJobSupport/wiki/AWS-Workstation-Setup
%
% This assumes you have an AWS account set up, and have configured the AWS
% CLI for your local machine.  You local machine must also have the jq
% utility installed, for parsing JSON.
%  https://stedolan.github.io/jq/
%
% This also assumes you have a Linux-based Amazon Machine Image ready to
% go, with the following already installed:
%   - Docker
%   - Matlab
%
% These jobs use Docker, SSH, and AWS.  Configuring all these takes a bunch
% of parameters.  See the "aws" profile created in
% mjsLocalConfigTemplate(), or your ToolboxToolbox local hook,
% MatlabJobSupportLocalHook.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   Calculate the factors of a big integer.

job = mjsJob( ...
    'name', 'factorBigInt', ...
    'jobCommand', 'factor(intmax(''uint32''))');

%% Choose AWS credentials and config.
% "aws" profile holds many boring but necessary parameters.  Try:
%   mjsGetEnvironmentProfile('aws')
%
% Although this is a simple, fast calculation, it will take a few minuts
% for the AWS instance to start.  In production, AWS should only be used
% for big jobs that take longer than a few minutes.

[status, result, awsCliScriptFile] = mjsExecuteAwsCli(job, ...
    'profile', 'aws', ...
    'dryRun', true);

fprintf('Generated AWS CLI script:\n');
system(sprintf('cat "%s"', awsCliScriptFile));
