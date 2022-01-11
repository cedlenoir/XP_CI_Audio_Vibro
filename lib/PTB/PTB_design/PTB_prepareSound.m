function res = prepareSound(s, varargin)
% 
% 
% -----------------------------------------------------------------
% INPUT
% 
% s   sound vector
%
%
% varargin
%     'trig'  trigger into channel 1 or 2 when using MOTU soundcard with Donovan's trigger box
% 
% -----------------------------------------------------------------
% OUTPUT
% 
% sound matrix ready to load into buffer
fs = 44100; 
clickdur = 0.001; 
clickamplitude = 0.9; 

if size(s,1)>size(s,2)
    s = s';
end

if size(s,1)<2
    s(2,:) = s;
end


if any(strcmpi(varargin,'trig'))
    
    click = [repmat(clickamplitude, 1,round(fs*clickdur)), zeros(1,length(s)-round(fs*clickdur))]; 
    silence = zeros(1,length(s)); 
    
    trig = varargin{find(strcmpi(varargin,'trig'))+1}; 
    if trig==1
        % sound to MAIN OUTS (L and R) and trigger click to channel 1
        res = [s;click;silence]; 
    elseif trig==2
        % sound to MAIN OUTS (L and R) and trigger click to channel 2
        res = [s;silence;click]; 
    elseif trig==0
        res = [s;silence;silence]; 
    end
    
else
    res = s;
end


