%% Periodogram from Autocorrelation


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

order = ["Delta" "Theta" "Alpha" "Beta" "Gamma"]

LF = {delta.full_LF;theta.full_LF;alpha.full_LF;beta.full_LF;gamma.full_LF};
ENV = {delta.full_ENV; theta.full_ENV; alpha.full_ENV; beta.full_ENV; gamma.full_ENV};
COH = {delta.full_COH; theta.full_COH; alpha.full_COH; beta.full_COH; gamma.full_COH};


sLF = {};sENV = {}; sCOH = {};

for i=1:length(order)
    sLF{i} = smooth(LF{i},10501);
    sENV{i} = smooth(ENV{i},10501);
    sCOH{i} = smooth(COH{i},10501);
end


autocorLF = {}; lagsLF = {};
autocorENV = {};lagsENV = {};
autocorCOH = {};lagsCOH = {};

for i=1:length(order)
    [autocorLF{i},lagsLF{i}] = xcov(sLF{i},'unbiased');
    [autocorENV{i},lagsENV{i}] = xcov(sENV{i},'unbiased');
    [autocorCOH{i},lagsCOH{i}] = xcov(sCOH{i},'unbiased'); 
end


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
%% Periodogram from FFT of Autocorr

pxxFT_LF = {}; pxxFT_ENV = {}; pxxFT_COH = {};
freqFT_LF = {}; freqFT_ENV = {}; freqFT_COH = {};

for i= 1:length(order)

    N0 = length(autocorCOH{i});
    N = N0*5;

    pxxFT_LF{i} = 1/(N0-1)*abs(fftshift(fft(normLF{i},N)));
    freqFT_LF{i} = -srate/2:srate/(length(autocorLF{i})*5):srate/2-(srate/(length(autocorLF{i})*5));

    pxxFT_ENV{i} = 1/(N0-1)*abs(fftshift(fft(normENV{i},N)));
    freqFT_ENV{i} = -srate/2:srate/(length(autocorENV{i})*5):srate/2-(srate/(length(autocorENV{i})*5));

    pxxFT_COH{i} = 1/(N0-1)*abs(fftshift(fft(normCOH{i},N)));
    freqFT_COH{i} = -srate/2:srate/(length(autocorCOH{i})*5):srate/2-(srate/(length(autocorCOH{i})*5));
end

 

%% FFT Plots

for i=1:length(order)

    varLF = var(normLF{i})
    varENV = var(normENV{i})
    varCOH = var(normCOH{i})

    fg = figure('WindowState','maximized')
    sgtitle(strcat('Periodogram for subject 08, For Band:',{' '},order(i)))  

    subplot(3,1,1)
    y = sqrt(pxxFT_LF{i}/varLF);
    x = freqFT_LF{i};
    xt = (1./x)/(3600);
    plot(xt,y)
    xlim([8 104])
    xticks([8:8:104])

    subplot(3,1,2)
    y = sqrt(pxxFT_ENV{i}/varENV);
    x = freqFT_ENV{i};
    xt = (1./x)/(3600);
    plot(xt,y)
    xlim([8 104])
    xticks([8:8:104])

    subplot(3,1,3)
    y = sqrt(pxxFT_COH{i}/varCOH);
    x = freqFT_COH{i};
    xt = (1./x)/(3600);
    plot(xt,y)
    xlim([8 104])
    xticks([8:8:104])

end

%% Pwelch periodograms

pxxW_LF = {};
pxxW_ENV = {};
pxxW_COH = {};

ffW_LF = {};
ffW_ENV = {};
ffW_COH = {};

vLF = {};
vENV = {};
vCOH = {};

for i=1:length(order)
    nLF = LF{i} - mean(LF{i});
    nENV = ENV{i} - mean(ENV{i});
    nCOH = COH{i} - mean(COH{i});
    
    vLF{i} = var(nLF);
    vENV{i} = var(nENV);
    vCOH{i} = var(nCOH);
    
    srate = 2;
    wind = kaiser(length(nLF));
    [pxxW_LF{i},ffW_LF{i}] = pwelch(nLF,wind,[],length(nLF)*5,srate);
    [pxxW_ENV{i},ffW_ENV{i}] = pwelch(nENV,wind,[],length(nLF)*5,srate);
    [pxxW_COH{i},ffW_COH{i}] = pwelch(nCOH,wind,[],length(nLF)*5,srate);
