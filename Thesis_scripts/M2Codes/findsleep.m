% Find seizure in annotation for iEEG data, got to folder of data with py
% converted


function [sleeploc,awakeloc,sleep_hour,awake_hour] = findsleep(Annot)

desc = Annot.description;
onset = Annot.onset;


str1 = 'slaapt'; %Locator for where seizure happened
str2 = 'slapen';

str3 = 'wakker';

sleeploc = [];
awakeloc = [];

for i=1:length(desc(:,1)) % Iterate through all annotations
    
    tfs = regexpi(desc(i,:),str1); % Search through the each line of char array
    tf2 = regexpi(desc(i,:),str2);
    tfa = regexpi(desc(i,:),str3);
    
    if isempty(tfs) == 0 %If seizure is located, save the location
        sleeploc = [sleeploc;i]; % Append seizure location
    end

    if isempty(tf2) == 0 %If seizure is located, save the location
        sleeploc = [sleeploc;i]; % Append seizure location
    end    
    
    if isempty(tfa) == 0 %If seizure is located, save the location
        awakeloc = [awakeloc;i]; % Append seizure location
    end    
    
end

sleep_hour = onset(sleeploc)/3600;
awake_hour = onset(awakeloc)/3600;

end