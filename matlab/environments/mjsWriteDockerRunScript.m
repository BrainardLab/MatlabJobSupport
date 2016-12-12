function scriptFile = mjsWriteDockerRunScript(varargin)
% Write a shell script that will invoke a given job in Docker.
%
% This saves us from having to write lots of Docker syntax by hand.  This
% assumes we're working with the conventions established in the Docker
% image ninjaben/mjs-base.
%
% It should be the case that you can copy the generated scriptFile and
% jobFile to another host and run them.  The host must have Matlab
% and Docker installed.  The rest should "just work".  At least, that is
% the goal.
%
% scriptFile = mjsWriteDockerRunScript(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addParameter('job', [], @(val) isempty(val) || isstruct(val));
parser.addParameter('scriptFile', '', @ischar);
parser.addParameter('jobFile', fullfile(tempdir(), 'mjs', 'job.json'), @ischar);
parser.addParameter('dockerImage', 'ninjaben/mjs-base', @ischar);
parser.addParameter('dockerOptions', '--rm --net=host', @ischar);
parser.addParameter('toolboxToolboxDir', '', @ischar);
parser.addParameter('toolboxesDir', '', @ischar);
parser.addParameter('toolboxHooksDir', '', @ischar);
parser.addParameter('matlabDir', '', @ischar);
parser.addParameter('logDir', '', @ischar);
parser.addParameter('commonToolboxDir', '', @ischar);
parser.addParameter('workingDir', fullfile(tempdir(), 'mjs'), @ischar);
parser.parse(varargin{:});
job = parser.Results.job;
scriptFile = parser.Results.scriptFile;
jobFile = parser.Results.jobFile;
dockerImage = parser.Results.dockerImage;
dockerOptions = parser.Results.dockerOptions;
toolboxToolboxDir = parser.Results.toolboxToolboxDir;
toolboxesDir = parser.Results.toolboxesDir;
toolboxHooksDir = parser.Results.toolboxHooksDir;
matlabDir = parser.Results.matlabDir;
logDir = parser.Results.logDir;
commonToolboxDir = parser.Results.commonToolboxDir;
workingDir = parser.Results.workingDir;

% optionally save the given job at the given jobFile
if ~isempty(job)
    mjsSaveJob(job, jobFile);
end

% default script name based on job name
if isempty(scriptFile)
    [jobPath, jobBase] = fileparts(jobFile);
    scriptFile = fullfile(jobPath, [jobBase '.sh']);
end

%% Make sure script dir exists.
scriptDir = fileparts(scriptFile);
if ~isempty(scriptDir) && 7 ~= exist(scriptDir, 'dir')
    mkdir(scriptDir);
end

fid = fopen(scriptFile, 'w');
if -1 == fid
    error('mjsWriteDockerRunScript:fopen', ...
        'Could not open file <%s> for writing.', scriptFile);
end

try
    %% Shebang for predictable environment.
    fprintf(fid, '#!/bin/sh\n');
    
    %% Find Matlab in the execution environment.
    if isempty(matlabDir)
        fprintf(fid, 'MATLAB_LINK="$(which matlab)"\n');
        fprintf(fid, 'MATLAB_EXECUTABLE="$(readlink -f "$MATLAB_LINK")"\n');
        fprintf(fid, 'MATLAB_BIN_DIR="$(dirname "$MATLAB_EXECUTABLE")"\n');
        fprintf(fid, 'MATLAB_DIR="$(dirname "$MATLAB_BIN_DIR")"\n');
    else
        fprintf(fid, 'MATLAB_DIR="%s"\n', matlabDir);
    end
    
    %% Do docker run with options and job command.
    fprintf(fid, 'docker run %s \\\n', dockerOptions);
    fprintf(fid, '-v "$MATLAB_DIR":/usr/local/MATLAB/from-host \\\n');
    
    if ~isempty(toolboxToolboxDir)
        fprintf(fid, '-v "%s":/mjs/ToolboxToolbox \\\n', toolboxToolboxDir);
    end
    
    if ~isempty(toolboxesDir)
        fprintf(fid, '-v "%s":/mjs/toolboxes \\\n', toolboxesDir);
    end
    
    if ~isempty(toolboxHooksDir)
        fprintf(fid, '-v "%s":/mjs/toolboxHooks \\\n', toolboxHooksDir);
    end
    
    if ~isempty(logDir)
        fprintf(fid, '-v "%s":/var/log/matlab \\\n', logDir);
    end
    
    if ~isempty(commonToolboxDir)
        fprintf(fid, '-v "%s":/opt/toolboxes \\\n', commonToolboxDir);
    end
    
    if isempty(workingDir)
        % working dir private in container
        fprintf(fid, '-e "WORKING_DIR=/var/mjs/working" \\\n');
    else
        % custom working dir mapped to host
        fprintf(fid, '-e "WORKING_DIR=%s" \\\n', workingDir);
        fprintf(fid, '-v "%s":"%s" \\\n', workingDir, workingDir);
    end
    
    fprintf(fid, '%s \\\n', dockerImage);
    fprintf(fid, '-r "mjsRunJobAndExit(''%s'');"\n', jobFile);
    
    
    fprintf(fid, '\n');
    
    fclose(fid);
    
catch err
    fclose(fid);
    rethrow(err);
end

system(['chmod +x ' scriptFile]);
