function [nevList] = findNamingSessions(patientID,patientDirectory)
%FINDNAMINGSESSIONS finds Naming data in a patient directory
%   nevList = findNamingSessions(patientID,patientDirectory) will search recursively through the directory
% 	in [patientDirectory] for MSIT data and will return the names of files that have
%	the appropriate trigger structure output from psychToolbox. These nev files will also be copied to
% 	a directory in the shethLabBackup Data folder called [patientID]_naming.

% author: EHS20160210

addpath('/mnt/mfs/shethLabBackup_nov15/Code/Analysis/')
cd /mnt/mfs/marlaNaming/


% 1) find .nev files in the directory
try
    dirlist = subdir(fullfile(patientDirectory,'*.nev'));
catch
    error('are you sure this is the right directory?')
end

% 2) open NEV files
addpath(genpath('~/NPMK'))

% initializing session count and list of files
sessionCount = 0;
nevList = cell(0);
nevListStr = char();

% looping over nev files.
for fl = 1:length(dirlist)
    try
        NEV = openNEV(dirlist(fl).name,'nomat','nosave');
        triggers = NEV.Data.SerialDigitalIO.UnparsedData;
        if isempty(triggers)
            display(sprintf('no triggers found in file %s',dirlist(fl).name))
        elseif isequal(triggers(1),255) && isequal(triggers(2),200)
            sessionCount = sessionCount+1;
            display('found the start of an auditory naming  session!')
            N = sum(triggers==220);
            display(sprintf('found %d trials of auditory naming in file %s',N,dirlist(fl).name))
            nevList = vertcat(nevList,dirlist(fl).name);
            nevListStr = horzcat(nevListStr,' ',dirlist(fl).name);
        elseif isequal(triggers(1),255) && isequal(triggers(2),201)
            sessionCount = sessionCount+1;
            display('found the start of an visual naming  session!')
            N = sum(triggers==220);
            display(sprintf('found %d trials of visual Naming in file %s',N,dirlist(fl).name))
            nevList = vertcat(nevList,dirlist(fl).name);
            nevListStr = horzcat(nevListStr,' ',dirlist(fl).name);
        elseif isequal(triggers(1),255) && ~isequal(triggers(2),200) && ~isequal(triggers(2),201)
            display('There is the start of a task in this file, though it isn"t a Naming session.')
        else
            display(sprintf('There are triggers in file %s, though they might not be Naming, or could be an incomplete session.',dirlist(fl).name))
        end
    catch
        display(sprintf('could not open the file %s. Skipping...',dirlist(fl).name));
    end
end

eval(['! mkdir /mnt/mfs/marlaNaming/' patientID '_naming/'])
eval(['! cp -v ' nevListStr '  /mnt/mfs/marlaNaming/' patientID '_naming/'])

end
