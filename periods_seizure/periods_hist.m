%% Create histograms of detected periods

clear all

order = ["Delta","Theta","Alpha","Beta","Gamma"];
siggies = ["LF", "ENV", "COH"];

subs = [02 03 04 05 06 07 08 09 10 14 21 24]
n_subs = length(subs)

tableLF = importexcel('LF');
tableENV = importexcel('ENV');
tableCOH = importexcel('COH');

%%
COH_periods = cell(1,length(order))
ENV_periods = cell(1,length(order))
LF_periods = cell(1,length(order))
%% Convert Table data into cells for each freq and

for j=1:length(order)

    tempL = tableLF(j,2:end);
    tempL2 = string(tempL{1,1:end});
    
    tempE = tableENV(j,2:end);
    tempE2 = string(tempE{1,1:end});
    
    tempC = tableCOH(j,2:end);
    tempC2 = string(tempC{1,1:end});

    for i=1:n_subs
        
        pLF = str2double(strsplit(tempL2(i),','))
        LF_periods{1,j} = [LF_periods{1,j} pLF]
        
        pENV = str2double(strsplit(tempE2(i),','))
        ENV_periods{1,j} = [ENV_periods{1,j} pENV]      
        
        pCOH = str2double(strsplit(tempC2(i),','))
        COH_periods{1,j} = [COH_periods{1,j} pCOH]      
    end
    
end

clear pCOH pENV pLF tempC tempC2 tempE tempE2 tempL tempL2

%% Histograms for Coherence

% edges = [0 8 16 24 32 40 48 54 64 72 80 88 96 104 112 120 128];
edges = [8:6:80];

for i=1:length(order)
    
    figure('WindowState','maximized')
    
    subplot(1,2,1)
    histogram(ENV_periods{1,i},edges)
    title('Histogram for periodicities detected for EEG-ENV of band: ',order(i),'FontSize',14)
    ylabel('# of peaks in Periodograms','FontSize',14)
    xlabel('Periodicity (hours)','FontSize',14)
    xticks([4:4:80])
    yticks([0:1:n_subs])
    ylim([0 n_subs])
    
    subplot(1,2,2)
    histogram(COH_periods{1,i},edges)
    title('Histogram for periodicities detected for Coherence of band: ',order(i),'FontSize',14)
    ylabel('# of peaks in Periodograms','FontSize',14)
    xlabel('Periodicity (hours)','FontSize',14)
    xticks([4:4:80])
    yticks([0:1:n_subs])
    ylim([0 n_subs])
        
    
end


%% For LF 

%%
i=5

figure('WindowState','maximized')
subplot(3,1,1)
histogram(LF_periods{1,i},edges)
title('Histogram for periodicities detected for HRV-LF','FontSize',14)
ylabel('# of peaks in Periodograms','FontSize',14)
xlabel('Periodicity (hours)','FontSize',14)
xticks([4:4:80])
yticks([0:1:n_subs])
ylim([0 n_subs])

subplot(3,1,2)
histogram(ENV_periods{1,i},edges)
title('Histogram for periodicities detected for Gamma-ENV','FontSize',14)
ylabel('# of peaks in Periodograms','FontSize',14)
xlabel('Periodicity (hours)','FontSize',14)
xticks([4:4:80])
yticks([0:1:n_subs])
ylim([0 n_subs])

subplot(3,1,3)
histogram(COH_periods{1,i},edges)
title('Histogram for periodicities detected for Coherence between HRV-LF and Gamma-ENV','FontSize',14)
ylabel('# of peaks in Periodograms','FontSize',14)
xlabel('Periodicity (hours)','FontSize',14)
xticks([4:4:80])
yticks([0:1:n_subs])
ylim([0 n_subs])
