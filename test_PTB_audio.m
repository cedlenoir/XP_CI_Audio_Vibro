
load('stimuli/stimuli.mat')

[s,fs] = audioread('stimuli/audio_stim250_mo.wav'); 

pahandle = PsychPortAudio('Open', 1, 1, 1,fs);

PsychPortAudio('FillBuffer', pahandle, [s,s]' ); 

% % pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
% pahandle = PsychPortAudio('Open', 1, 1, 1, stim.par.fs);
% 
% PsychPortAudio('FillBuffer', pahandle, [stim.par.tracks(1).s, stim.par.tracks(1).s]' ); 
% 
t0 = GetSecs; 

PsychPortAudio('Start',pahandle,[],t0+5,1); 

PsychPortAudio('Stop',pahandle,0); 

PsychPortAudio('Close');
