function mjsExecuteLocalJob(job, varargin)
% Pack up a job for Docker execution, execute it locally immediately.
%
% scriptFile = mjsWriteDockerRunScript(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addRequired('job', @isstruct);
parser.addParameter('jobFile', 'job.json', @ischar);
parser.parse(job, varargin{:});
job = parser.Results.job;
jobFile = parser.Results.jobFile;

mjsSaveJob(job, jobFile);
scriptFile = mjsWriteDockerRunScript(varargin{:});

scriptPath = fileparts(scriptFile);
if isempty(scriptPath)
    system(['./' scriptFile], '-echo');
else
    system(scriptFile, '-echo');
end
