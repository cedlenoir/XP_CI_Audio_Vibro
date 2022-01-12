function XP_CI_AudioVibro(modality,block)
% modality = 1;% for VIBRO; 2 for AUDIO
% order= 1;% for first and 2 for second vibro session
% call
try
    
    % ------ INITIALIZE ------
    %     clear all
    clc
    sca
    rand('state',sum(100*clock));
    WaitSecs(0.1);
    GetSecs;
    
    %     % Look if the iTrial variable exists in the workspace. If not, set it to
    %     % one, which means the experiment will go from the begining.
    %     if exist('iTrial')~=1
    %         iTrial = 1;
    %     end
    %
    %     % counts events to write the log (this should always start at 1 with every
    %     % new recording file)
    %     iEvent = 1;
    %
    %     if iTrial~=1
    %         warning(sprintf('I will NOT start from trial 1, but trial %d instead!\n\nARE YOU SURE???',iTrial))
    %     end
    
    % ------ SUBJECT INFO ------
    prompt          = {'Enter subject ID','Enter notes'};
    dlgtitle        = 'SUBJECT INFO';
    dims            = [1,35;5,35];
    definput        = {'',''};
    subjectInfo     = inputdlg(prompt,dlgtitle,dims,definput); % get info from a dialog prompt
    
    subID      = subjectInfo{1}; %Gets Subject ID
    subNotes   = subjectInfo{2};
    clockVal   = clock; %Current date and time as date vector. [year month day hour minute seconds]
    timestamp  = sprintf('%d-%d-%d_%d-%d-%.0f',clockVal(2),clockVal(3),clockVal(1),clockVal(4),clockVal(5),clockVal(6)); %makes unique filename
    experiment = 'XPCIAudioVibroRhythm'; % name of the experiment
    if modality == 1
        session = 'VIBRO';
    else
        session = 'AUDIO';
    end
    bloc=num2str(block);
    
    %%
    %------ PATHS ------
    addpath(genpath(fullfile('.','lib'))); % add the local PTB library
    stimPath = fullfile('.','stimuli'); % path with the stimuli
    if modality == 1
        instrPath = 'instr1';
    else
        instrPath = 'instr2';
    end
    
    logPath = fullfile('.','log',sprintf('%s_%s',subID,timestamp)); % create folder for this subject and day-time
    if ~isdir(logPath); mkdir(logPath); end
    logfileName = sprintf('log_%s_%s_%s_sub%s_%s.mat',experiment,session,bloc,subID,timestamp);
    
    % logtxtName = sprintf('log_sub%s_%s_%s.txt',experiment,subID,timestamp);
    % fidLog = fopen(fullfile(logPath,logtxtName),'w');
    % fprintf(fidLog,'%s \nsub%s \ndate and time: %s \n\n%s \n\n\n',experiment, subID,timestamp, subNotes);
    
    % ------ PARAMETERS ------
    % set experiment parameters
    cfg = struct();
    
    % load stimuli
    dStim = dir(fullfile(stimPath, '*.mat'));
    stim = load(fullfile(stimPath,dStim.name));
    cfg.stim = stim.par;
    
    cfg.stim.tracks(1).trig = 1; %vibro standard
    cfg.stim.tracks(2).trig = 2; %audio standard
    for i=3:8
        cfg.stim.tracks(i).trig = 3; %deviant vibro1
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cfg.nTrialsListenPerBlock = 15;
    
    cfg.nTrialsTapPerBlock = 7;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cfg.fs = cfg.stim.fs;
    cfg.fsDs = 1000; % downsampling frequency (to log tap data)
    [P,Q] = rat(cfg.fsDs/cfg.fs);
    
    % ------ KEYBOARD ------
    KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
    keyenter    = KbName({'Return'});
    keydelete   = KbName('DELETE');
    keyspace    = KbName('space');
    keyplus     = KbName('+');
    keyminus    = KbName('-');
    keyr        = KbName('r');
    keye        = KbName('e');
    keyl        = KbName('l');
    keyy        = KbName('y');
    keyn        = KbName('n');
    key1to7num  = KbName({'1','2','3','4','5','6','7','8','9','0'});
    key1to7     = KbName({'1!','2@','3#','4$','5%','6^','7&'});
    key1        = KbName({'1!'});
    key2        = KbName({'2@'});
    key1to5     = KbName({'1!','2@','3#','4$','5%'});
    ListenChar(0);
    
    % ------ SOUND ------
    InitializePsychSound(1);  % [reallyneedlowlatency=0]
    devices = PsychPortAudio('GetDevices');
    devIdx = find(~cellfun(@isempty, regexpi({devices.DeviceName},'Fireface')));
    devID = devices(devIdx).DeviceIndex;
    nSoundChans = 8; % open only 8 channels (max 18)
    
    pahandle = PsychPortAudio('Open', devID, 3, 3, cfg.fs, nSoundChans);% pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
    
    
