

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


%% Annotate events and artifacts
clear cfg1 cfg2 dir file data_org artifacts seizures

indir = '/home/epilepsy/Original_Data/new-patients-small-files';
patient = 'Demetriadou Kyriaki 2440';
%file = 'EDF + Day 11.edf'
file = 'DK_Episode_2.edf';

tic;
cfg1 = [];
%dir  = '/home/epilepsy/Original Data/new-patients/Demetriadou Kyriaki 2440/';
cfg1.dataset    = [indir '/' patient '/' file];
cfg1.continuous  = 'yes';           % Treat data as one contiguous file
data_org   = ft_preprocessing(cfg1);
toc/60

outdir = '/home/manast09/fieldtrip';

cfg2 = [];
cfg2.continuous  = 'yes';
cfg2.viewmode    = 'vertical';
cfg2.blocksize   = 10;
artifacts = ft_databrowser(cfg2,data_org);
if (~exist([outdir '/' patient], 'dir'))
    mkdir([outdir '/' patient]);
end
save([outdir '/' patient '/'  strrep(file,'.edf',' Artifacts.mat')], 'artifacts');
seizures  = ft_databrowser(cfg2,data_org);
save([outdir '/' patient '/'  strrep(file,'.edf',' Seizures.mat')], 'seizures');
