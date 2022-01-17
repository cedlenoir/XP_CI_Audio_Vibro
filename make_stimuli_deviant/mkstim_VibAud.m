function mkstim_VibAud(SUBID)

% Creates audio stimuli for XPVibro experiment !
%SUBID should be string!
SUBID='001';
par.sub=SUBID;
devaud=str2double(inputdlg('maximum IOI for deviant audio cycle (default 25ms):'));
devvib=str2double(inputdlg('maximum IOI for deviant vibro cycle (default 45ms):'));
% we will save all the stimuli in a big structure
par.tracks = struct();
par.devaudio=devaud;
par.devvibro=devvib;
% first modality
par.tracks(1).name = 'syncop-vibro';
par.tracks(1).pattern = [1 1 1 1 0 1 1 1 0 0 1 0]; %complex syncopated experiment

% second modality
par.tracks(2).name = 'syncop-audio';
par.tracks(2).pattern = [1 1 1 1 0 1 1 1 0 0 1 0]; %complex syncopated experiment

% sampling rate
par.fs           = 44100;

par.gridIOI        = 0.2;
par.maxAudio       = par.gridIOI*1000 + par.devaudio;
par.maxVibro       = par.gridIOI*1000 + par.devvibro;

% time between two successive events (either sound or silence)
%par.eventdur     = 0.15;
par.eventdur     = 0.030;

% duration of linear onset ramp for the sound event
par.rampon       = 0.010;

% duration of linear offset ramp for the sound event
par.rampoff      = 0.010;

% how many times the rhythmic pattern repeats in each trial
par.ncycles      = 25; % 17 cycles is 40.8s / 25 cycles is 60s(for 2.4s cycle)

% calculate duration of one long trial in seconds
par.trialdur    = par.ncycles * length(par.tracks(1).pattern) * par.gridIOI;

par.IS_NOISE    = true; %false; % TRUE -> use white noise carrier | FALSE -> use tone

% vibro carrier f0
%par.f0(1) = 86;
par.f0(1) = 126;
% audio carrier f0
par.f0(2) = 300;

%Cut off frequency for high pass filter if carrier is WN
par.hp = 300;

%%%% synthesis

% make time vector for one trial
t = (0 : 1/par.fs : par.trialdur-1/par.fs);

% make carrier for one trial
for i=1:length(par.f0)
    par.tracks(i).carrier=zeros(1,length(t));
end
if par.IS_NOISE
    par.tracks(1).carrier = sin(2*pi*t*par.f0(1));
    par.tracks(2).carrier = rand(size(t));
else
    for i=1:length(par.f0)
        par.tracks(i).carrier = sin(2*pi*t*par.f0(i));
    end
end

% make sure there is no clipping
for i=1:length(par.f0)
    par.tracks(i).carrier = par.tracks(i).carrier ./ max(abs(par.tracks(i).carrier));
end

% make envelope of one sound event
envEvent = ones(1, round(par.eventdur * par.fs));

% apply onset and offset ramp
envEvent(1:round(par.rampon*par.fs)) = envEvent(1:round(par.rampon*par.fs)) .* linspace(0,1,round(par.rampon*par.fs));

envEvent(end-round(par.rampoff*par.fs)+1:end) = envEvent(end-round(par.rampoff*par.fs)+1:end) .* linspace(1,0,round(par.rampoff*par.fs));


% go over modalities
for modaliti=1:length(par.tracks)
    
    % allocate envelope vector for the whole trial (as zeros)
    envTrial(modaliti,:) = zeros(size(par.tracks(modaliti).carrier));
    
    % make ncycles copies of the rhythmic pattern
    patternTrial(modaliti,:) = repmat(par.tracks(modaliti).pattern, 1, par.ncycles);
    
    % go over each event in the trial
    for i=1:length(patternTrial(modaliti,:))
        % if the event is sound
        if patternTrial(modaliti,i)
            % find the time of event onset
            eventTime = (i-1)*par.gridIOI;
            % convert to index
            eventIdx = round(eventTime*par.fs);
            % paste the sound event envelope
            envTrial(modaliti,[eventIdx+1:eventIdx+length(envEvent)]) = envEvent;
        end
    end
    
    % multiply carrier and envelope for the whole trial
    ss(modaliti,:) = par.tracks(modaliti).carrier .* envTrial(modaliti,:);
    
    % Filter audio if f0 = white noise 
    if  par.tracks(modaliti).name == 'syncop-audio' & par.IS_NOISE
           
            [filtb,filta] = butter(4,par.hp/(par.fs/2),'high');

                    % test impulse response function (IRF)
