% Extract all parts of 7 day signals obtained the full measurements of
% Coherence and Autocorrelation
% Run in Subject directory

clear all

load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\Full\Dates.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\Full\time_differences.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\Full\total_sleep_signals.mat')
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\Full\total_seiz_signals.mat')

subject_num = 8;
num_parts = 10;
band = 'Alpha';

parts = 1:num_parts;

dirs = strcat('E:\Isaac_D2\Interactions\Trials_lab\Subject0',num2str(subject_num))
cd(dirs)
%%
srate = 2;
min = 30; % Minutes for each window
window = min*60*srate;

parts_LF = {} % Cell containing all LF measurements of power over time
parts_ENV = {} % Cell containing all ENV measurements of power over time
parts_COH = {} % Cell containing all coherences measurements


for i=1:length(parts)
   fileList = dir('*_ALPHA.mat');
   load(fileList(i).name,'resultsMKFA2')
   
   MVARres = resultsMKFA2.MVARmeasures;
   
   f = MVARres.f;
   LF_IDX = find(f>0.04 & f<0.15);
   
   S_LF = MVARres.SP{2,2}; %LF spectrorgam
   S_env = MVARres.SP{1,1}; %EEG band ENV spectrogram    
   COH = MVARres.COH{2,1}; % Coherence between the two

    % Isolate components
   LF = S_LF(LF_IDX,:); 
   ENV = S_env(LF_IDX,:);
   LF_COH = COH(LF_IDX,:);
    
   meanLF = movmean(mean(LF),window);
   meanENV = movmean(mean(ENV),window);
   meanCOH = movmean(mean(LF_COH),window);
    
   parts_LF{end+1} = meanLF; % Place all parts in Cell Array
   parts_ENV{end+1} = meanENV;
   parts_COH{end+1} = meanCOH;
   
end

clear resultsMKFA2 MVARres

