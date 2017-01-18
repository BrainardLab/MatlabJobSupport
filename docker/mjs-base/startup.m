%% Startup script for use with the ToolboxToolbox and MatlabJobSupport.
%
% This startup.m is intended for use inside Docker containers that are
% based on the image ninjaben/mjs-base.
%
% It configures ToolboxToolbox to use directory conventions established in
% ninjaben/mjs-base:
%	- /mjs -- startup.m, initial dir for container startup
%	- /mjs/ToolboxToolbox -- the ToolboxToolbox
%   - /mjs/projects -- projects that can be deployed with ToolboxToolbox
%	- /mjs/toolboxes -- toolboxes installed by the ToolboxToolbox
%	- /mjs/toolboxHooks -- local toolbox hooks created by the ToolboxToolbox
%
% It also responds to a few environment variables, allowing for run-time
% configuration.  These should be set from "docker run", using the "-e"
% flag.
%   - TOOLBOX_TOOLBOX_FLAVOR -- version of ToolboxToolbox to check out:
%       - '' -> default version in the Docker image
%       - 'latest' -> do a "git pull"
%       - other -> do a "git checkout other"
%   - INPUT_DIR -- custom dir to map from host and add to Matlab path
%   - WORKING_DIR -- where to cd() when starting Matlab
%
% 2016-2017 benjamin.heasly@gmail.com

%% Locate an dupdate ToolboxToolbox.
toolboxToolboxDir = '/mjs/ToolboxToolbox';

% use specific version of toolbox toolbox?
toolboxToolboxFlavor = getenv('TOOLBOX_TOOLBOX_FLAVOR');
if strcmp('latest', toolboxToolboxFlavor)
    system('cd "%s" && git pull', toolboxToolboxDir);
elseif ~isempty(toolboxToolboxFlavor)
    system('cd "%s" && git checkout "%s"', toolboxToolboxDir, toolboxToolboxFlavor);
end


%% Set up the Matlab path for ToolboxToolbox.
originalDir = pwd();

try
    apiDir = fullfile(toolboxToolboxDir, 'api');
    cd(apiDir);
    tbResetMatlabPath('full');
catch err
    warning('Error setting ToolboxToolbox path during startup: %s', err.message);
end

cd(originalDir);


%% Matlab preferences that control ToolboxToolbox.

% clear old preferences, so we get a predictable starting place.
if (ispref('ToolboxToolbox'))
    rmpref('ToolboxToolbox');
end

% choose custom preferences below, or leave commented to accept defaults

% % default location for JSON configuration
% configPath = fullfile(tbUserFolder(), 'toolbox_config.json');
% setpref('ToolboxToolbox', 'configPath', configPath);

% % default folder to contain regular the toolboxes
toolboxRoot = '/mjs/toolboxes';
% setpref('ToolboxToolbox', 'toolboxRoot', toolboxRoot);

% % default folder to contain shared, pre-installed toolboxes
toolboxCommonRoot = '/opt/toolboxes';
% setpref('ToolboxToolbox', 'toolboxCommonRoot', toolboxCommonRoot);

% % default folder to contain non-toolbox projects
projectRoot = '/mjs/projects';
% setpref('ToolboxToolbox', 'projectRoot', projectRoot);

% % default folder for hooks that set up local config for each toolbox
localHookFolder = '/mjs/toolboxHooks';
% setpref('ToolboxToolbox', 'localHookFolder', localHookFolder);

% % location of ToolboxHub or other toolbox registry
% registry = tbDefaultRegistry();
% setpref('ToolboxToolbox', 'registry', registry);

% system command used to check whether the Internet is reachable
%   this helps avoid long timeouts, when Internet isn't reachable
%   many commands would work fine
%   some suggestions:
%
% good default for Linux and OS X
% checkInternetCommand = 'ping -c 1 www.google.com';
%
% good default for Windows
% checkInternetCommand = 'ping -n 1 www.google.com';
%
% alternatives in case ping is blocked by firewall, etc.
% checkInternetCommand = 'curl www.google.com';
% checkInternetCommand = 'wget www.google.com';
%
% no-op to assume Internet is always reachable
% checkInternetCommand = '';
%
% setpref('ToolboxToolbox', 'checkInternetCommand', checkInternetCommand);


%% Always deploy job support.
tbUse('MatlabJobSupport');


%% Add input dir to Matlab path.
inputDir = getenv('INPUT_DIR');
if ~isempty(inputDir) && 7 == exist(inputDir, 'dir')
    tbAddToPath(inputDir);
end


%% Start jobs in working dir.
workingDir = getenv('WORKING_DIR');
if isempty(workingDir) || 7 ~= exist(workingDir, 'dir')
    cd('/var/mjs');
else
    cd(workingDir);
end