%                     impulse  = [zeros(1,par.fs*5) 1 zeros(1,par.fs*5) ];
%                     fimpulse = filtfilt(filtb,filta,impulse);
%                     imptime  = (0:length(impulse)-1)/par.fs;
%                     
%                     mXir = abs(fft(fimpulse)); 
%                     Nir = length(fimpulse); 
%                     freq = [0 : floor(Nir/2)]/Nir * par.fs; 
%                     
%                     clf, figure(1)
%                     subplot 122
%                     stem(freq, mXir(1:floor(Nir/2)+1), 'marker', 'none')
%                     xlim([0,1000])
%                     ax = gca;
%                     ax.Title.String = 'Filter (impulse function)'
%                     xlim([0,1000])
                    
                    
                    % filter carrier
                     ss(modaliti,:) = filtfilt(filtb,filta, ss(modaliti,:));
    end
    
    % make it stereo and save to structure
    par.tracks(modaliti).s = [ss(modaliti,:)',ss(modaliti,:)'];
    par.tracks(modaliti).env = envTrial(modaliti,:);
end

% also write wav file
for i=1:length(par.tracks)
    filename{i,1}=strcat('sub',par.sub,'-',num2str(par.trialdur),'s-',num2str(par.f0(i)),'hz-',par.tracks(i).name,'.wav');
    audiowrite(filename{i},par.tracks(i).s, par.fs);
end

% save the structure
filenamemat=['sub',par.sub,'-',num2str(par.trialdur),'s-',num2str(par.f0(1)),'hz-',num2str(par.f0(2)),'hz','.mat'];
save(filenamemat,'par');
disp(filenamemat);
%%
%%% insert the deviant cycle in the standard trial
% load standard trial
% filename='sub001-60s-86hz-300hz.mat';
% load(filename);
% load deviant cycle
filenamemat = ['dev',num2str(par.maxAudio),'-',num2str(par.maxVibro),'ms-',num2str(par.f0(1)),'hz-',num2str(par.f0(2)),'hz','.mat'];
load(filenamemat);

%create the trial with deviant at random position
% take the 3 first standard trials
for i=1:2
    for j=1:size(par.tracks(i).s,2)
        par.tracks(i).temp(:,j)=par.tracks(i).s([1:(par.trialdur/par.ncycles*3*par.fs)],j);
    end
end

%ndevVib=[1 2];% number of deviant cycles in the first and second deviant trials in Vibro1 block (2 1)
ndevAud=[2 3];% number of deviant cycles in the first and second deviant trials in Audio block (1 3)
ndevVib=[3 2];% number of deviant cycles in the first and second deviant trials in Vibro2 block (2 3)

for k=1:length(par.tracks) % 2 conditions: vibro,audio
    if k==1% vibro 
        for p=1:2
            % random position within the 21 remaining cycles not consecutive
            is_success=0;
            while(~is_success)
                is_success=1;
                tempos=sort(randperm((22-ndevVib(p)),ndevVib(p)));
                param=diff(tempos);
                if find(param==1)
                    is_success=0;
                end
            end
            pos=tempos*par.fs*(par.trialdur/25);
            allpos=((2.4*par.fs)*(1:22-ndevVib(p)));
            allpos=[0 allpos];
            for i=1:ndevVib(p)
                idxDev(1,i)=find(allpos==pos(1,i));
            end
            % add the deviant trial to the standard stimuli vibro 1
            switch length(idxDev)
                case 1
                    if idxDev==1
                        for j=1:size(par.tracks(1).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*21*par.fs)],j)];
                        end
                    elseif idxDev>1
                        for j=1:size(par.tracks(1).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev))],j)];
                        end
                    end
                case 2
                    if idxDev(1)==1
                        for j=1:size(par.tracks(1).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-2))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(2)))],j)];
                        end
                    elseif idxDev(1)>1
                        for j=1:size(par.tracks(1).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(1)-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-idxDev(1)-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(2)))],j)];
                        end
                    end
                case 3
                    if idxDev(1)==1
                        for j=1:size(par.tracks(1).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-2))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(3)-idxDev(2)-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(3)))],j)];
                        end
                    elseif idxDev(1)>1
                        for j=1:size(par.tracks(1).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(1)-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-idxDev(1)-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(3)-idxDev(2)-1))],j);...
                                pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(3)))],j)];
                        end
                    end
            end
            par.tracks(2+p).name=strcat(['dev-vibro',num2str(k),'-',num2str(p)]);
            par.tracks(2+p).pattern=par.tracks(1).pattern;
            par.tracks(2+p).carrier=par.tracks(1).carrier;
            par.tracks(2+p).s=tempSdev;
            par.tracks(2+p).devpos=idxDev(1,1:ndevVib(p))+3;
            clear tempSdev idxDev;
        end
    elseif k==2% audio 1
        for p=1:2
            % random position within the 21 remaining cycles
            is_success=0;
            while(~is_success)
                is_success=1;
                tempos=sort(randperm((22-ndevAud(p)),ndevAud(p)));
                param=diff(tempos);
                if find(param==1)
                    is_success=0;
                end
            end
            pos=tempos*par.fs*(par.trialdur/25);
            allpos=((2.4*par.fs)*(1:22-ndevAud(p)));
            allpos=[0 allpos];
            for i=1:ndevAud(p)
                idxDev(1,i)=find(allpos==pos(1,i));
            end
            % add the deviant trial to the standard stimuli audio 1
            switch length(idxDev)
                case 1
                    if idxDev==1
                        for j=1:size(par.tracks(2).s,2)
                            tempSdev(:,j)=[par.tracks(2).temp(:,j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*21*par.fs)],j)];
                        end
                    elseif idxDev>1
                        for j=1:size(par.tracks(2).s,2)
                            tempSdev(:,j)=[par.tracks(2).temp(:,j);...
                                par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev))],j)];
                        end
                    end
                case 2
                    if idxDev(1)==1
                        for j=1:size(par.tracks(2).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-2))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(2)))],j)];
                        end
                    elseif idxDev(1)>1
                        for j=1:size(par.tracks(2).s,2)
                            tempSdev(:,j)=[par.tracks(2).temp(:,j);...
                                par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(1)-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-idxDev(1)-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(2)))],j)];
                        end
                    end
                case 3
                    if idxDev(1)==1
                        for j=1:size(par.tracks(2).s,2)
                            tempSdev(:,j)=[par.tracks(1).temp(:,j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-2))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(3)-idxDev(2)-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(3)))],j)];
                        end
                    elseif idxDev(1)>1
                        for j=1:size(par.tracks(2).s,2)
                            tempSdev(:,j)=[par.tracks(2).temp(:,j);...
                                par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(1)-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-idxDev(1)-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(3)-idxDev(2)-1))],j);...
                                pardev.tracks(2).s(:,j);par.tracks(2).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(3)))],j)];
                        end
                    end
            end
            par.tracks(4+p).name=strcat(['dev-audio',num2str(k-1),'-',num2str(p)]);
            par.tracks(4+p).pattern=par.tracks(2).pattern;
            par.tracks(4+p).carrier=par.tracks(2).carrier;
            par.tracks(4+p).s=tempSdev;
            par.tracks(4+p).devpos=idxDev(1,1:ndevAud(p))+3;
            clear tempSdev idxDev;
        end
    
