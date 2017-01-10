function [status, result, awsCliScriptFile, jobScriptFile] = mjsExecuteAwsCli(job, varargin)
% Turn a job into a Docker/SSH/AWS CLI shell script, execute it immediately.
%
% [status, result, scriptFile] = mjsExecuteAwsCli(job) causes the given
% job struct to be executed remotely, in a Docker container, via SSH and
% the Amazon Web Services Command Line Interface, aka AWS CLI.  A new,
% temporary Amazon EC2 instance will be created for the duration of the
% job.  Returns the execution status code and result.  Also returns the
% path to the script files that were generated.
%
% mjsExecuteAwsCli( ... 'jobScriptFile', jobScriptFile) specify an
% existing script file to run on the remote host.  The default is to
% generate a new script based on the given job.
%
% mjsExecuteAwsCli( ... 'dryRun', dryRun) specify whether to skip actual
% job execution, after generating the job scripts.  The default is false,
% go ahead and execute the job.
%
% mjsExecuteAwsCli( ... 'name', value ...) pass additional parameters to
% specify how the shell script will configure the container.  For details,
% see mjsWriteSshScript() and mjsWriteDockerRunScript(), which share
% parameters with this function.
%
% [status, result, awsCliScriptFile, jobScriptFile] = mjsExecuteAwsCli(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.addParameter('jobScriptFile', '', @ischar);
parser.addParameter('dryRun', false, @islogical);
parser.parse(job, varargin{:});
job = parser.Results.job;
jobScriptFile = parser.Results.jobScriptFile;
dryRun = parser.Results.dryRun;

if isempty(jobScriptFile)
    % write a script that contains the job and invokes it in Docker
    jobScriptFile = mjsWriteDockerRunScript(job, varargin{:});
end

% write a script that sends the first script out over AWS CLI and SSH
awsCliScriptFile = mjsWriteAwsCliScript(jobScriptFile, ...
    varargin{:}, ...
    'diskGB', job.diskGB);

if dryRun
    status = 0;
    result = 'dry run';
    return;
end

% execute the script we just wrote
scriptPath = fileparts(awsCliScriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' awsCliScriptFile], '-echo');
else
    [status, result] = system(awsCliScriptFile, '-echo');
end
