% Iterate anbd obtain locations of signal from Annot onset
% run in Py data folder
clear all
total_seizloc = {};
total_seizhours = {};

%%
load('E:\Isaac_D2\Data\Py_dat\M09\M09_03\Annots.mat')

desc = Annot.description;
onset = Annot.onset;

[seizloc,seiz_hour] = findseiz(Annot)

desc(seizloc,:)

%%
% attacks = [1];

i = 2
seizloc(i,:) = []
seiz_hour(:,i) = []
desc(seizloc,:)

% seizloc = seizloc(attacks);
% seiz_hour = seiz_hour(attacks);
%%

total_seizloc{end + 1} = seizloc;
total_seizhours{end + 1} = seiz_hour;