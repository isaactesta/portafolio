%% Create plots with Coherence of all bands for a subject in order to comapre them

clear all

order = ["Delta" "Theta" "Alpha" "Beta" "Gamma"]

load('E:\Isaac_D2\M2_codes\subjects_process\Subject24\Full\Dates.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject24\Full\time_differences.mat')
load('E:\Isaac_D2\Interactions\Trials_lab\Subject24\Periods\num_parts.mat')

delta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject24\Periods\Delta_full_res.mat');
theta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject24\Periods\Theta_full_res.mat');
alpha = load('E:\Isaac_D2\Interactions\Trials_lab\Subject24\Periods\Alpha_full_res.mat');
beta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject24\Periods\Beta_full_res.mat');
gamma = load('E:\Isaac_D2\Interactions\Trials_lab\Subject24\Periods\Gamma_full_res.mat');

subject_num = 24;
thesis_sub = 12

parts = 1:num_parts;
srate = 2;

%% Smooth out COH
COH = {delta.full_COH; theta.full_COH; alpha.full_COH; beta.full_COH; gamma.full_COH};
for i=1:length(order)
    COH{i} = smooth(COH{i},50000);
end
%% Plots for Coherence

% N = length(COH{i})
% real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);
% 
% ticks = real_t(1):hours(16):real_t(end);

figure('WindowState','maximized')
for i=1:length(order)

    N = length(COH{i})
    real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);

%     ticks = real_t(1):hours(total_length/14):real_t(end);
    plot(real_t,COH{i});hold on
end
title(strcat('Comparison of time-varying Coherence between HRV-LF and EEG envelopes for subject',{' '},num2str(thesis_sub)),'fontSize',14)
ylim([0 1])
xlim([real_t(1) real_t(end)])
% xticks(ticks)
ylabel('Coherence','fontSize',14)
xlabel('Date','fontSize',14)
legend(order)

