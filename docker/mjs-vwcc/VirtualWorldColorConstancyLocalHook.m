%% Configure VirtualWorldColorConstancy system defaults.
%
% This script attempts to locate system resources and create Matlab
% preferences necessary to use VirtualWorldColorConstancy.
%
% This version is set up for MatlabJobSupport


%% Set up some parameters for portability
projectName = 'VirtualWorldColorConstancy';

%% Where does output go?
% 
% The default for output if you are not a recognized user is in a subdir
% called output/VirtualWorldColorConstancy of what is returned by
% rtbGetUserFolder, which itself is configured as part of setting up
% RenderToolbox (there is a default if you don't do anything.)
%
% You may want to change this to be wherever you want the potentially big
% pile of output to end up.
%
% We make an attempt below to do sensible things for users/machines we know
% about before dropping to the default

workingDir = getenv('WORKING_DIR');
if isempty(workingDir) || 7 ~= exist(workingDir, 'dir')
    myFolder = '/var/render_toolbox';
else
    myFolder = workingDir;
end
dataDir = fullfile(myFolder,'VirtualWorldColorConstancy');
if (~exist(dataDir,'dir'))
    mkdir(dataDir);
end
setpref(projectName, 'baseFolder',dataDir);

