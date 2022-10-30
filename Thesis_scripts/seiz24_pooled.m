%% Pool seizures for one periodicity

clear all

period = 24 % Check for individual periodicities
srate = 2;

order = ["Delta","Theta","Alpha","Beta","Gamma"];
siggies = ["LF", "ENV", "COH"];

%% FOR HRV-LF
subs = [02 03 05 06 07 08 09 10 14 21]
specific_period = [27 25 27 22.97 22 24 21.34 27 26 22]
% subs = [02 03 05 06 07 08 14 21]
% specific_period = [27 25 27 22.97 22 24 26 22]
n_subs = length(subs)

j=5
 %% For Gamma 24

subs = [02 03 05 06 07 08 09 10 14 21]
specific_period = [23.77 25 23.65 23.60 21.16 24 25.9 25.55 27.33 20.67]
% subs = [02 03 05 06 07 08 14 21]
% specific_period = [23.77 25 23.65 23.60 21.16 24 27.33 20.67]

n_subs = length(subs)
j=5
%% For Beta 24
% subs = [02 03 04 05 06 07 08 09 10 14 21]
% % specific_period = [27 22 28 28 22.97 25.8 27 25.87 22 22 22]; %For beta

% subs = [02 03 04 05 06 07 08 14 21]
% specific_period = [27 22 28 28 22.97 25.8 27 22 22]; %For beta
% % % 
% n_subs = length(subs)
% 
% j = 4 % For band

%% For Alpha 24
% subs = [02 03 04 05 06 07 08 09 10 14 21]
% specific_period = [23.7 25 28 22 22.97 20.5 24 21.34 25 21 20.6]; %For alpha
% 
% subs = [02 03 04 05 06 07 08 14 21]
% specific_period = [23.7 25 28 22 22.97 20.5 24 21 20.6]; %For alpha

% n_subs = length(subs)
% j = 3 % For band

 %% For Theta 24
% % subs = [02 03 05 06 07 08 09 10 14 21]
% % specific_period = [23.7 27 24.4 22.97 25.8 24.68 26.68 25 21 20.6]; %For alpha

% subs = [02 03 05 06 07 08 14 21]
% specific_period = [23.7 27 24.4 22.97 25.8 24.68 21 20.6];

n_subs = length(subs)
j = 2 % For band

%% For Delta 24
% subs = [02 03 04 05 06 07 08 09 10 14 21]
% specific_period = [22.4 23 22 24.4 22.97 24.9 24 25.87 24.67 23.68 25.38]; %For alpha

subs = [02 03 04 05 06 07 08 14 21]
specific_period = [22.4 23 22 24.4 22.97 24.9 24 23.68 25.38]; %For alpha

n_subs = length(subs)
j = 1 % For band
%%
LF = {}; ENV = {}; COH = {}; order = {}; seiz = {}; parts = {}; start = {}; fin = {};
tseizloc = {}; tseiz = {};

for i=1:n_subs
[LF{i},ENV{i},COH{i},order{i},seiz{i},parts{i},start{i},fin{i}] = sigs_info(subs(i));

tseizloc{i} = seiz{i}*3600;
tseiz{i} = hours(seiz{i});
end

%% For Gamma band

filt_periodsLF = cell(1,length(subs)); HLF = cell(1,length(subs));
thetaHLF = cell(1,length(subs));rLF = cell(1,length(subs)); theta_seizLF = cell(1,length(subs));

filt_periodsENV = cell(1,length(subs)); HENV = cell(1,length(subs));
thetaHENV = cell(1,length(subs));rENV = cell(1,length(subs)); theta_seizENV = cell(1,length(subs));

filt_periodsCOH = cell(1,length(subs)); HCOH = cell(1,length(subs));
thetaHCOH = cell(1,length(subs));rCOH = cell(1,length(subs)); theta_seizCOH = cell(1,length(subs));

for i=1:length(subs)
  
    signal = LF{i}; % Select Subject
    N = length(signal{j});
    lSignal = N/(srate*3600)
    filt_periodsLF{1,i} = filter_periodicity(specific_period(i), signal{j}, srate,lSignal);     
    
    signal = ENV{i}; % Select Subject
    filt_periodsENV{1,i} = filter_periodicity(specific_period(i), signal{j}, srate,lSignal); 
    
    signal = COH{i};  % Select Subject
    filt_periodsCOH{1,i} = filter_periodicity(specific_period(i), signal{j}, srate,lSignal); 
   
    
    HLF{1,i} = hilbert(filt_periodsLF{1,i});
    thetaHLF{1,i} = angle(HLF{1,i})
    thetaHLF{1,i} = wrap(thetaHLF{1,i},2);
    
    HENV{1,i} = hilbert(filt_periodsENV{1,i});
    thetaHENV{1,i} = angle(HENV{1,i})
    thetaHENV{1,i} = wrap(thetaHENV{1,i},2);
    
    HCOH{1,i} = hilbert(filt_periodsCOH{1,i});
    thetaHCOH{1,i} = angle(HCOH{1,i})
    thetaHCOH{1,i} = wrap(thetaHCOH{1,i},2);
    
    theta_seizLF{1,i} = thetaHLF{1,i}(round(tseizloc{i}));
    theta_seizENV{1,i} = thetaHENV{1,i}(round(tseizloc{i}));
    theta_seizCOH{1,i} = thetaHCOH{1,i}(round(tseizloc{i}));
        
