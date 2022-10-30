function nl = normalized_char_path(G)
%NORMALIZED_CHAR_PATH    Normalized characteristic path length
%
%   nl = normalized_char_path(G);
%
%   The average characteristic path length of a network divided by that 
%   of a random network with the same AVERAGE degree
%
%   Input:      G,      binary (undirected) connection matrix.
%
%   Output:     nl,     Normalized characteristic path length
%
%   Requires: the Brain Connectivity Toolbox (BCT)
%
%   Manolis Christodoulakis @ 2012

    n = size(G,1);          % Number of nodes of G
    G(eye(n)~=0)=0;
    e = nnz(G)/2;        	% Number of edges of G (ignore self loops, if any)
    p = 2*e/(n*(n-1));      % Probability of occurrence of an edge (for random graph)
    k = 2*e/n;              % Average degree (for random graph)

    l = charpath(distance_bin(G));      % Mean shortest path of G
    lrand = log(n)/log(k);  % Mean shortest path of random graph

    nl = l/lrand;

end
