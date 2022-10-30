%% Using dates to connect the dates from all the parts
% Import Dates obtained form Python script, converts to datetime and get
% space between each recording

clear all

subject_num = 06;
num_parts = 10

dirs = strcat('E:\Isaac_D2\M2_codes\subjects_process\Subject0',num2str(subject_num),'\Full\Dates.mat')

% Import dates from working subject
load(dirs)

%% Convert strings to datetime

for i=1:num_parts
    record_start(i) = datetime(Dates(i,:),'Format','yy-MM-dd eee HH:mm:ss')
end

%% Difference between those datetimes
% Will need to get length of each recording to find difference
% Run inside of folder for each subject
[total_length, parts_length] = findlength(subject_num,num_parts);

end_times = record_start(1,1:num_parts) + hours(transpose(parts_length));

for i=2:num_parts %Time between recordings
    delta_t(i-1) = between(end_times(i-1),record_start(i))
end
