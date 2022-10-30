function [str]=network_to_freq_str(num)
    network_labels = {'Broadband';
        'Alpha band'; 
        'Beta band'; 
        'Gamma band'; 
        'Delta band'; 
        'Theta band'};
    str = network_labels{num};
end