%     cfg.soundVol=0.15;
    cfg.soundVol=0.1;
    PsychPortAudio('Volume',pahandle,cfg.soundVol);
    
    
    bufferSamples = round(cfg.fs * 70); % allocate 70-s buffer
    PsychPortAudio('GetAudioData', pahandle, bufferSamples); %preallocate tapping buffer
    
    bufferSamples = round(cfg.fs * 10); % allocate 10s buffer
    pushDelay = 0.100; % how much data to push at each loop iteration (each iteration will be 1/5 of this)
    pushDelaySamples = round(pushDelay*cfg.fs);
    initPushBuffSamples = bufferSamples/5; % first push N seconds into the buffer
    
%     % prepare white noise if needed
%     if modality == 1
%         [ys,fs]=audioread('bruitblanc.wav');
%     else
%     end
    
    %% INTRO
    
    type(fullfile(instrPath,'instr_beforeStart.txt')) % print intro instructions to the console
    PTB_printNewLine;
    PTB_waitForKeyKbCheck(keyspace);
    
    % ------ VOLUME ------
    % launch GUI to set volume and test triggers
    ListenChar(1);
    cfg.soundVol = PTB_volGUI_RME('pahandle',pahandle,'volume',cfg.soundVol, 'nchan', nSoundChans);
    ListenChar(0);
    
    PTB_printSectionLineThick
    fprintf('Current volume is %.4f\n',PsychPortAudio('Volume',pahandle))
    fprintf('Stimuli loaded. \n')
    fprintf('\npress SPACE to continue...\n')
    PTB_waitForKeyKbCheck(keyspace);
    
    % ------ INTRUCTIONS ------
    type(fullfile(instrPath,'instr_introduction.txt')) % print intro instructions to the console
    PTB_printNewLine;
    PTB_waitForKeyKbCheck(keyspace);
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% EEG session
    
    cfg.subjectID = subID;
    cfg.subject_notes = subNotes;
    cfg.experiment = experiment;
    cfg.timestamp = timestamp;
    cfg.session = session;
    cfg.bloc = bloc;
    
    % random order of the 12 trials (10 standard + 2 deviant not consecutively)
    is_success=0;
    while(~is_success)
        is_success=1;
        trials=[ones(1,9),ones(1,2)+1];
        trials=trials(randperm(length(trials)));
        trials=[1 trials];
        for n=1:11
            sum_n(1,n)=trials(1,n)+trials(1,n+1);
            if sum_n(1,n)==4
                is_success=0;
            end
        end
    end
    % change the second deviant '2' in '3'
