function [response]=writeOnScreenPTB(win, pahandle, allowedkeys, instr, options, sounds)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sounds is a cell containing all the soundfiles (N==length(options)
% 
% 
% 
% 
% 
% 
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ShowCursor; 
mouseind = GetMouseIndices; 
mouseind = max(mouseind); 

col_text = repmat(WhiteIndex(win),1,3); 
[xmax, ymax] = Screen('WindowSize',win);
[xcenter, ycenter] = RectCenter([0, 0, xmax, ymax]);
Screen('TextSize',win,35);  %sets textsize for keys pressed

baseRect = [0 0 50 50];
rect_col = [0.2, 0.2, 0.2]; 

ypos_instr = 0.1; 
xpos_tick = 0.25; 
xpos_opt = 0.3; 
yspacing = linspace(ymax*0.5,ymax*0.9,length(options)); 

returnKey = KbName('return');
deleteKey = KbName('delete');
upkey = KbName('uparrow'); 
downkey = KbName('downarrow'); 

enterpressed=0; %initializes loop flag
selected = logical(zeros(1,length(options))); 
clicked_play = logical(zeros(1,length(options))); 
isplaying = (zeros(1,length(options))); 


rect_coord_play = zeros(length(options),4); 
[~,idx] = max(cellfun(@length, options)); 
for i=1:length(options)
    [nx, ny, textbounds] = DrawFormattedText(win, options{i}, xmax*xpos_opt, yspacing(i), col_text); %draws options
    rect_coord_play(i,:) = textbounds; 
end

rect_coord_tick = zeros(length(options),4); 
for i=1:length(options)
    rect_coord_tick(i,:) = CenterRectOnPoint(baseRect, xmax*xpos_tick, mean(rect_coord_play(i,[2,4])));
end

%--------------------------first render----------------------------------------------
KbQueueFlush; 

DrawFormattedText(win,instr,'center',ymax*ypos_instr,col_text); %draws instructions
for i=1:length(options)
    Screen('FillRect', win, rect_col, rect_coord_tick(i,:));
    Screen('FillRect', win, rect_col, rect_coord_play(i,:));
    DrawFormattedText(win, options{i},'center','center', col_text,[],[],[],[],[],rect_coord_play(i,:)); %draws options
end
Screen('Flip',win);


%---------------------------loop---------------------------------------------
while ( enterpressed==0 )

    a = PsychPortAudio('GetStatus',pahandle); 
    if ~a.Active; isplaying = (zeros(1,length(options))); end; 
    
    [pressed, firstPress]=KbQueueCheck; %checks for keys
    enterpressed=firstPress(returnKey); %press return key to terminate each response

    [x, y, buttons] = GetMouse(win);    % Get the current position of the mouse
    but_rel = buttons; 
    while any(but_rel) % wait for release
          [~,~,but_rel] = GetMouse;
    end
    
    if buttons(1) 
        for i=1:length(selected)
            if  IsInRect(x, y, rect_coord_tick(i,:));    % See if the mouse cursor is inside the square
                selected(i) = ~selected(i); 
            end
        end
        for i=1:length(clicked_play)
            if  IsInRect(x, y, rect_coord_play(i,:));    % See if the mouse cursor is inside the square
                % if playing stop it
                if isplaying(i)
                    PsychPortAudio('Stop',pahandle);
                    isplaying = (zeros(1,length(options))); 
                % if not playing play it
                else
                    PsychPortAudio('Stop',pahandle);
                    clicked_play(i) = ~clicked_play(i); 
                    isplaying = (zeros(1,length(options))); 
                    isplaying(i) = 1; 
                end
            end
        end
    end
    
    % play if asked
    if any(clicked_play)
        s = prepareSound(sounds{find(clicked_play)});
        PsychPortAudio('FillBuffer',pahandle,s);
        PsychPortAudio('Start',pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
        clicked_play = logical(zeros(1,length(options))); 
    end
    
    % render
    DrawFormattedText(win,instr,'center',ymax*ypos_instr,col_text); %draws instructions
    for i=1:length(options)
        if selected(i)
            Screen('FillRect', win, [1 0 0], rect_coord_tick(i,:));
        else
            Screen('FillRect', win, rect_col, rect_coord_tick(i,:));
        end
        
        Screen('FillRect', win, rect_col, rect_coord_play(i,:));
        DrawFormattedText(win, options{i},'center','center', col_text,[],[],[],[],[],rect_coord_play(i,:)); %draws options
    end
    Screen('Flip',win);
    WaitSecs('YieldSecs', .050); % put in small interval to allow other system events
end


response = selected;
HideCursor







function stopSoundPTB(pahandle)
    PsychPortAudio('Stop',pahandle);



function playSoundPTB(s, pahandle)
%     a = PsychPortAudio('GetStatus',pahandle); 
    PsychPortAudio('FillBuffer',pahandle,s);
    PsychPortAudio('Start',pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart







