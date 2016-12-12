function [status, result] = mjsExecuteLocalJob(job, varargin)
% Turn a job into a Docker shell script, execute it locally, immediately.
%
% [status, result] = mjsExecuteLocalJob(job) causes the given job struct to
% be executed locally, in a Docker container.
%
% mjsExecuteLocalJob( ... 'name', value ...) pass additional arguments to
% configure how the container will be configured.  See
% mjsWriteDockerRunScript() for details.
%
% [status, result] = mjsExecuteLocalJob(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.parse(job, varargin{:});
job = parser.Results.job;

% write a script that contains the whole job
scriptFile = mjsWriteDockerRunScript(job, varargin{:});

% execute the script we just wrote
scriptPath = fileparts(scriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' scriptFile], '-echo');
else
    [status, result] = system(scriptFile, '-echo');
end