%         trials=[1 2 1];
    idxtrials=find(trials==2);
    trials(idxtrials(end))=3;
    trials=[trials,ones(1,10)];
    
    triali = 1;
    eventi = 1;
    
    while 1 % TRIALS
        
        % listening
        if triali<=cfg.nTrialsListenPerBlock
            task = 'listen';
            if modality == 1
                trigCode = cfg.stim.tracks(1).trig;
            else
                trigCode = cfg.stim.tracks(2).trig;
            end
            % tapping
        elseif triali>cfg.nTrialsListenPerBlock
            task = 'tap';
            trigCode = -1;
        end
        
        trialTerminated = 0;
        
        % ---- PREPARE SOUND AND TRIGGER ----
        % change polarity across trials
        if mod(triali,2) == 0
            polarity = 1;
        else
            polarity = -1;
        end
        
        if modality == 1 %vibro
            if block == 1 % block 1
                trial=trials(1,triali);
                switch trial
                    case 1 % vibro standard
                        trackName = cfg.stim.tracks(1).name;
                        s = cfg.stim.tracks(1).s;% s = cfg.stim.tracks(1).s/()
                        s = s * polarity;
                        sDur = length(s)/cfg.fs;
                        trigPulse = zeros(1,size(s,1));
                        trigPulse(1:round(0.100*cfg.fs)) = 1;
                        trigCode = cfg.stim.tracks(1).trig;
                        trigChan = 3;
                    case 2 % vibro first deviant
                        trackName = cfg.stim.tracks(3).name;
                        s = cfg.stim.tracks(3).s;
                        s = s * polarity;
                        sDur = length(s)/cfg.fs;
                        trigPulse = zeros(1,size(s,1));
                        trigPulse(1:round(0.100*cfg.fs)) = 1;
                        trigCode = cfg.stim.tracks(3).trig;
                        trigChan = 4;
                    case 3 % vibro second deviant
                        trackName = cfg.stim.tracks(4).name;
                        s = cfg.stim.tracks(4).s;
                        s = s * polarity;
                        sDur = length(s)/cfg.fs;
                        trigPulse = zeros(1,size(s,1));
                        trigPulse(1:round(0.100*cfg.fs)) = 1;
                        trigCode = cfg.stim.tracks(3).trig;
                        trigChan = 4;
                end
            elseif block == 2 % block 2 vibro
                trial=trials(1,triali);
                switch trial
                    case 1 % vibro standard
                        trackName = cfg.stim.tracks(1).name;
                        s = cfg.stim.tracks(1).s;
                        s = s * polarity;
                        sDur = length(s)/cfg.fs;
                        trigPulse = zeros(1,size(s,1));
                        trigPulse(1:round(0.100*cfg.fs)) = 1;
                        trigCode = cfg.stim.tracks(1).trig;
                        trigChan = 3;
                    case 2 % vibro first deviant
                        trackName = cfg.stim.tracks(7).name;
                        s = cfg.stim.tracks(7).s;
                        s = s * polarity;
                        sDur = length(s)/cfg.fs;
                        trigPulse = zeros(1,size(s,1));
                        trigPulse(1:round(0.100*cfg.fs)) = 1;
                        trigCode = cfg.stim.tracks(7).trig;
                        trigChan = 4;
                    case 3 % vibro second deviant
                        trackName = cfg.stim.tracks(8).name;
                        s = cfg.stim.tracks(8).s;
                        s = s * polarity;
                        sDur = length(s)/cfg.fs;
                        trigPulse = zeros(1,size(s,1));
                        trigPulse(1:round(0.100*cfg.fs)) = 1;
                        trigCode = cfg.stim.tracks(8).trig;
                        trigChan = 4;
                end
            end
        elseif modality == 2 % audio
            trial=trials(1,triali);
            switch trial
                case 1 % audio standard
                    trackName = cfg.stim.tracks(2).name;
                    s = cfg.stim.tracks(2).s;
                    s = s * polarity;
                    sDur = length(s)/cfg.fs;
                    trigPulse = zeros(1,size(s,1));
                    trigPulse(1:round(0.100*cfg.fs)) = 1;
                    trigCode = cfg.stim.tracks(2).trig;
                    trigChan = 4;
                case 2 % audio first deviant
                    trackName = cfg.stim.tracks(5).name;
                    s = cfg.stim.tracks(5).s;
                    s = s * polarity;
                    sDur = length(s)/cfg.fs;
                    trigPulse = zeros(1,size(s,1));
                    trigPulse(1:round(0.100*cfg.fs)) = 1;
                    trigCode = cfg.stim.tracks(5).trig;
                    trigChan = 3;
                case 3 % audio second deviant
                    trackName = cfg.stim.tracks(6).name;
                    s = cfg.stim.tracks(6).s;
                    s = s * polarity;
                    sDur = length(s)/cfg.fs;
                    trigPulse = zeros(1,size(s,1));
                    trigPulse(1:round(0.100*cfg.fs)) = 1;
                    trigCode = cfg.stim.tracks(6).trig;
                    trigChan = 3;
            end
        end
        
        clc % clear command window to make sure the exerimenter notices this will be a tapping trial...
        if strcmp(task,'tap')
            type(fullfile(instrPath,'instr_tappingTrial.txt'));
        else
            type(fullfile(instrPath,'instr_listeningTrial.txt'));
        end
        PTB_printNewLine;
        PTB_waitForKeyKbCheck(keyspace);
        type(fullfile(instrPath,'instr_startSoundPlayback.txt'));
        PTB_printNewLine;
        PTB_waitForKeyKbCheck(keyenter);
        WaitSecs(rand(1));  % wait 0-1 sec
        if modality == 1
            sound(ys,fs)
            disp('white noise on!')
        else
        end
        WaitSecs(2);
        
        % ---- PLAY SOUND ----
        % do the first push of audio to the buffer
        audio2push = zeros(nSoundChans, initPushBuffSamples);
        audio2push(1,:) = s(1:initPushBuffSamples,1); % left earphone
        if size(s,2)==2
            audio2push(2,:) = s(1:initPushBuffSamples,2); % right earphone
        end
        audio2push(5,:) = s(1:initPushBuffSamples,1); % copy of stimulus -> feed back to IN8 and record with tapping
        if trigChan>0
            audio2push(trigChan,:) = trigPulse(1:initPushBuffSamples);
        end
        currAudioIdx = initPushBuffSamples;
        [currUnderflow, nextSampleStartIdx, nextSampleETASecs] = PsychPortAudio('FillBuffer',pahandle,audio2push);
        
        % preallocate tapping data
        tapdata = zeros(2,(round(sDur)+10)*cfg.fs);
        tapidx = 0;
        
        % start playback
        startTime = PsychPortAudio('Start',pahandle,0,[],1);  % handle, repetitions, when=0, waitForStart
        % NOTE: above, need to set repetitions=0, otherwise it will not
        % allow you to seamlessly push more data into the buffer once the
        % sound is playing
        
        % initialise progress bar...
        type(fullfile(instrPath,'instr_playbackStarted.txt'));
        PTB_printNewLine;
        textprogressbar('trial progress: ');
        
        % PLAYBACK LOOP
        currTime = GetSecs;
        while 1
            WaitSecs(pushDelay/5);
            
            % update progress bar
            percent_progress = (currTime-startTime)/sDur*100;
            textprogressbar(percent_progress);
            
            % push data into the audio buffer
            if currAudioIdx < length(s)
                if currAudioIdx+pushDelaySamples > length(s)
                    audio2push              = zeros(nSoundChans, length(s)-currAudioIdx);
                    audio2push(1,:)         = s(currAudioIdx+1:end,1); % left earphone
                    if size(s,2)==2
                        audio2push(2,:)     = s(currAudioIdx+1:end,2); % right earphone
                    end
                    audio2push(5,:)         = s(currAudioIdx+1:end,1); % copy of stimulus -> feed back to IN8 and record with tapping
                    if trigChan>0
                        audio2push(trigChan,:) = trigPulse(currAudioIdx+1:end);
                    end
                    currAudioIdx          = inf;
                else
                    audio2push              = zeros(nSoundChans, pushDelaySamples);
                    audio2push(1,:)         = s(currAudioIdx+1:currAudioIdx+pushDelaySamples,1); % left earphone
                    if size(s,2)==2
                        audio2push(2,:)     = s(currAudioIdx+1:currAudioIdx+pushDelaySamples,2); % right earphone
                    end
                    audio2push(5,:)         = s(currAudioIdx+1:currAudioIdx+pushDelaySamples,1); % copy of stimulus -> feed back to IN8 and record with tapping
                    if trigChan>0
                        audio2push(trigChan,:) = trigPulse(currAudioIdx+1:currAudioIdx+pushDelaySamples);
                    end
                    currAudioIdx          = currAudioIdx+pushDelaySamples;
                end
                [currUnderflow, nextSampleStartIdx, nextSampleETASecs] = PsychPortAudio('FillBuffer',pahandle,audio2push,1);
            end
            
            % fetch datta from the audio buffer (tapping)
            fetchedAudio = PsychPortAudio('GetAudioData', pahandle);
            if ~isempty(fetchedAudio)
                tapdata(:,tapidx+1:tapidx+size(fetchedAudio,2)) = fetchedAudio([1,8],:); % extract channel 1 with tapping box, and channel 8 with stimulus copy
                tapidx = tapidx + size(fetchedAudio,2);
            end
            
            % exit the loop when playback ended
            currTime = GetSecs;
            if currTime-startTime >= sDur
                PsychPortAudio('Stop', pahandle);
                break;
            end
            
            % if DELETE pressed terminate the trial
            [keyDown, secs, keyCode] = KbCheck(-1);
            if ismember(find(keyCode),[keydelete])
                trialTerminated = 1;
                PsychPortAudio('Stop', pahandle);
                break
            end
            
        end
        
        textprogressbar(' end of playback');
        WaitSecs(0.5);
        clear sound;
        
        % do the final fetch from the input buffer
        fetchedAudio = PsychPortAudio('GetAudioData', pahandle);
        tapdata(:,tapidx+1:tapidx+size(fetchedAudio,2)) = fetchedAudio([1,8],:); % extract channel 1 with tapping box, and channel 8 with stimulus copy
        tapidx = tapidx + size(fetchedAudio,2);
        
        % ---- SAVE stimulus+trigger+tapping if tapping trial as audiofile ----
        tapdataDs = struct('tapdata', resample(tapdata(1,:),P,Q), 'fs', cfg.fsDs);
        if trialTerminated
            fileNameTap = fullfile(logPath, sprintf('%s_%s_%s_ID%s_%s_%s_%s_event%d_trial%d_TERMINATED.wav', experiment, session, bloc, subID, timestamp, trackName, task, eventi, triali));
        else
            fileNameTap = fullfile(logPath, sprintf('%s_%s_%s_ID%s_%s_%s_%s_event%d_trial%d.wav', experiment, session, bloc, subID, timestamp, trackName, task, eventi, triali));
        end
        disp('saving data...')
        audiowrite(fileNameTap, tapdata', cfg.fs); % 'BitsPerSample' -> only 8 bit resolution to save faster...
        
        % ---- UPDATE LOG ----
        cfg.log.trial(eventi).trackName = trackName;
        cfg.log.trial(eventi).startTime = startTime;
        cfg.log.trial(eventi).trigCode = trigCode;
        cfg.log.trial(eventi).trialIdx = triali;
        cfg.log.trial(eventi).eventIdx = eventi;
        cfg.log.trial(eventi).polarity = polarity;
        cfg.log.trial(eventi).session = session;
        cfg.log.trial(eventi).bloc = bloc;
        cfg.log.trial(eventi).soundVol = PsychPortAudio('Volume',pahandle);
        cfg.log.trial(eventi).trialTerminated = trialTerminated;
        cfg.log.trial(eventi).task = task;
        cfg.log.trial(eventi).trials = trials;
        cfg.log.trial(eventi).tapData = tapdataDs;
        cfg.log.trial(eventi).badTrial = 0;
        
        % ---- DISPLAY INSTRUCTIONS ----
        type(fullfile(instrPath,'instr_afterTrial.txt'));
        fprintf('\t--> to set Volume, press L (launch GUI)\n\n')
        PTB_printNewLine;
        idx = PTB_waitForKeyKbCheck([keyspace,keyr,keye,keyl]);
        if ismember(keyl,idx)
            % launch GUI to set volume and test triggers
            ListenChar(1);
            cfg.soundVol = PTB_volGUI_RME('pahandle',pahandle,'volume',cfg.soundVol,'nchan',nSoundChans);
            ListenChar(0);
            PTB_printSectionLineThick
            fprintf('Current volume is %.4f\n',PsychPortAudio('Volume',pahandle))
            type(fullfile(instrPath,'instr_afterTrial.txt'));
            PTB_printNewLine;
            idx = PTB_waitForKeyKbCheck([keyspace,keyr,keye]);
        end
        if ismember(keyspace,idx)
            % go to the next condition
            triali = triali+1; % update the condition index
            if triali > (cfg.nTrialsListenPerBlock+cfg.nTrialsTapPerBlock)
                break % break the while loop once all trials have been done for this track
            end
        elseif ismember(keyr,idx)
            % don't update the condition index and repeat trial
            cfg.log.trial(triali).badTrial = 1;
            triali = triali; % update the condition index
        elseif ismember(keye,idx)
            % termintate the experiment
            error(sprintf('\nexperiment terminated manually\n... data logged ...\n\n\n'))
        end
        eventi = eventi+1;
    end
    
    %% SAVE AND CLEAN UP
    clc
    fprintf('\n\n\n\n\nEND OF EXPERIMENT, THANK YOU ;)\n\n\n\n\n\n\n')
    save(fullfile(logPath,logfileName),'cfg');
    
    % copy the script file to the log folder
%     if ~isempty(mfilename)
%         copyfile([mfilename,'.m'], fullfile(logPath,[mfilename,'.m']));
%     end
%     
    sca;
    PsychPortAudio('Close');
    ListenChar(0);
    
catch e
    try
        disp('saving log')
        save(fullfile(logPath,logfileName),'log');
        disp('data log saved')
    catch
        disp('data log not saved')
    end
    rethrow(e)
end
end
