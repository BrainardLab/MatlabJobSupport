% Create a job and AWS run script for RenderToolbox4 validations.
%
% This script will produce a job struct suitable for running RenderToolbox4
% example recipes and validations.
%
% It will produce a shell script suitable for running the job on a
% short-lived AWS instance, via SSH, under control of the local
% workstation.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.

% choose a name for this job and the output bucket
jobDate = datestr(now(), 'yyyy-mm-dd-HH-MM-SS');

job = mjsJob( ...
    'name', 'renderToolboxEpicValidation', ...
    'toolboxCommand', 'tbUse(''RenderToolbox4'');', ...
    'jobCommand', 'rtbRunEpicExamples()');


%% Choose AWS credentials and config.
% "aws" profile holds many boring but necessary parameters.  Try:
%   params = mjsGetEnvironmentProfile('aws')

% use a biggish instance type
instanceType = 'm4.large';

% where to put the output on the AWS instance
outputDir = ['/home/ubuntu/' job.name];

% copy all the output to S3
bucketPath = ['s3://render-toolbox-reference/all-example-scenes/' jobDate];
hostCleanupCommand = sprintf('aws s3 cp "%s" "%s" --recursive --region us-west-2', ...
    outputDir, ...
    bucketPath);

[status, result, awsCliScriptFile] = mjsExecuteAwsCli(job, ...
    'profile', 'aws', ...
    'dockerImage', 'ninjaben/mjs-rtb:latest', ...
    'mountDockerSocket', true, ...a
    'instanceType', instanceType, ...
    'outputDir', outputDir, ...
    'hostCleanupCommand', hostCleanupCommand, ...
    'dryRun', true);

fprintf('Generated AWS CLI script:\n');
system(sprintf('cat "%s"', awsCliScriptFile));
