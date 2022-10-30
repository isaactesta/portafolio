function [dist] = coords_to_pairwise_distances(coords)
%COORDS_TO_PAIRWISE_DISTANCES creates a square matrix with the pairwise
%distances between the elements of the coords array (2D)

nchannels = size(coords,1);
dist = zeros(nchannels,nchannels);

for i=1:nchannels
    for j=i+1:nchannels
        dist(i,j) = sqrt( sum((coords(i,:) - coords(j,:)) .^ 2) );
    end
end

end