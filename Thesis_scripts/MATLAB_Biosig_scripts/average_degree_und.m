function d = average_degree_und(G)
%AVERAGE_DEGREE_UND    The average degree among all nodes of the graph
%
%   d = average_degree_und(G);
%
%   Input:      G,		(binary/weighted) undirected connection matrix.
%
%   Output:     d,     	average degree among all nodes of the graph.
%
%   Requires: the Brain Connectivity Toolbox (BCT)
%
%   Manolis Christodoulakis @ 2012

	d = mean(degrees_und(G));
end
