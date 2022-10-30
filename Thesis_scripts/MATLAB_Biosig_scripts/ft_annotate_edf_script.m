% Annotate events and artifacts (on new data)
%  ======================================================================
clear cfg indir outdir patient file data_org

% Settings
indir   = '/home/epilepsy/Original_Data/new-patients';
patient = 'Strati Nectaria 10838 - all edf files';
file    = 'EDF Day 325.edf';
eventtime = '18.43.17';
outdir  = '/home/epilepsy/fieldtrip';

% Calculate num records in previous files (with same start time/date)
header = edfread([indir '/' patient '/' file]);
startdate = header.startdate;
starttime = header.starttime;
records = header.records;
digits = regexp(file,'\d','match');
filenum_const = digits{1};
filenum_var = 0;
for i=2:size(digits,2)
    filenum_var = 10*filenum_var + str2num(digits{i});
end

total_records = 0;
for i=filenum_var-1:-1:1
    filename = char(strrep([indir '/' patient '/' file],regexp(file,'\d*','match'),[digits{1} int2str(i)]));
    tmp_hdr = edfread(filename);
    tmp_hdr.startdate
    tmp_hdr.starttime
    if isequal(tmp_hdr.startdate,startdate) && isequal(tmp_hdr.starttime,starttime)
        total_records = total_records + tmp_hdr.records;
    else
        disp(['Stopped at ' filename]);
        break;
    end
end
if i==1
    filename = char(strrep([indir '/' patient '/' file],regexp(file,'\d*','match'),digits{1}));
    tmp_hdr = edfread(filename);
    if isequal(tmp_hdr.startdate,startdate) && isequal(tmp_hdr.starttime,starttime)
        total_records = total_records + tmp_hdr.records;
    end
end
total_records

h2  = regexp(eventtime,'\d*','match');
h1  = regexp(starttime,'\d*','match');
sec = (str2num(h2{1})-str2num(h1{1}))*3600 ...
        + (str2num(h2{2})-str2num(h1{2}))*60 ...
        + (str2num(h2{3})-str2num(h1{3})) ...
        - total_records;
disp(['Open second ' num2str(sec)]);

%% Preprocessing and save (will simply load the data, if the same
% preprocessing has been done in the past)
data_org = ft_preprocess_loadsave(indir,patient,file,outdir,1,48);

% Mark events
ft_markevents_loadsave(patient,file,outdir,data_org,10);

