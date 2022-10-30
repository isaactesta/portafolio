%% Trial for reading iEEG data

% filename = 'res_tr1.edf';

[hdr, record] = edfread('res_tr1.edf');
chan_labels = hdr.Properties.VariableNames


%% Chan trials

smallerTable1 = hdr(:, {'ECG'});
ecg = table2array(smallerTable1);

