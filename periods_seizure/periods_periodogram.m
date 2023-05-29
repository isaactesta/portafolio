%% Get periodicities form Periodogram

clear all

load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\Dates.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\time_differences.mat')

delta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Delta_full_res.mat');
theta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Theta_full_res.mat');
alpha = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Alpha_full_res.mat');
beta = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Beta_full_res.mat');
gamma = load('E:\Isaac_D2\Interactions\Trials_lab\Subject08\Periods\Gamma_full_res.mat');


subject_num = 08;
num_parts = 10;

parts = 1:num_parts;
srate = 2;


%%

order = ["Delta" "Theta" "Alpha" "Beta" "Gamma"]

LF = {delta.full_LF;theta.full_LF;alpha.full_LF;beta.full_LF;gamma.full_LF};
ENV = {delta.full_ENV; theta.full_ENV; alpha.full_ENV; beta.full_ENV; gamma.full_ENV};
COH = {delta.full_COH; theta.full_COH; alpha.full_COH; beta.full_COH; gamma.full_COH};

%%
pxx_LF = {};
pxx_ENV = {};
pxx_COH = {};

ff_LF = {};
ff_ENV = {};
ff_COH = {};

vLF = {};
vENV = {};
vCOH = {};

for i=1:length(order)
    nLF = LF{i} - mean(LF{i});
    nENV = ENV{i} - mean(ENV{i});
    nCOH = COH{i} - mean(COH{i});
    
%     nLF = downsample(nLF,2);
%     nENV = downsample(nENV,2);
%     nCOH = downsample(nCOH,2);
%     
    vLF{i} = var(nLF);
    vENV{i} = var(nENV);
    vCOH{i} = var(nCOH);
    
    srate = 2;
    wind = kaiser(length(nLF));
%     wind =500000
%     [pxx_LF{i},ff_LF{i}] = periodogram(nLF,kaiser(length(nLF)),length(nLF),srate);
%     [pxx_ENV{i},ff_ENV{i}] = periodogram(nENV,kaiser(length(nLF)),length(nLF),srate);
%     [pxx_COH{i},ff_COH{i}] = periodogram(nCOH,kaiser(length(nLF)),length(nLF),srate);
    [pxx_LF{i},ff_LF{i}] = pwelch(nLF,wind,[],length(nLF)*5,srate);
    [pxx_ENV{i},ff_ENV{i}] = pwelch(nENV,wind,[],length(nLF)*5,srate);
    [pxx_COH{i},ff_COH{i}] = pwelch(nCOH,wind,[],length(nLF)*5,srate);
end
%% Plots for three autocorr
pkshLF = cell(1,5); pkshENV = cell(1,5);pkshCOH = cell(1,5);
lcshLF = cell(1,5); lcshENV = {}; lcshCOH = cell(1,5);

periodsLF = cell(1,5); periodsENV = cell(1,5); periodsCOH = cell(1,5);

%% Plots


for i=1:length(order) 
     
    pprom = 0.5;
    pdist = 5;

    fg = figure('WindowState','maximized')
    sgtitle(strcat('Periodogram for subject 08, For Band:',{' '},order(i)))  
    
    subplot(3,1,1)
    x = ff_LF{i};
    xt = (1./x)/(3600);
    y = sqrt(pxx_LF{i}/vLF{i});
    [ind,~] = find(xt(:,1) >= 8 & xt(:,1) < total_length/2);
    [pkshLF{i},lcshLF{i}] = findpeaks(y,'MinPeakDistance',pdist,'minPeakProminence',pprom);
    periodsLF{i} = xt(lcshLF{i}(1:10));
    plot(xt,y);hold on; plot(xt(lcshLF{i}),pkshLF{i},'o')
    title(strcat('Periodogram for time-varying HRV-LF for band',{' '},order(i),{' '},'For subject',num2str(subject_num)))
    xlabel('Period (Hour)')
    ylabel('Power')
