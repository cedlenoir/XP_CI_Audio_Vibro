function answer = getSubjectInfo()

prompt = {'Enter subject number: ', 'Condition (eeg/tapping)', 'Musical training (musician/nonmusician)'};
defaults = {'','',''};%you can put in default responses

answer = inputdlg(prompt, 'Subject Information',1.2,defaults); %opens dialog

if isempty(str2num(answer{1}))
    error(' !!!Subject ID is not a number!!! ')
end
