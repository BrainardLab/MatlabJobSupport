function [status, result, sshScriptFile, jobScriptFile] = mjsExecuteSsh(job, varargin)
% Turn a job into a Docker/SSH shell script, execute it immediately.
%
% [status, result, scriptFile] = mjsExecuteSsh(job) causes the given
% job struct to be executed remotely, via SSH, in a Docker container.
% Returns the execution status code and result.  Also returns the path to
% the script file that was generated.
%
% mjsExecuteSsh( ... 'jobScriptFile', jobScriptFile) specify an
% existing script file to run on the remote host.  The default is to
% generate a new script based on the given job.
%
% mjsExecuteSsh( ... 'dryRun', dryRun) specify whether to skip actual job
% execution, after generating the job scripts.  The default is false, go
% ahead and execute the job.
%
% mjsExecuteSsh( ... 'name', value ...) pass additional parameters to
% specify how the shell script will configure the container.  For details,
% see mjsWriteSshScript() and mjsWriteDockerRunScript(), which share
% parameters with this funciton.
%
% [status, result, sshScriptFile, jobScriptFile] = mjsExecuteSsh(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

arguments = mjsIncludeEnvironmentProfile(varargin{:});

parser = inputParser();
parser.KeepUnmatched = true;
parser.StructExpand = true;
parser.addRequired('job', @isstruct);
parser.addParameter('jobScriptFile', '', @ischar);
parser.addParameter('dryRun', false, @islogical);
parser.parse(job, arguments{:});
job = parser.Results.job;
jobScriptFile = parser.Results.jobScriptFile;
dryRun = parser.Results.dryRun;

if isempty(jobScriptFile)
    % write a script that contains the job and invokes it in Docker
    jobScriptFile = mjsWriteDockerRunScript(job, arguments{:});
end

% write a script that sends the first script out over SSH
sshScriptFile = mjsWriteSshScript(jobScriptFile, arguments{:});

if dryRun
    status = 0;
    result = 'dry run';
    return;
end

% execute the script we just wrote
scriptPath = fileparts(sshScriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' sshScriptFile], '-echo');
else
    [status, result] = system(sshScriptFile, '-echo');
end