end

%% Normalize both periodogramd between 0 and 1



for i=1:length(order)
    pxxW_LF{i} = normalize(pxxW_LF{i},'range');
    pxxW_ENV{i} = normalize(pxxW_ENV{i},'range');
    pxxW_COH{i} = normalize(pxxW_COH{i},'range');

    pxxFT_LF{i} = normalize(pxxFT_LF{i},'range');
    pxxFT_ENV{i} = normalize(pxxFT_ENV{i},'range');
    pxxFT_COH{i} = normalize(pxxFT_COH{i},'range');

end

%% FFT Plots v Welch Plots

for i=1:length(order)

    varLF = var(normLF{i})
    varENV = var(normENV{i})
    varCOH = var(normCOH{i})

    fg = figure('WindowState','maximized')
    sgtitle(strcat('Periodogram for subject 08, For Band:',{' '},order(i)))  

    subplot(3,1,1)
    y = sqrt(pxxFT_LF{i});
    x = freqFT_LF{i};
    xt = (1./x)/(3600);
    plot(xt,y); hold on
    x = ffW_LF{i};
    xt = (1./x)/(3600);
    y = sqrt(pxxW_LF{i});
    plot(xt,y)
    xlim([8 104])
    xticks([8:8:104])
    legend('FFT','Welch')
    title('Periodograms for HRV-LF')
    xlabel('Period (hour)')
    ylabel('Power')

    subplot(3,1,2)
    y = sqrt(pxxFT_ENV{i});
    x = freqFT_ENV{i};
    xt = (1./x)/(3600);
    plot(xt,y); hold on
    x = ffW_ENV{i};
    xt = (1./x)/(3600);
    y = sqrt(pxxW_ENV{i});
    plot(xt,y)
    xlim([8 104])
    xticks([8:8:104])
    legend('FFT','Welch')
    title('Periodograms for ENV')
    xlabel('Period (hour)')
    ylabel('Power')

    subplot(3,1,3)
    y = sqrt(pxxFT_COH{i});
    x = freqFT_COH{i};
    xt = (1./x)/(3600);
    plot(xt,y); hold on
    x = ffW_COH{i};
    xt = (1./x)/(3600);
    y = sqrt(pxxW_COH{i});
    plot(xt,y)
    xlim([8 104])
    xticks([8:8:104])
    legend('FFT','Welch')
    title('Periodograms for COH')
    xlabel('Period (hour)')
    ylabel('Power')


    filename = strcat('Periods\fft_periods\','fft_welch',num2str(subject_num),order(i),'.jpg')
%     saveas(fg, filename)
end
%%

i=5

varLF = var(normLF{i})
varENV = var(normENV{i})
varCOH = var(normCOH{i})

fg = figure('WindowState','maximized')
% sgtitle(strcat('Periodogram for subject 08, For Band:',{' '},order(i)))

subplot(3,1,1)
y = sqrt(pxxFT_LF{i}/varLF);
x = freqFT_LF{i};
xt = (1./x)/(3600);
plot(xt,y)
title(strcat('Periodogram for time-varying HRV-LF power of subject 7'),'FontSize',14)
xlabel('Period (Hour)','FontSize',14)
ylabel('Power','FontSize',14)
xlim([8 80])
xticks([8:4:80])


subplot(3,1,2)
y = sqrt(pxxFT_ENV{i}/varENV);
x = freqFT_ENV{i};
xt = (1./x)/(3600);
plot(xt,y)
title(strcat('Periodogram for time-varying Gamma-ENV power of subject 7'),'FontSize',14)
xlabel('Period (Hour)','FontSize',14)
ylabel('Power','FontSize',14)
xlim([8 80])
xticks([8:4:80])

subplot(3,1,3)
y = sqrt(pxxFT_COH{i}/varCOH);
x = freqFT_COH{i};
xt = (1./x)/(3600);
plot(xt,y)
title(strcat('Periodogram for time-varying coherence between HRV-LF and Gamma-ENV of subject 7'),'FontSize',14)
xlabel('Period (Hour)','FontSize',14)
ylabel('Power','FontSize',14)
xlim([8 80])
xticks([8:4:80])


