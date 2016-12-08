function mjsSaveJob(job, jobFile)
% Write a job to disk.
%
% mjsSaveJob(job, jobFile) writes the given job struct to disk at the
% given jobFile.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addRequired('job', @isstruct);
parser.addRequired('jobFile', @ischar);
parser.parse(job, jobFile);
job = parser.Results.job;
jobFile = parser.Results.jobFile;

savejson('', job, jobFile);
