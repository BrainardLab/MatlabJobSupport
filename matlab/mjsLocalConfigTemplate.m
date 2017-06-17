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
        'dockerNetwork', '--mac-address="what is linux matlab mac address?"');
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
    'dockerImage', 'brainardlab/mjs-base:latest', ...
    'javaDir', 'bundled');


%% Aws jobs.
%   This profile is good for running jobs on short-lived AWS instances.
%
%   It requires that you have the AWS CLI set up on your local machine.
%       https://github.com/BrainardLab/MatlabJobSupport/wiki/AWS-Workstation-Setup
%
%   It also requires that you have the jq utility installed on your local
%   machine.
%       https://stedolan.github.io/jq/
%
%   It also assumes that your AWS account has an AMI set up with Docker and
%   Matlab both installed and ready to go.
%
%   The settings below should be good for the Brainard Lab AWS account.
%   But keeping this up to date will require someont to become familiar
%   with the AWS EC2 section of the AWS account.

% Amazon Machine Image called "RTB Jobs 11".
%   Ubuntu image with Docker, Matlab, and AWS CLI installed
amiId = 'ami-faa2229a';

% allow the instance to use the AWS CLI
%   to do things like copy data to and from S3
iamProfile = 'ecsInstanceRole';

% the size/style of the virtual machine to spin up
%   Matlab wants at least 2GB ram -> at least t2.small
instanceType = 't2.small';

% firewall for the AWS instance
%   default allows access to the Matlab License server inside AWS
%   all-ssh allows us to connect and send the job from here
securityGroups = {'default', 'all-ssh'};

% user name to use on the server
user = 'ubuntu';

% you need to have this "identity" file locally
%   to match an identity known to the AWS account
%   ask David, Nicolas, or Ben
identity = '$HOME/aws/render-toolbox.pem';

% whether to terminate the instance when the job is done
terminate = true;

% local file where we can auto-accept remote ssh key
%   this prevents us having to type "yes" before the job can run
knownHostsFile = '$HOME/.ssh/known_hosts';

mjsSetEnvironmetProfile('aws', ...
    'dockerImage', 'brainardlab/mjs-base:latest', ...
    'javaDir', 'bundled', ...
    'outputOwner', user, ...
    'amiId', amiId, ...
    'iamProfile', iamProfile, ...
    'instanceType', instanceType, ...
    'securityGroups', securityGroups, ...
    'user', user, ...
    'identity', identity, ...
    'terminate', terminate, ...
    'knownHostsFile', knownHostsFile);

