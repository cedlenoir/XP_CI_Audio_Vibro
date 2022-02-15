
function [cfg] = PTB_printInstruction(cfg,path)


%%%% Screen display script %%%%%
% parameters

Screen('Preference', 'SkipSyncTests', cfg.skipSyncTest);
Screen('Preference', 'Verbosity', cfg.verbose); %Make PTB Shut up
Screen('Preference', 'TextEncodingLocale', 'fr_BE.ISO8859-1');

cfg.instr.allinstr = dir(path); %get all instruction files
cfg.instr.numfiles = length(cfg.instr.allinstr);

%% Get all PTB instructions to display from directory

if  strcmpi(cfg.instr.type, 'beforeGui')
    cfg.instr.fileBeg  = 'PTBinstr_beforeGui'; %only pick these according to instruction type
    
elseif strcmpi(cfg.instr.type, 'beforeStart')
    cfg.instr.fileBeg  = 'PTBinstr_beforeStart'; %only pick these according to instruction type
    
elseif strcmpi(cfg.instr.type, 'betweenTrial')
    cfg.instr.fileBeg  = 'PTBinstr_betweenTrial'; %only pick these according to instruction type
    
elseif strcmpi(cfg.instr.type, 'beforeTapping')
    cfg.instr.fileBeg  = 'PTBinstr_beforeTapping'; %only pick these according to instruction type
    
    
elseif strcmpi(cfg.instr.type, 'nextIsTapping')
    cfg.instr.fileBeg  = 'PTBinstr_nextIsTapping'; %only pick these according to instruction type
    
    
elseif strcmpi(cfg.instr.type, 'betweenTapping')
    cfg.instr.fileBeg  = 'PTBinstr_betweenTapping'; %only pick these according to instruction type
    
elseif strcmpi(cfg.instr.type,'lastTapping')
    cfg.instr.fileBeg  = 'PTBinstr_lastTapping';
    
elseif strcmpi(cfg.instr.type, 'end')
    cfg.instr.fileBeg  = 'PTBinstr_end'; %only pick these according to instruction type
end

% loop over to keep only instruction files starting with PTB
index =1;
for i=1:cfg.instr.numfiles
    if contains(cfg.instr.allinstr(i).name,cfg.instr.fileBeg)
        filenametext{index} = cfg.instr.allinstr(i).name;
        index = index+1;
    end
end


%% Open a window on screen

if  strcmpi(cfg.instr.type, 'beforeGui') || strcmpi(cfg.instr.type, 'beforeStart')
    [cfg.screen.windowPtr, cfg.screen.windowRect] = Screen('OpenWindow', cfg.screen.screenNum, cfg.color.background); %opens a window and defines a pointer + saves screen coordinates
end

% Format text according to predefined parameters
Screen('TextFont', cfg.screen.windowPtr, cfg.text.Font); %Sets all text in the chosen font
Screen('TextSize', cfg.screen.windowPtr, cfg.text.fontSize);
Screen('TextStyle',cfg.screen.windowPtr, 1);

%Get size of screen in pixels
[cfg.screen.Xpixels, cfg.screen.Ypixels] = Screen('WindowSize',cfg.screen.windowPtr);



%Sync and get a time stamp and frame duration
cfg.screen.vbl        = Screen('Flip', cfg.screen.windowPtr); %time stamp
cfg.screen.ifi        = Screen('GetFlipInterval', cfg.screen.windowPtr); %flip duration
cfg.screen.waitframes = 1;
cfg.screen.secs2wait  = cfg.screen.ifi*200;

%Set priority for script execution to realtime priority
Priority(MaxPriority(cfg.screen.windowPtr));

%% Loop and display instructions

for i = 1:length(filenametext)
    
%     %get file path
%     filetoread= fullfile(path,filenametext{i});
%     %get text to display from instruction text file
% %       file = fopen(filetoread, 'r');
% %       textToDisp = textscan(file, '%s');
% %       fclose(file);
%         
% textToDisp = fileread(filetoread);
    
      fileName = char(filenametext{i});            % Get text File name turn it into a char 
      fileName = [fileName(1:end-4), '.mat'];      % Get the corresponding matfile 
      filePath = fullfile(cfg.instrPath, fileName);% Get full path of matfile
      
      load(filePath);           % open the designated matfile
      textToDisp = temp;     % Get Uint8 variables

    
    [nx, ny, bbox] = DrawFormattedText(cfg.screen.windowPtr, textToDisp, 'center', 200, cfg.color.text,[],[],[],2); %gets the text ready to present on screen
    
    
    cfg.screen.vbl = Screen('Flip', cfg.screen.windowPtr, cfg.screen.vbl + (cfg.screen.waitframes - 0.5) * cfg.screen.secs2wait); %presents the word on the screen
 
    
    % Wait for keyboard stroke
    
   PTB_waitForKeyKbCheck(cfg.keya);
    
%     %if s go back to previous slide
%     if keyCodePressed == cfg.keys && i>2
%         i=i-2;
%     end
%     
    % KbStrokeWait;
    
    
end




end
 