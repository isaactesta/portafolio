% Find total lenght of recordings

% subject_num is the number of the subject
% num_parts is the number of parts the subject length is divided into
% Length of results all are given in hours

function [total_length, parts_length] = findlength(subject_num,num_parts)

parts = 1:num_parts;

fileList = dir('M*');

srate = 256;
convert_time = srate*3600;

parts_length = []

for i=1:length(parts)
   dirx = fileList(i).name
   cd(dirx) % Go to the direcotry of folder
   
   load('Data_full.mat', 'ECG')
   len = length(ECG(1,:))/convert_time %convert length to time
   parts_length = [parts_length; len]
   
   cd .. % To go back to the directory with all the folders of subject parts
end

total_length = sum(parts_length)

end

