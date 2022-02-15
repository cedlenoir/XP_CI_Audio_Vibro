function res=backupPTB(experiment, timestamp, log_path)

d = dir2(log_path); 

tmp = strsplit(log_path,filesep); 
SUBJECT = tmp{end}; 

zipfilename = sprintf('backup_%s_%s_%s.zip',experiment,SUBJECT,timestamp); 
% zippedfiles = zip(fullfile(log_path,zipfilename),log_path);

zip(fullfile(log_path,zipfilename),{d.name},log_path);