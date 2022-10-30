%% Get periodicities form Periodogram

clear all

load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\Dates.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\time_differences.mat')

delta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Delta_full_res.mat');
theta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Theta_full_res.mat');
alpha = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Alpha_full_res.mat');
beta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Beta_full_res.mat');
gamma = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Gamma_full_res.mat');

load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\total_sleep_signals.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\total_seiz_signals.mat')

subject_num = 08;
num_parts = 10;

parts = 1:num_parts;
srate = 2;

%%

order = ["Delta" "Theta" "Alpha" "Beta" "Gamma"]

LF = {delta.full_LF;theta.full_LF;alpha.full_LF;beta.full_LF;gamma.full_LF};
ENV = {delta.full_ENV; theta.full_ENV; alpha.full_ENV; beta.full_ENV; gamma.full_ENV};
COH = {delta.full_COH; theta.full_COH; alpha.full_COH; beta.full_COH; gamma.full_COH};

%% Smooth out

sLF = {};sENV = {}; sCOH = {};

for i=1:length(order)
    sLF{i} = smooth(LF{i},10501);
    sENV{i} = smooth(ENV{i},10501);
    sCOH{i} = smooth(COH{i},10501);
end

%%
autocorLF = {}; lagsLF = {};
autocorENV = {};lagsENV = {};
autocorCOH = {};lagsCOH = {};

for i=1:length(order)
    [autocorLF{i},lagsLF{i}] = xcov(sLF{i},'unbiased');
    [autocorENV{i},lagsENV{i}] = xcov(sENV{i},'unbiased');
    [autocorCOH{i},lagsCOH{i}] = xcov(sCOH{i},'unbiased'); 
end

%%
conv = (srate*3600);
N = length(alpha.full_COH);
cutoff = (N/(srate*3600))*(2/3)

posidx = find(lagsCOH{2}/conv > cutoff,1,'first')
negidx = find(lagsCOH{3}/conv > -cutoff,1,'first')

normCOH = {};normLF={};normENV={};

for i=1:length(order)
    
    autocorENV{i}=autocorENV{i}(negidx:posidx);
    autocorLF{i}=autocorLF{i}(negidx:posidx);
    autocorCOH{i}=autocorCOH{i}(negidx:posidx);
    
    normENV{i} = autocorENV{i}/max(max(abs(autocorENV{i})));
    normLF{i} = autocorLF{i}/max(max(abs(autocorLF{i})));
    normCOH{i} = autocorCOH{i}/max(max(abs(autocorCOH{i})));
end
%% Plots autocorr only

for i=1:length(order)

    N = length(COH{i});
    real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);
    ticks = real_t(1):hours(24):real_t(end);

    graphs_titles = strcat('Results for subject',{' '}, num2str(subject_num),{' '},'for',{' '}, order(i),' band')
    fg = figure('WindowState','maximized')
    sgtitle(graphs_titles)

    subplot(3,1,1)
    x = lagsCOH{i}/(srate*3600);
    plot(x(negidx:posidx),normCOH{i})
    xlabel('Lag (hours)')
    ylabel('Autocorrelation')
    xlim([-cutoff cutoff])
    title('Autocorrelation for Coherence')
    xticks([-120:10:120])

    subplot(3,1,2)
    x = lagsLF{i}/(srate*3600);
    plot(x(negidx:posidx),normLF{i})
    xlabel('Lag (hours)')
    ylabel('Autocorrelation')
    xlim([-cutoff cutoff])
    title('Autocorrelation for HRV-LF')
    xticks([-120:10:120])

    subplot(3,1,3)
    x = lagsENV{i}/(srate*3600);
    plot(x(negidx:posidx),normENV{i})
    xlabel('Lag (hours)')
    ylabel('Autocorrelation')
    xlim([-cutoff cutoff])
    title('Autocorrelation for EEG-ENV')
    xticks([-120:10:120])
