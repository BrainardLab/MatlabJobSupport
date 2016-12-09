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
            mjsExecuteLocalJob(job, 'workingDir', testCase.tempDir);
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
            [status, result] = mjsExecuteLocalJob(job);
            
            testCase.assertNotEqual(status, 0);
            
            messageIndex = strfind(result, expectedMessage);
            testCase.assertNotEmpty(messageIndex);
        end
    end
    
end