%     xlim([8 total_length/2])
%     xticks(8:4:total_length/2)
    xlim([0 total_length/2])
    xticks(0:4:total_length/2)

    subplot(3,1,2)
    x = ff_ENV{i};
    xt = (1./x)/(3600);
    y = sqrt(pxx_ENV{i}/vENV{i});
    [ind,~] = find(xt(:,1) >= 8 & xt(:,1) < total_length/2);
    [pkshENV{i},lcshENV{i}] = findpeaks(y,'MinPeakDistance',pdist,'minPeakProminence',pprom);
    periodsENV{i} = xt(lcshENV{i}(1:10));
    plot(xt,y);hold on; plot(xt(lcshENV{i}),pkshENV{i},'o')
    title(strcat('Periodogram for time-varying EEG-ENV for band',{' '},order(i),{' '},'For subject',num2str(subject_num)))
    xlabel('Period (Hour)')
    ylabel('Power')
    xlim([0 total_length/2])
    xticks(0:4:total_length/2)
      
    subplot(3,1,3)
    x = ff_COH{i};
    xt = (1./x)/(3600);
    y = sqrt(pxx_COH{i}/vCOH{i});
    [ind,~] = find(xt(:,1) >= 8 & xt(:,1) < total_length/2);
    [pkshCOH{i},lcshCOH{i}] = findpeaks(y,'MinPeakDistance',pdist,'minPeakProminence',pprom); 
    periodsCOH{i} = xt(lcshCOH{i}(1:10));
    plot(xt,y);hold on; plot(xt(lcshCOH{i}),pkshCOH{i},'o')
    title(strcat('Periodogram for time-varying COH for band',{' '},order(i),{' '},'For subject',num2str(subject_num)))
    xlabel('Period (Hour)')
    ylabel('Power')
    xlim([0 total_length/2])
    xticks(0:4:total_length/2)
% 
%     filename = strcat('Periods\Figs\Periodograms\','periodogram',num2str(subject_num),order(i),'.jpg')
%     saveas(fg, filename)
end

% save('Periods\periodicities.mat','periodsENV','periodsCOH','periodsLF')

%%
figure;
i = 4
x = ff_ENV{i};
xt = (1./x)/(3600);
% y = 10*log10(pxx_ENV{i}/vENV{i});
y = sqrt(pxx_ENV{i}/vENV{i});
plot(xt,y)
title(strcat('Periodogram for time-varying EEG-ENV for band',{' '},order(i),{' '},'For subject',num2str(subject_num)))
xlabel('Period (Hr)')
ylabel('Power')
xlim([4 total_length/2])
xticks(4:8:total_length/2)
%%
i = 3;
x = ff_LF{i};
xt = 1./x;
% log3x = log10(1./x)/log10(3);
% y = 10*log10(pxx_ENV{i}/vENV{i});
y = sqrt(pxx_LF{i}/vLF{i});
plot(xt,smooth(y))
title(strcat('Periodogram for time-varying HRV-LF for band',{' '},order(i),{' '},'For subject 0',num2str(subject_num)))
xlabel('Period (Hr)')
ylabel('Power')
% xlim([2 70])
% xticks(2:6:70)
% xt = get(gca, 'XTick');
% % xp = log2(1./xt);
% set(gca, 'XTick',xt, 'XTickLabel',xp*100, 'XDir','reverse')
%% Plot for thesis

i=5

subplot(3,1,1)
x = ff_LF{i};
xt = (1./x)/(3600);
y = sqrt(pxx_LF{i}/vLF{i});
plot(xt,y);
title(strcat('Periodogram for time-varying HRV-LF power of subject 7'),'FontSize',14)
xlabel('Period (Hour)','FontSize',14)
ylabel('Power','FontSize',14)
xlim([8 total_length/2])
xticks(8:4:total_length/2)

subplot(3,1,2)
x = ff_ENV{i};
xt = (1./x)/(3600);
y = sqrt(pxx_ENV{i}/vENV{i});
plot(xt,y);
title(strcat('Periodogram for time-varying Gamma-ENV power of subject 7'),'FontSize',14)
xlabel('Period (Hour)','FontSize',14)
ylabel('Power','FontSize',14)
xlim([8 total_length/2])
xticks(8:4:total_length/2)

subplot(3,1,3)
x = ff_COH{i};
xt = (1./x)/(3600);
y = sqrt(pxx_COH{i}/vCOH{i});
[ind,~] = find(xt(:,1) >= 8 & xt(:,1) < total_length/2);
plot(xt,y);
title(strcat('Periodogram for time-varying coherence between HRV-LF and Gamma-ENV of subject 7'),'FontSize',14)
xlabel('Period (Hour)','FontSize',14)
ylabel('Power','FontSize',14)
xlim([8 total_length/2])
xticks(8:4:total_length/2)

