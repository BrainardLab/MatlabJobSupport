function [status, result, jobScriptFile, awsScriptFile] = mjsExecuteAwsCli(job, varargin)
% Turn a job into a Docker/SSH/AWS CLI shell script, execute it immediately.
%
% [status, result, scriptFile] = mjsExecuteAwsCli(job) causes the given
% job struct to be executed remotely, in a Docker container, via SSH and
% the Amazon Web Services Command Line Interface, aka AWS CLI.  A new,
% temporary Amazon EC2 instance will be created for the duration of the
% job.  Returns the execution status code and result.  Also returns the
% path to the script files that were generated.
%
% mjsExecuteAwsCli( ... 'amiId', amiId) specify id of the Amazon Machine
% Image to use for the new EC2 instance.  The AMI should have Docker and
% Matlab already installed.
%
% mjsExecuteAwsCli( ... 'instanceType', instanceType) specify the instance
% type to create.  For Matlab, use at least t2.small, or at least 2GB of
% memory.
%
% mjsExecuteAwsCli( ... 'securityGroups', securityGroups) name of security
% groups that allow SSH access from here, as well as access to any Matlab
% license server that's required.
%
% mjsExecuteAwsCli( ... 'terminate', terminate) specify whether to
% terminate the instance after the job fails or completes.  The default is
% true -- do terminate the instance.
%
% mjsExecuteAwsCli( ... 'iamProfile', iamProfile) configure an "IAM"
% profile for the instance to use.  This an optional way to give the
% instance access to other AWS resources, like S3.
%
% mjsExecuteAwsCli( ... 'name', value ...) pass additional parameters to
% specify how the shell script will configure the container.  For details,
% see mjsExecuteSsh and mjsWriteDockerRunScript(), which share parameters
% with this function.
%
% [status, result, scriptFile] = mjsExecuteAwsCli(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.addParameter('amiId', '', @ischar);
parser.addParameter('instanceType', 't2.small', @ischar);
parser.addParameter('securityGroups', {'default'}, @iscellstr);
parser.addParameter('terminate', true, @islogical);
parser.addParameter('iamProfile', '', @ischar);
parser.parse(job, varargin{:});
job = parser.Results.job;
amiId = parser.Results.amiId;
instanceType = parser.Results.instanceType;
securityGroups = parser.Results.securityGroups;
terminate = parser.Results.terminate;
iamProfile = parser.Results.iamProfile;

% I want this to compose mjsExecuteSsh
% So mjsExecuteSsh should produce a shell script I can re-use use, instead
% of calling system directly.
%
% Then, do I suck that script into a single bigger script?  That would be
% better for cut and paste of jobs.  Or, do I just call that script from
% this new script.  That seems cleaner.  In that case, try to put scripts
% in one folder and zip them up?  That's reasonably transportable, as long
% as the scripts are mutually-contained.
%
% Either way, local, ssh, and awscli should all have two parts: script
% generation vs script execution.  Or just script generation, and one
% separate function to execute the last script.
