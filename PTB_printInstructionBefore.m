
function PTB_printInstructionBefore(path)
sca

%%%% Screen display script %%%%%

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 0); %Make PTB Shut up

%% Get all PTB instructions to display from directory

allinstr = dir(path);  %get all instruction files
fileBeg  = 'PTBinstr_beforeStart';
numfiles = length(allinstr);


% loop over to keep only instruction files starting with PTB
index =1;
for i=1:numfiles
    if contains(allinstr(i).name,fileBeg) 
        filenametext{index} = allinstr(i).name;
        index = index+1;
    end
end



%% Set display parameters

backColor = [100 100 100]; %[0.5 0.5 0.5]
textColor = [255 255 255]; %white
textFont  = 'Arial Unicode MS'; 
fontSize  = 80;


%% Open a window on screen 

screenNum = 1; %0 = sets the screen as the main screen 
[windowPtr, windowRect] = Screen('OpenWindow', screenNum, backColor); %opens a window and defines a pointer + saves screen coordinates

Screen('TextFont', windowPtr, textFont); %Sets all text in the chosen font
Screen('TextSize', windowPtr, fontSize);
Screen('TextStyle',windowPtr, 1); 

%Sync and get a time stamp and frame duration
vbl        = Screen('Flip', windowPtr); %time stamp
ifi        = Screen('GetFlipInterval', windowPtr); %flip duration  
waitframes = 1;
secs2wait  = ifi*700; 


%% Loop and display instructions

for i = 1:length(filenametext)
    
%get file path
filetoread= fullfile(path,filenametext{i});
%get text to display from instruction text file 
textToDisp = fileread(filetoread); 

% Flip each instruction to the screen 

DrawFormattedText(windowPtr, textToDisp, 'Center', 'Center', textColor); %gets the text ready to present on screen
vbl = Screen('Flip', windowPtr, vbl + (waitframes - 0.5) * secs2wait); %presents the word on the screen 

% % Wait 10 seconds for reading
% KbStrokeWait;
WaitSecs(5);
end

sca %close the screen


end
 