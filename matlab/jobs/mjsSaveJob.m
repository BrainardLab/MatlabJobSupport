function jobJson = mjsSaveJob(job, varargin)
% Write a job to disk.
%
% jobJson = mjsSaveJob(job) reutrns a JSON string equivalent to the given
% job struct.
%
% jobJson = mjsSaveJob(job, 'jobFile', jobFile) also writes the JSON string
% to disk at the given jobFile.
%
% jobJson = mjsSaveJob(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addRequired('job', @isstruct);
parser.addParameter('jobFile', '', @ischar);
parser.parse(job, varargin{:});
job = parser.Results.job;
jobFile = parser.Results.jobFile;


%% Make sure target dir exists.
jobDir = fileparts(jobFile);
if ~isempty(jobDir) && 7 ~= exist(jobDir, 'dir')
    mkdir(jobDir);
end

jobJson = savejson('', job, jobFile);
