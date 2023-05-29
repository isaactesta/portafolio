function [filtered_data] = remove_artifacts(data)
%REMOVE_ARTIFACTS Filter 1-50Hz and remove eye artifacts
%
% data and filtered_data are matrices, where columns are channels and rows
%   are the recorded data

    % Filtering (do we need detrend? or is it done in eegfilt?)
    filtered_data = data';%filtered_data = detrend(data(:,1:24)); 

    [filtered_data]=eegfilt(filtered_data,256,1,0);
    [filtered_data]=eegfilt(filtered_data,256,0,50);
    filtered_data=filtered_data';  

    % REGRESS_EOG yields the regression coefficients for 
    % correcting EOG artifacts in EEG recordings.
    % Corrected data is obtained through
    
    n = size(data,2);
    [R] = regress_eog(covm(filtered_data,'E'), 1:n-2, n-1:n);
    [filtered_data] = filtered_data * R.r0;    % without offset correction

end

