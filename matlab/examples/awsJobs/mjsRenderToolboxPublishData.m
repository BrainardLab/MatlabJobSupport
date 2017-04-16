% Create a job and AWS run script for publishing RenderToolbox4 data.
%
% This script will produce a job struct suitable for publishing
% RenderToolbox reference data to the brainard-archiva archive.
%   http://52.32.77.154/
%
% It will produce a shell script suitable for running the job on a
% short-lived AWS instance, via SSH, under control of the local
% workstation.
%
% The general flow of things is like this:
%   - mjsRenderToolboxEpicExamples.m runs RenderToolbox examples and stores
%   outputs on S3
%   - mjsRenderToolboxPublishData.m gets the outputs from S3, zips each
%   example, and publishes to brainard-archiva via RemoteDataToolbox
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% Get "write" credentials for brainard-archivs.

% tbUse('RenderToolbox4')
rdtConfig = rdtCredentialsDialog(rdtConfiguration('render-toolbox'));


%% The job we want to run.

% choose a data set by its name, which is the date when it was run
jobDate = '2017-02-22-16-47-00';

jobCommand = sprintf('rtbPublishReferenceData(''dryRun'', false, ''referenceVersion'', ''%s'', ''rdtUsername'', ''%s'', ''rdtPassword'', ''%s'')', ...
    jobDate, ...
    rdtConfig.username, ...
    rdtConfig.password);

job = mjsJob( ...
    'name', 'renderToolboxPublishData', ...
    'toolboxCommand', 'tbUse(''RenderToolbox4'');', ...
    'jobCommand', jobCommand);


%% Choose AWS credentials and config.
% "aws" profile holds many boring but necessary parameters.  Try:
%   params = mjsGetEnvironmentProfile('aws')

% where to put data from S3 on the EC2 instance
dataDir = '/home/ubuntu/rtb-reference';

% copy reference data from S3 before starting the job
bucketPath = ['s3://render-toolbox-reference/all-example-scenes/' jobDate];
hostSetupCommand = sprintf('aws s3 cp "%s" "%s" --recursive --region us-west-2', ...
    bucketPath, ...
    dataDir);

[status, result, awsCliScriptFile] = mjsExecuteAwsCli(job, ...
    'profile', 'aws', ...
    'dockerImage', 'brainardlab/mjs-rtb:latest', ...
    'mountDockerSocket', true, ...
    'outputDir', dataDir, ...
    'hostSetupCommand', hostSetupCommand, ...
    'dryRun', true);
