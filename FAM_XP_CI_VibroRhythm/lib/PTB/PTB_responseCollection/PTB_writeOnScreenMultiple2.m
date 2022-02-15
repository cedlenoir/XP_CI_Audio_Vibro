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

instr = sprintf(instr); 

if any(strcmpi(varargin, 'respopt'))
    disp_resp_opt = 1; 
    respopt = varargin{find(strcmpi(varargin,'respopt'))+1}; 
    respopt = sprintf(respopt);     
    [x,y,textrect] = DrawFormattedText(win,instr,'center',ymax*ypos_instr,col_text); %draws instructions
    ypos_respopt = textrect(end); 
else
    disp_resp_opt = 0; 
end


returnKey = KbName('return');
deleteKey = KbName('delete');
upkey = KbName('uparrow'); 
downkey = KbName('downarrow'); 
enterpressed=0; %initializes loop flag
currentpos = 1; 
AsteriskBuffer=cell(length(options),1); %initializes buffer

if length(AsteriskBuffer)==2
    bufspacing = linspace(ymax*0.5,ymax*0.6,length(AsteriskBuffer)); 
    xpos_options = 0.5; 
    xpos_resp = 0.44; 
else
    bufspacing = linspace(ymax*0.5,ymax*0.9,length(AsteriskBuffer)); 
    xpos_options = 0.3; 
    xpos_resp = 0.25; 
end

% get coordinates for the text boxes
resp_textbox = zeros(length(options),4); 
option_textbox = zeros(length(options),4); 
for i=1:length(options)
    resp_textbox(i,:) = CenterRectOnPoint(baseRect, xmax*xpos_resp, bufspacing(i)); 
    [~,~,option_textbox(i,:)] = DrawFormattedText(win, options{i}, xmax*xpos_options, bufspacing(i), col_text,[],[],[],[],[],[]); %draws options
end
optionlength = max(option_textbox(:,3)-option_textbox(:,1)); 
% optionheight = max(option_textbox(:,4)-option_textbox(:,2)); 
% option_textbox(:,3) = option_textbox(:,1)+optionlength; 
% option_textbox(:,2) = bufspacing'-optionheight/2; 
% option_textbox(:,4) = option_textbox(:,2) + optionheight; 

optionheight = baseRect(4); 
for i=1:length(options)
    option_textbox(i,:) = CenterRectOnPoint([0,0,optionlength,optionheight], xmax*xpos_options, bufspacing(i)); 
end







KbQueueFlush; 

DrawFormattedText(win,instr,'center',ymax*ypos_instr,col_text); %draws instructions
if disp_resp_opt
    DrawFormattedText(win,respopt,xmax*xpos_resp,ypos_respopt,col_text); % draw response options
end
for i=1:length(AsteriskBuffer)
    if i==currentpos
        Screen('FillRect', win, rect_col, resp_textbox(i,:));
    end
    Screen('FillRect', win, rect_col, option_textbox(i,:));
    DrawFormattedText(win, AsteriskBuffer{i},'center','center',col_text,[],[],[],[],[],resp_textbox(i,:)); %draws responses
    DrawFormattedText(win, options{i},'center','center',col_text,[],[],[],[],[],option_textbox(i,:)); %draws responses
end
Screen('Flip',win);





while ( enterpressed==0 | any(cellfun(@isempty, AsteriskBuffer,'uni',1)))
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
            Screen('FillRect', win, rect_col, resp_textbox(i,:));
        end
        Screen('FillRect', win, rect_col, option_textbox(i,:));
        DrawFormattedText(win, AsteriskBuffer{i},'center','center',col_text,[],[],[],[],[],resp_textbox(i,:)); %draws responses
        DrawFormattedText(win, options{i},'center','center',col_text,[],[],[],[],[],option_textbox(i,:)); %draws responses
    end
    Screen('Flip',win);

    WaitSecs('YieldSecs', .05); % put in small interval to allow other system events
end

response = AsteriskBuffer;







