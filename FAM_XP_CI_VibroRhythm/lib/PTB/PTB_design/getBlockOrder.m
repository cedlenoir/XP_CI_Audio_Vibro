

function getBlockOrder(ID,music)






nBlocks = length(blockNames);
if strcmpi(subjectInfo{2},'eeg')
    global blockOrder
    blockOrder = conditionOrder(SUBJECT,nBlocks,'latin');
elseif strcmpi(subjectInfo{2},'tapping')
    global blockOrder
end











%%


blockOrderPath = '/Users/philbrown/Documents/MATLAB/data/Exp1/EEG/for_getBlockOrder';

d = dir([blockOrderPath,'/*.mat'])
names = {d.name}


for i=1:length(names)
    if strcmpi(names{i}(1:2),'11')
        
        load([blockOrderPath, filesep, names{i}])
        res.music_training = [];
        save([blockOrderPath, filesep, names{i}],'res')
    end
end
    