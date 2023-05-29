% Create plot with filtered signal and angular plots

function [f] = angplots(signal,order,subject_num,real_t,seiz,theta_seiz,r,R)

subplot(2,2,[1 2])
plot(real_t,signal)
hold on
ylim([min(signal) max(signal)])
p2 = plot([seiz; seiz], repmat(ylim',1,size(seiz,2)), '-k','Color', 'r');
title('Filtered periodic signal')
legend('Periodic signal','Seizure onset')
xlabel('Date','FontSize',14)
ylabel('Amplitude','FontSize',14)
% for i=1:length(sleep_patch)
%     X_S = [sleep_patch(i) sleep_patch(i) awake(i) awake(i)];
%     p3 = fill(X_S,Y_S,grey, 'FaceAlpha',0.2);
%     hold on
% end


subplot(2,2,3)
circ_plot(transpose(theta_seiz),'pretty','bo',true,'linewidth',2,'color','r')
set(gca,'XColor','none','YColor','none')
text(2,0.5,strcat('Rayleight test results: ',{' '},num2str(r)),'FontSize',14)
text(2,0.3,strcat('R value: ',{' '},num2str(R)),'FontSize',14)

subplot(2,2,4)
circ_plot(transpose(theta_seiz),'hist',[],20,true,true,'linewidth',2,'color','r')
% title(strcat('Distribution of seizure onset phases'),'FontSize',14)
end