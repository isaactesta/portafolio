% Find seizure in annotation for iEEG data, got to folder of data with py
% converted


function [seizloc] = findseiz(Annot)

desc = Annot.description;
str = 'Aanval'; %Locator for where seizure happened

seizloc = [];

for i=1:length(desc(:,1)) % Iterate through all annotations
    
    tf = strfind(desc(i,:),str) % Search through the each line of char array
    
    if isempty(tf) == 0 %If seizure is located, save the location
        seizloc = [seizloc;i]; % Append seizure location
    end
end

end