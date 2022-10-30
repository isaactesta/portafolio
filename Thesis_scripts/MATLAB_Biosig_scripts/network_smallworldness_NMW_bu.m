function s = network_smallworldness_NMW_bu(G)
%NETWORK_SMALLWORLDNESS_NMW_BU    Network "small-worldness"
%
%   s = network_smallworldness_NMW_bu(G);
%
%   The measure of network "small-worldness" as defined by Humphries et al.
%   2008. There are two definition of "small-worldness". Here we use the
%   one based on the definition of Network Clustering by Newman, Moore and
%   Watts (instead of the Watts-Strogatz one)
%
%   Input:      G,      binary (undirected) connection matrix.
%
%   Output:     s,      Network "small-worldness".
%                       s>1 indicates that the network is small-world
%
%   Requires: the Brain Connectivity Toolbox (BCT)
%
%   Reference: Mark D. Humphries, Kevin Gurney.
%               Network ‘Small-World-Ness’: A Quantitative Method for 
%               Determining Canonical Network Equivalence, 2008.
%
%   Manolis Christodoulakis @ 2012

    n = size(G,1);          % Number of nodes of G
    G(eye(n)~=0)=0;
    e = nnz(G)/2;        	% Number of edges of G (ignore self loops, if any)
    p = 2*e/(n*(n-1));      % Probability of occurrence of an edge (for random graph)
    k = 2*e/n;              % Average degree (for random graph): (n-1)*p
    
    c = network_clustering_NMW_bu(G);  % Clustering coefficient of G
    crand = p;              % Clustering coefficient of random graph

    l = charpath(distance_bin(G));     % Mean shortest path of G
    lrand = log(n)/log(k);  % Mean shortest path of random graph
    
    s = (c * lrand) / (crand * l);
    
%    global sw
%    if isempty(sw)
%        sw = zeros(180,8);
%    end
%    persistent count 
%    if isempty(count)
%        count = 0;
%    end
%    count = count + 1;
%    sw(count,:) = [count e k c crand l lrand s];
%    count
%    sw(count,:)
 
end