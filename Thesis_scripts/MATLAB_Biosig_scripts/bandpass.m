function [ filtered_data ] = bandpass( data, low, high )
%BANDPASS Bandpass using EEGLAB
%
% Manolis Christodoulakis @ 2012

    disp('Filtering... ');

    filtered_data = detrend(data);
    
    filtered_data = filtered_data';
    [filtered_data]=eegfilt(filtered_data,200,low,0);
    [filtered_data]=eegfilt(filtered_data,200,0,high);
    filtered_data = filtered_data';
    
    fprintf('Done!\n');

end

