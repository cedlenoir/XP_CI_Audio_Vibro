function [response]=writeOnScreenPTB(win, allowedkeys, instruction, options)

mouseind = GetMouseIndices; 
mouseind = max(mouseind); 

col_text = repmat(WhiteIndex(win),1,3); 
[xmax, ymax] = Screen('WindowSize',win);
[xcenter, ycenter] = RectCenter([0, 0, xmax, ymax]);

baseRect = [0 0 50 50];
rect_col = [0.2, 0.2, 0.2]; 
rect_sel_col = [0.2, 0.2, 0.2]; 

returnKey = KbName('return');
deleteKey = KbName('delete');
upkey = KbName('uparrow'); 
downkey = KbName('downarrow'); 
enterpressed=0; %initializes loop flag
selected = logical(zeros(1,length(options))); 
bufspacing = linspace(ymax*0.5,ymax*0.9,length(options)); 

rect_coord = zeros(length(options),4); 
for i=1:length(options)
    [normBoundsRect, offsetBoundsRect, textHeight, xAdvance] = Screen('TextBounds',win,'0',xmax*0.25, bufspacing(i)); 
    rect_coord(i,:) = CenterRectOnPointd([0,0,xAdvance*2,textHeight], xmax*0.25+xAdvance/2, bufspacing(i)-textHeight*0.333);
end

%--------------------------first render----------------------------------------------
KbQueueFlush; 

Screen('TextSize',win,40); %sets textsize for instructions
DrawFormattedText(win,instruction,'center',ymax*0.2,col_text); %draws instructions
Screen('TextSize',win,35);  %sets textsize for keys pressed
for i=1:length(options)
    Screen('FillRect', win, rect_col, rect_coord(i,:));
    DrawFormattedText(win, options{i}, xmax*0.3, bufspacing(i), col_text); %draws options
end
Screen('Flip',win);


%---------------------------loop---------------------------------------------
while ( enterpressed==0 )
    
    [x, y, buttons] = GetMouse(win);    % Get the current position of the mouse

    [pressed, firstPress]=KbQueueCheck; %checks for keys
    enterpressed=firstPress(returnKey); %press return key to terminate each response
    
    if buttons(1) 
        isinside = zeros(size(selected)); 
        for i=1:length(isinside)
            if  IsInRect(x, y, rect_coord(i,:));    % See if the mouse cursor is inside the square
                selected(i)=~selected(i); 
            end
        end
    end
        
    % render
    Screen('TextSize',win,40); %sets textsize for instructions
    DrawFormattedText(win,instruction,'center',ymax*0.2,col_text); %draws instructions
    Screen('TextSize',win,35);  %sets textsize for keys pressed
    for i=1:length(options)
        if selected(i)
            Screen('FillRect', win, [1 0 0], rect_coord(i,:));
        else
            Screen('FillRect', win, rect_col, rect_coord(i,:));
        end
        DrawFormattedText(win, options{i}, xmax*0.3, bufspacing(i), col_text); 
    end
    Screen('Flip',win);
    
    WaitSecs('YieldSecs', .05); % put in small interval to allow other system events
    end

response = selected; 
