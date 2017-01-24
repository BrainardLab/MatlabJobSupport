function mjsLocalConfigTemplate()
%% Template for setting up MatlabJobSupport configuration.
%
% If you are using ToolboxToolbox, this template will become your local
% hook for MatlabJobSupport.  You should find it in your localHooksFolder
% and edit it.  It should be named "MatlabJobSupportLocalHook.m"
%
% If you are not using Toolbox Toolbox, you should copy this script to some
% place outside of the MatlabJobSupport repository.  You should edit your
% copy with any local confuguration that you need.  You should run your
% copy whenever you want to make sure MatlabJobSupport is properly
% configured.
%
% This script sets up a few default environment profiles for executing
% jobs.  You should edit these and add other profiles as you like.
%
% See mjsSetEnvironmetProfile() for more about environment profiles.
%
% 2016-2017 Brainard Lab, University of Pennsylvania


%% Local Docker execution.
%   On Linux, local Docker execution should "just work".
%   On a Mac, you need to have an activated Linux Matlab installation
%   sitting on your hard drive.  We need to tell MatlabJobSupport where
%   this installation sits, and the MAC address used in the Matlab license.

if ismac()
    mjsSetEnvironmetProfile('local', ...
        'matlabDir', 'where is linux matlab installation?', ...
        'dockerNetwork', 'what is linux matlab mac address?');
end


%% Jenkins jobs.
%   This profile is good for jobs running on our Jenkins server.
%
%   Jenkins can check out versions of code that we want to test, into a
%   folder called the $WORKSPACE.
%   We need to mount this $WORKSPACE into the job container so that we can
%   run tests on the checked-out version, instead of the default version.
%
%   It's also handy to add config for other things tests might need, like
%   auto-updating the docker image on the Jenkins server, and finding Java.

mjsSetEnvironmetProfile('jenkins', ...
    'commonToolboxDir', '$WORKSPACE', ...
    'projectsDir', '$WORKSPACE', ...
    'dockerImage', 'ninjaben/mjs-base:latest', ...
    'javaDir', 'bundled');
