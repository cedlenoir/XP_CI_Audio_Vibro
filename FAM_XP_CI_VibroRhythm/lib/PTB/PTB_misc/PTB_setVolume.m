function vol = PTB_setVolume(win, pahandle, dev_idx, varargin)

% --------------------- INPUTS ---------------------------
% win             handle for the screen
% pahandle        handle of the audio device
% dev_idx         index of the audio device (sound card)
%                 this is not pahandle, this is what you get with PsychPortAudio('GetDevices')
% 
% varargin
% 
%     f0          frequency of the test tone (default 440 hz)
%     tone_dur    duration of the test tone (default 1 sec)
%     vol         starting volume (default 0.05)
%     step_dB     change in volume for each step in dB (default 3 dB)
% 
% --------------------- OUTPUTS ---------------------------
% vol             the final volume



[xmax, ymax]        = Screen('WindowSize',win);
[xcenter, ycenter]  = RectCenter([0, 0, xmax, ymax]);

pastatus    = PsychPortAudio('GetStatus',pahandle); 
fs          = pastatus.SampleRate; 
ramp_samp   = round(0.01*fs); 
f0          = 440; 
tone_dur    = 1; 
vol         = 0.01; 
step_dB     = 3; 

adev = PsychPortAudio('GetDevices'); 
n_chan = adev(dev_idx).NrOutputChannels; 

%------------------------- parse varargin ---------------------
if any(strcmpi(varargin,'f0'))
    f0 = varargin{find(strcmpi(varargin,'f0'))+1}; 
end
if any(strcmpi(varargin,'tone_dur'))
    tone_dur = varargin{find(strcmpi(varargin,'tone_dur'))+1}; 
end
if any(strcmpi(varargin,'vol'))
    vol = varargin{find(strcmpi(varargin,'vol'))+1}; 
end
if any(strcmpi(varargin,'step_dB'))
    step_dB = varargin{find(strcmpi(varargin,'step_dB'))+1}; 
end

%--------------------------------------------------------------
t = [0:1*fs-1]/fs; 
s = 1 * sin(2*pi*t*f0); 
s(1:ramp_samp) = s(1:ramp_samp).*linspace(0,1,ramp_samp); 
s(end-ramp_samp+1:end) = s(end-ramp_samp+1:end).*linspace(1,0,ramp_samp); 

s_out = zeros(n_chan, length(s)); 
s_out(1,:) = s; 
s_out(2,:) = s; 


DrawFormattedText(win,'Let''s set the sound volume.\n\n...','center',ymax*0.2,[1,1,1]);
DrawFormattedText(win,'Press arrow UP to hear sound louder. \nPress arrow DOWN to hear sound softer. \n\nIf everything is ok, press ENTER to continue.\n\n','center','center',[1,1,1]);
Screen('Flip',win);

PsychPortAudio('FillBuffer',pahandle, s_out); 
sw=0; 
while sw==0

    vol 
    PsychPortAudio('Volume', pahandle, vol); 
    PsychPortAudio('Start',pahandle); 
    PsychPortAudio('Stop',pahandle,1); 
    
    idx = PTB_waitForKey(KbName({'space','enter','DownArrow','2','UpArrow','8'}));
    if idx==KbName('DownArrow') | idx==KbName('2')
        vol = max(0, vol/10^(step_dB/20)); 
    elseif idx==KbName('UpArrow') | idx==KbName('8')
        vol = min(1, vol*10^(step_dB/20)); 
    elseif idx==KbName('space') | idx==KbName('enter')
        sw=1; 
    end
end

