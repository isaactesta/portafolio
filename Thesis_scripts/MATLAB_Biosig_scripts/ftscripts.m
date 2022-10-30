%% Test importing EDF data to FT, via matlab

% Import into Matlab matrices
[EDFdata,EDFheader]=ReadEDF('/home/epilepsy/Original Data/new-patients-small-files/Demetriadou Kyriaki 2440/DK_Episode_2.edf');

% Store header info into FT format
data            = [];
data.label      = EDFheader.labels;
data.fsample    = EDFheader.samplerate(1);
 
% Store the data in FT format, initially in one trial
nsamples = size(EDFdata{1,1},1);
data.trial{1} = cell2mat(EDFdata)';
data.time{1}  = (0:1/data.fsample:(nsamples-1)/data.fsample)'; %EDFheader.records * data.fsample * ones(1,size(EDFdata,2));

%data.trialinfo  = % Optional


%% Test reading directly from EDF file
cfg1            = [];
%cfg.trialdef    = [];
%cfg1.trialdef.eventtype  = 'annotation';
cfg.trialdef.triallength = Inf;
cfg1.trialdef.ntrials    = 1;
cfg1.dataset    = '/home/epilepsy/Original Data/new-patients-small-files/Demetriadou Kyriaki 2440/DK_Episode_2.edf';

%cfg1.trialdef.eventtype  = 'seizure';
%cfg1.trialdef.eventvalue = 3; % the value of the stimulus trigger for fully incongruent (FIC).
%cfg1.trialdef.prestim    = 1;
%cfg1.trialdef.poststim   = 2;

cfg2         = ft_definetrial(cfg1);
dataPrepro   = ft_preprocessing(cfg2);

%% Test reading from EDF: header, data, events
tic
filename = '/home/epilepsy/Original Data/new-patients/Demetriadou Kyriaki 2440/EDF + Day 11.edf';
header1  = ft_read_header(filename);
data1    = ft_read_data(filename);
event1   = ft_read_event(filename);
toc/60

%% Test preprocessing first, then define trials
tic;
cfg1 = [];
cfg1.dataset     = '/home/epilepsy/Original Data/new-patients-small-files/Demetriadou Kyriaki 2440/DK_Episode_2.edf';
cfg1.continuous  = 'yes';           % Treat data as one contiguous file
%cfg1.bpfilter     = 'yes';
%cfg1.bpfreq       = [1 40];
%cfg1.dftfilter    = 'yes';
%cfg1.dftfreq      = 50;
cfg1.bsfilter     = 'yes';
cfg1.bsfreq       = [49.8 51.2];
data_org   = ft_preprocessing(cfg1);
toc/60
figure; pwelch(data_org.trial{1,1}(1,:));

cfg2 = [];
cfg2.continuous  = 'yes';
cfg2.viewmode    = 'vertical';
cfg2.blocksize   = 10;
ft_databrowser(cfg2,data_org);

% chansel  = 1; 
% plot(data_org.time{1}, data_org.trial{1}(chansel, :))
% xlabel('time (s)')
% ylabel('channel amplitude (uV)')
% legend(data_org.label(chansel))

%% View data directly from file
cfg1 = [];
cfg1.continuous  = 'yes';
cfg1.viewmode    = 'vertical';
cfg1.blocksize   = 10;
cfg1.dataset     = '/home/epilepsy/Original Data/new-patients-small-files/Demetriadou Kyriaki 2440/DK_Episode_2.edf';
%cfg1.dataset    = '/home/epilepsy/Original Data/new-patients/Demetriadou Kyriaki 2440/EDF + Day 11.edf';
seizures = ft_databrowser(cfg1);



%% Test change montage of old data
%  ======================================================================

% Import from txt file
source = '/home/manolisc/epilepsy/Exports/focal_Export-Mxxxxxxxxx~ Cx_95a3aa1d-cd6c-4844-acbd-921d46a45f8b/seizure_16_48_31_920_[-15min_+15min].txt';
[data_txt,indices] = importEEG(source,0);

% Store the data in FT format (First 26 channels)
data          = [];
data.label    = {'AC1'; 'AC2'; 'Ref'; 'Fp1'; 'F7'; 'T3'; 'T5'; 'O1'; 'F3'; 'C3'; 'P3'; 'Fz'; 'Cz'; 'Pz'; 'F4'; 'C4'; 'P4'; 'Fp2'; 'F8'; 'T4'; 'T6'; 'O2'; 'AC23'; 'AC24'; 'AC25'; 'AC26'};
data.fsample  = 200;
nsamples      = size(data_txt,1);
data.trial{1} = data_txt(:,1:26)';
data.time{1}  = (0:1/data.fsample:(nsamples-1)/data.fsample);

