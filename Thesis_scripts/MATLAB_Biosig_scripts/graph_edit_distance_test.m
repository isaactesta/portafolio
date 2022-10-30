function d = graph_edit_distance_test(g1,g2)
%graph_edit_distance Calculates the edit distance between two graphs with unique node labels
%   
%   g1, g2 are the adjacency matrices of the graphs (currently have to be
%   the same size). Graphs are considered undirectional.
%
%   Reference: Peter J. Dickinson, Horst Bunke, Arek Dadej, and Miro 
%   Kraetzl (2003), On Graphs with Unique Node Labels.
%
% Manolis Christodoulakis @ 2014

n1  = size(g1,1); 
n2  = size(g2,1);
if n1~=n2
    error('Adjacency matrix dimensions do not match!');
end

% Undirectional graphs, count half the edges
C1  = nnz(g1)/2;
C2  = nnz(g2)/2;
C0  = nnz(g1.*g2)/2;
%C0x = nnz(xor(g1,g2))/2;

d1 = nnz(g1)/n1;
d2 = nnz(g2)/n2;

% Calculate the distance (undirected, so divide by 2)
%d   = (C1 + C2 - 2*C0 + C0x)/2;
%d   = (C1 + C2 - 2*C0);
d   = (C1 + C2 - 2*C0)
/(d1+d2);
%d   = 2*C0/(C1+C2);
%assert((C1 + C2 - 2*C0)==C0x);

end