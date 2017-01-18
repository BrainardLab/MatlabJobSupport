classdef MjsLocalJobTests < matlab.unittest.TestCase
    % Test local execution of a simple job.
    
    properties
        tempDir = fullfile(tempdir(), 'MjsLocalJobTests');
    end
    
    methods (TestMethodSetup)
        function freshTempDir(testCase)
            if 7 == exist(testCase.tempDir, 'dir')
                rmdir(testCase.tempDir, 's');
            end
            mkdir(testCase.tempDir);
        end
    end
    
    methods
        function [job, intValue, outputFile] = integerSaverJob(testCase)
            intValue = randi(1e9);
            outputFile = fullfile(testCase.tempDir, 'integerSaverJob.mat');
            command = sprintf('intValue=%d;save(''%s'', ''intValue'');', ...
                intValue, outputFile);
            job = mjsJob( ...
                'name', 'integerSaverJob', ...
                'jobCommand', command);
        end
        
        function [job, errorMessage] = errorJob(testCase)
            errorMessage = 'This is a test error.';
            command = {@error, errorMessage};
            job = mjsJob( ...
                'name', 'errorJob', ...
                'jobCommand', command);
        end
        
    end
    
    methods (Test)
        
        function testInMatlabSuccess(testCase)
            [job, intValue, outputFile] = testCase.integerSaverJob();
            mjsRunJob(job);
            testCase.assertEqual(exist(outputFile, 'file'), 2);
            jobOutput = load(outputFile);
            testCase.assertEqual(jobOutput.intValue, intValue);
        end
        
        function testInDockerSuccess(testCase)
            [job, intValue, outputFile] = testCase.integerSaverJob();
            mjsExecuteLocal(job, ...
                'scriptFile', fullfile(testCase.tempDir, 'scripts', [job.name '.sh']), ...
                'outputDir', testCase.tempDir);
            testCase.assertEqual(exist(outputFile, 'file'), 2);
            jobOutput = load(outputFile);
            testCase.assertEqual(jobOutput.intValue, intValue);
        end
        
        function testInMatlabError(testCase)
            errorMessage = 'no error';
            [job, expectedMessage] = testCase.errorJob();
            try
                mjsRunJob(job);
            catch err
                errorMessage = err.message;
            end
            testCase.assertEqual(errorMessage, expectedMessage);
        end
        
        function testInDockerError(testCase)
            [job, expectedMessage] = testCase.errorJob();
            [status, result] = mjsExecuteLocal(job, ...
                'scriptFile', fullfile(testCase.tempDir, 'scripts', [job.name '.sh']), ...
                'outputDir', testCase.tempDir);
            
            testCase.assertNotEqual(status, 0);
            
            messageIndex = strfind(result, expectedMessage);
            testCase.assertNotEmpty(messageIndex);
        end
        
        function testInDockerInputFolderPathError(testCase)
            % copy a test function deep inside the input dir.
            pathHere = fileparts(mfilename('fullpath'));
            testFunction = fullfile(pathHere, 'fixture', 'mjsJobTestFunction.m');
            inputDir = fullfile(testCase.tempDir, 'input');
            workingDeep = fullfile(inputDir, 'deep', 'deep');
            mkdir(workingDeep);
            deepFunction = fullfile(workingDeep, 'deepTestFunction.m');
            copyfile(testFunction, deepFunction);
            
            % "forget" to add the input folder that contains the function
            job = mjsJob( ...
                'name', 'forgotInputDir', ...
                'jobCommand', {@deepTestFunction});
            status = mjsExecuteLocal(job, ...
                'scriptFile', fullfile(testCase.tempDir, 'scripts', [job.name '.sh']), ...
                'outputDir', testCase.tempDir);
            
            % should fail because mjsJobTestFunction not on Matlab path
            testCase.assertNotEqual(status, 0);
        end
        
        function testInDockerInputFolderPathSuccess(testCase)
            % copy a test function deep inside the input dir.
            pathHere = fileparts(mfilename('fullpath'));
            testFunction = fullfile(pathHere, 'fixture', 'mjsJobTestFunction.m');
            inputDir = fullfile(testCase.tempDir, 'input');
            workingDeep = fullfile(inputDir, 'deep', 'deep');
            mkdir(workingDeep);
            deepFunction = fullfile(workingDeep, 'deepTestFunction.m');
            copyfile(testFunction, deepFunction);
            
            % "remember" to add the input folder that contains the function
            job = mjsJob( ...
                'name', 'rememberedInputDir', ...
                'jobCommand', {@deepTestFunction});
            [status, result] = mjsExecuteLocal(job, ...
                'scriptFile', fullfile(testCase.tempDir, 'scripts', [job.name '.sh']), ...
                'inputDir', inputDir, ...
                'outputDir', testCase.tempDir);
            
            % should succeed with mjsJobTestFunction on the Matlab path
            testCase.assertEqual(status, 0);
        end
        
        
        function testInDockerWithLogFile(testCase)
            job = testCase.integerSaverJob();
            mjsExecuteLocal(job, ...
                'scriptFile', fullfile(testCase.tempDir, 'scripts', [job.name '.sh']), ...
                'outputDir', testCase.tempDir, ...
                'logDir', testCase.tempDir);
            
            expectedLogFile = fullfile(testCase.tempDir, 'matlab.log');
            testCase.assertEqual(exist(expectedLogFile, 'file'), 2);
            
            fid = fopen(expectedLogFile, 'r');
            try
                logText = fread(fid, '*char')';
            catch err
                fclose(fid);
                rethrow(err);
            end
            fclose(fid);
            
            expectedMessage = 'Finished job named "integerSaverJob"';
            messageIndex = strfind(logText, expectedMessage);
            testCase.assertNotEmpty(messageIndex);
        end
        
        function testInDockerWithCommonToolbox(testCase)
            % install a toolbox in a shared toolbox folder
            commonToolboxDir = fullfile(tempdir(), 'toolboxes');
            tbUse('sample-repo', 'toolboxRoot', commonToolboxDir);
            
            % make a job that uses the same toolbox
            job = testCase.integerSaverJob();
            job.toolboxCommand = {@tbUse, 'sample-repo'};
            
            % run the job with the shared toolbox folder mapped in
            [status, result] = mjsExecuteLocal(job, ...
                'scriptFile', fullfile(testCase.tempDir, 'scripts', [job.name '.sh']), ...
                'outputDir', testCase.tempDir, ...
                'commonToolboxDir', commonToolboxDir);
            
            testCase.assertEqual(status, 0);
            
            % job should find sample-repo from the shared folder /opt/toolboxes,
            %   not in the internal folder /mjs/toolboxes
            expectedMessage = 'Adding "sample-repo" to path at "/opt/toolboxes/sample-repo"';
            messageIndex = strfind(result, expectedMessage);
            testCase.assertNotEmpty(messageIndex);
        end
        
    end
end