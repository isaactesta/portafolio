%% Process the ECG data after combining parts of each subject

% Process and Filter ECG
[m, n] = size(ECG);
[row, col] = find(isnan(ECG)); % check for Nan values

filt_ecg = filter_ecg(ECG,srate);

filt_ecg(filt_ecg < -0.005) = -0.005;
filt_ecg(filt_ecg > 0.005) = 0.005; % 0.003 Is the max QRS ampltiude

filt_ecg(filt_ecg < -0.003) = -0.003;
filt_ecg(filt_ecg > 0.003) = 0.003; % 0.003 Is the max QRS ampltiude

% filt_ecg(filt_ecg < -0.0015) = -0.0015;
% filt_ecg(filt_ecg > 0.0015) = 0.0015; % 0.003 Is the max QRS ampltiude

plot(ECG)
hold on
plot(filt_ecg)

%% QRS detected
[m, n] = size(filt_ecg);
time_ecg = zeros(n,2);
for j = 1:1:n
        time_ecg(j,1) = (j-1)/srate;
end
time_ecg(:,2) = filt_ecg;

% for M07_07: time_ecg = time_ecg(10000:end,:);

% Change inversion
[qrs_times1, qrs_amp1, qrs_messy1] = find_qrs_peaks_mark (time_ecg,0,-1,srate);
[hr1, t1, rejected_beats1, qrs_times1, qrs_messy1, destruction1, restoration1] = preprocess_fast (qrs_times1, qrs_messy1, srate, 1);

%% Save QRS Detection

filename = strcat(destination_folder{1},'\QRS_detected.mat')
save(filename,'qrs_times1','t1','rejected_beats1','srate','qrs_amp1')

lSignal = qrs_times1(end)/3600;

%% MVAR model

Y = obtain_hrv(qrs_times1);
x = 1:size(Y);
[B,TF,lower,upper,center] = filloutliers(Y,'linear','percentiles',[0.1 99.9]);
figure;
plot(x,Y,x,B,'o',x,lower*ones(1,size(Y,1)),x,upper*ones(1,size(Y,1)),x,center*ones(1,size(Y,1)))
legend('Original Data','Filled Data','Lower Threshold','Upper Threshold','Center Value')

% B(B>2) = 2;
% B(B<0) = 0;
figure;
plot(Y);hold on
plot(B)

%% For very messy parts such as M07_11
% B  = smooth(B)
% plot(B1)
%%

B = B-mean(B(:));
B = B/std(B(:));
RR = transpose(B);

param.pmax=10;           %Maximum MVAR model order to be considered when optimizing with the GA
param.pmaxGARCH=5;       %Maximum order to be considered when fitting GARCH models on the TV-MVAR residuals
param.metric=1;          %GA Fitness function (1 for multivariate AIC, 2 for multivariate BIC)
param.ignore=100;        %Number of time points to ignore due to initialization of the estimator (i.e. conventional/proposed KF)
param.smoothflag=1;      %Set to 1 to apply smoothing on the estimated TV-MVAR coefficients
param.hetflag=1;         %Set to 1 for the heteroskedastic case - The TV covariance of the MVAR residuals is estimated using GARCH models
param.measflag=1;        %Set to 1 to estimate the TV-MVAR measures (i.e. COH,PCOH,DC,gPDC) based on the obtained TV-MVAR coefficients
param.nfft=256;          %Number of points for the calculation of the TV-MVAR measures in the frequency domain 
param.fs=1;              %Sampling Frequency
siglab={'y1','y2','y3'}; %Labels for the time-series
param.M=1;               %Number of time-series (i.e. the dimension of the MVAR model)
heterosk=1;              %Set to 1 to simulate a TV-MVAR process driven by heteroskedastic noise or 0 for the homoskedastic case
                         %In the heteroskedastic case The variance of the driving noise is initially 1 (i.e. S=[1 0 0;0 1 0;0 0 1])                   
                         %for all time series but then the covariance changes to S=[0.5 0 0;0 0.8 0;0 0 0.2] at time point 551
                         %In the homoskedastic case the covariance is constant [1 0 0;0 1 0;0 0 1]

nworkers=6;            %Choose based on your computer specs 
parpool(nworkers)      %Initialize parallel pool with nworkers
param.ga_opts = gaoptimset('TolFun',1e-12,'StallGenLimit',30,'Generations',100,'Display','iter','UseParallel','always');  


[XMKFA2, JMKFA2]=GA_MVAR_MKFA2(RR,param);
resultsMKFA2=simulate_MVAR_MKFA2(XMKFA2,RR,param);

%% Save MVAR Res

filename = strcat(destination_folder{1},'\MVAR_res.mat')
save(filename,'resultsMKFA2','RR','XMKFA2', 'JMKFA2','lSignal')


plot_MVAR_res(resultsMKFA2,lSignal)