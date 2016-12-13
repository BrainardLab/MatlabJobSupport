function job = mjsJob(varargin)
% Create a standard data structure that represents a Matlab job.
%
% job = mjsJob(varargin) creates a data structure with a standard format
% for representing a Matlab job to be run later.  This allows us to declare
% a job or calculation that we want to run in terms of the command itself
% and required dependenceis and resources.
%
% Once declared, we can then transmit and execute the job in some suitable
% environment, like a compute cluster, AWS, Google, etc.  But the details
% of where the job will be run are out of scope here.  The goal here is an
% abstract job declaration that could be executed in any of those
% environments.
%
% Here are the expected fields.  Any of them can be omitted or set to an
% empty value, to accept whatever defaults are in the execution
% environment.
%   - name -- any handy name for the job
%   - tbUseArgs -- arguments to pass to ToolboxToolbox tbUse()
%   - setupCommand -- command to run after tbUse() and before jobCommand
%   - jobCommand -- job or computation command to run
%   - cleanupCommand -- command to run after jobCommand
%   - diskGB -- estimated minimum storage required to complete job
%   - memoryGB -- estimated minimum memory required to complete job
%
% setupCommand, jobCommand, and cleanupCommand are all things that we want
% to "run".  For strings, this means pass the string to eval().  For cell
% arrays, this means pass the elements of the cell array to feval().
%
% job = mjsJob(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.CaseSensitive = true;
parser.PartialMatching = true;
parser.KeepUnmatched = true;
parser.addParameter('name', 'job', @ischar);
parser.addParameter('tbUseArgs', {}, @iscell);
parser.addParameter('setupCommand', '', @(val) ischar(val) || iscell(val));
parser.addParameter('jobCommand', '', @(val) ischar(val) || iscell(val));
parser.addParameter('cleanupCommand', '', @(val) ischar(val) || iscell(val));
parser.addParameter('diskGB', [], @isnumeric);
parser.addParameter('memoryGB', [], @isnumeric);
parser.parse(varargin{:});

% let the parser to the work
job = parser.Results;
