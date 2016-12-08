function scriptFile = mjsWriteDockerRunScript(varargin)
% Write a shell script that will invoke a given job in Docker.
%
% This saves us from having to write lots of Docker syntax by hand.  This
% assumes we're working with the conventions established in the Docker
% image ninjaben/mjs-base.
%
% scriptFile = mjsWriteDockerRunScript(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addParameter('scriptFile', 'job.sh', @ischar);
parser.addParameter('jobFile', 'job.json', @ischar);
parser.addParameter('dockerImage', 'ninjaben/mjs-base', @ischar);
parser.addParameter('dockerOptions', '--rm --net=host', @ischar);
parser.addParameter('matlabDir', '', @ischar);
parser.addParameter('logDir', '', @ischar);
parser.addParameter('commonToolboxDir', '', @ischar);
parser.addParameter('workingFolder', '', @ischar);
parser.parse(varargin{:});
scriptFile = parser.Results.scriptFile;
jobFile = parser.Results.jobFile;
dockerImage = parser.Results.dockerImage;
dockerOptions = parser.Results.dockerOptions;
matlabDir = parser.Results.matlabDir;
logDir = parser.Results.logDir;
commonToolboxDir = parser.Results.commonToolboxDir;
workingFolder = parser.Results.workingFolder;


fid = fopen(scriptFile, 'w');
if -1 == fid
    error('mjsWriteDockerRunScript:fopen', ...
        'Could not open file <%s> for writing.', scriptFile);
end

try
    %% Shebang for predictable environment.
    fprintf(fid, '#! /bin/sh\n');
    
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
    
    if ~isempty(logDir)
        fprintf(fid, '-v "%s":/var/log/matlab \\\n', logDir);
    end
    
    if ~isempty(commonToolboxDir)
        fprintf(fid, '-v "%s":/opt/toolboxes \\\n', commonToolboxDir);
    end
    
    if ~isempty(workingFolder)
        fprintf(fid, '-v "$WORKING_DIR":/var/mjs/working \\\n');
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
