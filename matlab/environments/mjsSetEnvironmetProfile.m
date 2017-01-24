function profile = mjsSetEnvironmetProfile(name, varargin)
% Save a named environment profile with setpref().
%
% profile = mjsSetEnvironmetProfile(name, ...) saves an environment
% profile with the given name, using Matlab's built-in setpref().
%
% An environment profile is a named set of name-value pairs, either listed
% as parameters, or gathered into a struct.  You can create environment
% profiles using this function.  For example:
%
%   % listing parameters
%   mjsSetEnvironmetProfile('mac-book', ...
%       'projectsDir', '/home/me/projects', ...
%       'logDir', '/home/me/logs')
%
%   % using a struct
%   profile.projectsDir = '/home/me/projects';
%   profile.logDir = '/home/me/logs';
%   mjsSetEnvironmetProfile('mac-book', profile)
%
% Once you've created an environment profile with this function, you can
% use it by name, with other MatlabJobSupport functions.  The result will
% be as if you had passed the profile's name-value pairs to the other
% function.  For example:
%
%   mjsExecuteLocal(job, 'profile', 'mac-book')
%
% Using profiles like this should help avoid tedious typing and errors.
% You onlt need to create the profile once, and then you can re-use it by
% name many times.
%
% Profiles also should help with sharing code.  You and your collaborator
% each could create a profile named 'mac-book'.  The values in each of your
% profiles could be specific to your own, personal MacBooks.  But you could
% still share common code that refers to a 'mac-book' profile.
%
% See also mjsGetEnvironmetProfile().
%
% profile = mjsSetEnvironmetProfile(name, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.StructExpand = true;
parser.addRequired('name', @ischar);
parser.parse(name, varargin{:});
name = parser.Results.name;

% ket the parser do the work
profile = parser.Unmatched;

% save the profile
setpref('MatlabJobSupport', name, profile);
