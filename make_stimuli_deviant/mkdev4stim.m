% create 1 deviant cycle with 
% cosine function increasing IOI from standard IOI (stdIOI of 200 ms) to maxIOI ms 
stdIOI=200; 
pardev.maxAudIOI=245; %225
pardev.maxVibIOI=245; %250


%for Vibro (modality 1)
aV=(pardev.maxVibIOI-stdIOI)/2;
bV=stdIOI+aV;
x=linspace(-pi,pi,12);% 12 bins as in the pattern
yV=aV*cos(x)+bV;
% figure
% plot(x,yV)
IOIV=(yV/1000);

% for Audio (modality 2)
aA=(pardev.maxAudIOI-stdIOI)/2;
bA=stdIOI+aA;
x=linspace(-pi,pi,12);% 12 bins as in the pattern 
yA=aA*cos(x)+bA;
% figure
% plot(x,yA)
IOIA=(yA/1000);
 
% we will save all the stimuli in a big structure
pardev.tracks = struct();
 
% first modality
% pardev.tracks(1).name = 'deviant-syncop-vibro';
% pardev.tracks(1).pattern = [1 1 1 1 0 1 1 1 0 0 1 0]; %complex syncopated experiment
% 
% pardev.tracks(1).name = 'deviant-syncopFAM-vibro';
% pardev.tracks(1).pattern = [1 1 1 0 1 1 0 0 1 0 1 0]; %complex syncopated familiarization (26 from Tomas)
% 
pardev.tracks(1).name = 'deviant-UNsyncopFAM-vibro';
pardev.tracks(1).pattern = [1 1 1 0 1 1 1 0 1 1 0 0]; % Unsyncopated for familiarisation 
% 
% second modality 
% pardev.tracks(2).name = 'deviant-syncop-audio';
% pardev.tracks(2).pattern = [1 1 1 1 0 1 1 1 0 0 1 0]; %complex syncopated experiment

% pardev.tracks(2).name = 'deviant-syncopFAM-audio'; 
% pardev.tracks(2).pattern = [1 1 1 0 1 1 0 0 1 0 1 0]; %complex syncopated familiarization (26 from Tomas)

pardev.tracks(2).name = 'deviant-UNsyncopFAM-audio'; 
pardev.tracks(2).pattern = [1 1 1 0 1 1 1 0 1 1 0 0]; % Unsyncopated for familiarisation 


% sampling rate 
pardev.fs          = 44100; 
 
% par.gridIOI      = 0.200;% for standard 
pardev.gridIOIAud  = IOIA;% for deviant Audio 
pardev.gridIOIVib  = IOIV;% for deviant Vibro 
 
% time between two successive events (either sound or silence) 
pardev.eventdur    = 0.030; 
 
% duration of linear onset ramp for the sound event 
pardev.rampon      = 0.010; 
 
% duration of linear offset ramp for the sound event 
pardev.rampoff     = 0.010; 
 
% how many times the rhythmic pattern repeats in each trial 
pardev.ncycles     = 1; % 17 cycles is 40.8s / 25 cycles is 60s(for 2.4s cycle) 
 
% calculate duration of one long trial in seconds 
% par.trialdur    = par.ncycles * length(par.tracks(1).pattern) * par.gridIOI; 
pardev.trialdurAud    = pardev.ncycles * sum(pardev.gridIOIAud(1,:)); 
pardev.trialdurVib    = pardev.ncycles * sum(pardev.gridIOIVib(1,:)); 
 
% vibro carrier f0 
pardev.f0(1) = 126; 
% audio carrier f0 
pardev.f0(2) = 0; 
pardev.ISNOISE = true; % WN carrier
pardev.filtertype = 'bandpass';
pardev.hp = 300;
pardev.lp = 3000;
pardev.bp = [pardev.hp pardev.lp];


%%%% synthesis 
 
% make time vector for one trial 
tAud(1,:) = (0 : 1/pardev.fs : pardev.trialdurAud-1/pardev.fs); 
tVib(1,:) = (0 : 1/pardev.fs : pardev.trialdurVib-1/pardev.fs); 
 
% make carrier for one trial 
pardev.tracks(1).carrier=zeros(1,length(tVib)); 
pardev.tracks(2).carrier=zeros(1,length(tAud)); 
 
pardev.tracks(1).carrier = sin(2*pi*tVib*pardev.f0(1)); 

if pardev.ISNOISE
    pardev.tracks(2).carrier = rand(size(tAud));
else
    pardev.tracks(2).carrier = sin(2*pi*tAud*pardev.f0(2)); 
end
 
% make sure there is no clipping 
for i=1:length(pardev.f0) 
    pardev.tracks(i).carrier = pardev.tracks(i).carrier ./ max(abs(pardev.tracks(i).carrier)); 
end 
 
% make envelope of one sound event 
envEvent = ones(1, round(pardev.eventdur * pardev.fs)); 
 
% apply onset and offset ramp 
envEvent(1:round(pardev.rampon*pardev.fs)) = envEvent(1:round(pardev.rampon*pardev.fs)) .* linspace(0,1,round(pardev.rampon*pardev.fs)); 
 
