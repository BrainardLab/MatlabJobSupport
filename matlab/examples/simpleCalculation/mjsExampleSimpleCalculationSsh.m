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

% local file where we can auto-accept remote ssh key
knownHostsFile = '/home/ben/.ssh/known_hosts';

[status, result, sshScript] = mjsExecuteSsh(job, ...
    'host', host, ...
    'user', user, ...
    'identity', identity, ...
    'knownHostsFile', knownHostsFile);


%% Look at the SSH script that was generated.
%   Let's look at the shell script generated above, by the command
%   mjsExecuteSsh(job).

fprintf('Generated shell script:\n');
system(sprintf('cat "%s"', sshScript));

% The first line attempts to auto-accept the public SSH key from the remote
% host.  This avoids a user prompt to type "yes".
%
% The last few lines connect to the remote host via SSH and send in the
% command that we want to execute using the shell's "<" redirect operator.
% The file that we send in is a "docker run" script generated for the same
% job, using mjsWriteDockerRunScript().
