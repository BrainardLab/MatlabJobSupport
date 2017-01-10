function awsCliScriptFile = mjsWriteAwsCliScript(jobScriptFile, varargin)
% Write a shell script that will run the given jobScriptFile, via AWS CLI.
%
% This saves us from having to write lots of AWS CLI and SSH syntax by hand.
%
% AWS CLI is the Amazon Web Services Command Line Interface.
%   https://aws.amazon.com/cli/
%
% mjsWriteAwsCliScript = mjsWriteAwsCliScript(jobScriptFile) generates a
% shell script that will cause the given jobScriptFile be executed
% remotely, via ASW CLI and SSH.  The general outline is:
%   - start an AWS EC2 instance using AWS CLI
%   - execute the jobScriptFile via SSH on the instance
%   - terminate the instance
%
% mjsWriteAwsCliScript( ... 'awsCliScriptFile', awsCliScriptFile) specify
% the name of the new AWS CLI script that should be generated.  The default
% is chosen based on the jobScriptFile.
%
% mjsWriteAwsCliScript( ... 'amiId', amiId) specify id of the Amazon
% Machine Image to use for the new EC2 instance.  The AMI should have the
% following already installed:
%   - Docker
%   - Matlab
%   - jq (for parsing JSON, see https://stedolan.github.io/jq/)
%
% mjsWriteAwsCliScript( ... 'instanceType', instanceType) specify the
% instance type to create.  For Matlab, use at least t2.small, or at least
% 2GB of memory.
%
% mjsWriteAwsCliScript( ... 'securityGroups', securityGroups) name of
% security groups that allow SSH access from here, as well as access to any
% Matlab license server that's required.
%
% mjsWriteAwsCliScript( ... 'terminate', terminate) specify whether to
% terminate the instance after the job fails or completes.  The default is
% true -- do terminate the instance.
%
% mjsWriteAwsCliScript( ... 'iamProfile', iamProfile) configure an "IAM"
% profile for the instance to use.  This an optional way to give the
% instance access to other AWS resources, like S3.
%
% scriptFile = mjsWriteAwsCliScript(varargin)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('jobScriptFile', @ischar);
parser.addParameter('awsCliScriptFile', '', @ischar);
parser.addParameter('amiId', '', @ischar);
parser.addParameter('instanceType', 't2.small', @ischar);
parser.addParameter('securityGroups', {'default'}, @iscellstr);
parser.addParameter('terminate', true, @islogical);
parser.addParameter('iamProfile', '', @ischar);
parser.addParameter('identity', '', @ischar);
parser.addParameter('diskGB', [], @isnumeric);
parser.parse(jobScriptFile, varargin{:});
jobScriptFile = parser.Results.jobScriptFile;
awsCliScriptFile = parser.Results.awsCliScriptFile;
amiId = parser.Results.amiId;
instanceType = parser.Results.instanceType;
securityGroups = parser.Results.securityGroups;
terminate = parser.Results.terminate;
iamProfile = parser.Results.iamProfile;
identity = parser.Results.identity;
diskGB = parser.Results.diskGB;

% default aws cli script name based on job script name
[jobScriptPath, jobScriptBase] = fileparts(jobScriptFile);
if isempty(awsCliScriptFile)
    awsCliScriptFile = fullfile(jobScriptPath, [jobScriptBase '-aws-cli.sh']);
end


%% Make sure script dir exists.
scriptDir = fileparts(awsCliScriptFile);
if ~isempty(scriptDir) && 7 ~= exist(scriptDir, 'dir')
    mkdir(scriptDir);
end

fid = fopen(awsCliScriptFile, 'w');
if -1 == fid
    error('mjsWriteAwsCliScript:fopen', ...
        'Could not open file <%s> for writing.', scriptFile);
end

try
    fprintf(fid, '#!/bin/sh\n');
    fprintf(fid, '## Begin script generated by mjsWriteAwsCliScript.m\n');

    fprintf(fid, '# automatically quit after errors\n');
    fprintf(fid, 'set -e\n');
    
    fprintf(fid, '\n');
    fprintf(fid, 'echo "Hello."\n');
    fprintf(fid, 'date\n');

    
    %% Build AWS CLI command to request a new instance.
    fprintf(fid, '\n');
    fprintf(fid, '# invoke aws ec2 run-instances with lots of options \n');
    fprintf(fid, '# and save result in a JSON file \n');
    fprintf(fid, 'echo "Requesting <%s> for <%s>"\n', instanceType, amiId);
    fprintf(fid, 'aws ec2 run-instances \\\n');
    fprintf(fid, '  --image-id %s \\\n', amiId);
    fprintf(fid, '  --count 1 \\\n');
    fprintf(fid, '  --instance-type %s \\\n', instanceType);
    
    securityGroupArg = sprintf('%s ', securityGroups{:});
    fprintf(fid, '  --security-groups %s \\\n', securityGroupArg);
    
    if ~isempty(iamProfile)
        fprintf(fid, '  --iam-instance-profile %s \\\n', iamProfile);
    end
    
    if ~isempty(identity)
        [~, keyName] = fileparts(identity);
        fprintf(fid, '  --key-name %s \\\n', keyName);
    end
    
    if ~isempty(diskGB)
        diskGbArg = sprintf('[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":%d,\"DeleteOnTermination\":true,\"VolumeType\":\"gp2\"}}]', ...
            diskGB);
        fprintf(fid, '  --block-device-mappings %s \\\n', diskGbArg);
    end
    
    % redirect results JSON to temp file
    instanceDetailsFile = sprintf('/tmp/%s.json', jobScriptBase);
    fprintf(fid, '  --output json > "%s"\n', instanceDetailsFile);
    
    
    %% Add handy tags to the instance.
    fprintf(fid, '\n');
    fprintf(fid, '# scrape out new instance Id using jq (https://stedolan.github.io/jq/) \n');
    fprintf(fid, 'INSTANCE_ID=$(jq -r ".Instances[0].InstanceId" %s)\n', instanceDetailsFile);
    
    fprintf(fid, '\n');
    fprintf(fid, '# add tags to help keep track of the new instance \n');
    fprintf(fid, 'aws ec2 create-tags \\\n');
    fprintf(fid, '  --resources "$INSTANCE_ID" \\\n');
    fprintf(fid, '  --tags Key=Name,Value=%s Key=Script,Value=%s \n', jobScriptBase, 'mjsWriteAwsCliScript');
    
    
    %% Wait for the instance to be ready.
    fprintf(fid, '\n');
    fprintf(fid, '# wait for the instance to come up\n');
    fprintf(fid, 'echo "Waiting for instance <$INSTANCE_ID> to start..."\n');
    fprintf(fid, 'aws ec2 wait instance-status-ok \\\n');
    fprintf(fid, '  --instance-ids "$INSTANCE_ID" \n');
    
    fprintf(fid, '\n');
    fprintf(fid, 'echo "...OK"\n');
    fprintf(fid, 'date\n');
    
    %% Update the instance details, now that it's ready.
    fprintf(fid, '\n');
    fprintf(fid, '# update instance details to get DNS name \n');
    fprintf(fid, 'aws ec2 describe-instances \\\n');
    fprintf(fid, '  --instance-ids "$INSTANCE_ID" \\\n');
    fprintf(fid, '  --output json > "%s"\n', instanceDetailsFile);
    
    fprintf(fid, '\n');
    fprintf(fid, 'INSTANCE_DNS_NAME=$(jq -r ".Reservations[0].Instances[0].PublicDnsName" %s)\n', ...
        instanceDetailsFile);
    
    
    %% Insert an ssh script right here inside this aws-cli script!
    %   this is the fun part!
    fprintf(fid, '\n\n');
    mjsWriteSshScript(jobScriptFile, ...
        varargin{:}, ...
        'host', '$INSTANCE_DNS_NAME', ...
        'sshScriptFid', fid);
    
    %% Clean up.
    if terminate
        % terminate the instance
        fprintf(fid, '\n');
        fprintf(fid, '# terminate the instance after the job is done\n');
        fprintf(fid, 'echo "Terminating instance <$INSTANCE_ID>..."\n');
        fprintf(fid, 'aws ec2 terminate-instances \\\n');
        fprintf(fid, '  --instance-ids "$INSTANCE_ID" \\\n');
        fprintf(fid, '  --output json >> "%s"\n', instanceDetailsFile);
        
        % wait for it to be terminated
        fprintf(fid, '\n');
        fprintf(fid, '# wait for instance to be done terminating\n');
        fprintf(fid, 'aws ec2 wait instance-terminated \\\n');
        fprintf(fid, '  --instance-ids "$INSTANCE_ID" \n');
        
        fprintf(fid, '\n');
        fprintf(fid, 'echo "...OK"\n');
    else
        % leave instance running, with some info
        fprintf(fid, 'echo "Leaving instance <$INSTANCE_ID> running at <$INSTANCE_DNS_NAME>."\n');
    end
    
    fprintf(fid, '\n');
    fprintf(fid, 'echo "Bye-bye."\n');
    fprintf(fid, 'date\n');
    
    fprintf(fid, '\n');
    fprintf(fid, '## End script generated by mjsWriteAwsCliScript.m\n');
    fprintf(fid, '\n');
    
    fclose(fid);
    
catch err
    fclose(fid);
    rethrow(err);
end

system(['chmod +x ' awsCliScriptFile]);
