function job = mjsLoadJob(jobFile)
% Read a job from disk.
%
% job = mjsLoadJob(jobFile) reads a job struct from disk from the given
% jobFile.
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addRequired('jobFile', @ischar);
parser.parse(jobFile);
jobFile = parser.Results.jobFile;

job = loadjson(jobFile);
