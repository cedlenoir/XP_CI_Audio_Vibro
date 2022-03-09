% list text files
txtlist = dir('**/*.txt');
% txt2disp = fileread('path/filename')

for i=1:size(txtlist,1)
    temp = fileread(fullfile(txtlist(i).folder,txtlist(i).name));
    temp = uint8(temp);
    save([txtlist(i).name(1:end-4),'.mat'],'temp')
<<<<<<< HEAD
    
=======
end
>>>>>>> branch
    % save filename.mat

% send to Flora