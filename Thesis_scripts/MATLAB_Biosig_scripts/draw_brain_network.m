%DRAW_BRAIN_NETWORK Plots an undirected brain graph (network)
%   A           The adjacency matrix of the graph
%   montage     The montage used ('ref' or 'bipolar')
%
% Manolis Christodoulakis @2012

function h = draw_brain_network(A,montage,excl_node_index)
    %%%% PARAMETERS
    % Should the figure be visible (disable for speed)? ('on' or 'off')
    fig_visible = 'off';
    
    % Should the node labels be printed?
    node_labels = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Get the size of the Adjacency matrix
    [n n2] = size(A);
    if n~=n2
        error('Adjacency matrix must be square!');
    end
    
    % Nodes coordinates
    if strcmp(montage,'ref')
        nodes = [-4.8	 13.68;     % Fp1
                  -12	  8.16;     % F7
                -14.4        0;     % T3
                  -12	 -8.16;     % T5
                 -4.8	-13.68;     % O1                 
                   -6      7.2;     % F3
                 -7.2        0;     % C3
                   -6	  -7.2;     % P3
                    0	   7.2;     % Fz
                    0	  -7.2;     % Pz
                    6	   7.2;     % F4
                  7.2        0;     % C4
                    6	  -7.2;     % P4
                  4.8	 13.68;     % Fp2
                  12	  8.16;     % F8
                 14.4        0;     % T4
                   12	 -8.16;     % T6                 
                  4.8  -13.68];     % O2
        labels = { 'Fp1'; 'F7'; 'T3'; 'T5'; 'O1'; 'F3'; 'C3'; 'P3';
                   'Fz'; 'Pz'; 'F4'; 'C4'; 'P4'; 
                   'Fp2'; 'F8'; 'T4'; 'T6'; 'O2'; 
                 };
        dx = 0; dy = 0;
    elseif strcmp(montage,'bipolar')
        nodes = [-8.4	 10.92;     % Fp1-F7
                -13.2	  4.08;     % F7-T3
                -13.2	 -4.08;     % T3-T5
                 -8.4	-10.92;     % T5-O1
                  8.4	 10.92;     % Fp2-F8
                 13.2	  4.08;     % F8-T4
                 13.2	 -4.08;     % F4-T6
                  8.4	-10.92;     % T6-O2
                 -5.4	 10.44;     % Fp1-F3
                 -6.6	   3.6;     % F3-C3
                 -6.6	  -3.6;     % C3-P3
                 -5.4	-10.44;     % P3-O1
                  5.4	 10.44;     % Fp2-F4
                  6.6	   3.6;     % F4-C4
                  6.6	  -3.6;     % C4-P4
                  5.4	-10.44;     % P4-O2
                    0	   3.6;     % Fz-Cz
                    0	 -3.6];     % Cz-Pz
        labels = {  'Fp1-F7'; 'F7-T3'; 'T3-T5'; 'T5-O1'; 'Fp2-F8';
                    'F8-T4'; 'F4-T6'; 'T6-O2'; 'Fp1-F3'; 'F3-C3';
                 	'C3-P3'; 'P3-O1'; 'Fp2-F4'; 'F4-C4'; 'C4-P4';
                  	'P4-O2'; 'Fz-Cz'; 'Cz-Pz'
                };
        dx = -1.8; dy = 1.5;
    else
        error(['Montage ' montage ' has unkown coordinates']);
    end
    
    if nargin==3
        index = true(1,size(nodes,1));
        index(excl_node_index) = false;
        nodes = nodes(index,:);
    end
    
    if n~=size(nodes,1)
        error('Adjacency matrix dimension does not much nodes coordinates!');
    end
    
    % Plot the nodes
    h = figure('visible',fig_visible);
    clf(h);
    scatter(nodes(:,1),nodes(:,2),40,'k','filled');
    hold on;
    
    % Add labels
    x_label_loc = nodes(:,1)+dx;
    y_label_loc = nodes(:,2)+dy;
    if strcmp(montage,'bipolar') 
        x_label_loc([1:4]) = x_label_loc([1:4]) - 2.5;
        x_label_loc([9:12]) = x_label_loc([9:12]) - 1.3;
        x_label_loc([9 12]) = x_label_loc([9 12]) + 1.5;
        x_label_loc([13 16]) = x_label_loc([13 16]) - 2;
        y_label_loc([9 12 13 16]) = y_label_loc([9 12 13 16]) - 3.8;
%         y_label_loc([1 5]) = y_label_loc([1 5]) + 0.8;
%         y_label_loc([9 13]) = y_label_loc([9 13]) - 2.4;
%         x_label_loc([9 13]) = x_label_loc([9 13]) - 0.8;
%         y_label_loc([12 16]) = y_label_loc([12 16]) - 2.8;
%         x_label_loc([1 4 13 16]) = x_label_loc([1 4 13 16]) - 1;
    end
    if node_labels
        text(x_label_loc, y_label_loc, labels)
    end
    
    % Plot surrounding scalp perimeter
    ang = 0:0.01:2*pi; 
    r   = 18;
    plot(r*cos(ang),r*sin(ang),'LineWidth',2);
    nose = [-1 18; 0 20; 1 18];
    plot(nose(:,1),nose(:,2),'LineWidth',2);
    set(findall(gcf,'type','text'),'fontSize',14);
    
    % Get from linear indexes the subscript equivalents
    [ind1,ind2]=ind2sub(size(A),find(A(:)));
    
    % Plot the connections
    arrayfun(@(p,q)line([nodes(p,1),nodes(q,1)],[nodes(p,2),nodes(q,2)],'LineWidth',2),ind1,ind2);
    axis equal off
    hold off;
end