clear all


%%

addpath(genpath('CPP_BIDS/src'))


cfg.dir.output = './log'; 

cfg.task.name = 'listen'; 

% get from the command line
cfg = userInputs(cfg); 

cfg.testingDevice = 'eeg'; 

% add default parameters that haven't been set yet
cfg = checkCFG(cfg); 

% creates filename strings
cfg = createFilename(cfg); 

%%
% We can define what extra columns we want in our tsv file beyond the 
% BIDS holy trinity ('onset', 'duration', 'trial_type')

% Say we want to keep track of the type of target that what presented during a trial and of its position
logFile.extraColumns = {'rhythm', 'trigger'};

logFile = saveEventsFile('init',cfg,logFile); 

logFile.extraColumns.rhythm.bids.Description = 'name of the rhythmic pattern'; 
logFile.extraColumns.rhythm.bids.Levels = {'unsyncopated','syncopated'}; 

logFile.extraColumns.trigger.bids.Description = 'EEG trigger value'; 
logFile.extraColumns.trigger.bids.Levels 






% mkdir(fullfile(cfg.dir.outputSubject, cfg.fileName.modality))
logFile = saveEventsFile('open',cfg,logFile); 

% trial 1
logFile(1,1).onset = 2; 
logFile(1,1).trial_type = 'listen'; 


