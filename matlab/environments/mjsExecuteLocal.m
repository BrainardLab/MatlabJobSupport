function [status, result, scriptFile] = mjsExecuteLocal(job, varargin)
% Turn a job into a Docker shell script, execute it locally, immediately.
%
% [status, result, scriptFile] = mjsExecuteLocal(job) causes the given
% job struct to be executed locally, in a Docker container.  Returns the
% execution status code and result.  Also returns the path to the script
% file that was generated.
%
% mjsExecuteLocal( ... 'dryRun', dryRun) specify whether to skip actual job
% execution, after generating the job script.  The default is false, go
% ahead and execute the job.
%
% mjsExecuteLocal( ... 'name', value ...) pass additional parameters to
% specify how the shell script will configure the container.  For details,
% see mjsWriteDockerRunScript(), which takes the same parameters.
%
% [status, result, scriptFile] = mjsExecuteLocal(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.addParameter('dryRun', false, @islogical);
parser.parse(job, varargin{:});
job = parser.Results.job;
dryRun = parser.Results.dryRun;

% write a script that contains the whole job
scriptFile = mjsWriteDockerRunScript(job, varargin{:});

if dryRun
    status = 0;
    result = 'dry run';
    return;
end

% execute the script we just wrote
scriptPath = fileparts(scriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' scriptFile], '-echo');
else
    [status, result] = system(scriptFile, '-echo');
end