end

%% Pool together seizure phases

pooledLF = cell2mat(theta_seizLF);
pooledENV = cell2mat(theta_seizENV);
pooledCOH = cell2mat(theta_seizCOH);

rLF = circ_rtest(pooledLF)
rENV = circ_rtest(pooledENV)
rCOH = circ_rtest(pooledCOH)

RLF = circ_r(transpose(pooledLF))
RENV = circ_r(transpose(pooledENV))
RCOH = circ_r(transpose(pooledCOH))

%% for env and Coh plots
% Change titles to autmotacally put period
fg=figure('WindowState','maximized')
titulo = strcat('For circadian periodicitity',{' '},num2str(period),',',{' '}, 'Num of seizures = ',{' '} ...
    ,num2str(length(pooledLF)),',', {' '},'For Band = ',{' '},order{j}{j})
% title(strcat('Seizure correlation for circadian periodicity))
sgtitle(titulo)

% subplot(3,2,1)
% circ_plot(transpose(pooledLF),'pretty','bo',true,'linewidth',2)
% text(2,0.5,strcat('Rayleight test results: ',num2str(rLF)),'FontSize',14)
% text(2,0.2,strcat('R Value: ',num2str(RLF)),'FontSize',14)
% 
% title('Angular plot for LF of pooled 24 Hr periodicities')
% 
% subplot(3,2,2)
% circ_plot(transpose(pooledLF),'hist')
%%
fg=figure('WindowState','maximized')
% title(strcat('Angular plots of circadian periodicity for envelope of',{' '},order{j}{j},{' '},'band'),'FontSize',16)

subplot(1,2,1)
circ_plot(transpose(pooledENV),'pretty','bo',true,'linewidth',2,'color','r')
text(0.01,0.3,strcat('Rayleight test results: ',num2str(rENV)),'FontSize',14)
text(0.01,0.2,strcat('R Value: ',num2str(RENV)),'FontSize',14)
set(gca,'XColor','none','YColor','none')
 title(strcat('Angular plots of circadian periodicity for envelope of',{' '},order{j}{j},{' '},'band'),'FontSize',17)
titleHandle = get( gca ,'Title' );
pos  = get( titleHandle , 'position' );
pos1 = pos + [0 0.125 0] 
set( titleHandle , 'position' , pos1 );

subplot(1,2,2)
circ_plot(transpose(pooledENV),'hist',[],20,true,true,'linewidth',2,'color','r')
title(strcat('Distribution of seizure onset phases'),'FontSize',17)
%%
fg=figure('WindowState','maximized')
% sgtitle(strcat('Angular plots of circadian periodicity for coherence between',{' '},order{j}{j},{' '},'band and HRV-LF'),'FontSize',16)
subplot(1,2,1)
circ_plot(transpose(pooledCOH),'pretty','bo',true,'linewidth',2,'color','r')
text(0.01,0.3,strcat('Rayleight test results: ',num2str(rCOH)),'FontSize',14)
text(0.01,0.2,strcat('R Value: ',num2str(RCOH)),'FontSize',14)
set(gca,'XColor','none','YColor','none')
title(strcat('Angular plots of circadian periodicity for coherence between',{' '},order{j}{j},{' '},'band and HRV-LF'),'FontSize',17)
titleHandle = get( gca ,'Title' );
pos  = get( titleHandle , 'position' );
pos1 = pos + [0 0.125 0] 
set( titleHandle , 'position' , pos1 );
% title('Angular plot for LF of pooled 24 Hr perio

subplot(1,2,2)
circ_plot(transpose(pooledCOH),'hist',[],20,true,true,'linewidth',2,'color','r')
title(strcat('Distribution of seizure onset phases'),'FontSize',17)

%% For HRV-LF plot
fg=figure('WindowState','maximized')
% title(strcat('Angular plots of circadian periodicity for HRV-LF'),'FontSize',16)
subplot(1,2,1)
circ_plot(transpose(pooledLF),'pretty','bo',true,'linewidth',2,'color','r')
text(0.01,0.3,strcat('Rayleight test results: ',num2str(rLF)),'FontSize',14)
text(0.01,0.2,strcat('R Value: ',num2str(RLF)),'FontSize',14)
set(gca,'XColor','none','YColor','none')
title(strcat('Angular plots of circadian periodicity for HRV-LF'),'FontSize',17)
titleHandle = get( gca ,'Title' );
pos  = get( titleHandle , 'position' );
pos1 = pos + [0 0.125 0] 
set( titleHandle , 'position' , pos1 );
% title('Angular plot for LF of pooled 24 Hr periodicities')

subplot(1,2,2)
circ_plot(transpose(pooledLF),'hist',[],20,true,true,'linewidth',2,'color','r')
title(strcat('Distribution of seizure onset phases'),'FontSize',17)
