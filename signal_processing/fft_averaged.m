%% Compute Periodograms from subjects and average them out

clear all

srate = 2;
conv = (srate*3600);

order = ["Delta","Theta","Alpha","Beta","Gamma"];
siggies = ["LF", "ENV", "COH"];

subs = [02 03 04 05 06 07 08 09 10 14 21]
n_subs = length(subs)

LF = {}; ENV = {}; COH = {}; order = {}; seiz = {}; parts = {}; start = {}; fin = {};
tseizloc = {}; tseiz = {};

for i=1:n_subs
    [LF{i},ENV{i},COH{i},order{i},seiz{i},parts{i},start{i},fin{i}] = sigs_info(subs(i));
    
    tseizloc{i} = seiz{i}*3600;
    tseiz{i} = hours(seiz{i});
end

autocorLF = {}; lagsLF = {};
autocorENV = {};lagsENV = {};
autocorCOH = {};lagsCOH = {};


%%

j = 5 % For Band

for i=1:length(subs)
    % smooth out signals
    sLF = smooth(LF{i}{j},10501);
    sENV = smooth(ENV{i}{j},10501);
    sCOH = smooth(COH{i}{j},10501);

    % Compute Autocorrelation
    [autocorLF{i},lagsLF{i}] = xcov(sLF,'unbiased');
    [autocorENV{i},lagsENV{i}] = xcov(sENV,'unbiased');
    [autocorCOH{i},lagsCOH{i}] = xcov(sCOH,'unbiased'); 
end

[N,id] = min(cellfun('size',autocorCOH,1))

% cutoff = (N/(srate*3600))*(2/3);
cutoff = 80

posidx = find(lagsCOH{11}/conv > cutoff,1,'first')
negidx = find(lagsCOH{11}/conv > -cutoff,1,'first')

%% Normalize autocorrs

normCOH = {};normLF={};normENV={};


for i=1:length(subs)
    
    autocorENV{i}=autocorENV{i}(negidx:posidx);
    autocorLF{i}=autocorLF{i}(negidx:posidx);
    autocorCOH{i}=autocorCOH{i}(negidx:posidx);
    
    normENV{i} = autocorENV{i}/max(max(abs(autocorENV{i})));
    normLF{i} = autocorLF{i}/max(max(abs(autocorLF{i})));
    normCOH{i} = autocorCOH{i}/max(max(abs(autocorCOH{i})));
end

%% Periodogrmas from FFT

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

%%

% for i=1:length(subs)
% 
%     varLF = var(normLF{i})
%     varENV = var(normENV{i})
%     varCOH = var(normCOH{i})
% 
%     fg = figure('WindowState','maximized')
% %     sgtitle(strcat('Periodogram for subject 05, For Band:',{' '},order(i)))  
% 
%     subplot(3,1,1)
%     y = sqrt(pxxFT_LF{i}/varLF);
%     x = freqFT_LF{i};
%     xt = (1./x)/(3600);
%     [xt,idx] = sort(xt);
%     plot(xt,y(idx))
%     xlim([8 80])
%     xticks([8:8:80])
% 
%     subplot(3,1,2)
%     y = sqrt(pxxFT_ENV{i}/varENV);
%     x = freqFT_ENV{i};
%     xt = (1./x)/(3600);
%     [xt,idx] = sort(xt);
%     plot(xt,y(idx))
%     xlim([8 80])
%     xticks([8:8:80])
% 
%     subplot(3,1,3)
%     y = sqrt(pxxFT_COH{i}/varCOH);
%     x = freqFT_COH{i};
%     xt = (1./x)/(3600);
%     [xt,idx] = sort(xt);
%     plot(xt,y(idx))
%     xlim([8 80])
%     xticks([8:8:80])
% 
% end

%%

% sgtitle('Periodograms with average between subjects')
fg = figure('WindowState','maximized')
% subplot(3,1,1)
mLF = mean(pxxFT_LF,2);
y = sqrt(mLF);
x = freqFT_LF{i};
xt = (1./x)/(3600);
[xt,idx] = sort(xt);
plot(xt,y(idx))
xlim([8 80])
xticks([8:4:80])
title('Average periodogram for the LF of HRV','FontSize',14)
xlabel('Period (hours)','FontSize',14)
ylabel('Power','FontSize',14)
% % 
% subplot(3,1,2)
% mPENV = mean(pxxFT_ENV,2);
% y = sqrt(mPENV);
% x = freqFT_ENV{i};
% xt = (1./x)/(3600);
% [xt,idx] = sort(xt);
% plot(xt,y(idx))
% xlim([8 80])
% xticks([8:4:80])
% title('Average periodogram for ENV of Gamma band','FontSize',14)
% xlabel('Period (hours)','FontSize',14)
% ylabel('Power','FontSize',14)
% 
% subplot(3,1,3)
% mPCOH = mean(pxxFT_COH,2);
% y = sqrt(mPCOH);
% x = freqFT_COH{i};
% xt = (1./x)/(3600);
% [xt,idx] = sort(xt);
% plot(xt,y(idx))
% xlim([8 80])
% xticks([8:4:80])
% title('Average periodogram for Coherence between Gamma-ENV and LF-HRV','FontSize',14)
% xlabel('Period (hours)','FontSize',14)
% ylabel('Power','FontSize',14)