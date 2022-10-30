for yo = 1:size(messy,1),
    more_aberrant = find (t>=messy(yo,1) & t <= messy(yo,2));
    aberrant (more_aberrant) = ones(size(more_aberrant));
end