% Create a job and Docker run script for testing the ToolboxToolbox.
%
% This script will produce a job struct suitable for running all the unit
% tests for the ToolboxToolbox.
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
%   First, cd to the folder that contains the ToolboxToolbox tests.
%   Then invoke the test runner function.

job = mjsJob( ...
    'name', 'testToolboxToolbox', ...
    'setupCommand', 'cd(fileparts(which(''tbAssertTestsPass'')))', ...
    'jobCommand', 'tbAssertTestsPass');

fprintf('Here''s the job we just created:\n');
disp(job);


%% Run the job directly here in this Matlab process.
%   This will eval() the commands in the job struct and print log messages.
%   It may take 1-2 minutes.
%   The last message should be "Finished job named "testToolboxToolbox"".

mjsRunJob(job);


%% Run the job in a Docker container on this machine.
%   This will generate a shell script to invoke Matlab with this job, in a
%   separate Docker process.  It handles lots of shell and Docker syntax
%   for us.
%   Again, it may take 1-2 minutes.
%
%   You may see some red text scroll by, which looks like an error.  But
%   this is normal while the ToolboxToolbox configures Matlab inside the
%   Docker container.  It happens because we mount Matlab from this
%   machine, into the Docker container.  So Matlab is initially confused by
%   the new environment.

[status, result, localScript] = mjsExecuteLocalJob(job);
fprintf('Docker execution had status %d (0 is good.).\n', status);

fprintf('Shell script generated for local machine:\n');
system(sprintf('cat "%s"', localScript));


%% Generate a shell script to be run on a remote Jenkins server.
%   We have a Jenkins test server, where we'd like to run this same job for
%   continuous testing of the ToolboxToolbox code.
%
%   The Jenkins server knows how to check out branches of the
%   ToolboxToolbox code from GitHub, into a folder called the WORKSPACE.
%
%   We want to run the tests on the WORKSPACE version of ToolboxToolbox,
%   rather than the default version that comes with our Docker image.  So
%   we need to generate a shell script that mounts the WORKSPACE into the
%   Docker container at the right place.  We can do this by specifying a
%   value for the container's 'toolboxToolboxDir'.

jenkinsScript = mjsWriteDockerRunScript(job, ...
    'toolboxToolboxDir', '$WORKSPACE');

fprintf('Shell script for remote Jenkins server:\n');
system(sprintf('cat "%s"', jenkinsScript));
fprintf('The special line for Jenkins is the one with "$WORKSPACE".\n');



%% Install in Jenkins.
%   The next step would be to copy the Jenkins shell script into a new
%   project on our Jenkins server.  Since the server has matlab and Docker
%   installed, this script is able to take care of the rest.
%
%   What's cool about this is we can create the job locally and test it
%   in Docker locally.  Then when we ship the job off to Jenkins, Docker
%   gives us confidence that the job will run the same there as it did
%   here.
%
%   Also, we don't have to install or configure anything special on the
%   Jenkins server in order to run this job -- just Matlab and Docker, and
%   the generated script takes care of the rest.
