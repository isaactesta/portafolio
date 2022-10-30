function b = betweenness_centralization_bin(G)
%BETWEENNESS_CENTRALIZATION_BIN    Node betweenness centralization
%
%   b = betweenness_centralization_bin(G);
%
%   Node betweenness centralization is a summary measure of the variation
%   in betweeness centrality over the entire network. Specifically, it
%   is the ratio of the variation in betweeness centrality scores to the
%   maximum variation.
%
%   Input:      G,      binary (directed/undirected) connection matrix.
%
%   Output:     b,     fraction indicating the percentage variation.
%
%   Requires: the Brain Connectivity Toolbox (BCT)
%
%   Reference: Wouter de Nooy, Andrej Mrvar and Vladimir Batagelj
%               Exploratory Social Network Analysis with Pajek 
%               (Structural Analysis in the Social Sciences), 2005.
%
%
%   Manolis Christodoulakis @ 2012

    n = size(G,1);
    
    % Compute the betweenness centrality of each node
    C = betweenness_bin(G);
    
    % Sum the variance from the maximum
    sum_variance = sum(max(C)-C);
    
    % Max variance in same size star
    max_variance = (n-1)*(n-1)*(n-2)/2;
    
    % Betweeness centralization
    b = sum_variance/max_variance; 
end
