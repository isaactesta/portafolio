function property = calculate_net_property(fname, nets, smooth)
%CALCULATE_NET_PROPERTY Given a binary network, calculates a network
%property
%   Optionally, smooths the property line by the amount provided in arg 3
%
% Manolis Christodoulakis @ 2017

    fprintf(['Calculating network property ' fname '... ']);

    [~, ~, ntimemoments, nnets] = size(nets);

    for net=1:nnets
        for t=1:ntimemoments
           C(:,t,net) = feval(fname,nets(:,:,t,net));
        end
    end

    if nargin >= 3
        nbands = size(C,1);
        for net=1:nnets
            for band = 1:nbands
                property(band,:,net) = remove_mean(C(band,:,net)', smooth);
            end
        end
    else
        property = C;
    end
    
    fprintf('Done!\n');
end

