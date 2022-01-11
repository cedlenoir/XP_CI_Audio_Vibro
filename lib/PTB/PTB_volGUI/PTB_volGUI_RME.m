function varargout = PTB_volGUI_RME(varargin)
% PTB_VOLGUI_RME MATLAB code for PTB_volGUI_RME.fig
%      PTB_VOLGUI_RME, by itself, creates a new PTB_VOLGUI_RME or raises the existing
%      singleton*.
%
%      H = PTB_VOLGUI_RME returns the handle to a new PTB_VOLGUI_RME or the handle to
%      the existing singleton*.
%
%      PTB_VOLGUI_RME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PTB_VOLGUI_RME.M with the given input arguments.
%
%      PTB_VOLGUI_RME('Property','Value',...) creates a new PTB_VOLGUI_RME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PTB_volGUI_RME_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PTB_volGUI_RME_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PTB_volGUI_RME

% Last Modified by GUIDE v2.5 24-Nov-2019 09:28:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PTB_volGUI_RME_OpeningFcn, ...
                   'gui_OutputFcn',  @PTB_volGUI_RME_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT




% --- Executes just before PTB_volGUI_RME is made visible.
function PTB_volGUI_RME_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PTB_volGUI_RME (see VARARGIN)

% Choose default command line output for PTB_volGUI_RME
handles.output = hObject;

if any(strcmp(varargin,'pahandle'))   
    handles.pahandle = varargin{find(strcmp(varargin,'pahandle'))+1}; % get the pahandle for the audio device
end
if any(strcmp(varargin,'volume'))   
    handles.vol = varargin{find(strcmp(varargin,'volume'))+1}; % get the initial volume passed to GUI
else
    handles.vol = str2num(handles.VolumeEdit.String); % otherwise get value from volume edit
end
handles.VolumeEdit.String = num2str(handles.vol); % update the volume edit (just to be sure)
PsychPortAudio('Volume',handles.pahandle,handles.vol); % set the new volume value


handles.StatusText.String = {'It might take couple of seconds','between the first time you','press PLAY and sound onset',}; 


pastatus = PsychPortAudio('GetStatus',handles.pahandle); 
handles.fs = pastatus.SampleRate; 

handles.outdev_idx = pastatus.OutDeviceIndex; 
a_devices = PsychPortAudio('GetDevices'); 
paidx = find([a_devices.DeviceIndex]==handles.outdev_idx); 


if any(strcmp(varargin,'nchan'))   
    handles.nchan = varargin{find(strcmp(varargin,'nchan'))+1}; 
else
    handles.nchan = a_devices(paidx).NrOutputChannels; 
end




%------------------------------------------------------------
%               !!! set this manually !!!

handles.trig1chan = 3; % channel to send trigger 1
handles.trig2chan = 4; % channel to send trigger 2

% note: trigger 3 will be sent to both channels simultaneously
%------------------------------------------------------------


% Update handles structure
guidata(hObject, handles);

uiwait(); 





% --- Executes during object creation, after setting all properties.
function VolumeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VolumeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('to_load/*.wav'); 
[handles.s,handles.fs] = audioread(fullfile(pathname,filename)); 
handles.StatusText.String = {'Sound file loaded'}; 

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try 
    s = handles.s(1:round(handles.fs*15),:); % get only 15 seconds due to memory limits
    s_out = zeros(handles.nchan, length(s)); 
    s_out(1,:) = s(:,1); % left earphone
    if size(s_out,2)==2
        s_out(2,:) = s(:,2); % right earphone
    end
    PsychPortAudio('Stop',handles.pahandle); 
    PsychPortAudio('FillBuffer',handles.pahandle,s_out);        
    % play sound
    start_time = PsychPortAudio('Start',handles.pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
catch
    handles.StatusText.String = {'You need to load','the wav file first!'}; 
end



% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PsychPortAudio('Stop',handles.pahandle); 



% --- Executes on button press in Trig1Button.
function Trig1Button_Callback(hObject, eventdata, handles)
% hObject    handle to Trig1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trig_pulse = zeros(1,round(0.200*handles.fs)); 
trig_pulse(1:round(0.100*handles.fs)) = 1; 
s_out = zeros(handles.nchan, length(trig_pulse)); 
s_out(handles.trig1chan,:) = trig_pulse; 
PsychPortAudio('Stop',handles.pahandle); 
PsychPortAudio('FillBuffer',handles.pahandle,s_out);        
start_time = PsychPortAudio('Start',handles.pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
handles.StatusText.String = {''}; 




% --- Executes on button press in SendTrig2Button.
function SendTrig2Button_Callback(hObject, eventdata, handles)
% hObject    handle to SendTrig2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trig_pulse = zeros(1,round(0.200*handles.fs)); 
trig_pulse(1:round(0.100*handles.fs)) = 1; 
s_out = zeros(handles.nchan, length(trig_pulse)); 
s_out(handles.trig2chan,:) = trig_pulse; 
PsychPortAudio('Stop',handles.pahandle); 
PsychPortAudio('FillBuffer',handles.pahandle,s_out);        
start_time = PsychPortAudio('Start',handles.pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
handles.StatusText.String = {''}; 




% --- Executes on button press in SendTrig3Button.
function SendTrig3Button_Callback(hObject, eventdata, handles)
% hObject    handle to SendTrig3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
trig_pulse = zeros(1,round(0.200*handles.fs)); 
trig_pulse(1:round(0.100*handles.fs)) = 1; 
s_out = zeros(handles.nchan, length(trig_pulse)); 
s_out(handles.trig1chan,:) = trig_pulse; 
s_out(handles.trig2chan,:) = trig_pulse; 
PsychPortAudio('Stop',handles.pahandle); 
PsychPortAudio('FillBuffer',handles.pahandle,s_out);        
start_time = PsychPortAudio('Start',handles.pahandle,[],[],1);  % handle, repetitions, when=0, waitForStart
handles.StatusText.String = {''}; 




function VolumeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to VolumeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vol = str2double(get(hObject,'String')); % get value from volume edit
PsychPortAudio('Volume',handles.pahandle,handles.vol); % set the new volume value
% Update handles structure
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of VolumeEdit as text
%        str2double(get(hObject,'String')) returns contents of VolumeEdit as a double



% --- Executes on button press in ExitButton.
function ExitButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vol = str2num(handles.VolumeEdit.String); % get value from volume edit
PsychPortAudio('Volume',handles.pahandle,handles.vol); % set the new volume value
guidata(hObject, handles);
uiresume(); 
% closereq(); 




% --- Outputs from this function are returned to the command line.
function varargout = PTB_volGUI_RME_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.vol;
delete(hObject); 

% Get default command line output from handles structure
