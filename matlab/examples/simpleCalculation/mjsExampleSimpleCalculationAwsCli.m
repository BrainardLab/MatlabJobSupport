% Create a job and Docker run script for a simple calculation, via AWS CLI.
%
% This script will produce a job struct suitable for doing a simple
% calculation.  It will try to execute the job remotely using the Amazon
% Web Services Command Line Interface (aka AWS CLI).
%
% This assumes you have an AWS account set up, and have configured the AWS
% CLI for your local machine.  It also assumes you have a Linux-based
% Amazon Machine Image ready to go, with Matlab and Docker installed.
%
% Setting all that up would be outside the scope of this example.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

clear;
clc;

%% The job we want to run.
%   Calculate the factors of a big integer.

job = mjsJob( ...
    'name', 'factorBigInt', ...
    'jobCommand', 'factor(intmax(''uint32''))');

fprintf('Here''s the job we just created:\n');
disp(job);


%% Choose AWS credentials and config.
%   This example uses credentials and config that would only work for the
%   members of the Brainard Lab at UPenn -- sorry!  At least, they show you
%   how to call the mjsExecuteAwsCliJob() function.
%
%   The output should look the same as for a local job.  The last message
%   should be "Finished job named "factorBigInt"".

% a Linux-based Amazon Machine Image with Matlab and Docker
amiId = 'ami-16d57076';

% the size/style of the virtual machine to spin up
%   Matlab wants at least 2GB ram -> at least t2.small
instanceType = 't2.small';

% must allow SSH access, and access to Matlab license server, if any
securityGroups = {'default', 'all-ssh'};

% user name to use on the server
user = 'ubuntu';

% private key / identity file for the same user
identity = '/home/ben/aws/bsh-imac-workstation.pem';

% whether to terminate the instance when the job is done
terminate = true;

[status, result, sshScript] = mjsExecuteAwsCli(job, ...
    'amiId', amiId, ...
    'instanceType', instanceType, ...
    'securityGroups', securityGroups, ...
    'user', user, ...
    'identity', identity, ...
    'terminate', terminate, ...
    'dryRun', true);


%% Look at the AWS CLI script that was generated.
%   Let's look at the shell script generated above, by the command
%   mjsExecuteAwsCliJob(job).

fprintf('Generated shell script:\n');
system(sprintf('cat "%s"', sshScript));
