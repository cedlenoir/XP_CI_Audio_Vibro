function [thr,UD] = setVolumeUDPTB(win, pahandle, dev_idx, varargin)
% 
% we will be working with dBFS here, so we will have negative values with
% maximum is 0 dB (which corresponds to amplitude 1)
% 
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
%     step_dB     change in volume for each step in dB (default 2 dB)
% 
% --------------------- OUTPUTS ---------------------------
% thr             estimated threshold
% 
% 
% 
% ---------------------------------------------------------



[xmax, ymax]        = Screen('WindowSize',win);
[xcenter, ycenter]  = RectCenter([0, 0, xmax, ymax]);

pastatus    = PsychPortAudio('GetStatus',pahandle); 
fs          = pastatus.SampleRate; 
ramp_samp   = round(0.01*fs); 
f0          = 440; 
tone_dur    = 1; 
start_vol   = 0.0016; % starting point
step_dB     = 2; 
up          = 1; 
down        = 1; 
stopcriterion = 'reversals';   
stoprule    = 10; % number of reversals
startval    = 20*log10(start_vol); 
reject_reversals = 2; 

adev = PsychPortAudio('GetDevices'); 
n_chan = adev(dev_idx).NrOutputChannels; 

%------------------------- parse varargin ---------------------
if any(strcmpi(varargin,'f0'))
    f0 = varargin{find(strcmpi(varargin,'f0'))+1}; 
end
if any(strcmpi(varargin,'tone_dur'))
    tone_dur = varargin{find(strcmpi(varargin,'tone_dur'))+1}; 
end
if any(strcmpi(varargin,'start_vol'))
    start_vol = varargin{find(strcmpi(varargin,'start_vol'))+1}; 
end
if any(strcmpi(varargin,'step_dB'))
    step_dB = varargin{find(strcmpi(varargin,'step_dB'))+1}; 
end
if any(strcmpi(varargin,'stop_reversals'))
    stoprule = varargin{find(strcmpi(varargin,'stop_reversals'))+1}; 
end
if any(strcmpi(varargin,'reject_reversals'))
    reject_reversals = varargin{find(strcmpi(varargin,'reject_reversals'))+1}; 
end


%--------------------------------------------------------------
t = [0:1*fs-1]/fs; 
s = 1 * sin(2*pi*t*f0); 
s(1:ramp_samp) = s(1:ramp_samp).*linspace(0,1,ramp_samp); 
s(end-ramp_samp+1:end) = s(end-ramp_samp+1:end).*linspace(1,0,ramp_samp); 

s_out = zeros(n_chan, length(s)); 
s_out(1,:) = s; 
s_out(2,:) = s; 




UD = PAL_AMUD_setupUD('up',up,'down',down, 'StepSizeDown',step_dB,'StepSizeUp', ...
     step_dB,'stopcriterion',stopcriterion,'stoprule',stoprule, ...
     'startvalue',startval, 'xMax',0);

 
 

DrawFormattedText(win,'Let''s set the sound volume.\n\n...','center',ymax*0.2,[1,1,1]);
DrawFormattedText(win,'Press enter to start. \n\n\n\n','center','center',[1,1,1]);
Screen('Flip',win);
PTB_waitForKey(KbName('enter')); 

DrawFormattedText(win,'Let''s set the sound volume.\n\n...','center',ymax*0.2,[1,1,1]);
DrawFormattedText(win,'Press [Y or1] if the tone was present. \nPress [N or 2] if the tone was absent. \n\n\n\n','center','center',[1,1,1]);
Screen('Flip',win);

PsychPortAudio('FillBuffer',pahandle, s_out); 
PsychPortAudio('Volume', pahandle, 10^(UD.startValue/20)); 
sw=0; 
while sw==0 & ~UD.stop
    
    WaitSecs(rand+0.5); 
    
    PsychPortAudio('Start',pahandle)
    PsychPortAudio('Stop',pahandle,1); 
    
    idx = PTB_waitForKey([KbName({'y','1','2'}),KbName('n')]);

    if idx==KbName('y') | idx==KbName('1')
        UD = PAL_AMUD_updateUD(UD, 1); %update UD structure
    elseif idx==KbName('n') | idx==KbName('2')
        UD = PAL_AMUD_updateUD(UD, 0); %update UD structure
    elseif idx==KbName('escape') | idx==KbName('/')
        sw=1; 
    end
    
    new_vol = 10^(UD.xCurrent/20); 
    old_vol = PsychPortAudio('Volume', pahandle, new_vol); 
    
end


thr = PAL_AMUD_analyzeUD(UD, 'reversals', max(UD.reversal)-reject_reversals);


