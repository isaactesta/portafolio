function nc = normalized_clustering_coef2(G)
%NORMALIZED_CLUSTERING_COEF    Normalized clustering coefficient
%
%   nc = normalized_clustering_coef2(G);
%
%   The clustering coefficient of a network divided by the clustering
%   coefficient of a random network with the same degree DISTRIBUTION
%
%   Input:      G,      binary (undirected) connection matrix.
%
%   Output:     nc,     Normalized clustering coefficient
%
%   Requires: the Brain Connectivity Toolbox (BCT)
%
%   Manolis Christodoulakis @ 2012

    n = size(G,1);          % Number of nodes of G
    
    G(eye(n)~=0)=0;         % Ignore self loops
    G(G>0) = 1;             % Make sure it's binary
    degrees = sum(G);       % Degree distribution
    
    
    
    e = nnz(G)/2;        	% Number of edges of G (ignore self loops, if any)
    p = 2*e/(n*(n-1));      % Probability of occurrence of an edge (for random graph)
    k = 2*e/n;              % Average degree (for random graph)

    c = network_clustering_WS_bu(G);    % Clustering coefficient of G
    crand = p;              % Clustering coefficient of random graph

    nc = c/crand;

end