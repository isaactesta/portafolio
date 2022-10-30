function cluster_nets = nets_to_clusternets(nets,clusters)
%nets_to_clusternets Creates new nets from clusters, max connectivity
%
% Currently uses the max function to find the connectivity between
% clusters. Only works in the first frequency (4th dimension is ignored)
%
% Manolis Christodoulakis @ 2014

    % Init
    nnets       = size(nets,3);
    nclusters   = numel(clusters);

    % Nets in vector form
    cluster_nets_vect = zeros(nclusters*(nclusters-1)/2,nnets);
    k = 0;
    for i=1:nclusters-1
        for j=i+1:nclusters
            k = k+1;
            cluster_nets_vect(k,:) = max(max(nets(clusters{i},clusters{j},:)));
        end
    end

    % Convert to square form (adjacency matrix)
    cluster_nets = zeros(nclusters,nclusters,nnets);
    for net=1:nnets
        cluster_nets(:,:,net) = squareform(cluster_nets_vect(:,net));
    end

end
