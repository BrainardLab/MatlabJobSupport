%% Startup script for use with the Toolbox Toolbox.
%

%% Where is the Toolbox Toolbox installed?
toolboxToolboxDir = '/mjs/ToolboxToolbox';


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
localHookFolder = fullfile(tbUserFolder(), '/mjs/toolboxHooks');
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


%% Set up Matlab path for job support
tbUse('MatlabJobSupport');
tbAddToolboxPath('toolboxPath', '/var/mjs/working');

%% Start jobs in working dir
cd('/var/mjs/working');

