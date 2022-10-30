function C = plot_nodes_property(fname, graphs, duration, evstart_sec, evend_sec, outdir,network_labels)
%PLOT_NODES_PROPERTY Plots the change of a property of each node (or the graph as a whole) through time
%
%   Example C=plot_nodes_property('degrees_und',graphs);
%   Other fnames include: betweenness_bin, clustering_coef_bu, density_und,
%       modularity_und, transitivity_bu etc.
%
% INPUT
%   fname    : A function that measures some property of the nodes of the
%              graph (or of the graph as a whole)
%   graphs   : A 3-dimensional matrix (i,j,k) where i,j are nodes, entry
%              (i,j) denotes the presence of a connection, and k is time
%			   NEW ADDITION: graphs can be a 4-dimensional matrix, where
%			   the fourth dimension stores different networks to be plotted
%			   on the same plot.
%   duration : Integer indicating the time gap between successive graphs
%              This is used in annotating the x axis of the plot
%   evstart_sec, evend_sec : Each element indicates the second where an 
%               event starts and ends respectively
%   outdir   : The directory where the figures will be saved; if it does
%              not exist it will be created
%   network_labels : 
%
% OUTPUT
%   C        : A 2D matrix where columns correspond to time moments 
%              (index k of graphs), and rows correspond to the values
%              measured (i.e. one value per node, or just one value for the
%             whole graph)
%
% Manolis Christodoulakis @ 2011

    global MULTIPLE_NETWORKS_PER_FIG;
    
    % Set to 0 to have each network (frequency) plotted on its own
    % Set to 1 to have all frequencies plot in the same figure
    % Will be automatically set to 0 if only 1 network is available
     multiple = MULTIPLE_NETWORKS_PER_FIG;
%    multiple = 1;

    % Set default values - OUTDATED
    if nargin<3, duration = 5; end
    if nargin<4, evstart_sec = []; end
    if nargin<5, evend_sec = []; end
    if nargin<6, outdir = []; end
    if nargin<7 || isempty(network_labels)
        network_labels = {'all bands' 'alpha band' 'beta band' 'gamma band' 'delta band' 'theta band'};
    end


    % Compute the function once for each graph
    disp(['    ' fname '...']);
    [~, ~, timemoments, networks] = size(graphs);
    
    for t=1:timemoments
    	for j=1:networks
	       C(:,t,j) = feval(fname,graphs(:,:,t,j));
        end
    end

    % Plot
    c_rows = size(C,1);
    if networks>1
	    channels_per_plot  = 1;
    else
        multiple = 0;
	    channels_per_plot  = min(2,c_rows);  % in case we only have one row to plot
	end
	
	num_figures = ceil(c_rows / channels_per_plot);
%	num_lines_per_fig = channels_per_plot * networks
    reset_line_num_per_fig = 0;
    
    for k=1:num_figures
        if (multiple == 1)
            h = create_fig(fname,k);
        end
%     	% Add title and hold on
%     	fig_title 		 = [fname ' ' int2str(k)];
%     	h				 = figure('Name',fig_title,...
%                             'Visible','off', ...
%                             'Units','pixels',...
%                             'Position',[0 0 1152 864]); 
       	color_list 		 = 'grbcmyk';
%       	% markerstyle_list = '+o*sdx';
%     	hold all;
    	
    	% Plot all the lines
        if timemoments*duration>7200        % more than two hours
            time_scale = duration/3600;     % hour scale
            evstart_sec = evstart_sec/3600;
            evend_sec = evend_sec/3600;
            xaxis_label = 'Time (hours)';
        elseif timemoments*duration>120     % more than two minutes
            time_scale = duration/60;       % minute scale
            evstart_sec = evstart_sec/60;
            evend_sec = evend_sec/60;
            xaxis_label = 'Time (min)';
        else
            time_scale = duration;          % second scale
            xaxis_label = 'Time (sec)';
        end
        
        current_plot_color_num = 1;
    	for i=1:channels_per_plot
			if channels_per_plot>1
                if reset_line_num_per_fig
                    channel_label = ['Channel ' int2str(i)];
                else
                    channel_label = ['Channel ' int2str((k-1)*channels_per_plot + i)];
                end      
            else
		    	channel_label = '';
            end

            if (multiple == 1)
                for j=1:networks
