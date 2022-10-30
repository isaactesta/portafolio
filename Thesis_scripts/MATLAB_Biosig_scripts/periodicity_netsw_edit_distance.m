function periodicity_netsw_edit_distance(dir,mainfile,experiment,thresholds)
% Calculates periodicity over time, based on the topology of the graphs
%
% Loads the weighted adjacency matrices (nets_w5), calculates average
% networks (e.g. over one minute) and calculates the correlation of the
% cumulative graph edit distance, over a number of networks (e.g. 500)
%
% Manolis Christodoulakis @2014

    % --------------------------------------------------------------------
    % --- Customization
    patient_title       = patient_to_str_public(dir);
%     avg_time        	= 60;               % Average over this many sec
%     mean_step           = avg_time / 5;     % 5 sec windows
%     num_windows_to_corr = 180;     % # windows to calculate correlation on  
    
    % --------------------------------------------------------------------
    % --- Load the data and calculate average nets
%    load(filename,'nets_w5','srate','seizstart','seizend');
    load([dir '/' mainfile '.mat'],'srate','seizstart','seizend');
    load([dir '/' mainfile '/' experiment '/nets.mat'],'nets_w5');
    figdir = [dir '/' mainfile '/' experiment '/window=5/threshold=' num2str(thresholds(1))];

    %display(['Seizure at ' num2str(evstart/(3600*srate)) ' hours']);
    [nrows ncols nnets nfreq] = size(nets_w5);
    %bin_nets(:,:,:,:) = binarize(nets_w5,thresholds);
    
%     avg_bin_nets    = zeros(nrows,ncols,ceil(nnets/mean_step));
%     navgnets        = floor(nnets/mean_step);
%     for f=1:nfreq
%         for i=1:navgnets
%             avg_bin_nets(:,:,i,f) = mean(nets_w5(:,:,(i-1)*mean_step+1:min(i*mean_step,nnets),f),3);
%             avg_bin_nets(:,:,i,f) = binarize(avg_bin_nets(:,:,i,f),threshold);
%         end
%     end

    % --------------------------------------------------------------------
    % --- Calculate periodicities, plot, and save, for every freq. band
    for f=1:nfreq
        if (nfreq==1)
            net_filename = '';
            net_title = '';
        else
            net_filename = ['_' strrep(network_to_freq_str(f),' band','')];
            net_title = ['(' network_to_freq_str(f) ')'];
        end

        % ----------------------------------------------------------------
        % --- Calculate periodicity with cross correlations
        % --- over limited number of windows
        leave_out = 720;
        distances = zeros(nnets-leave_out,size(thresholds,2));
        for tr = 1:size(thresholds,2)
            bin_nets = binarize(nets_w5(:,:,:,f),thresholds(tr));
            parfor shift=1:nnets-leave_out
                sum_distance = 0;
                for k=1:nnets-shift
                    sum_distance = sum_distance + graph_edit_distance(bin_nets(:,:,k),bin_nets(:,:,shift+k));
                end
                distances(shift,tr) = sum_distance/(nnets-shift);
            end
        end

        % ----------------------------------------------------------------
        % --- Plot
        % Set the time scale to hours
        x_axis_values = [5/3600:5/3600:...
                         (nnets-leave_out)*5/3600];
        x_axis_title = 'Time lag (hours)';
        graph_title = [patient_title ' - Graph Edit Distance periodicity ' net_title];

        h = figure;
        plot(x_axis_values,distances); hold on;
        xlabel(x_axis_title);
        title(graph_title);
        set(findall(gcf,'type','text'),'fontSize',20) 
        set(findall(gcf,'type','axes'),'fontsize',15)
%         ylim([25 37])
        
        % Indicate specific events if there are any
        % (Leave out, x axis denotes lags, not time)
        %for e=seizstart
        %    arrayfun(@(x) add_vline(x,'--'),e/(3600*srate));
        %end

        % ----------------------------------------------------------------
        % --- Save
        figdir = [dir '/' mainfile '/' experiment '/window=5/threshold=' num2str(thresholds(1))];
        if ~exist(figdir,'dir') mkdir(figdir); end;
        save([figdir '/periodicity_edit_dist' net_filename '.mat'],...
            'distances','x_axis_values','seizstart','graph_title',...
            'net_title','srate','figdir','x_axis_title');
        saveas(h, [figdir '/periodicity_edit_dist' net_filename '.jpg']);
        saveas(h, [figdir '/periodicity_edit_dist' net_filename '.fig']);
        close;
    end
end