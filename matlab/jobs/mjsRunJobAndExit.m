function mjsRunJobAndExit(job)
% Call mjsRunJob() in a try-catch, then exit Matlab with a status code.
%
% mjsRunJobAndExit(job)
%
% 2016-2017 Brainard Lab, University of Pennsylvania

try
    mjsRunJob(job);
    exit();
catch err
    report = err.getReport('extended');
    disp(report);
    exit(-1);
end
