function c = network_clustering_WS_bu(G)
%NETWORK_CLUSTERING_WS_BU    Clustering of the network as a whole
%
%   c = network_clustering_WS_bu(G);
%
%   This is simply the mean of the clustering coefficient (as defined by
%   Watts and Strogatz, 1998) of the nodes of the network.
%   Note: there are two differnt definitions of clustering coefficient. Here
%   we use the one implemented in the BCT, which is the one defined by Watts 
%   and Strogatz.
%
%   Input:      G,      binary (undirected) connection matrix.
%
%   Output:     c,      clustering of the network.
%
%   Requires: the Brain Connectivity Toolbox (BCT)
%
%   Reference: Watts DJ, Strogatz SH (1998) Collective dynamics of ‘small-
%   world’ networks. Nature 393: 440–442.
%
%
%   Manolis Christodoulakis @ 2012
    
    c = mean(clustering_coef_bu(G));

end