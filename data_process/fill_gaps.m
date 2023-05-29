function [X,gaps] = fill_gaps(X,value)
%replace_nans Replacing missing data with random data with the same mean 
% and variance as the data preceding the gap
%
% If value is provided, then all occurrences of the value are considered
% as gaps. Otherwise, NaNs are considered as gaps


    if nargin<2, I = find(isnan(X));
    else         I = find(isnan(X)|X==value); end
    
    if numel(I)==0 
        gaps = [];
        return; 
    end
    
    ngaps     = numel(find(diff(I)>1)) + 1;
    gap_start = [I(1); I(find(diff(I)>1)+1)];
    gap_end   = [I(find(diff(I)>1)); I(end)];
    large_gap_size = 200;
    
    % Fill the gaps
    for i = 1:ngaps
        gap_size = gap_end(i)-gap_start(i)+1;
        before   = max(1,gap_start(i)-gap_size):gap_start(i)-1;

        if gap_size <= large_gap_size
            % Small gap, just copy the few values missing
            X(gap_start(i):gap_end(i)) = X(before);
            
        else
            % Large gap, insert random data
            mn   = mean(X(before));
            sd   = std(X(before));
            X(gap_start(i):gap_end(i)) = sd.*randn(gap_size,1) + mn;
        end
    
    end
    
    % Calculate the numbers of rows (ignore cols, channels) where large
    % gaps are found
    large_gap_ind = find(gap_end-gap_start>large_gap_size);
    [gap_s_row,~] = ind2sub(size(X),gap_start(large_gap_ind));
    [gap_e_row,~] = ind2sub(size(X),gap_end(large_gap_ind));
    [gapsl,gapsr] = IntervalUnion(gap_s_row,gap_e_row);
    gaps          = [gapsl gapsr];
    
end