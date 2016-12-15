% Create a job and Docker run script for a simple calculation, via ssh.
%
% This script will produce a job struct suitable for doing a simple
% calculation.  It will try to execute the job remotely, via SSH.
%
% This assumes you have a Linux server running somewhere with Matlab and
% Docker installed, and you have SSH credentials to connect to it.
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


%% Choose SSH credentials.
%   This example uses credentials that would only work for the developer --
%   sorry!  At least, they show you how to call the mjsExecuteSsh()
%   function.
%
%   The output should look the same as for a local job.  The last message
%   should be "Finished job named "factorBigInt"".

% address or hostname of the remote job server
host = 'ec2-35-164-119-122.us-west-2.compute.amazonaws.com';

% user name to use on the server
user = 'ubuntu';

% private key / identity file for the same user
identity = '/home/ben/aws/bsh-imac-workstation.pem';

[status, result, sshScript] = mjsExecuteSsh(job, ...
    'host', host, ...
    'user', user, ...
    'identity', identity);
