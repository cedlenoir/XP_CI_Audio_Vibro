function doSoundCheckPTB(win, pahandle, varargin)

[xmax, ymax]        = Screen('WindowSize',win);
[xcenter, ycenter]  = RectCenter([0, 0, xmax, ymax]);

pastatus    = PsychPortAudio('GetStatus',pahandle); 
fs          = pastatus.SampleRate; 
t           = [0:1*fs-1]/fs; 
ramp_samp   = round(0.01*fs); 

s = 0.7 * sin(2*pi*t*440); 
s(1:ramp_samp) = s(1:ramp_samp).*linspace(0,1,ramp_samp); 
s(end-ramp_samp+1:end) = s(end-ramp_samp+1:end).*linspace(1,0,ramp_samp); 

R = cat(1,zeros(1,length(s)),s); 
L = cat(1,s,zeros(1,length(s))); 

if any(strcmpi(varargin,'motu'))
    R = [R; zeros(size(R))]; 
    L = [L; zeros(size(L))]; 
end

sw=0; 
while sw==0
    
    DrawFormattedText(win,'This is a soundcheck\n\n...','center',ymax*0.2,[1,1,1]);
    DrawFormattedText(win,'Press [z] to hear sound in your LEFT ear. \nPress [m] to hear sound in your RIGHT ear. \n\nIf everything is ok, press SPACE to continue.\n\n','center','center',[1,1,1]);
    Screen('Flip',win);
    
    idx = waitForKey([KbName('space'),KbName('z'),KbName('m')]);
    
    if idx==KbName('z')
        PsychPortAudio('FillBuffer',pahandle, L); 
        PsychPortAudio('Start',pahandle)
        PsychPortAudio('Stop',pahandle,1); 
        
    elseif idx==KbName('m')
        PsychPortAudio('FillBuffer',pahandle, R); 
        PsychPortAudio('Start',pahandle)
        PsychPortAudio('Stop',pahandle,1); 
        
    elseif idx==KbName('space')
        sw=1; 
        
    end
    
end

