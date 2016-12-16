function [status, result, sshScriptFile] = mjsExecuteSsh(job, varargin)
% Turn a job into a Docker/SSH shell script, execute it immediately.
%
% [status, result, scriptFile] = mjsExecuteSsh(job) causes the given
% job struct to be executed remotely, via SSH, in a Docker container.
% Returns the execution status code and result.  Also returns the path to
% the script file that was generated.
%
% mjsExecuteSsh( ... 'name', value ...) pass additional parameters to
% specify how the shell script will configure the container.  For details,
% see mjsWriteSshScript() and mjsWriteDockerRunScript(), which share
% parameters with this funciton.
%
% [status, result, scriptFile] = mjsExecuteSsh(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.addParameter('dockerScriptFile', '', @ischar);
parser.parse(job, varargin{:});
job = parser.Results.job;
dockerScriptFile = parser.Results.dockerScriptFile;

if isempty(dockerScriptFile)
    % write a script that contains the job
    dockerScriptFile = mjsWriteDockerRunScript(job, varargin{:});
end

% write a script that sends the first script out over SSH
sshScriptFile = mjsWriteSshScript(job, varargin{:}, ...
    'dockerScriptFile', dockerScriptFile);

% execute the script we just wrote
scriptPath = fileparts(sshScriptFile);
if isempty(scriptPath)
    [status, result] = system(['./' sshScriptFile], '-echo');
else
    [status, result] = system(sshScriptFile, '-echo');
end
