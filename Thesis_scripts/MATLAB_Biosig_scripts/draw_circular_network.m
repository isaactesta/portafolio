%DRAW_CIRCULAR_NETWORK Plots an undirected circular graph (network)
%   A is the adjacency matrix of the graph
%
% Manolis Christodoulakis @2012

function draw_circular_network(A)
    % Get the size of the Adjacency matrix
    [n n2] = size(A);
    if (n ~= n2)
        error('Adjacency matrix must be square!');
    end
    
    % Create the nodes
    theta=linspace(0,2*pi,n);%theta=theta(1:end-1); % n equally-spaced points
    [x,y]=pol2cart(theta,1);    % theta is the angle, 1 is the radius
    
    % Get from linear indexes the subscript equivalents
    [ind1,ind2]=ind2sub(size(A),find(A(:)));
    
    % Plot the connections
    h=figure;clf(h);
    plot(x,y,'.k','markersize',20);hold on
    arrayfun(@(p,q)line([x(p),x(q)],[y(p),y(q)]),ind1,ind2);
    axis equal off
end