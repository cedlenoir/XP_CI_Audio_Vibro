function drawCross(win,rect)

screen = max(Screen('Screens'));
xCenter = rect(3)/2;
yCenter = rect(4)/2;

% fix cross pararmeters
armLength = 40;
xCoord = [-armLength,armLength,0,0];
yCoord = [0,0,-armLength,armLength];
allCoord = [xCoord; yCoord];
lineWidthPix = 4;

Screen('DrawLines',win,allCoord,lineWidthPix,WhiteIndex(screen),[xCenter,yCenter],2);
Screen('Flip',win);  
