function [nets] = binarize_fixed_connectivity(nets,connectivity)
%BINARIZE_FIXED_CONNECTIVITY Binarizes a network so that only a percentage
%of the connections is allowed
%
% Manolis Christodoulakis @ 2012

    fprintf(['Binarizing network (connectivity = ' num2str(connectivity) ')... ']);
    
    [n, ~, timemoments, frequencies] = size(nets);
    num_connections = 2 * ceil( connectivity * n*(n-1)/2 );
    fprintf(['# connections = ' num2str(ceil( connectivity * n*(n-1)/2 )) '...']);
    
    for i=1:timemoments
        for j=1:frequencies
            current = nets(:,:,i,j);
            sorted = sort(reshape(current,n*n,1));
            t = sorted(n*n - num_connections + 1);
            current(current>=t|current<=-t)=1;
            current(current<1)=0;
            nets(:,:,i,j) = current;
        end
    end
    
    fprintf('Done!\n');
end