%     
    filename = strcat('Periods\Figs\autocorr_smooth\','autocorrsub',num2str(subject_num),order(i),'.jpg')
    saveas(fg, filename)
end

%% Plots full signals

for i=1:length(order)

    N = length(COH{i});
    real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);
    ticks = real_t(1):hours(24):real_t(end);

    graphs_titles = strcat('Results for subject',{' '}, num2str(subject_num),{' '},'for',{' '}, order(i),' band')
    fgs = figure('WindowState','maximized')
    sgtitle(graphs_titles)

    subplot(2,3,1)
    p1 = plot(real_t,COH{i});
    xlabel('Time (hours)')
    ylabel('Coherence')
    xticks(ticks)
    xlim([real_t(1) real_t(end)+hours(1)])
    title(strcat('Time-Varying coherence between',{' '}, order(i),'-ENV and HRV-LF'))
    subplot(2,3,4)
    x = lagsCOH{i}/(srate*3600);
    plot(x(negidx:posidx),normCOH{i})
    xlabel('Lag (hours)')
    ylabel('Autocorrelation')
    xlim([-cutoff cutoff])
    title('Autocorrelation for Coherence')

    subplot(2,3,2)
    p1 = plot(real_t,LF{i});
    ylim([0 1])
    xlabel('Time (hours)')
    ylabel('Power')
    xticks(ticks)
    xlim([real_t(1) real_t(end)+hours(1)])
    title('Power over time of HRV-LF')
    subplot(2,3,5)
    x = lagsLF{i}/(srate*3600);
    plot(x(negidx:posidx),normLF{i})
    xlabel('Lag (hours)')
    ylabel('Autocorrelation')
    xlim([-cutoff cutoff])
    title('Autocorrelation for HRV-LF')

    subplot(2,3,3)
    p1 = plot(real_t,ENV{i});
    ylim([0 1])
    xlabel('Time (hours)')
    ylabel('Power')
    xticks(ticks)
    xlim([real_t(1) real_t(end)+hours(1)])
    title(strcat('Power over time of',{' '}, order(i),'-ENV'))
    subplot(2,3,6)
    x = lagsENV{i}/(srate*3600);
    plot(x(negidx:posidx),normENV{i})
    xlabel('Lag (hours)')
    ylabel('Autocorrelation')
    xlim([-cutoff cutoff])
    title('Autocorrelation for EEG-ENV')

    filename = strcat('Periods\Figs\full_signals\','fullsigxcorr',num2str(subject_num),order(i),'.jpg')
    saveas(fgs, filename)
    
end
%% Seiz

seiz = total_seizhours{1};


parts_total_length = zeros(num_parts,1);
parts_total_length(1) = parts_length(1);

for i=2:num_parts
    parts_total_length(i,1) = parts_length(i)+parts_total_length(i-1);
    seiz = [seiz total_seizhours{i} + parts_total_length(i-1)];
end

seiz = hours(seiz);
seiz = seiz + real_t(1);
%% Plot only signals for Thesis.
i=5

N = length(COH{i});
real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);

figure('WindowState','maximized')
% sgtitle('Time series for Subject 7','FontSize',14)

subplot(3,1,1)
plot(real_t,LF{i})
ylim([0 0.5])
hold on
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
ylim([0 0.5])
xlim([real_t(1) real_t(end)])
xlabel('Date','FontSize',14)
ylabel('Power','FontSize',14)
title('Time-varying HRV-LF power of subject 7','FontSize',14)
legend('Signal','Seizure onset'),set(legend,'fontsize',14);

subplot(3,1,2)
plot(real_t,ENV{i})
ylim([0 0.5])
hold on
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
ylim([0 0.5])
xlim([real_t(1) real_t(end)])
xlabel('Date','FontSize',14)
ylabel('Power','FontSize',14)
title('Time-varying Gamma-ENV power of subject 7','FontSize',14)
% legend('Power','Seizure onset')

subplot(3,1,3)
plot(real_t,COH{i})
ylim([0 1])
hold on
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
ylim([0 1])
xlim([real_t(1) real_t(end)])
xlabel('Date','FontSize',14)
ylabel('Coherence','FontSize',14)
title('Time-varying coherence between HRV-LF and Gamma-ENV of subject 7','FontSize',14)
% legend('Coherence','Seizure onset')

%% Plot only xcorr only for Thesis

i = 5


N = length(COH{i});
real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);
ticks = real_t(1):hours(24):real_t(end);

% graphs_titles = strcat('Results for subject',{' '}, num2str(subject_num),{' '},'for',{' '}, order(i),' band')
fg = figure('WindowState','maximized')
% sgtitle(graphs_titles)


subplot(3,1,1)
x = lagsLF{i}/(srate*3600);
plot(x(negidx:posidx),normLF{i})
xlabel('Lag (hours)','FontSize',14)
ylabel('Autocorrelation','FontSize',14)
xlim([-cutoff cutoff])
title('Autocorrelation for HRV-LF of subject 7','FontSize',14)
xticks([-120:10:120])

subplot(3,1,2)
x = lagsENV{i}/(srate*3600);
plot(x(negidx:posidx),normENV{i})
xlabel('Lag (hours)','FontSize',14)
ylabel('Autocorrelation','FontSize',14)
xlim([-cutoff cutoff])
title('Autocorrelation for Gamma-ENV of subject 7','FontSize',14)
xticks([-120:10:120])

subplot(3,1,3)
x = lagsCOH{i}/(srate*3600);
plot(x(negidx:posidx),normCOH{i})
xlabel('Lag (hours)','FontSize',14)
ylabel('Autocorrelation','FontSize',14)
xlim([-cutoff cutoff])
title('Autocorrelation for Coherence between HRV-LF and Gamma-ENV of subject 7','FontSize',14)
xticks([-120:10:120])