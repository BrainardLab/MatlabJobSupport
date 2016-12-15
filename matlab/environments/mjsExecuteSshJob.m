function [status, result, scriptFile] = mjsExecuteSshJob(job, varargin)
% Turn a job into a Docker/SSH shell script, execute it immediately.
%
% [status, result, scriptFile] = mjsExecuteSshJob(job) causes the given
% job struct to be executed remotely, via SSH, in a Docker container.
% Returns the execution status code and result.  Also returns the path to
% the script file that was generated.
%
% mjsExecuteSshJob( ... 'host', host) specify the address or hostname of
% the remote host to access via SSH.
%
% mjsExecuteSshJob( ... 'port', port) specify the port to connect to on the
% remote host.
%
% mjsExecuteSshJob( ... 'user', user) specify the usename to use when
% connecting to the remote host.
%
% mjsExecuteSshJob( ... 'identity', identity) specify the path to an
% identity file (often .pem) to use for authenticating with the remote
% host.
%
% mjsExecuteSshJob( ... 'knownHostsFile', knownHostsFile) specify the path
% to the ssh "known_hosts" file, where the ssh key of the given host can be
% automatically accepted.  The default is '~/.ssh/known_hosts'.
%
% mjsExecuteSshJob( ... 'name', value ...) pass additional parameters to
% specify how the shell script will configure the container.  For details,
% see mjsWriteDockerRunScript(), which takes the same parameters.
%
% [status, result, scriptFile] = mjsExecuteSshJob(job, varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('job', @isstruct);
parser.addParameter('host', 'localhost', @ischar);
parser.addParameter('port', [], @isnumeric);
parser.addParameter('user', '', @ischar);
parser.addParameter('identity', '', @ischar);
parser.addParameter('knownHostsFile', '', @ischar);
parser.parse(job, varargin{:});
job = parser.Results.job;
host = parser.Results.host;
port = parser.Results.port;
user = parser.Results.user;
identity = parser.Results.identity;
knownHostsFile = parser.Results.knownHostsFile;

if isempty(user)
    [~, user] = system('whoami');
end

%% Write a script that contains the whole job.
scriptFile = mjsWriteDockerRunScript(job, varargin{:});


%% Try to automatically accept the remote ssh key.
%   this avoids prompting the user to accept the key
if ~isempty(knownHostsFile)
    keyCommand = sprintf('env -i ssh-keyscan -H "%s" >> "%s"', ...
        host, knownHostsFile);

    fprintf('Accepting public key for remote host:\n');
    fprintf('  %s\n', keyCommand);
    system(keyCommand, '-echo');
end

%% Try to run the job script on the remote host.
if isempty(port)
    portOption = '';
else
    portOption = sprintf('-p %d', port);
end

if isempty(identity)
    idOption = '';
else
    idOption = sprintf('-i "%s"', identity);
end

sshCommand = sprintf('env -i ssh %s %s "%s@%s" ''sh -s'' < "%s"', ...
    portOption, ...
    idOption, ...
    user, ...
    host, ...
    scriptFile);

fprintf('Doing SSH command on remote host:\n');
fprintf('  %s\n', sshCommand);
[status, result] = system(sshCommand, '-echo');
