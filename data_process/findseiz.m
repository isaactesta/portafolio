% Find seizure in annotation for iEEG data, got to folder of data with py
% converted


function [seizloc,seiz_hour] = findseiz(Annot)

desc = Annot.description;
onset = Annot.onset;

str = 'AANVAL'; %Locator for where seizure happened

seizloc = [];

for i=1:length(desc(:,1)) % Iterate through all annotations
    
    tf = regexpi(desc(i,:),str); % Search through the each line of char array
    
    if isempty(tf) == 0 %If seizure is located, save the location
        seizloc = [seizloc;i]; % Append seizure location
    end
end

seiz_hour = onset(seizloc)/3600;

end