%% Plot signals 
% 
% figure
% for i=1:num_parts
%     N = length(parts_COH{i});
%     t = linspace(record_start(i),end_times(i),N);
%     plot(t,parts_COH{i})
% %     ylim([-40 40]) %Add y lim based on plot
%     hold on
% %     plot([startMC; startMC], repmat(ylim',1,size(startMC,2)), '-k','Color', 'r')
% % that is the previou seiz plot, will have to add timestamps to it
%     hold on
%     title('Time varying Coherence')
% end
% 
% figure
% for i=1:num_parts
%     N = length(parts_ENV{i});
%     t = linspace(record_start(i),end_times(i),N);
%     plot(t,parts_ENV{i})
% %     ylim([-40 40]) %Add y lim based on plot
%     hold on
% %     plot([startMC; startMC], repmat(ylim',1,size(startMC,2)), '-k','Color', 'r')
% % that is the previou seiz plot, will have to add timestamps to it
%     hold on
%     title('EEG delta power over time')
% end
% 
% figure
% for i=1:num_parts
%     N = length(parts_LF{i});
%     t = linspace(record_start(i),end_times(i),N);
%     plot(t,parts_LF{i})
% %     ylim([-40 40]) %Add y lim based on plot
%     hold on
% %     plot([startMC; startMC], repmat(ylim',1,size(startMC,2)), '-k','Color', 'r')
% % that is the previou seiz plot, will have to add timestamps to it
%     hold on
%     title('LF Power over time')
% end
% 

%%  Stitch together signals
% Convert the tiem between signals as NaN and then fill those gaps
full_LF = parts_LF{1};
full_ENV = parts_ENV{1};
full_COH = parts_COH{1};

for i=1:6 
    s_gap1 = seconds(time(delta_t(i)))
    n = NaN(s_gap1,1);
        
    full_LF = [full_LF transpose(n) parts_LF{i+1}];
    full_ENV = [full_ENV transpose(n) parts_ENV{i+1}];
    full_COH = [full_COH transpose(n) parts_COH{i+1}];
    
end

% Add time from 7a and 8
load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\M08_07a\QRS_detected.mat', 'desc')
i = 7;  % gas is too small, doesnt matter
s_gap1 = seconds(time(delta_t(i))) 
n = NaN(s_gap1,1);
full_LF = [full_LF transpose(n) parts_LF{i+1}];
full_ENV = [full_ENV transpose(n) parts_ENV{i+1}];
full_COH = [full_COH transpose(n) parts_COH{i+1}];

i = 8
s_gap1 = seconds(time(delta_t(i))) 
n = NaN(s_gap1,1);
full_LF = [full_LF transpose(n) parts_LF{i+1}];
full_ENV = [full_ENV transpose(n) parts_ENV{i+1}];
full_COH = [full_COH transpose(n) parts_COH{i+1}];

load('E:\Isaac_D2\M2_codes\subjects_process\Subject08\M08\M08_08\QRS_detected.mat', 'desc')
i = 9
sToAdd = 4e5/256
s_gap1 = seconds(time(delta_t(i))+seconds(sToAdd))
n = NaN(floor(s_gap1),1);
full_LF = [full_LF transpose(n) parts_LF{i+1}];
full_ENV = [full_ENV transpose(n) parts_ENV{i+1}];
full_COH = [full_COH transpose(n) parts_COH{i+1}];
%%

full_LF = fillgaps(full_LF);
full_ENV = fillgaps(full_ENV);
full_COH = fillgaps(full_COH);

%% Autocorrelation to find periodicities.

[autocorLF,lagsLF] = xcorr(full_LF,'unbiased');
[autocorENV,lagsENV] = xcorr(full_ENV,'unbiased');
[autocorCOH,lagsCOH] = xcorr(full_COH,'unbiased'); 
%%
seiz = total_seizhours{1};
sleep = total_sleephours{1};
awake = total_awakehours{1};

parts_total_length = zeros(num_parts,1);
parts_total_length(1) = parts_length(1);

for i=2:num_parts
    parts_total_length(i,1) = parts_length(i)+parts_total_length(i-1);
    seiz = [seiz total_seizhours{i} + parts_total_length(i-1)];
    sleep = [sleep total_sleephours{i} + parts_total_length(i-1)];
    awake = [awake total_awakehours{i} + parts_total_length(i-1)];
end


%%
N = length(full_COH);
real_t = linspace(record_start(parts(1)),end_times(parts(end)),N);
%%
graphs_titles = strcat('Results for subject',{' '}, num2str(subject_num),{' '},'for',{' '}, band,' band')
%% Plots with seiz and sleep
grey  = [127 127 127]./255;

seiz = hours(seiz);
seiz = seiz + real_t(1);

sleep = hours(sleep);
sleep = sleep + real_t(1);

awake = hours(awake);
awake = awake + real_t(1);
%%
sleep_patch = [sleep([3 4 5 6 7 10])]
awake_patch = [awake([1 2 3 4 5 6])]

Y_S = [0 1 1 0];

sleep_non_patch = sleep([1 2]);

filename = strcat('Periods/',band,'_full_res.mat')
save(filename,'full_ENV','full_COH','full_LF','band','srate','seiz','awake','sleep','real_t','sleep_patch','awake_patch','-v7.3')
%%
ticks = real_t(1):hours(24):real_t(end);
figure
sgtitle(graphs_titles)

subplot(2,3,1)
p1 = plot(real_t,full_COH);
% ylim([0 1])
% hold on
% p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
% for i=1:length(sleep_patch)
%     X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
%     p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
%     hold on
% end
xlabel('Time (hours)')
ylabel('Coherence')
xticks(ticks)
xlim([real_t(1) real_t(end)+hours(1)])
title(strcat('Time-Varying coherence between',{' '}, band,'-ENV and HRV-LF'))
% legend([p1 p2(end) p3],{'Coherence','Seizure','Sleep'})
subplot(2,3,4)
plot(lagsCOH/(srate*3600),autocorCOH)
xlabel('Lag (hours)')
ylabel('Autocorrelation')
xlim([0 175])
title('Autocorrelation')

subplot(2,3,2)
p1 = plot(real_t,full_LF);
ylim([0 1])
% hold on
% p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
% for i=1:length(sleep_patch)
%     X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
%     p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
%     hold on
% end
xlabel('Time (hours)')
ylabel('Power')
xticks(ticks)
xlim([real_t(1) real_t(end)+hours(1)])
title('Power over time of HRV-LF')
% legend([p1 p2(end) p3],{'Power','Seizure','Sleep'})
subplot(2,3,5)
plot(lagsLF/(srate*3600),autocorLF)
xlabel('Lag (hours)')
ylabel('Autocorrelation')
xlim([0 175])
title('Autocorrelation')

subplot(2,3,3)
p1 = plot(real_t,full_ENV);
ylim([0 1])
% hold on
% p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
% for i=1:length(sleep_patch)
%     X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
%     p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
%     hold on
% end
xlabel('Time (hours)')
ylabel('Power')
xticks(ticks)
xlim([real_t(1) real_t(end)+hours(1)])
title(strcat('Power over time of',{' '}, band,'-ENV'))
% legend([p1 p2(end) p3],{'Power','Seizure','Sleep'})
subplot(2,3,6)
plot(lagsENV/(srate*3600),autocorENV)
xlabel('Lag (hours)')
ylabel('Autocorrelation')
xlim([0 175])
title('Autocorrelation')


%%
ticks = real_t(1):hours(10):real_t(end);

figure
subplot(3,1,1)
p1 = plot(real_t,full_COH);
ylim([0 1])
hold on
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
for i=1:length(sleep_patch)
    X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
    p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
    hold on
end
p4 = plot([sleep_non_patch; sleep_non_patch], repmat(ylim',1,size(sleep_non_patch,2)), '-k','Color', 'g');
xlabel('Time (hours)')
ylabel('Coherence')
xticks(ticks)
xlim([real_t(1) real_t(end)+hours(1)])
title(strcat('Time-Varying coherence between',{' '}, band,'-ENV and HRV-LF'))
% legend([p1 p2(end) p3 p4(end)],{'Power','Seizure','Sleep','Sleep with unidentified wake time'})

subplot(3,1,2)
p1 = plot(real_t,full_LF);
ylim([0 1])
hold on
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
for i=1:length(sleep_patch)
    X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
    p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
    hold on
end
p4 = plot([sleep_non_patch; sleep_non_patch], repmat(ylim',1,size(sleep_non_patch,2)), '-k','Color', 'g');
xlabel('Time (hours)')
ylabel('Power')
xticks(ticks)
xlim([real_t(1) real_t(end)+hours(1)])
title('Power over time of HRV-LF')
% legend([p1 p2(end) p3 p4(end)],{'Power','Seizure','Sleep','Sleep with unidentified wake time'})

subplot(3,1,3)
p1 = plot(real_t,full_ENV);
ylim([0 1])
hold on
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
for i=1:length(sleep_patch)
    X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
    p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
    hold on
end
p4 = plot([sleep_non_patch; sleep_non_patch], repmat(ylim',1,size(sleep_non_patch,2)), '-k','Color', 'g');
xlabel('Time (hours)')
ylabel('Power')
xticks(ticks)
xlim([real_t(1) real_t(end)+hours(1)])
title(strcat('Power over time of',{' '}, band,'-ENV'))
legend([p1 p2(end) p3 p4(end)],{'Power','Seizure','Sleep','Sleep with unidentified wake time'})

%%
%% Trial for shit, ignore and delete

K = full_COH - mean(full_COH);

[row, col] = find(isnan(full_COH));

hcons = 12
j = total_length/12

T = srate*3600*hcons;
% [pxx,f] = plomb(K,T);
%%

[pxx,f] = periodogram(K,kaiser(length(K)),51200,srate);
fg = f*j/3600;
plot(f*total_length,pxx)

%%

Kr = downsample(K,60);
[pxx,f] = periodogram(Kr,kaiser(length(Kr)),[],0.5);


pxx(pxx>5) = 5;
pxx(pxx<0) = 0;

plot(f*total_length*2,10*log10(pxx))