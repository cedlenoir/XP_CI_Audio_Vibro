function cfg = drawCross(cfg)

%%%% Screen display script %%%%%
% parameters

Screen('Preference', 'SkipSyncTests', cfg.skipSyncTest);
Screen('Preference', 'Verbosity', cfg.verbose); %Make PTB Shut up

%%Define settings
  screenNum = 1; %0 = sets the screen as the main screen 
  backColor = [100 100 100];
  crossColor= [255 255 255];
  screen = max(Screen('Screens'));
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
lineWidthPix = 4;


% Screen('DrawLines',windowPtr,crossColor,allCoord,lineWidthPix,[xCenter,yCenter],2);

Screen('DrawLines',win,allCoord, lineWidthPix,crossColor,[xCenter yCenter]);
Screen('Flip',win);
WaitSecs(65); % for 60 second trial
sca;

end
