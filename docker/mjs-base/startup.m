%% Startup script for use with ToolboxToolbox and MatlabJobSupport.
%

%% Where is the Toolbox Toolbox installed?
toolboxToolboxDir = '/mjs/ToolboxToolbox';

% use specific version of toolbox toolbox?
toolboxToolboxFlavor = getenv('TOOLBOX_TOOLBOX_FLAVOR');
if strcmp('latest', toolboxToolboxFlavor)
    system('cd "%s" && git pull', toolboxToolboxDir);
elseif ~isempty(toolboxToolboxFlavor)
    system('cd "%s" && git checkout "%s"', toolboxToolboxDir, toolboxToolboxFlavor);
end

%% Set up the path.
originalDir = pwd();

try
    apiDir = fullfile(toolboxToolboxDir, 'api');
    cd(apiDir);
    tbResetMatlabPath('full');
catch err
    warning('Error setting Toolbox Toolbox path during startup: %s', err.message);
end

cd(originalDir);


%% Matlab preferences that control ToolboxToolbox.

% uncomment any or all of these that you wish to change

% % default location for JSON configuration
% configPath = fullfile(tbUserFolder(), 'toolbox_config.json');
% setpref('ToolboxToolbox', 'configPath', configPath);

% default folder to contain regular the toolboxes
toolboxRoot = '/mjs/toolboxes';
setpref('ToolboxToolbox', 'toolboxRoot', toolboxRoot);

% default folder to contain shared, pre-installed toolboxes
toolboxCommonRoot = '/opt/toolboxes';
setpref('ToolboxToolbox', 'toolboxCommonRoot', toolboxCommonRoot);

% default folder for hooks that set up local config for each toolbox
localHookFolder = '/mjs/toolboxHooks';
setpref('ToolboxToolbox', 'localHookFolder', localHookFolder);

% % location of ToolboxHub or other toolbox registry
% registry = tbDefaultRegistry();
% setpref('ToolboxToolbox', 'registry', registry);

% % system command used to check whether the Internet is reachable
% if ispc()
%     checkInternetCommand = 'ping -n 1 www.google.com';
% else
%     checkInternetCommand = 'ping -c 1 www.google.com';
% end
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
