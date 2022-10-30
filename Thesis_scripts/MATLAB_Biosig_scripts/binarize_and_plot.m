function [data,indices,nets_weighted,lags] = binarize_and_plot(dir,seizid)
%binarize_and_plot Finds cross correlations between channels...
% then binarizes for various thresholds and plots the results

SRATE = 200;            % sampling rate, 200Hz
MAXACCEPTEDLAG=0.15;    % Crosscorrelation will be accepted only if it 
                        % occurred within this time lag
window_size = 2000;     % The windows for cross correlations, 10 sec @ 200Hz 

% Set source and destination
source = [dir '\seizure_' seizid '.txt']
destination = [dir '\seizure_' seizid];
mkdir(destination);

% Load or create cross correlations
if exist([destination '\data.mat'],'file')
    load([destination '\data.mat']);
else
    % Load the data from file
    [data,indices]=importEEG(source,0);
    
    % Load the annotations
    annot = import_annotations([dir '\annotations.txt']);
    
    % Filter the data
    filtered_data = detrend(data(:,1:25)');
    %[filtered_data]=eegfilt(filtered_data,200,1,0);
    [filtered_data]=eegfilt(filtered_data,200,0,50);
    % Cross-correlate
    [nets_weighted,lags] = window_cross_correlation_weighted(filtered_data',window_size);
    save([destination '\data.mat']);
end;

% Set lags to 1 if within window, 0 otherwise
lags_bin = lags;
lags_bin(abs(lags)>=MAXACCEPTEDLAG*SRATE)=0;
lags_bin(abs(lags)<MAXACCEPTEDLAG*SRATE)=1;

for t=0.55:0.1:1
    nets = nets_weighted;
    % Binarize with threshold
    nets(nets>t|nets<-t)=1;
    nets(nets<1)=0;
    % Set to 0 if out of boundary
    nets = nets.*lags_bin;
    
    plot_nodes_property('degrees_und',nets);
    plot_nodes_property('betweenness_bin',nets);
    plot_nodes_property('clustering_coef_bu',nets);
    plot_nodes_property('charpath',nets);
    
    subdir = [destination '\' num2str(t)];
    mkdir(subdir);
    movefile('*.jpg',subdir);
end 
end

