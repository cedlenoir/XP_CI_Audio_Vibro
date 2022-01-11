function [win,rect,soundHandle] = initializePTB(varargin)

fs = 44100;
PsychDefaultSetup(2);

%% keyboard

% if any(strcmpi(varargin,'allkeys'))
% else
%     if ismac
%         RestrictKeysForKbCheck([4,28,17,44,15,22, [89:98]]); % 4='a'; 44='space'; 28='y'; 17='n'; 15='l'; 8='e'; 22='s'; [89:98]='1-0'; 
%     elseif ispc
%         RestrictKeysForKbCheck([65,32,89,78, 82, 96:105,49:55]); % 65='a'; 32='space'; 89='y'; 78='n'; [96:105]='0-9 numeric', [48:57]='0-9 normal', 82='r'; 
%     end
% end



%% screen

if ~any(strcmpi(varargin,'noScreen'))
    
    HideCursor();
    screen = max(Screen('Screens'));
    greycol = GrayIndex(screen);
    blackcol = 0;
    
    [win,rect] = PsychImaging('OpenWindow',screen,blackcol);
    
    Screen('BlendFunction',win,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
    Screen('TextSize',win,32);
    ListenChar(-1);
    Priority(MaxPriority(win));
    
else
    win = [];
    rect = [];
end



%% sound

if any(strcmpi(varargin,'buffersize'))
    buffer_size = varargin{find(strcmpi(varargin,'buffersize'))+1};
    disp('Careful about changing buffersize...hope you know what you are doin...');
else
    buffer_size = [];
end

InitializePsychSound(1);  % [reallyneedlowlatency=0]
aDevices = PsychPortAudio('GetDevices');
{aDevices.DeviceName}'    ; 


if any(strcmpi(varargin,'duo'))
    deviceID = aDevices(find(strcmpi({aDevices.DeviceName},'DUO-CAPTURE EX 44.1kHz'))).DeviceIndex;
elseif any(strcmpi(varargin,'focusrite'))
    deviceID = aDevices(find(strcmpi({aDevices.DeviceName},'Scarlett 18i8 USB'))).DeviceIndex;
elseif any(strcmpi(varargin,'builtin'))
    deviceID = aDevices(find(strcmpi({aDevices.DeviceName},'Built-in Output'))).DeviceIndex;
elseif any(strcmpi(varargin,'QUAD-OUT'))
    deviceID = aDevices(find(strcmpi({aDevices.DeviceName},'MAIN (QUAD-CAPTURE)') & [aDevices.NrOutputChannels]==2)).DeviceIndex;
elseif any(strcmpi(varargin,'motu'))
    deviceID = aDevices(find(~cellfun(@isempty, strfind({aDevices.DeviceName},'MOTU')))).DeviceIndex;
elseif any(strcmpi(varargin,'soundcard'))
    deviceID = aDevices(find(strcmpi({aDevices.DeviceName}, varargin{find(strcmpi(varargin,'soundcard'))})));
else
    deviceID = aDevices(find(~cellfun(@isempty, regexp({aDevices.DeviceName},'QUAD-CAPTURE')))).DeviceIndex;
end


if any(strcmpi(varargin, 'channels'))
    channels = varargin{find(strcmpi(varargin,'channels'))+1};
else
    channels = 2;
end


if any(strcmpi(varargin,'tapping'))
    soundHandle = PsychPortAudio('Open',deviceID,3,3,fs,channels); %[, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);  
    PsychPortAudio('GetAudioData', soundHandle, 100);
    disp('Initializing for INPUT and OUTPUT (tapping)...')
else
    soundHandle = PsychPortAudio('Open',deviceID,1,3,fs,channels); %[, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
    disp('Initializing for OUTPUT only...')
end


if any(strcmpi(varargin,'volume'))
    PsychPortAudio('Volume', soundHandle, varargin{find(strcmpi(varargin,'volume'))+1});
    disp(sprintf(['\n\nsetting volume to: ',num2str(varargin{find(strcmpi(varargin,'volume'))+1}), '\n\n']))
else
    PsychPortAudio('Volume', soundHandle, 0.53);
    disp(sprintf(['\n\n!!!!!!!!!!!!!!!!!!!!\nNo volume specified. Setting volume to: ',num2str(0.53), '\n\n']))
end



