function plot_all(nets,window_size,evstart,evend,figdir,network_labels)
    fprintf('Plotting... \n');
    
    global PLOT_AVERAGE;

    if ~exist(figdir,'dir')
        mkdir(figdir);
    end
    
    if nargin<6
        network_labels = [];
    end
    
    if PLOT_AVERAGE
        av_win_size     = 30;   % In seconds
        av_nwindows  = floor(av_win_size/window_size);
        [n1 n2 n3 n4]   = size(nets);
        av_nets_n3      = ceil(n3/av_nwindows);
        av_nets         = zeros(n1,n2,av_nets_n3,n4);
        for i=1:av_nets_n3
            av_nets(:,:,i,:) = mean(nets(:,:,(i-1)*av_nwindows+1:i*av_nwindows,:),3);
        end
        figdir = [figdir '_average'];
    else
        av_nets = nets;
        av_window_size = window_size;
    end
    
    % The distance matrix contains lengths of shortest paths between all
    % pairs of nodes
    frames = size(av_nets,3);
    distances = zeros(size(av_nets));
    for i=1:frames
        distances(:,:,i) = distance_bin(av_nets(:,:,i));
    end
    
    
    
    % Plot properties of the graph (network- and node-specific)
%    plot_nodes_property('degrees_und',av_nets,av_window_size,evstart,evend,figdir,network_labels);
    plot_nodes_property('average_degree_und',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('density_und',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%    plot_nodes_property('betweenness_bin',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%    plot_nodes_property('clustering_coef_bu',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('charpath',distances,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('betweenness_centralization_bin',av_nets,av_window_size,evstart,evend,figdir,network_labels);
    plot_nodes_property('network_clustering_WS_bu',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%    plot_nodes_property('network_clustering_NMW_bu',av_nets,av_window_size,evstart,evend,figdir,network_labels);
    plot_nodes_property('efficiency_bin',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('network_smallworldness_WS_bu',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%    plot_nodes_property('network_smallworldness_NMW_bu',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('normalized_clustering_coef',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('normalized_char_path',av_nets,av_window_size,evstart,evend,figdir,network_labels);
%     plot_nodes_property('max_component_size',av_nets,av_window_size,evstart,evend,figdir,network_labels);
    
    % Plot average properties (for larger time windows)
%     av_duration     = 30;
%     av_num_windows  = floor(av_duration/duration);
%     [n1 n2 n3 n4]   = size(nets);
%     av_nets_n3      = ceil(n3/av_num_windows);
%     av_nets         = zeros(n1,n2,av_nets_n3,n4);
%     for i=1:av_nets_n3
%         av_nets(:,:,i,:) = mean(nets(:,:,(i-1)*av_num_windows+1:i*av_num_windows,:),3);
%     end
%     plot_nodes_property('average_degree_und',av_nets,av_duration,evstart,evend,figdir,network_labels);
%     plot_nodes_property('betweenness_centralization_bin',av_nets,av_duration,evstart,evend,figdir,network_labels);
%     plot_nodes_property('network_clustering_WS_bu',av_nets,av_duration,evstart,evend,figdir,network_labels);
%     plot_nodes_property('efficiency_bin',av_nets,av_duration,evstart,evend,figdir,network_labels);
%     plot_nodes_property('network_smallworldness_WS_bu',av_nets,av_duration,evstart,evend,figdir,network_labels);
%     plot_nodes_property('normalized_clustering_coef',av_nets,av_duration,evstart,evend,figdir,network_labels);
%     plot_nodes_property('normalized_char_path',av_nets,av_duration,evstart,evend,figdir,network_labels);
    
    
    fprintf('Done!\n');
end

