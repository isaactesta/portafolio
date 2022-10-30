function plot_all_brain_networks(nets,montage,figdir,excl_node_index)
    
    timemoments = size(nets,3);
    if ~exist([figdir '/graphs'],'dir')
      mkdir([figdir '/graphs']); 
    end
    
    for i=1:timemoments
      draw_brain_network(nets(:,:,i),montage,excl_node_index);
      saveas(gcf, [figdir '/graphs/graph' int2str(i) '.jpg'])
      close(gcf);
    end
end
