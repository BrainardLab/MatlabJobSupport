function mjsRunJob(job)
% Standard way to execute a job here in matlab.
%
% mjsRunJob(job)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addRequired('job', @(val) isstruct(val) || ischar(val));
parser.parse(job);
job = parser.Results.job;

if ischar(job)
    job = mjsLoadJob(job);
end

printTimestamp('Starting job named "%s"', job.name);


%% Set up.
if job.pwdPath
    pathToAdd = pwd();
    printTimestamp('...adding to path <%s>', pathToAdd);
    tbAddToolboxPath('toolboxPath', pathToAdd);
    printTimestamp('...added to path');
end

if ~isempty(job.tbUseArgs)
    argString = strtrim(evalc('disp(job.tbUseArgs)'));
    printTimestamp('...doing tbUse() with args <%s>', argString);
    tbUse(job.tbUseArgs{:});
    printTimestamp('...did tbUse()');
end

if ~isempty(job.setupCommand)
    doCommand(job.setupCommand, 'setup');
end

%% The job.
if ~isempty(job.jobCommand)
    doCommand(job.jobCommand, 'job');
end

%% Clean Up.
if ~isempty(job.cleanupCommand)
    doCommand(job.cleanupCommand, 'cleanup');
end

printTimestamp('Finished job named "%s"', job.name);


%% Consistent way to fprint with a leading timestamp.
function printTimestamp(messageFormat, varargin)
nowString = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
fprintf(['%s -- ' messageFormat '\n'], nowString, varargin{:});


%% Consistent way to eval() a string or feval() a cell array.
function doCommand(command, name)
if ischar(command)
    printTimestamp('...doing %s command <%s>', name, command);
    eval(command);
    printTimestamp('...did %s command', name);
elseif iscell(command)
    commandString = strtrim(evalc('disp(command)'));
    printTimestamp('...doing %s command <%s>', name, commandString);
    feval(command{:});
    printTimestamp('...did %s command', name);
end