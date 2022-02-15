function [response]=writeOnScreenPTB(win, allowedkeys, instr, options, varargin)
% 
% varargin
% 
% 'respopt' - string with options separated by \n, will print aligned to
% left
% 
% 
% 
% 

col_text = repmat(WhiteIndex(win),1,3); 
[xmax, ymax] = Screen('WindowSize',win);
[xcenter, ycenter] = RectCenter([0, 0, xmax, ymax]);
Screen('TextSize',win,35);  %sets textsize for keys pressed

baseRect = [0 0 50 50];
rect_col = [0.2, 0.2, 0.2]; 

ypos_instr = 0.1; 
xpos_options = 0.3; 
xpos_resp = 0.25; 

if any(strcmpi(varargin, 'respopt'))
    disp_resp_opt = 1; 
    respopt = varargin{find(strcmpi(varargin,'respopt'))+1}; 
    respopt = sprintf(respopt);     
    [normBoundsRect, offsetBoundsRect, textHeight, xAdvance] = Screen('TextBounds',win, instr, xcenter, ymax*ypos_instr); 
    ypos_respopt = ymax*ypos_instr + ceil(length(strfind(instr,'\n')))*textHeight; 
end

instr = sprintf(instr); 

returnKey = KbName('return');
deleteKey = KbName('delete');
upkey = KbName('uparrow'); 
downkey = KbName('downarrow'); 
enterpressed=0; %initializes loop flag
currentpos = 1; 
AsteriskBuffer=cell(length(options),1); %initializes buffer
bufspacing = linspace(ymax*0.5,ymax*0.9,length(AsteriskBuffer)); 

KbQueueFlush; 

DrawFormattedText(win,instr,'center',ymax*ypos_instr,col_text); %draws instructions
if disp_resp_opt
    DrawFormattedText(win,respopt,xmax*xpos_resp,ypos_respopt,col_text); % draw response options
end
for i=1:length(AsteriskBuffer)
    if i==currentpos
        [normBoundsRect, offsetBoundsRect, textHeight, xAdvance] = Screen('TextBounds',win,'0',xmax*xpos_resp, bufspacing(i)); 
        centeredRect = CenterRectOnPointd([0,0,xAdvance*2,textHeight], xmax*xpos_resp+xAdvance/2, bufspacing(i)-textHeight*0.333);
        Screen('FillRect', win, rect_col, centeredRect);
    end
    DrawFormattedText(win, options{i}, xmax*xpos_resp, bufspacing(i), col_text); %draws keyspressed
    DrawFormattedText(win, AsteriskBuffer{i}, xmax*xpos_options, bufspacing(i), col_text); %draws options
end
Screen('Flip',win);

while ( enterpressed==0 )
    [ pressed, firstPress]=KbQueueCheck; %checks for keys
    enterpressed=firstPress(returnKey); %press return key to terminate each response
    if (pressed & ~enterpressed) %keeps track of key-presses and draws text
        if firstPress(deleteKey) %if delete key then erase last key-press
            AsteriskBuffer{currentpos}=AsteriskBuffer{currentpos}(1:end-1); %erase last key-press
        elseif firstPress(upkey)
            currentpos = max(currentpos-1, 1); 
        elseif firstPress(downkey)
            currentpos = min(currentpos+1, length(options)); 
        else %otherwise add to buffer
           firstPress(find(firstPress==0))=NaN; %little trick to get rid of 0s
          [endtime Index]=min(firstPress); % gets the RT of the first key-press and its ID
           if ismember(Index,allowedkeys) & length(AsteriskBuffer{currentpos})<1
               toadd = KbName(Index); 
               AsteriskBuffer{currentpos}=[AsteriskBuffer{currentpos} toadd(1)]; %adds key to buffer
           end
        end
    end
    DrawFormattedText(win,instr,'center',ymax*ypos_instr,col_text); %draws instructions
    if disp_resp_opt
        DrawFormattedText(win,respopt,xmax*xpos_resp,ypos_respopt,col_text); % draw response options
    end
    for i=1:length(AsteriskBuffer)
        if i==currentpos
            [normBoundsRect, offsetBoundsRect, textHeight, xAdvance] = Screen('TextBounds',win,'0',xmax*xpos_resp, bufspacing(i)); 
            centeredRect = CenterRectOnPointd([0,0,xAdvance*2,textHeight], xmax*xpos_resp+xAdvance/2, bufspacing(i)-textHeight*0.333);
            Screen('FillRect', win, rect_col, centeredRect);
        end
        DrawFormattedText(win, options{i}, xmax*xpos_options, bufspacing(i), col_text); %draws options
        DrawFormattedText(win, AsteriskBuffer{i}, xmax*xpos_resp, bufspacing(i), col_text); %draws keyspressed
    end
    Screen('Flip',win);
    WaitSecs('YieldSecs', .05); % put in small interval to allow other system events
end

response = AsteriskBuffer; 
