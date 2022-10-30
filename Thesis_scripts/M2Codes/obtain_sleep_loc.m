% Iterate anbd obtain locations of signal from Annot onset
% run in Py data folder
clear all

total_sleeploc = {};
total_sleephours = {};

total_awakeloc = {};
total_awakehours = {};
%%
load('E:\Isaac_D2\Data\Py_dat\M06\M06_01\Annots.mat')

desc = Annot.description;
onset = Annot.onset;

[sleeploc,awakeloc,sleep_hour,awake_hour] = findsleep(Annot)

desc(sleeploc,:) 

%%
% attacks = [1];

sleeploc(2) = []
sleep_hour(:,2) = []
desc(sleeploc,:)

% awakeloc(2) = []
% awake_hour(:,2) = []

sleep_hour
awake_hour

% sleeploc = sleeploc(attacks);
% sleep_hour = sleep_hour(attacks);
%%

total_sleeploc{end + 1} = sleeploc;
total_sleephours{end + 1} = sleep_hour;

total_awakeloc{end + 1} = awakeloc;
total_awakehours{end + 1} = awake_hour;