%     elseif k==3% vibro 2
%         for p=1:2
%             % random position within the 21 remaining cycles
%             is_success=0;
%             while(~is_success)
%                 is_success=1;
%                 tempos=sort(randperm((22-ndevVib2(p)),ndevVib2(p)));
%                 param=diff(tempos);
%                 if find(param==1)
%                     is_success=0;
%                 end
%             end
%             pos=tempos*par.fs*(par.trialdur/25);
%             allpos=((2.4*par.fs)*(1:22-ndevVib2(p)));
%             allpos=[0 allpos];
%             for i=1:ndevVib2(p)
%                 idxDev(1,i)=find(allpos==pos(1,i));
%             end
%             % add the deviant trial to the standard stimuli vibro 2
%             switch length(idxDev)
%                 case 1
%                     if idxDev==1
%                         for j=1:size(par.tracks(1).s,2)
%                             tempSdev(:,j)=[par.tracks(1).temp(:,j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*21*par.fs)],j)];
%                         end
%                     elseif idxDev>1
%                         for j=1:size(par.tracks(1).s,2)
%                             tempSdev(:,j)=[par.tracks(1).temp(:,j);...
%                                 par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev))],j)];
%                         end
%                     end
%                 case 2
%                     if idxDev(1)==1
%                         for j=1:size(par.tracks(1).s,2)
%                             tempSdev(:,j)=[par.tracks(1).temp(:,j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-2))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(2)))],j)];
%                         end
%                     elseif idxDev(1)>1
%                         for j=1:size(par.tracks(1).s,2)
%                             tempSdev(:,j)=[par.tracks(1).temp(:,j);...
%                                 par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(1)-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-idxDev(1)-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(2)))],j)];
%                         end
%                     end
%                 case 3
%                     if idxDev(1)==1
%                         for j=1:size(par.tracks(1).s,2)
%                             tempSdev(:,j)=[par.tracks(1).temp(:,j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-2))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(3)-idxDev(2)-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(3)))],j)];
%                         end
%                     elseif idxDev(1)>1
%                         for j=1:size(par.tracks(1).s,2)
%                             tempSdev(:,j)=[par.tracks(1).temp(:,j);...
%                                 par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(1)-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(2)-idxDev(1)-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(idxDev(3)-idxDev(2)-1))],j);...
%                                 pardev.tracks(1).s(:,j);par.tracks(1).s([1:(par.trialdur/par.ncycles*par.fs*(25-3-idxDev(3)))],j)];
%                         end
%                     end
%             end
%             % add the deviant trial to the standard stimuli vibro 2
%             par.tracks(6+p).name=strcat(['dev-vibro',num2str(k-1),'-',num2str(p)]);
%             par.tracks(6+p).pattern=par.tracks(1).pattern;
%             par.tracks(6+p).carrier=par.tracks(1).carrier;
%             par.tracks(6+p).s=tempSdev;
%             par.tracks(6+p).devpos=idxDev(1,1:ndevVib2(p))+3;
%             clear tempSdev idxDev;
%         end
    end
end
disp(filenamemat);
save(filenamemat,'par');

for i=3:6%3:8
    audiowrite([par.tracks(i).name,'.wav'],par.tracks(i).s, par.fs);
end

%plots
for i=1:length(par.tracks)
    figure(i);
    plot(par.tracks(i).s(:,1));
end
%clear;

end

