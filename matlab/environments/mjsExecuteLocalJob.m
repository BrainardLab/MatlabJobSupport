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

% write job file to working folder on host
workingJobFile = fullfile(workingDir, [job.name '.json']);
mjsSaveJob(job, workingJobFile);

% invoke the job file from the working folder in the container
scriptFile = mjsWriteDockerRunScript(varargin{:}, 'jobFile', workingJobFile);

scriptPath = fileparts(scriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' scriptFile], '-echo');
else
    [status, result] = system(scriptFile, '-echo');
end