%                    plot(1:duration:timemoments*duration,C(channels_per_plot*(k-1)+i,:,j),...
                    plot(time_scale:time_scale:timemoments*time_scale,C(channels_per_plot*(k-1)+i,:,j),...
                            'Color',color_list(current_plot_color_num),...
                            'DisplayName',[channel_label network_labels(j)]);
                    xlabel(xaxis_label);
                    current_plot_color_num = current_plot_color_num + 1;
                end
            else
                for j=1:networks
                    h = create_fig(fname,k,j);
                    plot(time_scale:time_scale:timemoments*time_scale,C(channels_per_plot*(k-1)+i,:,j),...
                            'Color',color_list(current_plot_color_num),...
                            'DisplayName',[channel_label network_labels(j)]);
                    xlabel(xaxis_label);
                    current_plot_color_num = current_plot_color_num + 1;
                    annotate_fig(h,fname,current_plot_color_num,evstart_sec,evend_sec,outdir);
                    if ~isempty(outdir)
                        save_fig(h,fname,k,duration,outdir,network_labels,j);
                    end
                end                
            end
        end

        if (multiple == 1)
            annotate_fig(h,fname,current_plot_color_num,evstart_sec,evend_sec,outdir);
%     	% Finalize and save
%         title(fname_to_str(fname));
%     
%         if current_plot_color_num > 2
%             legend show;
%         end
% 
%          % Indicate specific events if there are any
%         if (nargin>=4)	       
%             arrayfun(@(e) add_vline(e,'--'),evstart_sec);
%         end
%         
%         if (nargin>=5)
%             arrayfun(@(e) add_vline(e,':'),evend_sec);
%         end
        
%        hold off;
        
            if ~isempty(outdir)
                save_fig(h,fname,k,duration,outdir,network_labels);
%             if ~exist(outdir,'dir')
%                 mkdir(outdir); 
%             end
%             
%             % set(h, 'Visible', 'on'); 
%             if (duration>=30)
%                 saveas(h, [outdir '/' fname 'dur' num2str(duration) '_' num2str(k) '.jpg']);
%                 saveas(h, [outdir '/' fname 'dur' num2str(duration) '_' num2str(k) '.fig']);
%             else 
%                 saveas(h, [outdir '/' fname num2str(k) '.jpg']);
%                 saveas(h, [outdir '/' fname num2str(k) '.fig']);
%             end
%             % set(h, 'Visible', 'off'); 
%             close(h)
            end
        end
    end
end

function fig_handle = create_fig(name,fig_num,network_num)
    % Set the network label, if any
    network_labels = {'all bands' 'alpha band' 'beta band' 'gamma band' ...
                        'delta band' 'theta band'};
    if (nargin>=3)
        netlabel = network_labels{network_num};
    else
        netlabel = '';
    end
    
    % Add title and hold on
    fig_title 		 = [name ' ' int2str(fig_num) netlabel];
    fig_handle		 = figure('Name',fig_title,...
                        'Visible','off', ...
                        'Units','pixels',...
                        'Position',[0 0 1152 864]); 
    % markerstyle_list = '+o*sdx';
    
    hold all;
end

function save_fig(h,name,fig_num,duration,outdir,network_labels,network_num)

    hold off;
    
    if ~exist(outdir,'dir')
        mkdir(outdir); 
    end
    
    if nargin>=6 && ~isempty(network_labels)
        network_labels = strrep(network_labels,' ', '_');
        if (nargin>=7)
            netlabel = ['_' network_labels{network_num}];
        else
            netlabel = '';
        end
    else
        netlabel = '';
    end

    if (duration>=30)
        saveas(h, [outdir '/' name '_dur' num2str(duration) '_' ...
            num2str(fig_num) netlabel '.jpg']);
        saveas(h, [outdir '/' name '_dur' num2str(duration) '_' ...
            num2str(fig_num) netlabel '.fig']);
    else 
        saveas(h, [outdir '/' name num2str(fig_num) netlabel '.jpg']);
        saveas(h, [outdir '/' name num2str(fig_num) netlabel '.fig']);
    end
    
    close(h)
end

function annotate_fig(h,name,current_plot_color_num,evstart_sec,evend_sec,outdir)
    % Finalize and save
    title([patient_to_str_public(outdir) ' - ' fname_to_str(name)]);

    if current_plot_color_num > 2
        legend show;
    end

     % Indicate specific events if there are any
    if (nargin>=4)	       
        arrayfun(@(e) add_vline(e,'--'),evstart_sec);
    end

    if (nargin>=5)
        arrayfun(@(e) add_vline(e,':'),evend_sec);
    end
    
    set(findall(gcf,'type','text'),'fontSize',24) 
    set(findall(gcf,'type','axes'),'fontsize',14)
end
