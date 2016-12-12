function [status, result] = mjsExecuteLocalJob(job, varargin)
% Pack up a job for Docker execution, execute it locally immediately.
%
% scriptFile = mjsWriteDockerRunScript(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.addParameter('workingDir', fullfile(tempdir(), 'mjs'), @ischar);
parser.parse(job, varargin{:});
job = parser.Results.job;
workingDir = parser.Results.workingDir;

% write the job, and a script that will run the job
workingJobFile = fullfile(workingDir, [job.name '.json']);
scriptFile = mjsWriteDockerRunScript(varargin{:}, ...
    'job', job, ...
    'jobFile', workingJobFile);

% execute the script we just wrote
scriptPath = fileparts(scriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' scriptFile], '-echo');
else
    [status, result] = system(scriptFile, '-echo');
end
