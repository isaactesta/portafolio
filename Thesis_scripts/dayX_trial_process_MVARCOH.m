%% Preprocess the first day of the subject for EEG and ECG to start interactions trials
% Will try coherence based on multivariate MVAR

clear all

load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\M08_02a\Data_full.mat', 'EEG')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\M08_02a\QRS_detected.mat', 'qrs_times1')

Y = obtain_hrv(qrs_times1);
x = 1:size(Y);
[HRV,TF,lower,upper,center] = filloutliers(Y,'linear','percentiles',[0.1 99.9]);

HRV(HRV>5) = 5;
HRV(HRV<0) = 0;

clear TF lower upper center
%% Pre-EEG

% For Full thing
[filtered_data]=eegfilt(EEG,256,0,50);

% Check Channels
mEEG = mean(filtered_data,1);
srate = 256;
srate_new = 64;

srate_f = 2;
lSignal = length(mEEG)/(3600*srate);

% Delta-ENV
% deltab = get_delta_band(mEEG,srate);
% deltab = resample(deltab,srate_new,srate);
% t_eeg = (0:length(deltab)-1)/(64); %time in seconds
% [up,lo] = envelope(deltab); % Will be using up - the upper envelope

% Beta - ENV, for trial
betab = get_beta_band(mEEG,srate);
betab = resample(betab,srate_new,srate);
t_eeg = (0:length(betab)-1)/(64); %time in seconds
[up,lo] = envelope(betab); % Will be using up - the upper envelope

% % Alpha - ENV, for trial
% alphab = get_alpha_band(mEEG,srate);
% alphab = resample(alphab,srate_new,srate);
% t_eeg = (0:length(alphab)-1)/(64); %time in seconds
% [up,lo] = envelope(alphab); % Will be using up - the upper envelope

% % Theta - ENV, for trial
% thetab = get_theta_band(mEEG,srate);
% thetab = resample(thetab,srate_new,srate);
% t_eeg = (0:length(thetab)-1)/(64); %time in seconds
% [up,lo] = envelope(thetab); % Will be using up - the upper envelope

% % Gamma - ENV, for trial
% gammab = get_gamma_band(mEEG,srate);
% gammab = resample(gammab,srate_new,srate);
% t_eeg = (0:length(gammab)-1)/(64); %time in seconds
% [up,lo] = envelope(gammab); % Will be using up - the upper envelope

% mEEG = resample(mEEG,srate_new,srate);
% t_eeg = (0:length(mEEG)-1)/(64); %time in seconds
% [up,lo] = envelope(mEEG);

% plot(t_eeg,deltab)
% plot(t_eeg,alphab)
% hold on
% plot(t_eeg,up,t_eeg,lo,'linewidth',1.5)
% legend('q','up','lo')

ENV = resample(up,srate_f,srate_new);
t_eeg = (0:length(ENV)-1)/(srate_f);
% plot(ENV)


%% Pre HRV, process for same length

HRV = resample(HRV,srate_f,1);
HRV = transpose(HRV);

del = (size(HRV,2)-1)/lSignal;
t_HRV = (0:size(HRV,2)-1)/del;
tq = t_eeg/3600;

HRV = interp1(t_HRV,HRV,tq,'linear');
%%
HRV = HRV-mean(HRV(:)); % Normalize to get ready for mvar
HRV = HRV/std(HRV(:));

ENV = ENV-mean(ENV(:));
ENV = ENV/std(ENV(:));

signals = cat(1,ENV,HRV);

% For Sub21_02, will start at 25 (which is at 50 seconds)
% signals = signals(:,25:end);
%% MVAR using in in row 1 the frq band and in row the the HRV
clear qrs_times1 up tq x Y filtered_data EEG mEEG HRV lo ENV t_eeg t_HRV

param.pmax=10;           %Maximum MVAR model order to be considered when optimizing with the GA
param.pmaxGARCH=5;       %Maximum order to be considered when fitting GARCH models on the TV-MVAR residuals
param.metric=1;          %GA Fitness function (1 for multivariate AIC, 2 for multivariate BIC)
param.ignore=100;        %Number of time points to ignore due to initialization of the estimator (i.e. conventional/proposed KF)
param.smoothflag=1;      %Set to 1 to apply smoothing on the estimated TV-MVAR coefficients
param.hetflag=1;         %Set to 1 for the heteroskedastic case - The TV covariance of the MVAR residuals is estimated using GARCH models
param.measflag=1;        %Set to 1 to estimate the TV-MVAR measures (i.e. COH,PCOH,DC,gPDC) based on the obtained TV-MVAR coefficients
param.nfft=256;          %Number of points for the calculation of the TV-MVAR measures in the frequency domain 
param.fs=2;              %Sampling Frequency
siglab={'Beta-ENV','HRV'};    %Labels for the time-series
param.M=2;               %Number of time-series (i.e. the dimension of the MVAR model)
heterosk=1;              %Set to 1 to simulate a TV-MVAR process driven by heteroskedastic noise or 0 for the homoskedastic case
                         %In the heteroskedastic case The variance of the driving noise is initially 1 (i.e. S=[1 0 0;0 1 0;0 0 1])                   
                         %for all time series but then the covariance changes to S=[0.5 0 0;0 0.8 0;0 0 0.2] at time point 551
                         %In the homoskedastic case the covariance is constant [1 0 0;0 1 0;0 0 1]

nworkers=6;            %Choose based on your computer specs 
parpool(nworkers)      %Initialize parallel pool with nworkers
param.ga_opts = gaoptimset('TolFun',1e-12,'StallGenLimit',30,'Generations',100,'Display','iter','UseParallel','always');  


[XMKFA2, JMKFA2]=GA_MVAR_MKFA2(signals,param);
resultsMKFA2=simulate_MVAR_MKFA2(XMKFA2,signals,param);

%% Save in interaction folder of subject
filename =  'resultsMKFA_08_BETA'
save(filename,'resultsMKFA2','signals','XMKFA2','lSignal','siglab','-v7.3')

