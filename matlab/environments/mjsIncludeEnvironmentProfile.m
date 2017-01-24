function arguments = mjsIncludeEnvironmentProfile(varargin)
% Merge the given varargin with a named environment profile, if any.
%
% arguments = mjsIncludeEnvironmentProfile(varargin) scans the given
% varargin for a parameter named 'profile'.  If found, loads the
% environment profile with that name and returns an argument struct
% that includes the profile as well as the given varargin.
%
% If varargin contains no 'profile' parameter, or if the named profile
% isn't found, returns the an argument struct with just the name-value
% pairs from the given varargin.
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
    arguments = parser.Unmatched;
    return;
end

profile = mjsGetEnvironmentProfile(profileName);
if isempty(profile)
    arguments = parser.Unmatched;
    return;
end

%% Merge the profile wiht the given arguments.
parser.parse(profile, varargin{:});
arguments = parser.Unmatched;
