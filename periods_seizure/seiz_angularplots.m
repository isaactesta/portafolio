%% Filter periodicities and build angular plots

clear all

sub = 9
period = 24
srate = 2;

[LF,ENV,COH,order,seiz,parts,start,fin] = sigs_info(sub);

tseizloc = seiz*3600;

tseiz = hours(seiz);

%%
filt_periodsLF = cell(1,length(order)); HLF = cell(1,length(order));
thetaHLF = cell(1,length(order));rLF = cell(1,length(order)); theta_seizLF = cell(1,length(order));

filt_periodsENV = cell(1,length(order)); HENV = cell(1,length(order));
thetaHENV = cell(1,length(order));rENV = cell(1,length(order)); theta_seizENV = cell(1,length(order));

filt_periodsCOH = cell(1,length(order)); HCOH = cell(1,length(order));
thetaHCOH = cell(1,length(order));rCOH = cell(1,length(order)); theta_seizCOH = cell(1,length(order));

for i=1:length(order)
  
    signal = LF{i};
    N = length(signal);
    lSignal = N/(srate*3600)
    filt_periodsLF{1,i} = filter_periodicity(period, signal, srate,lSignal);     
    
    signal = ENV{i};    
    filt_periodsENV{1,i} = filter_periodicity(period, signal, srate,lSignal); 
    
    signal = COH{i};   
    filt_periodsCOH{1,i} = filter_periodicity(period, signal, srate,lSignal); 
   
    
    HLF{1,i} = hilbert(filt_periodsLF{1,i});
    thetaHLF{1,i} = angle(HLF{1,i})
    thetaHLF{1,i} = wrap(thetaHLF{1,i},2);
    
    HENV{1,i} = hilbert(filt_periodsENV{1,i});
    thetaHENV{1,i} = angle(HENV{1,i})
    thetaHENV{1,i} = wrap(thetaHENV{1,i},2);
    
    HCOH{1,i} = hilbert(filt_periodsCOH{1,i});
    thetaHCOH{1,i} = angle(HCOH{1,i})
    thetaHCOH{1,i} = wrap(thetaHCOH{1,i},2);
    
    theta_seizLF{1,i} = thetaHLF{1,i}(round(tseizloc));
    theta_seizENV{1,i} = thetaHENV{1,i}(round(tseizloc));
    theta_seizCOH{1,i} = thetaHCOH{1,i}(round(tseizloc));
    
    rLF{1,i} = circ_rtest(theta_seizLF{1,i})
    rENV{1,i} = circ_rtest(theta_seizENV{1,i})
    rCOH{1,i} = circ_rtest(theta_seizCOH{1,i})

    RLF{1,i} = circ_r(transpose(theta_seizLF{1,i}))
    RENV{1,i} = circ_r(transpose(theta_seizENV{1,i}))
    RCOH{1,i} = circ_r(transpose(theta_seizCOH{1,i}))
end


% theta_seiz = thetaH(round(tseizloc))
%%
% for i=1:length(order)
% 	N  = length(filt_periodsLF{i})
%     real_t = linspace(start,fin,N);
%     real_seiz = tseiz + real_t(1);
%     
%     fg=figure('WindowState','maximized')
%     sgtitle(strcat('Angular plots for',{' '}, num2str(period), 'HR of LF for band:',{' '},order(i),{' '},'For subject: ',num2str(sub)))
%     
%     angplots(filt_periodsLF{i},order(i),sub,real_t,real_seiz,theta_seizLF{i},rLF{i},RLF{i})
%     filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%02d'),'\angplots_rLF',num2str(sub,'%02d'),order(i),'.jpg')
% %     filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%1.1f'),'\angplots_rLF',num2str(sub,'%02d'),order(i),'.jpg')
% %     saveas(fg, filename)
% end

%%
for i=1:length(order)
	N  = length(filt_periodsENV{i})
    real_t = linspace(start,fin,N);
    real_seiz = tseiz + real_t(1);
    
    fg=figure('WindowState','maximized')
    sgtitle(strcat('Angular plots for',{' '}, num2str(period), 'HR periodicity of ENV for',{' '},order(i),{' '},'band',{' '},'of subject ',{' '},num2str(10)))
   
    angplots(filt_periodsENV{i},order(i),sub,real_t,real_seiz,theta_seizENV{i},rENV{i},RENV{i})
     filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%02d'),'\angplots_rENVTHESIS',num2str(sub,'%02d'),order(i),'.jpg')
%     filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%1.1f'),'\angplots_rENV',num2str(sub,'%02d'),order(i),'.jpg')
    saveas(fg, filename)
end

%%
for i=1:length(order)
	N  = length(filt_periodsCOH{i})
    real_t = linspace(start,fin,N);
    real_seiz = tseiz + real_t(1);
    
    fg=figure('WindowState','maximized')
    sgtitle(strcat('Angular plots for',{' '}, num2str(period), 'HR periodicity of Coherence between',{' '},order(i),{' '},'band and HRV-LF',{' '},'of subject',{' '},num2str(10)))
   
    angplots(filt_periodsCOH{i},order(i),sub,real_t,real_seiz,theta_seizCOH{i},rCOH{i},RCOH{i})
    filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%02d'),'\angplots_rCOHTHESIS',num2str(sub,'%02d'),order(i),'.jpg')
    saveas(fg, filename)
end

%% Lone HRV plot

% For thesis this is subject 6


i = 5

N  = length(filt_periodsLF{i})
real_t = linspace(start,fin,N);
real_seiz = tseiz + real_t(1);

fg=figure('WindowState','maximized')
sgtitle(strcat('Angular plots for',{' '}, num2str(period),{' '}, 'HR periodicty of LF for HRV',{' '}, 'of subject',{' '},num2str(10)))

angplots(filt_periodsLF{i},order(i),sub,real_t,real_seiz,theta_seizLF{i},rLF{i},RLF{i})
filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%02d'),'\angplots_rLF_THESIS',num2str(sub,'%02d'),'.jpg')
% filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%1.1f'),'\angplots_rLF',num2str(sub,'%02d'),'.jpg')
saveas(fg, filename)

%%

i=5

N  = length(filt_periodsCOH{i})
real_t = linspace(start,fin,N);
real_seiz = tseiz + real_t(1);

fg=figure('WindowState','maximized')
sgtitle(strcat('Angular plots for',{' '}, num2str(period), 'HR periodicity of Coherence between',{' '},order(i),{' '},'band and HRV-LF',{' '},'of subject',{' '},num2str(08)))

angplots(filt_periodsCOH{i},order(i),sub,real_t,real_seiz,theta_seizCOH{i},rCOH{i},RCOH{i})
filename = strcat('Figs\seizcorr\sub',num2str(sub,'%02d'),'\Period',num2str(period,'%02d'),'\angplots_rCOHTHESIS',num2str(sub,'%02d'),order(i),'.jpg')
saveas(fg, filename)
