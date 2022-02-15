% Flora february 2022, inspired by CPP 

function [cfg] = setScreenParameters(cfg)

% Initialize the parameters ans general config variables



%%% Debug mode settings

cfg.debug.do         = false;      % for debug mode set to true
cfg.debug.smallWin   = false;      % to test only in small window
cfg.debug.transpWin  = false;      % to test with transparent screen 

cfg.verbose          = 0;          %make PTB shut up 
cfg.skipSyncTest     = 1;          %no syncing

cfg.screen.screenNum = 1;          % set to 0 for main screen
cfg.keya             = KbName('a');% define key for flipping screen 

%%% Parameters

cfg.color.white      = [255 255 255];
cfg.color.black      = [0 0 0];
cfg.color.grey       = mean([cfg.color.white; cfg.color.black]);
cfg.color.background = cfg.color.grey;
cfg.color.text       = cfg.color.white;
cfg.color.cross      = cfg.color.white;

cfg.text.Font  = 'Helvetica'; 
cfg.text.fontSize  = 80;

end
