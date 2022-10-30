%% Generate 24 hour periodicity to correlate seizure onset

clear all

T = 24;
t = 1:230;
y = sin(2*pi*t / T);

srate = 2;

order = ["Delta","Theta","Alpha","Beta","Gamma"];
siggies = ["LF", "ENV", "COH"];

subs = [02 03 04 05 06 07 08 09 10 14 21]
n_subs = length(subs)


%% 

LF = {}; ENV = {}; COH = {}; order = {}; seiz = {}; parts = {}; start = {}; fin = {};
tseizloc = {}; tseiz = {};

for i=1:n_subs
[LF{i},ENV{i},COH{i},order{i},seiz{i},parts{i},start{i},fin{i}] = sigs_info(subs(i));

tseizloc{i} = seiz{i}*3600;
tseiz{i} = hours(seiz{i});
end

%%

thetaH = cell(1,length(subs));
theta_seiz = cell(1,length(subs));


H = hilbert(y);
thetaH = angle(H)
thetaH = wrap(thetaH,2); 

for i=1:length(subs)
     
    theta_seiz{i} = thetaH(round(tseizloc{i}/3600));
end

%%
pooled = cell2mat(theta_seiz);
r = circ_rtest(pooled)
R = circ_r(transpose(pooled))
fseiz = cell2mat(seiz);

%% For plot

fg=figure('WindowState','maximized')
sgtitle(strcat('Angular plots for 12 Wave all subjects'),'FontSize',16)

subplot(2,2,[1 2])
plot(t,y)
hold on
ylim([min(y) max(y)])
p2 = plot([fseiz; fseiz], repmat(ylim',1,size(fseiz,2)), '-k','Color', 'r');
title('12 Hr Periodic Wave')
legend('Periodic signal','Seizure onset')
xlabel('Time (Hours)','FontSize',14)
ylabel('Amplitude','FontSize',14)

subplot(2,2,3)
circ_plot(transpose(pooled),'pretty','bo',true,'linewidth',2,'color','r')
text(2,0.5,strcat('Rayleight test results: ',{' '},num2str(r)),'FontSize',14)
text(2,0.3,strcat('R value: ',{' '},num2str(R)),'FontSize',14)

% title('Angular plot for LF of pooled 24 Hr periodicities')

subplot(2,2,4)
circ_plot(transpose(pooled),'hist',[],20,true,true,'linewidth',2,'color','r')