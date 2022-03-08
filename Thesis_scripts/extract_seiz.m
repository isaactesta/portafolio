%% Extract seizures from converted data


subject_num = 10;
num_parts = 07;

parts = 1:num_parts;
folders = ['M' num2str(subject_num,'%02d') '_']


%% Iterate throught folders to find seizures

seiz_signals = {}

for i=1:length(parts)
   dir = [folders num2str(parts(i),'%02d')] %create path for each directory
   cd(dir) % Go to the direcotry of folder
   
   load('Annots.mat')
   seizloc = findseiz(Annot)
   seiz_signals{end+1} = seizloc; % Place all parts in Cell Array
   
   cd .. % To go back to the directory with all the folders of subject parts
end
