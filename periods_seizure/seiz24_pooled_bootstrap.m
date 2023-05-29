%% Try bootstrapping with reduced # of seizures to avoid biasing results

clear all

period = 24 % Check for individual periodicities
srate = 2;

order = ["Delta","Theta","Alpha","Beta","Gamma"];
siggies = ["LF", "ENV", "COH"];

% subs = [02 03 05 07 08 10 14 21]
% specific_period = [24 24 25 22 24 27 26 23]

% n_subs = length(subs)

%% FOR HRV-LF
% subs = [02 03 05 06 07 08 09 10 14 21]
% specific_period = [27 25 27 22.97 22 24 21.34 27 26 22]
subs = [02 03 05 06 07 08 14 21]
specific_period = [27 25 27 22.97 22 24 26 22]
n_subs = length(subs)
% 
j=5

%% For Gamma 24
% % 
% subs = [02 03 05 06 07 08 09 10 14 21]
% % specific_period = [24 24 25 22 24 27 26 23]
subs = [02 03 05 06 07 08 14 21]
specific_period = [23.77 25 23.65 23.60 21.16 24 27.33 20.67]

n_subs = length(subs)
j=5
 %% Periods Beta
% subs = [02 03 04 05 06 07 08 09 10 14 21]
% specific_period = [27 22 28 28 22.97 25.8 27 25.87 22 22 22]; %For beta
% specific_period = [27 22 28 28 24.99 25.8 27 24.39 22 22 22]; %For beta
% subs = [02 03 04 05 06 07 08 14 21]
% specific_period = [27 22 28 28 22.97 25.8 27 22 22]; %For beta
% % 
% n_subs = length(subs)


% j = 4 % For band
%% Periods Alpha
% subs = [02 03 04 05 06 07 08 09 10 14 21]
% specific_period = [23.7 25 28 22 22.97 20.5 24 21.34 25 21 20.6]; %For alpha
subs = [02 03 04 05 06 07 08 14 21]
specific_period = [23.7 25 28 22 22.97 20.5 24 21 20.6]; %For alpha
n_subs = length(subs)
j = 3 % For band
%% For Theta 24
% subs = [02 03 05 07 08 10 14 21]
% specific_period = [23.7 27 24.4 25.8 24.68 25 21 20.6]; %For alpha

subs = [02 03 05 06 07 08 14 21]
specific_period = [23.7 27 24.4 22.97 25.8 24.68 21 20.6];

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
    thetaHLF{1,i} = angle(HLF{1,i});
    thetaHLF{1,i} = wrap(thetaHLF{1,i},2);
    
    HENV{1,i} = hilbert(filt_periodsENV{1,i});
    thetaHENV{1,i} = angle(HENV{1,i});
    thetaHENV{1,i} = wrap(thetaHENV{1,i},2);
    
    HCOH{1,i} = hilbert(filt_periodsCOH{1,i});
    thetaHCOH{1,i} = angle(HCOH{1,i});
    thetaHCOH{1,i} = wrap(thetaHCOH{1,i},2);
    
    theta_seizLF{1,i} = thetaHLF{1,i}(round(tseizloc{i}));
    theta_seizENV{1,i} = thetaHENV{1,i}(round(tseizloc{i}));
    theta_seizCOH{1,i} = thetaHCOH{1,i}(round(tseizloc{i}));
        
end

min_seiz = min(cellfun('size',theta_seizLF,2));

%% Obtain minimum amount of seizures from subjects and select random seizure for each subject

N_trials = 100

rLF = zeros(1,N_trials); rENV = zeros(1,N_trials); rCOH = zeros(1,N_trials);
RLF = zeros(1,N_trials); RENV = zeros(1,N_trials); RCOH = zeros(1,N_trials);

for j=1:N_trials

    sampleLF = {}; sampleENV = {}; sampleCOH = {};
    
    for i=1:length(subs)
        sampleLF{1,i} = randsample(theta_seizLF{1,i}, min_seiz);
        sampleENV{1,i} = randsample(theta_seizENV{1,i}, min_seiz);
        sampleCOH{1,i} = randsample(theta_seizCOH{1,i}, min_seiz);
    end
    
    pooledLF = cell2mat(sampleLF);
    pooledENV = cell2mat(sampleENV);
    pooledCOH = cell2mat(sampleCOH);
    
    rLF(j) = circ_rtest(pooledLF);
    rENV(j) = circ_rtest(pooledENV);
    rCOH(j) = circ_rtest(pooledCOH);
    
    RLF(j) = circ_r(transpose(pooledLF));
    RENV(j) = circ_r(transpose(pooledENV));
    RCOH(j) = circ_r(transpose(pooledCOH));
end

%%

N_significantLF = sum(rLF <= 0.05)
N_significantENV = sum(rENV <= 0.05)
N_significantCOH = sum(rCOH <= 0.05)

%%
MAXrENV = max(rENV)
MINrENV = min(rENV)

MAXRENV = max(RENV)
MINRENV = min(RENV)
%%

MAXrCOH = max(rCOH)
MINrCOH = min(rCOH)

MAXRCOH = max(RCOH)
MINRCOH = min(RCOH)
