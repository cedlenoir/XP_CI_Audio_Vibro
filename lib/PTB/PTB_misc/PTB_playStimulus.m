% load
[fileName,pathName] = uigetfile('*.wav;*.mp3','choose sound file','/Users/philbrown/Documents/MATLAB/stimuli');
[s,fs] = audioread([pathName,filesep,fileName]);
s = prepareSound(s);


% get RMS
s_rms = rms([rms(s(1,:)),rms(s(2,:))]);
target_rms = sqrt(0.5);
gain_needed = 20*log10(target_rms/s_rms);



% set your target volume
baseline = 0.0143;   %calibrated 80dB
% baseline = 0.008;   %calibrated 75dB
% baseline = 0.0045;   %calibrated 70dB


volume = baseline * 10^(gain_needed/20); 


if volume>0.3
    warning(sprintf('\nREQUESTED VOLUME TOO HIGH!!! \nRISK OF HEARING DAMAGE!!!!! \n\n'))
end

[~,~,soundHandle]=initializePsychtoolbox('eeg','noScreen', 'volume', volume, 'focusrite');  

for i=1:10
    
disp(sprintf('\npress SPACE to start...'));
KbStrokeWait();
disp(sprintf('wait for it...'));
WaitSecs(2+rand(1)*2);  % wait 2-4 sec
disp(sprintf('PLAYING!!'));
         


PsychPortAudio('FillBuffer',soundHandle,s);
startTime = PsychPortAudio('Start',soundHandle,[],[],1);  % handle, repetitions, when=0, waitForStart
[actualStartTime, trackPositionWhenEnded, nBufferOverruns, estStopTime] = PsychPortAudio('Stop',soundHandle,1); %actualStartTime is the same as returned by Start command in WaitForStart mode


end

closePsychtoolbox()