envEvent(end-round(pardev.rampoff*pardev.fs)+1:end) = envEvent(end-round(pardev.rampoff*pardev.fs)+1:end) .* linspace(1,0,round(pardev.rampoff*pardev.fs)); 
 
 
% go over modalities 
for modaliti=1:2 
    if modaliti == 1 
        % allocate envelope vector for the whole trial (as zeros) 
        envTrialVib(1,:) = zeros(size(pardev.tracks(modaliti).carrier)); 
         
        % make ncycles copies of the rhythmic pattern 
        patternTrialVib(modaliti,:) = repmat(pardev.tracks(modaliti).pattern, 1, pardev.ncycles); 
         
        % go over each event in the trial 
        for i=1:length(patternTrialVib(modaliti,:)) 
            % if the event is sound 
            if patternTrialVib(modaliti,i) 
                % find the time of event onset 
                eventTime = (i-1)*pardev.gridIOIVib(1,i); 
                % convert to index 
                eventIdx = round(eventTime*pardev.fs); 
                % paste the sound event envelope 
                envTrialVib(modaliti,[eventIdx+1:eventIdx+length(envEvent)]) = envEvent; 
            end 
        end 
        % multiply carrier and envelope for the whole trial 
        sVib(1,:) = pardev.tracks(modaliti).carrier .* envTrialVib(1,:); 
        % make it stereo and save to structure 
        pardev.tracks(modaliti).s = [sVib(1,:)',sVib(1,:)']; 
        pardev.tracks(modaliti).env = envTrialVib(1,:); 
    elseif modaliti == 2 
        % allocate envelope vector for the whole trial (as zeros) 
        envTrialAud(1,:) = zeros(size(pardev.tracks(modaliti).carrier)); 
         
        % make ncycles copies of the rhythmic pattern 
        patternTrialAud(modaliti,:) = repmat(pardev.tracks(modaliti).pattern, 1, pardev.ncycles); 
         
        for i=1:length(patternTrialAud(modaliti,:)) 
            % if the event is sound 
            if patternTrialAud(modaliti,i) 
                % find the time of event onset 
                eventTime = (i-1)*pardev.gridIOIAud(1,i); 
                % convert to index 
                eventIdx = round(eventTime*pardev.fs); 
                % paste the sound event envelope 
                envTrialAud(1,[eventIdx+1:eventIdx+length(envEvent)]) = envEvent; 
            end 
        end 
    % multiply carrier and envelope for the whole trial 
    sAud(1,:) = pardev.tracks(modaliti).carrier .* envTrialAud(1,:); 
    
      % Filter audio if f0 = white noise 
    if  pardev.ISNOISE
        
     
        if     strcmp(pardev.filtertype,'bandpass')
            [filtb,filta] = butter(4,pardev.bp/(pardev.fs/2),pardev.filtertype);
            
        elseif strcmp(pardev.filtertype,'high')
            [filtb,filta] = butter(4,pardev.hp/(pardev.fs/2),par.filtertype);
        end
           

                    % test impulse response function (IRF)
                    impulse  = [zeros(1,pardev.fs*5) 1 zeros(1,pardev.fs*5) ];
                    fimpulse = filtfilt(filtb,filta,impulse);
                    imptime  = (0:length(impulse)-1)/pardev.fs;
                    
                    mXir = abs(fft(fimpulse)); 
                    Nir = length(fimpulse); 
                    freq = [0 : floor(Nir/2)]/Nir * pardev.fs; 
                    
                    clf, figure(1)
                    stem(freq, mXir(1:floor(Nir/2)+1), 'marker', 'none')
                    xlim([0,1000])
                    ax = gca;
                    ax.Title.String = 'Filter (impulse function)'
                    xlim([0,5000])
                    
                    
                    % filter carrier
                      sAud(1,:) = filtfilt(filtb,filta, sAud(1,:));
    end
    % make it stereo and save to structure 
    pardev.tracks(modaliti).s = [sAud(1,:)',sAud(1,:)']; 
    pardev.tracks(modaliti).env = envTrialAud(1,:); 
    end 
end 

maxIOI(1) = pardev.maxVibIOI;
maxIOI(2) = pardev.maxAudIOI;

% also write wav file 
for i=1:length(pardev.tracks) 
    if pardev.ISNOISE & i == 2        
        if strcmp(pardev.filtertype,'bandpass')
            filename{i,1}=strcat('dev',num2str(maxIOI(i)),'ms-','WN_BP-',pardev.tracks(i).name,'-',num2str(pardev.lp),'.wav'); 
        elseif strcmp(pardev.filtertype,'high')
           filename{i,1}=strcat('dev',num2str(maxIOI(i)),'ms-','WN_HP-',pardev.tracks(i).name,'.wav');
        end
           audiowrite(filename{i},pardev.tracks(i).s, pardev.fs); 
    else
           filename{i,1}=strcat('dev',num2str(maxIOI(i)),'ms-',num2str(pardev.f0(i)),'hz-',pardev.tracks(i).name,'.wav'); 
           audiowrite(filename{i},pardev.tracks(i).s, pardev.fs); 
    end
end 
 
% save the structure and name according to 
if pardev.ISNOISE
    
    if strcmp(pardev.filtertype,'bandpass')
        
        %Unsyncop familiarization
        filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-','WN_BP-',num2str(pardev.lp),'-','UnsyncopFam','.mat'];
        
%         %Syncop familiarization
%         filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-','WN_BP-',num2str(pardev.lp),'-','syncopFam','.mat'];
%         
%         %Syncop experiment
%         filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-','WN_BP-',num2str(pardev.lp),'.mat'];
%         
    elseif strcmp(pardev.filtertype,'high')
        %Unsyncop familiarization
        filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-','WN_HP-','UnsyncopFam','.mat'];
        
        % Syncop familiarization
        %filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-','WN_HP-','syncopFam','.mat'];
        
%         %Syncop experiment
%         filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-','WN_HP-','.mat'];
        
    end
   
else 
    filenamemat=['dev',num2str(maxIOI(1)),'-',num2str(maxIOI(2)),'ms-',num2str(pardev.f0(1)),'hz-',num2str(pardev.f0(2)),'hz','.mat']; 
end

save(filenamemat,'pardev'); 
 
clear all; 
clc;
