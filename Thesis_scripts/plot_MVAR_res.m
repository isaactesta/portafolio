% Function to plot the results of the mvar res with spectrogram and the
% three time series


function plot_MVAR_res(resultsMKFA2,lSignal)

[S,f,HF,LF,mean_HF,mean_LF] = ext_res_mean(resultsMKFA2);
y_hat = resultsMKFA2.YHAT;

tdel= (size(S,2)-1)/lSignal;
tdel2 = (size(y_hat,2)-1)/lSignal;

t=(0:size(S,2)-1)/tdel;
that=((0:size(y_hat,2)-1)/tdel2);

figure('units','normalized','outerposition',[0 0 1 1])
subplot(3,4,[1 2 5 6 9 10])
[map, descriptorname, description] = colorcet('L3');
colormap(map)
imagesc(t,f,S)
colorbar
title('Subject')
set(gca,'YDir','normal')
%title(sprintf('%s_S %s',meth,siglab{1}));
xlabel('Time (hours)')
ylabel('Frequency (Hz)')
caxis([0 1])

subplot(3,4,[3 4])
plot(that,y_hat)
xlabel('Time (hours)')
ylabel('RR Interval')
title('HRV')

subplot(3,4,[7 8])
plot(t,mean_HF)
xlabel('Time (hours)')
ylabel('Power')
title('HF Band')

subplot(3,4,[11 12])
plot(t,mean_LF)
xlabel('Time (hours)')
ylabel('Power')
title('LF Band')
end