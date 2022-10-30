function [ bipolar_data, channel_labels ] = nicolet_to_bipolar(data, ncols)
%XLTEK_TO_BIPOLAR Converts the Nicolet raw data to bipolar
%   Assumes that rows are time moments and cols are channels
%
% Manolis Christodoulakis @ 2015

    if (nargin<2)
        ncols = 18;
    end
    
%     tic
    nlines       = size(data,1);
    bipolar_data = zeros(nlines,ncols);
%     channel_labels  = {'Fp1'; 'Fp2';  'F3';  'F4';  'C3'; 
%                         'C4'; 'P3';   'P4';  '01';  '02';  
%                         'F7'; 'F8';   'T3';  'T4';  'T5';  
%                         'T6';  'A1';  'A2';  'Fz';  'Cz';  
%                         'Pz'; 'ROC'; 'LOC';  '24';  'T1';
%                         'T2'; 'EMG'; 'EKG'; 'Photic'};

    bipolar_data(:,1)  = data(:,1)  - data(:,11);   %  Fp1 - F7
    bipolar_data(:,2)  = data(:,11) - data(:,13);   %   F7 - T3
    bipolar_data(:,3)  = data(:,13) - data(:,15);   %   T3 - T5
    bipolar_data(:,4)  = data(:,15) - data(:,9);    %   T5 - O1
    bipolar_data(:,5)  = data(:,2)  - data(:,12);   %  Fp2 - F8
    bipolar_data(:,6)  = data(:,12) - data(:,14);   %   F8 - T4
    bipolar_data(:,7)  = data(:,14) - data(:,16);   %   T4 - T6
    bipolar_data(:,8)  = data(:,16) - data(:,10);   %   T6 - O2
    bipolar_data(:,9)  = data(:,1)  - data(:,3);    %  Fp1 - F3
    bipolar_data(:,10) = data(:,3)  - data(:,5);    %   F3 - C3
    bipolar_data(:,11) = data(:,5)  - data(:,7);    %   C3 - P3
    bipolar_data(:,12) = data(:,7)  - data(:,9);    %   P3 - O1
    bipolar_data(:,13) = data(:,2)  - data(:,4);    %  Fp2 - F4
    bipolar_data(:,14) = data(:,4)  - data(:,6);    %   F4 - C4
    bipolar_data(:,15) = data(:,6)  - data(:,8);    %   C4 - P4
    bipolar_data(:,16) = data(:,8)  - data(:,10);   %   P4 - O2
    bipolar_data(:,17) = data(:,19) - data(:,20);   %   Fz - Cz
    bipolar_data(:,18) = data(:,20) - data(:,21);   %   Cz - Pz
%     toc
    
%     tic
%     i = [ 1 11 13 15  2 12 14 16 1:2:7 2:2:8  19 20]
%     j = [11 13 15  9 12 14 16 10 3:2:9 4:2:10 20 21]
%     bp2 = data(:,i) - data(:,j);
%     toc    
%     isequal(bipolar_data,bp2)
%     assert(isequal(bipolar_data,bp2));
    
    bipolar_data   = bipolar_data(:,1:ncols);

    channel_labels = {'Fp1-F7';'F7-T3';'T3-T5';'T5-O1';'Fp2-F8';...
                      'F8-T4';'T4-T6';'T6-O2';'Fp1-F3';'F3-C3';...
                      'C3-P3';'P3-O1';'Fp2-F4';'F4-C4';'C4-P4';...
                      'P4-O2';'Fz-Cz';'Cz-Pz'};

end

