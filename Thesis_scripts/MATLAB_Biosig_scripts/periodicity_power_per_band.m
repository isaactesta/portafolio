function periodicity_power_per_band(dir,mainfile)
%periodicity_power_per_band Calculates and plots the power and its
%autocorrelation in every channel, as well as the mean and std power across
%channels, for each frequency band
%
% Input:
%   datafile    is the path to the file containing filtered_data
%
% Output:
%   The power in every channel for each frequency band
%   The mean and the std of the power across channels for each freq. band
%   Save the above in mat file, and plots and saves the plots in jpg
%
% Manolis Christodoulakis @ 2014

    datafile = [dir '/' mainfile '_ica_data__bipolar__ICA.mat']
    load(datafile,'filtered_data');
    
    load([dir '/' mainfile '.mat'],'srate','starttime','seizstart',...
                'seizend','sleepstart','sleepend');

    window = 5;
    
    [ndatapoints,nchannels] = size(filtered_data);
    nwindows = ceil(ndatapoints/(window*srate));

    fband_freq_start = [1   8 13 30 1 4];
    fband_freq_stop  = [45 13 30 45 4 8];
    fband_labels = {'broadband' 'alpha band' 'beta band' 'gamma band' 'delta band' 'theta band'};
    nfbands = size(fband_freq_start,2);
    assert(nfbands == size(fband_freq_stop,2));
    assert(nfbands == size(fband_labels,2));
    
    outdir  = strrep(datafile,'.mat','_channel_power_periodicities');
    if ~exist(outdir,'dir') mkdir(outdir); end
    patient_title = strrep(patient_to_str_public(outdir),'Patient','Pat.');

    % Don't recalculate if the data is already there
    if exist([outdir '/power_per_chan_per_band.mat'],'file')
        display('Loading existing data...');
        load([outdir '/power_per_chan_per_band.mat']);
    else
        pxx_mean_per_band = zeros(nwindows,nfbands);
        pxx_std_per_band  = zeros(nwindows,nfbands);
        pxx_per_chan_per_band = zeros(nwindows,nchannels,nfbands);

        % Calculate the power in each channel, the mean power, and the std
        fprintf('%3.0f',0)
        for wstart=1:window*srate:ndatapoints
            fprintf('\b\b\b%3.0f',floor(100*wstart/ndatapoints))
            wend = min(wstart + window*srate -1, ndatapoints);
            [p1,f] = pwelch(filtered_data(wstart:wend,1),[],[],[],srate);
            pxx = zeros(size(p1,1),nchannels);
            pxx(:,1) = p1;
            for i=2:18
                [pxx(:,i),~] = pwelch(filtered_data(wstart:wend,i),[],[],[],srate);
            end

            fband_indx_start = zeros(nfbands,1);
            fband_indx_stop  = zeros(nfbands,1);
            for i=1:nfbands
                fband_indx_start(i) = find(f>fband_freq_start(i),1,'first');
                fband_indx_stop(i)  = find(f<fband_freq_stop(i),1,'last');
            end

            t = (wstart + window*srate -1)/(window*srate);
            for i=1:nfbands
                power_in_band = 10*log10(sum(pxx(fband_indx_start(i):fband_indx_stop(i),:)));
                pxx_per_chan_per_band(t,:,i)  = power_in_band;
                pxx_mean_per_band(t,i) = mean(power_in_band);
                pxx_std_per_band(t,i)  = std(power_in_band);
            end
        end
        fprintf('\n')
        
        % Save the power, the mean and the std in mat file
        save([outdir '/power_per_chan_per_band.mat'],'pxx_per_chan_per_band','pxx_mean_per_band','pxx_std_per_band','outdir','-v7.3');
    end
        
    
    % Create and save the plots
    for i=1:nfbands
        % Plot power
        h = figure;
        errorbar((1:size(pxx_mean_per_band(:,i)))*window/3600,pxx_mean_per_band(:,i),pxx_std_per_band(:,i),'Color',[.7 .7 .7]); hold on;
        plot((1:size(pxx_mean_per_band(:,i)))*window/3600,pxx_mean_per_band(:,i),'b');
        xlim([1 size(pxx_mean_per_band(:,i),1)*window/3600])
        title([patient_title ' - Power in ' upper(fband_labels{i}(1)) fband_labels{i}(2:end)]);
        xlabel('Time (hours)')
        set(findall(gcf,'type','text'),'fontSize',20);
        set(findall(gcf,'type','axes'),'fontsize',17);
        %saveas(h,[outdir '/power_' strrep(fband_labels{i},' ','_') '.jpg']);
        savefig([outdir '/power_' strrep(fband_labels{i},' ','_')],h,'jpeg','-r150');
        close;
        
        % Plot power with events
%         figtitle = [patient_title ' - Power in ' upper(fband_labels{i}(1)) fband_labels{i}(2:end)];
        figtitle = [upper(fband_labels{i}(1)) fband_labels{i}(2:end)];
        g = plot_with_events(pxx_mean_per_band(:,i),...
                            3600/5,[],starttime,...
                            figtitle,seizstart/(5*srate),seizend/(5*srate),...
                            sleepstart/(5*srate),sleepend/(5*srate));
        savefig([outdir '/power_withevents_' strrep(fband_labels{i},' ','_')],g,'jpeg','-r150');
        close;

        h = figure;
%         [acf,lags] = autocorr(pxx_mean_per_band(:,i),length(pxx_mean_per_band(:,i))-1);
        [acf,lags] = xcorr(detrend(pxx_mean_per_band(:,i),'constant'), 'unbiased');
        nwindows = size(pxx_mean_per_band(:,i),1);
        acf = acf./acf(nwindows);
        leave_out =  15*3600/window;
        plot((0:nwindows-1-leave_out)*window/3600,acf(nwindows:2*nwindows-1-leave_out))
        ylim([-0.35 0.8]);
        title([patient_title ' - Autocor. of Power in ' upper(fband_labels{i}(1)) fband_labels{i}(2:end)]);
        xlabel('Time lag (hours)')
        set(findall(gcf,'type','text'),'fontSize',20);
        set(findall(gcf,'type','axes'),'fontsize',17);
        savefig([outdir '/periodicity_power_' strrep(fband_labels{i},' ','_')],h,'jpeg','-r150');
        close;
    end
end