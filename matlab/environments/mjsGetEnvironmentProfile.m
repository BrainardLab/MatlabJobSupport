function profile = mjsGetEnvironmentProfile(name)
% Load a named environment profile with getpref().
%
% profile = mjsGetEnvironmentProfile(name) finds the environment profile
% with the given name, and returns it.  If there is no such profile,
% returns an empty struct.
%
% See mjsSetEnvironmetProfile() for more about environment profiles.
%
% profile = mjsGetEnvironmentProfile(name)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.addRequired('name', @ischar);
parser.parse(name);
name = parser.Results.name;

if ispref('MatlabJobSupport', name)
    profile = getpref('MatlabJobSupport', name);
else
    profile = struct();
end
