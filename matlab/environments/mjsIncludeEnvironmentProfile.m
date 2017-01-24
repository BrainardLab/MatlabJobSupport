function arguments = mjsIncludeEnvironmentProfile(varargin)
% Merge the given varargin with a named environment profile, if any.
%
% arguments = mjsIncludeEnvironmentProfile(varargin) scans the given
% varargin for a parameter named 'profile'.  If found, loads the
% environment profile with that name and returns an updated argument list
% that includes the profile as well as the given varargin.
%
% If varargin contains no 'profile' parameter, or if the named profile
% isn't found, returns varargin as-is.
%
% arguments = mjsIncludeEnvironmentProfile(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.StructExpand = true;
parser.addParameter('profile', '', @ischar);
parser.parse(varargin{:});
profileName = parser.Results.profile;

%% Check for a named profile.
if isempty(profileName)
    arguments = varargin;
    return;
end

profile = mjsGetEnvironmentProfile(profileName);
if isempty(profile)
    arguments = varargin;
    return;
end

%% Merge the profile wiht the given arguments.
parser.parse(profile, varargin{:});
arguments = parser.Unmatched;
