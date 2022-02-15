
% paths
if ispc
    addpath(genpath('C:\Users\HotDesk\Dropbox\stimulus_presentation\stimulusPresentationLib'));
    stim_list_path = 'C:\Users\HotDesk\Dropbox\stimulus_presentation\XPFamiliarity\stimulus_list.txt';
elseif ismac
    addpath(genpath('~/Dropbox/stimulus_presentation/stimulusPresentationLib'));
    stim_list_path = '~/Dropbox/stimulus_presentation/XPFamiliarity/stimulus_list.txt';
end

SUBJECT = 999; 
key1to7 = KbName({'1!','2@','3#','4$','5%','6^','7&'});
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue


PsychDebugWindowConfiguration
[win,rect,pahandle] = initializePTB('listening', 'builtin', 'volume', 0.0804); % 75dB SPL with Beyerdynamics


types = {'pitch','duration','tempo', 'arithmetics'}; 

instr = 'How demanding did you find the different tasks? \nUse the [up] and [down] arrows to navigate and \nnumber keys to rate the difficulty of the tasks. \nPress [ENTER] when done...\n\n'; 
respopt = '\nUse the [up] and [down] arrows to rate the difficulty of the tasks: \n[1] least difficult \n[7] most difficult\n\n\n'; 
resp = writeOnScreenMultiple2PTB(win, key1to7, instr, types,'respopt',respopt); 
res.subjectiveDifficulty = [types', resp]; 

instr = ['To what extend do you think you used the regular \nbeat in the rhythms to carry out the different tasks? \n\nUse the [up] and [down] arrows to navigate and \nnumber keys to rate how much you used the regular beat in the tasks. \nPress [ENTER] when done...\n\n']; 
respopt = ['\n[1] I did not use the beat at all (it would not help with the task) \n[7] I really focused on the beat, because it made the task much easier \n\n\n']; 
resp = writeOnScreenMultiple2PTB(win, key1to7, instr, types, 'respopt', respopt); 
res.beatUse = [types', resp]; 



%%
cd /Users/tomaslenc/Dropbox/stimulus_presentation/XPFamiliarity
load_path = fullfile('.','to_load');
log_path = fullfile('.','log');

% trial order
fid = fopen(stim_list_path, 'r');
[sound_files] = textscan(fid, '%s %d');
trig_codes = sound_files{2};
sound_files = sound_files{1};
fclose(fid); 

n_blocks =  4;
n_trials = length(sound_files);

trial_order = blockOrder(SUBJECT,length(sound_files),'latin');


% check if you can load all audiofiles
sounds = cell(1,length(sound_files)); 
for i=1:length(sound_files)
    try
        [sounds{i},fs] = audioread([load_path, filesep, sound_files{trial_order(i)}]);
    catch
        error(sprintf('Cannot load %s', sound_files{trial_order(i)}))
    end
end
{sound_files{trial_order}}
options = strcat('track ', cellfun(@num2str, num2cell([1:length(sound_files)]),'un',0)); 

% if end, ask about previous familiarity
instr = 'Do you think you have ever heard any of these tracks \nBEFORE THIS EXPERIMENT?\n\nClick on the track to play it and tick the box left to the track \nif you think you have heard it before this experiment. \nClick on the track again to stop playback.\n\nPress [enter] when done...'; 
respose = tickMousePlayer2PTB(win,pahandle,key1to7,instr,options,sounds)
res.everHeardBefore= [sound_files(trial_order), num2cell(respose)'];