% Preprocess as single trial
cfg = [];
cfg.continuous = 'yes';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 1;
cfg.dftfilter  = 'yes';
%cfg.channel    = {'all','-AC1','-AC2','-Ref','-AC26'}; 
data   = ft_preprocessing(cfg,data);

% Split in segments (5 second windows)
cfg = [];
cfg.length = 5;
data = ft_redefinetrial(cfg,data);

% Plot
cfg_plot = [];
cfg_plot.continuous = 'yes';
cfg_plot.viewmode   = 'vertical';
cfg_plot.blocksize  = 5;
ft_databrowser(cfg_plot,data);

% Change montage to common reference and replot
%averageref_data = ft_montage_single2commonref(data);
%ft_databrowser(cfg_plot,averageref_data);

% Change montage to bipolar and replot
bipolar_data = ft_montage_single2bipolar(data);
ft_databrowser(cfg_plot,bipolar_data);

% Fourier-representation of the data
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
freq_data     = ft_freqanalysis(cfg, bipolar_data);

% Coherence coefficient
cfg           = [];
cfg.method    = 'coh';
coh           = ft_connectivityanalysis(cfg, freq_data);

% Plot the coherence coefficients
cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, coh);

%% Look into more detail
figure
plot(coh.freq, squeeze(coh.cohspctrm(1,2,:)))
title(sprintf('connectivity between %s and %s', coh.label{1}, coh.label{2}));
xlabel('freq (Hz)')
ylabel('coherence')




%% Annotate events and artifacts (on new data)
%  ======================================================================
clear cfg indir outdir patient file data_org

% Settings
indir   = '/home/epilepsy/Original_Data/new-patients';
patient = 'Strati Nectaria 10838 - all edf files';
file    = 'EDF Day 325.edf';
outdir  = '/home/manolisc/fieldtrip';
eventtime = '15.48.09';

%% Calculate num records in previous files (with same start time/date)
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

%% Mark events
% cfg = [];
% cfg.continuous  = 'yes';
% cfg.viewmode = 'vertical';
% cfg.blocksize = 5;
% cfg.selectfeature = 'seizure';
% disp('Annotating events...');
% cfg  = ft_databrowser(cfg,data_org);
% 
% % Mark artifacts around events
% cfg.selectfeature = 'artifacts';
% disp('Annotating artifacts...');
% cfg = ft_databrowser(cfg,data_org);
% 
% % Save
% if (~exist([outdir '/' patient], 'dir'))
%     mkdir([outdir '/' patient]);
% end
% save([outdir '/' patient '/'  strrep(file,'.edf',' seizures-and-artifacts.mat')], 'cfg');
ft_markevents_loadsave(patient,file,outdir,data_org,10);



%% Annotate events and artifacts (on old data)
%  ======================================================================

clear cfg indir outdir patient file data_org data data_txt indices

% Settings
indir   = '/home/manolisc/epilepsy/Exports';
patient = 'focal_Export-Txxxxx~ Kxxxxx_c840d375-4129-4384-935a-0c6241e004aa';
file    = 'seizure_59_33_52_810_[-15min_+15min].txt';
outdir  = '/home/manolisc/fieldtrip';

% Import from txt file
[data_txt,indices] = importEEG([indir '/' patient '/' file],0);

% Store the data in FT format (First 26 channels)
data          = [];
data.label    = {'AC1'; 'AC2'; 'Ref'; 'Fp1'; 'F7'; 'T3'; 'T5'; 'O1'; 'F3'; 'C3'; 'P3'; 'Fz'; 'Cz'; 'Pz'; 'F4'; 'C4'; 'P4'; 'Fp2'; 'F8'; 'T4'; 'T6'; 'O2'; 'AC23'; 'AC24'; 'AC25'; 'AC26'};
data.fsample  = 200;
nsamples      = size(data_txt,1);
data.trial{1} = data_txt(:,1:26)';
data.time{1}  = (0:1/data.fsample:(nsamples-1)/data.fsample);

