function size = max_component_size(adj)
    [~,comp_sizes] = get_components(adj);
    
    size = max(comp_sizes);
end