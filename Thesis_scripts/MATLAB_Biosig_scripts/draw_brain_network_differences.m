function [isdifferent] = draw_brain_network_differences(A,B,montage,legends,include_common)
%DRAW_BRAIN_NETWORK_DIFFERENCES Plots the edges occuring only in one of the
%two networks
%   A               The adjacency matrix of the first graph
%   B               The adjacency matrix of the second graph
%   montage         The montage used ('ref' or 'bipolar')
%   legends         Two strings, for labeling edges occurring only in the
%                   first and second graph respectively
%   include_common  0 or 1, indicates whether to print common edges or not
%   isdifferent     0 or 1, indicating whether the two networks differ
%
% Manolis Christodoulakis @2012

    isdifferent = 0;
    
    % Get the size of the Adjacency matrices
    [n n2]  = size(A);
    [n3 n4] = size(B);
    if n~=n2 || n3~=n4 || n~=n3
        error('Adjacency matrices must be square and have equal size!');
    end
    
    if nargin<4 || isequal(legends,[])
        legends = {'In the 1st graph only' 'In the 2nd graph only'};
    end
    if nargin<5
        include_common = 0;
    elseif include_common==1 && size(legends,2)<3
        legends{3} = 'Common';
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
    elseif strcmp(montage,'avgref')
        nodes = [-4.8	 13.68;     % Fp1
                  -12	  8.16;     % F7
                -14.4        0;     % T3
                  -12	 -8.16;     % T5
                 -4.8	-13.68;     % O1                 
                   -6      7.2;     % F3
                 -7.2        0;     % C3
                   -6	  -7.2;     % P3
                    0	   7.2;     % Fz
                    0        0;     % Cz
                    0	  -7.2;     % Pz
                    6	   7.2;     % F4
                  7.2        0;     % C4
                    6	  -7.2;     % P4
                  4.8	 13.68;     % Fp2
                  12	  8.16;     % F8
                 14.4        0;     % T4
                   12	 -8.16;     % T6                 
                  4.8  -13.68];     % O2
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
    else
        error(['Montage ' montage ' has unkown coordinates']);
    end
    
    if n~=size(nodes,1)
        error('Adjacency matrix dimension does not much nodes coordinates!');
    end
    
    % Plot the nodes and surrounding scalp perimeter
    h    = figure; clf(h);
    scatter(nodes(:,1),nodes(:,2),40,'k','filled');
    hold on;
    ang  = 0:0.01:2*pi; 
    r    = 18;
    plot(r*cos(ang),r*sin(ang));
    nose = [-1 18; 0 20; 1 18];
    plot(nose(:,1),nose(:,2));
    
    % Edges occuring in the first but not the second graph
    h = [];
    l = {};
    [ind1 ind2]=ind2sub(size(A),find((A-B)==1));
    gl = arrayfun(@(p,q) line([nodes(p,1),nodes(q,1)],[nodes(p,2),nodes(q,2)], ...
        'Color','g'),ind1,ind2);
    if size(ind1,1)>0
        isdifferent = 1;
%         legend(rl(1),legends{1});
        h = gl(1);
        l = {legends{1}};
    end

    % Edges occuring in the second but not the first graph
    [ind1 ind2]=ind2sub(size(A),find((A-B)==-1));
    rl = arrayfun(@(p,q) line([nodes(p,1),nodes(q,1)],[nodes(p,2),nodes(q,2)], ...
        'Color','r'),ind1,ind2);
    if size(ind1,1)>0
        isdifferent = 1;
%         legend(gl(1),legends{2});
        h = [h; rl(1)];
        l = [l legends{2}];
    end
    
    if include_common
        % Edges occuring in both graphs
        [ind1 ind2]=ind2sub(size(A),find((A+B)==2));
        kl = arrayfun(@(p,q) line([nodes(p,1),nodes(q,1)],[nodes(p,2),nodes(q,2)], ...
            'Color','k'),ind1,ind2);
        if size(ind1,1)>0
            isdifferent = 1;
    %         legend(gl(1),legends{2});
            h = [h; kl(1)];
            l = [l legends{3}];
        end
    end

    
    if size(h,1)==3
        legend(h,l{1},l{2},l{3});
    elseif size(h,1)==2
        legend(h,l{1},l{2});
    elseif size(h,1)==1
        legend(h,l{1});
    end
    legend show;
    axis equal off
    hold off;
end