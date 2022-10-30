function [str]=fname_to_str(fname)
    switch fname
        case 'degrees_und'
            str = 'Degrees';
        case 'betweenness_bin'
            str = 'Betweeness Centrality';
        case 'clustering_coef_bu'
            str = 'Clustering Coefficient';
        case 'density_und'
            str = 'Density';
        case 'modularity_und'
            str = 'Modularity';
        case 'transitivity_bu'
            str = 'Transitivity';
        case 'charpath'
            str = 'Characteristic Path Length';
        case 'betweenness_centralization_bin'
            str = 'Betweeness Centralization';
        case 'efficiency_bin'
            str = 'Global Efficiency';
        case 'network_clustering_WS_bu'
            str = 'Clustering Coefficient';
        case 'network_clustering_NMW_bu'
            str = 'Global Clustering (Newton, Moore and Watts)';
        case 'network_smallworldness_WS_bu'
            str = 'Network Small-worldness';
        case 'network_smallworldness_NMW_bu'
            str = 'Network Small-worldness (Newton, Moore and Watts)';
        case 'average_degree_und'
            str = 'Average Degree';
        case 'normalized_clustering_coef'
            str = 'Normalized Clustering Coefficient';
        case 'normalized_char_path'
            str = 'Normalized Characteristic Path Length';
        case 'max_component_size'
            str = 'Maximum-component Size';
        otherwise
            str = fname;
    end
end