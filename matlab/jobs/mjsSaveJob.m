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

%% Can't serialize function handles to json.
job.setupCommand = commandFunctionToString(job.setupCommand);
job.jobCommand = commandFunctionToString(job.jobCommand);
job.cleanupCommand = commandFunctionToString(job.cleanupCommand);

%% Make sure target dir exists.
jobDir = fileparts(jobFile);
if ~isempty(jobDir) && 7 ~= exist(jobDir, 'dir')
    mkdir(jobDir);
end

savejson('', job, jobFile);


%% Try to convert function_handle command to equivalent strings.
function command = commandFunctionToString(command)

if iscell(command) && ~isempty(command) && isa(command{1}, 'function_handle')
    command{1} = func2str(command{1});
end
