function [status, result, scriptFile] = mjsExecuteLocal(job, varargin)
% Turn a job into a Docker shell script, execute it locally, immediately.
%
% [status, result, scriptFile] = mjsExecuteLocal(job) causes the given
% job struct to be executed locally, in a Docker container.  Returns the
% execution status code and result.  Also returns the path to the script
% file that was generated.
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
