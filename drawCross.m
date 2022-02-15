function [cfg] = drawCross(cfg)
% Will only work if screen already open !

%%%% Screen display script %%%%%
% parameters

Screen('Preference', 'SkipSyncTests', cfg.skipSyncTest);
Screen('Preference', 'Verbosity', cfg.verbose); %Make PTB Shut up

win  = cfg.screen.windowPtr;
rect = cfg.screen.windowRect;
xCenter = rect(3)/2;
yCenter = rect(4)/2;
% 
% %Open external monitor
% [windowPtr, windowRect] = Screen('OpenWindow', screenNum, backColor);


% fix cross pararmeters
armLength = 80;
xCoord = [-armLength,armLength,0,0];
yCoord = [0,0,-armLength,armLength];
allCoord = [xCoord; yCoord];
lineWidthPix = 6;


% Screen('DrawLines',windowPtr,crossColor,allCoord,lineWidthPix,[xCenter,yCenter],2);

Screen('DrawLines',win,allCoord, lineWidthPix,cfg.color.cross,[xCenter yCenter]);
Screen('Flip',win);
% KbStrokeWait;
% WaitSecs(65); % for 60 second trial
% sca;

end