% Preprocess as single trial
% cfg = [];
% cfg.continuous = 'yes';
% cfg.hpfilter   = 'yes';
% cfg.hpfreq     = 1;
% cfg.lpfilter   = 'yes';
% cfg.lpfreq     = 48;
% cfg.dftfilter  = 'yes';
% cfg.channel    = {'all','-AC1','-AC2','-Ref','-AC26'}; 
% data = ft_preprocessing(cfg,data);
data_org = ft_preprocess_loadsave(indir,patient,file,outdir,1,48);
bipolar_data = ft_montage_single2bipolar(data);

%% Mark events
% cfgfile = [outdir '/' patient '/'  strrep(file,'.txt','__seizures-and-artifacts.mat')];
% if (exist(cfgfile, 'file'))
%     load(cfgfile,'cfg');
% else
%     cfg = [];
%     cfg.continuous  = 'yes';
%     cfg.viewmode = 'vertical';
%     cfg.blocksize = 10;
%     cfg.selectfeature = 'seizure'; 
% end
% cfg  = ft_databrowser(cfg,bipolar_data);
% 
% % Mark artifacts around events
% cfg.selectfeature = 'artifacts';
% cfg = ft_databrowser(cfg,bipolar_data);
% 
% % Save
% if (~exist([outdir '/' patient], 'dir'))
%     mkdir([outdir '/' patient]);
% end
% save(cfgfile, 'cfg');
ft_markevents_loadsave(patient,file,outdir,bipolar_data,10);


%% Add comments to saved artifacts
%  ======================================================================
clear cfg annotated_cfg;
file = '/home/manolisc/fieldtrip/focal_Export-Mxxxxxxxxx~ Cx_95a3aa1d-cd6c-4844-acbd-921d46a45f8b/seizure_4_18_11_250_[-15min_+15min]__seizures-and-artifacts.mat';

if ~exist(strrep(file,'.mat','__annotated.mat'),'file')
    load(file);
else
    load(strrep(file,'.mat','__annotated.mat'));
end

if ~exist('annotated_cfg','var')
    annotated_cfg = cfg;

    if size(annotated_cfg.artfctdef.seizure.artifact,1)==2
        annotated_cfg.artfctdef.seizure.artifact(1,2) = annotated_cfg.artfctdef.seizure.artifact(2,2);
        annotated_cfg.artfctdef.seizure.artifact(2,:) = [];
    else
        disp('Seizure not marked automatically!');
    end

    annotated_cfg.artfctdef.artifacts.artifact = num2cell(annotated_cfg.artfctdef.artifacts.artifact);
    event_start_times = cfg.artfctdef.artifacts.artifact(:,1)/200;
    openvar('annotated_cfg.artfctdef.artifacts.artifact');
else
    event_start_times = cfg.artfctdef.artifacts.artifact(:,1)/200;
    openvar('annotated_cfg.artfctdef.artifacts.artifact');
end
disp('Don''t forget to SAVE changes when done!');

%% Save annotated artifacts
save(strrep(file,'.mat','__annotated.mat'),'annotated_cfg');
disp('Changes have been saved');



%% Connectivity analysis on old data
%  ======================================================================

clear cfg indir outdir patient file data_org data data_txt indices

% Settings
indir   = '/home/manolisc/epilepsy/Exports';
patient = 'focal_Export-Mxxxxxxxxx~ Cx_95a3aa1d-cd6c-4844-acbd-921d46a45f8b';
file    = 'seizure_16_48_31_920_[-15min_+15min].txt';
outdir  = ['/home/manolisc/fieldtrip/' patient '/' strrep(file,'.txt','')];

% Import from txt file
[data_txt,indices] = importEEG([indir '/' patient '/' file],0);

% Store the data in FT format (First 26 channels)
data          = [];
data.label    = {'AC1'; 'AC2'; 'Ref'; 'Fp1'; 'F7'; 'T3'; 'T5'; 'O1'; 'F3'; 'C3'; 'P3'; 'Fz'; 'Cz'; 'Pz'; 'F4'; 'C4'; 'P4'; 'Fp2'; 'F8'; 'T4'; 'T6'; 'O2'; 'AC23'; 'AC24'; 'AC25'; 'AC26'};
data.fsample  = 200;
nsamples      = size(data_txt,1);
data.trial{1} = data_txt(:,1:26)';
data.time{1}  = (0:1/data.fsample:(nsamples-1)/data.fsample);
clear data_txt;

