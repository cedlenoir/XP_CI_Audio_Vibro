function sendMOTUtrig(pahandle,trig)    




fs = 44100; 
clickdur = 0.001; 
clickamplitude = 0.9; 

click = [repmat(clickamplitude, 1,round(fs*clickdur))]; 
silence = zeros(1,length(click)); 

if trig==1
    % sound to MAIN OUTS (L and R) and trigger click to channel 1
    s = [silence;silence;click;silence]; 
elseif trig==2
    % sound to MAIN OUTS (L and R) and trigger click to channel 2
    s = [silence;silence;silence;click]; 
elseif trig==3
    s = [silence;silence;click;click]; 
end

PsychPortAudio('FillBuffer',pahandle,s);
PsychPortAudio('Start',pahandle); 
