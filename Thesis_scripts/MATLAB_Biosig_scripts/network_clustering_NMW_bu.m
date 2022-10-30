function c = network_clustering_NMW_bu(G)
%NETWORK_CLUSTERING_NMW_BU    Clustering of the network as a whole
%
%   c = network_clustering_NMW_bu(G);
%
%   This is simply the network clustering measure based on transitivity, as
%   defined by Newman, Moore and Watts (2000).
%   Note: the other definition of clustering coefficient is by 
%   Watts and Strogatz.
%
%   Input:      G,      binary (undirected) connection matrix.
%
%   Output:     c,      clustering of the network.
%
%   Reference: Newman ME, Moore C, Watts DJ (2000) Mean-field solution 
%   of the small-world network model
%
%
%   Manolis Christodoulakis @ 2012
    
    % Calculate the number of paths of length 2
    G2              = G * G;
    num_2_paths     = ( sum(sum(G2)) - trace(G2) )/2;

    % Calculate the number of triangles
    G3              = G2 * G;
    num_triangles   = trace(G3) / 6;  % Because the graph is undirected
                                      % (for directed, divide by 3)
    
    % Return the network clustering 
    c = 3 * num_triangles / num_2_paths;
end