% Preprocess as single trial
cfg = [];
cfg.continuous = 'yes';
cfg.hpfilter   = 'yes';
cfg.hpfreq     = 1;
cfg.lpfilter   = 'yes';
cfg.lpfreq     = 48;
cfg.demean     = 'yes';
%cfg.dftfilter  = 'yes';
%cfg.channel    = {'all','-AC1','-AC2','-Ref','-AC26'}; 
data = ft_preprocessing(cfg,data);

% Split in segments (5 second windows)
% cfg = [];
% cfg.length = 10;
% data = ft_redefinetrial(cfg,data);

%save([outdir '/data.mat'], 'data');

% Convert to bipolar
bipolar_data = ft_montage_single2bipolar(data);
clear data;

%% TEMP - leave a small portion for testing purposes
bipolar_data.trial{1,1} = bipolar_data.trial{1,1}(:,1:2000);
bipolar_data.time{1,1} = bipolar_data.time{1,1}(:,1:2000);
bipolar_data.sampleinfo(2) = 2000;

%% Fourier-representation of the data
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'dpss';
cfg.output    = 'fourier';
cfg.tapsmofrq = 2;
cfg.keeptrials = 'yes';
cfg.foilim=[1 49];
freq_data     = ft_freqanalysis(cfg, bipolar_data);
save([outdir '/freq_data.mat'], 'freq_data');


%% Hanning window
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'hanning';
cfg.output    = 'fourier';
% cfg.output    = 'pow';
cfg.foi       = [1:1:49];
% cfg.foilim=[1 49];
cfg.t_ftimwin = ones(length(cfg.foi),1).*5;   % length of time window = 2 sec
cfg.toi       = 0:0.5:2.5;                % time window "slides" from -0.5 to 1.5
%cfg.t_ftimwin = 5./cfg.foi;
cfg.keeptrials= 'yes';
freq_data       = ft_freqanalysis(cfg, bipolar_data);
save([outdir '/freq_data.mat'], 'freq_data');


%% Coherence coefficient
cfg           = [];
cfg.method    = 'coh';
%cfg.channel   = {'all' '-AC23-AC1' '-AC24-AC2' '-AC25-AC26'};
coh           = ft_connectivityanalysis(cfg, freq_data);

%% Plot the coherence coefficients
cfg           = [];
cfg.parameter = 'cohspctrm';
cfg.zlim      = [0 1];
ft_connectivityplot(cfg, coh);

% Look into more detail
figure
plot(coh.freq, squeeze(coh.cohspctrm(3,1,:)))
title(sprintf('connectivity between %s and %s', coh.label{3}, coh.label{1}));
xlabel('freq (Hz)')
ylabel('coherence')


%% Hanning window NEW - trying Hanning on continuous data
cfg           = [];
cfg.method    = 'mtmfft';
cfg.taper     = 'hanning';
cfg.output    = 'fourier';
% cfg.output    = 'pow';
cfg.foi       = [1:1:49];
% cfg.foilim=[1 49];
 cfg.t_ftimwin = ones(length(cfg.foi),1).*5;   % length of time window = 5 sec
 cfg.toi       = 0:2.5:50;                % time window "slides"
%cfg.t_ftimwin = 5./cfg.foi;
cfg.keeptrials= 'yes';
freq_data       = ft_freqanalysis(cfg, bipolar_data);
save([outdir '/freq_data.mat'], 'freq_data');


%% By Italian guy
timwin = 5;
cfg = [];
cfg.output      = 'fourier';
cfg.method      = 'mtmconvol';
cfg.taper       = 'hanning';
%cfg.foi         = 2:1/timwin:49;
cfg.foi         = 1:1:49;
% cfg.t_ftimwin = 5./cfg.foi;
%cfg.tapsmofrq   = ones(length(cfg.foi),1).*5;
cfg.keeptrials  = 'yes';
% cfg.pad         = 'maxperlen';
 cfg.toi         = 1:timwin:bipolar_data.time{1,1}(end);
%cfg.toi         = 2:0.1:4;
 cfg.t_ftimwin   = ones(length(cfg.foi),1).*timwin;
freq_data       = ft_freqanalysis(cfg, bipolar_data);

%%
cfg           = [];
cfg.method    = 'coh';
%cfg.channel   = {'all' '-AC23-AC1' '-AC24-AC2' '-AC25-AC26'};
coh           = ft_connectivityanalysis(cfg, freq_data);

%%
cfg           = [];
cfg.method    = 'wpli';
%cfg.channel   = {'all' '-AC23-AC1' '-AC24-AC2' '-AC25-AC26'};
wpli           = ft_connectivityanalysis(cfg, freq_data);
