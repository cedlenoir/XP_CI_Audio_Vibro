function [response]=writeOnScreenPTB(win, allowedkeys, instruction)
[xmax, ymax] = Screen('WindowSize',win);
returnKey = KbName('return');
deleteKey = KbName('delete');
enterpressed=0; %initializes loop flag
AsteriskBuffer=[]; %initializes buffer
KbQueueFlush; 

Screen('TextSize',win,28); %sets textsize for instructions
DrawFormattedText(win,instruction,'center',ymax*0.3); %draws instructions
Screen('TextSize',win,40);  %sets textsize for keys pressed
DrawFormattedText(win, AsteriskBuffer, 'center','center'); %draws keyspressed
Screen('Flip',win);

while ( enterpressed==0 )
    [ pressed, firstPress]=KbQueueCheck; %checks for keys
    enterpressed=firstPress(returnKey); %press return key to terminate each response
    if (pressed & ~enterpressed) %keeps track of key-presses and draws text
        if firstPress(deleteKey) %if delete key then erase last key-press
            AsteriskBuffer=AsteriskBuffer(1:end-1); %erase last key-press
        else %otherwise add to buffer
           firstPress(find(firstPress==0))=NaN; %little trick to get rid of 0s
          [endtime Index]=min(firstPress); % gets the RT of the first key-press and its ID
           if ismember(Index,allowedkeys)
               toadd = KbName(Index); 
               AsteriskBuffer=[AsteriskBuffer toadd(1)]; %adds key to buffer
           end
        end
        Screen('TextSize',win,28); %sets textsize for instructions
        DrawFormattedText(win,instruction,'center',ymax*0.3); %draws instructions
        Screen('TextSize',win,40);  %sets textsize for keys pressed
        DrawFormattedText(win, AsteriskBuffer, 'center','center'); %draws keyspressed
        Screen('Flip',win);
    end;
    WaitSecs('YieldSecs', .05); % put in small interval to allow other system events
end;
response = str2num(AsteriskBuffer); 
