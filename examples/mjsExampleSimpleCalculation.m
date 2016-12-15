% Create a job and Docker run script for a simple calculation.
%
% This script will produce a job struct suitable for doing a simple
% calculation.
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
%   Calculate the factors of a big integer.

job = mjsJob( ...
    'name', 'factorBigInt', ...
    'jobCommand', 'factor(intmax(''uint32''))');

fprintf('Here''s the job we just created:\n');
disp(job);


%% Run the job directly here in this Matlab process.
%   This will evaluate the command in the job struct and print log
%   messages.
%   It may take a few seconds.
%   The last message should be "Finished job named "factorBigInt"".

mjsRunJob(job);


%% Run the job in a Docker container on this machine.
%   This will generate a shell script to invoke Docker with Matlab and this
%   job.  It will invoke the shell script, thus executing the job in a
%   separate process.
%
%   You may see some red text scroll by, which looks like an error.  But
%   this is normal.  It happens because we mount Matlab from this host
%   machine, into the Docker container.  So Matlab is initially confused by
%   its new environment.

[status, result, localScript] = mjsExecuteLocal(job);

fprintf('Docker execution had status %d (0 is good.).\n', status);


%% Look at the script that was generated.
%   Let's look at the shell script generated above, by the command
%   mjsExecuteLocal(job).

fprintf('Generated shell script:\n');
system(sprintf('cat "%s"', localScript));

% The first line contains a JSON representation of the job struct.
%
% The next four lines locate the Matlab installation on the host.
%
% The last lines invoke Docker to run the job.  This has several parts:
%   - "--net=host" makes the container's network look like the host, so the Matlab license works
%   - mount the Matlab installation from the host into the container
%   - specify input, output, and working directories -- in this case the defaults
%   - use the base MatlabJobSupport Docker image, ninjaben/mjs-base
%   - invoke matlab with the function mjsRunJobAndExit(), and the JSON job representation
%
% All of these generated commands can be customized by passing parameters
% to mjsExecuteLocal().  For example, 'inputDir' and 'outputDir' can by
% specified in order share directories from the host with the container.
%
% See also mjsWriteDockerRunScript(), which generates a shell script but
% doesn't actually run it.  This is a good way to pack up a job for
% execution on another machine.
