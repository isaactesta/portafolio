%% Combine EEG trials anad extract ECG
% Go to Directory where EEG trials are located
% CHANGE LINE 23
clear all
% Load all mat files in that directory
F = dir('*.mat')
for i = 1:length(F)
    load(F(i).name)
end

currentFolder = pwd
out=regexp(currentFolder,'\','split'); %Folder for Part of specific subject
%% Concatenate EEG arrays to obtain full recordings and clear the three parts

% eeg_chans = cat(1,Channels1,Channels2,Channels3)
EEG = cat(1,EEG1,EEG2,EEG3);

clear Channels1 Channels2 Channels3 EEG1 EEG2 EEG3
srate = 256;
 
[m, n] = size(EEG);
% CHANGE STORE PATH
store_path = strcat('E:\Isaac_D2\M2_codes\subjects_process\Subject10\',out(5),'\');
destination_folder = strcat(store_path,out{end})
mkdir(destination_folder{1}) % Create folder to store

% Create filename and save in destination of subject part
filename = strcat(destination_folder{1},'\Data_full.mat') 

save(filename,'ECG','EEG','srate','-v7.3')

