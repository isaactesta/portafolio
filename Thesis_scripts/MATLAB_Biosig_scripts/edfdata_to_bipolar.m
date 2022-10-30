function bipolar_data = edfdata_to_bipolar(EDFdata)
%EDFDATA_TO_BIPOLAR Converts a data matrix that has been imported from EDF,
%   and is presumably unipolar, to bipolar montage.
%
%     1   'Fp1'
%     2   'Fp2'
%     3   'F3'
%     4   'F4'
%     5   'C3'
%     6   'C4'
%     7   'P3'
%     8   'P4'
%     9   'O1'
%     10  'O2'
%     11  'F7'
%     12  'F8'
%     13  'T3'
%     14  'T4'
%     15  'T5'
%     16  'T6'
%     17  'A1'
%     18  'A2'
%     19  'Fz'
%     20  'Cz'
%     21  'Pz'
%     22  'ROC'
%     23  'LOC'
%     24  'T1'
%     25  'T2'
%     26  'EMG'
%     27  'ECG EKG'
%     28  'Photic'
    
% Manolis Christodoulakis @ 2012

    data = cell2mat(EDFdata);
    n    = size(data,1);
    bipolar_data = zeros(n,23);

    bipolar_data(:,1)  = data(:,1) - data(:,11);    % Fp1-F7
    bipolar_data(:,2)  = data(:,11) - data(:,13);   % F7-T3
    bipolar_data(:,3)  = data(:,13) - data(:,15);   % T3-T5
    bipolar_data(:,4)  = data(:,15) - data(:,9);    % T5-O1
    bipolar_data(:,5)  = data(:,2) - data(:,12);    % Fp2-F8
    bipolar_data(:,6)  = data(:,12) - data(:,14);   % F8-T4
    bipolar_data(:,7)  = data(:,14) - data(:,16);   % T4-T6
    bipolar_data(:,8)  = data(:,16) - data(:,10);   % T6-O2
    bipolar_data(:,9)  = data(:,1) - data(:,3);     % Fp1-F3
    bipolar_data(:,10) = data(:,3) - data(:,5);     % F3-C3
    bipolar_data(:,11) = data(:,5) - data(:,7);     % C3-P3
    bipolar_data(:,12) = data(:,7) - data(:,9);     % P3-O1
    bipolar_data(:,13) = data(:,2) - data(:,4);     % Fp2-F4
    bipolar_data(:,14) = data(:,4) - data(:,6);     % F4-C4
    bipolar_data(:,15) = data(:,6) - data(:,8);     % C4-P4
    bipolar_data(:,16) = data(:,8) - data(:,10);    % P4-O2
    bipolar_data(:,17) = data(:,19) - data(:,20);   % Fz-Cz
    bipolar_data(:,18) = data(:,20) - data(:,21);   % Cz-Pz
    
    % Additional channels, as would have been exported in bipolar by
    % Nicolet
    bipolar_data(:,19) = data(:,23) - data(:,17);   % LOC-A1
    bipolar_data(:,20) = data(:,22) - data(:,18);   % ROC-A2
    bipolar_data(:,21) = data(:,27);                % ECG EKG
    bipolar_data(:,22) = data(:,28);                % Photic
    bipolar_data(:,23) = data(:,26);                % EMG
end

