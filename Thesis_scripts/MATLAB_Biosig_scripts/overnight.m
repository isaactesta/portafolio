% Overnight script

montages     = {'bipolar'; 'ref'; 'avgref'};

correlations = {'cross-corr';                       % 1
                'cross-corr_no_zero_lag';           % 2
                'cross-corr_no_symmetric';          % 3
                'coherence';                        % 4
                'coherence_freq_bands';             % 5
                'mean_coherence';                   % 6
                'mean_coherence_freq_bands';        % 7
                'mean_imaginary_coherence';         % 8
                'imaginary_coherence';              % 9 
                'imaginary_coherence_freq_bands';   % 10
                'pli';                              % 11
                'pli_cpsd';                         % 12
                'wpli'};                            % 13

% % Original
% thresholds   = [0.75; 0.75; 0.5;
%                 0.75; 0.75; 
%                 0.4; 0.4;
%                 0.08;
%                 0.65; 0.65; 
%                 0.13; 0.55; 0.6]; 

% For Maria
thresholds   = [0.85; 0.9; 0.1;
                0.9; 0.9; 
                0.9; 0.9;
                0.9;
                0.65; 0.65; 
                0.13; 0.55; 0.75]; 
            
filterings   = {'ICA'; 'f1-60_notch'; 'f1-45'; 'f1-50'; 'f1-60'; 
                'alpha'; 'beta'; 'gamma'; 'delta'; 'theta'; 
                'ICA_alpha'; 'ICA_beta'; 'ICA_gamma'; 'ICA_delta'; 
                'ICA_theta'}; 
            
long_seiz_mat = {'/home/manolisc/epilepsy/Exports/II-9fee1' 'Export1';      % 1) I.I.
                 '/home/manolisc/epilepsy/Exports/MC-95a3a' 'Export1';      % 2) M.C.
                 '/home/manolisc/epilepsy/Exports/TK-c840d' 'Export1';      % 3) T.K.
                 '/home/manolisc/epilepsy/Exports/HE-bb167' 'Export1-2';    % 4) H.E.
                 '/home/manolisc/epilepsy/Exports/MG-f84c1' 'Export1-2part'; % 5) M.G.
                 '/home/manolisc/epilepsy/Exports/DP-98304' 'Export1';      % 6) Psychogenic
                 '/home/manolisc/epilepsy/Exports/GM-10837' 'Export1';      % 7) GM
                 '/home/manolisc/epilepsy/Exports/MV-5859'  'Export1-4';    % 8) MV
                 '/home/manolisc/epilepsy/Exports/RC-4337'  'Export1-2';    % 9) RC
                 '/home/manolisc/epilepsy/Exports/MC2-9672' 'Export1-3';    % 10) MC2
                 '/home/manolisc/epilepsy/Exports/KC-11561' 'Export1-2';    % 11) KC
};

% %% Calculate networks
% % Montage, 1 = bipolar
% mrange = [2 3];
% % Correlations, 1 = cross-corr, 3 = corrected cross-corr, 5 = coh freq
% % bands
% crange = [11 13];
% % Filtering, 1 = ICA, 3 = f1-45
% frange = [12 11];
% % Seizures (i.e. patient number)
% srange = [4];
% % Suffix to add to the filename
% patient_suffix = '_ica';
% 
%         for f = frange
% for s = srange
%     for c = crange
%             for m = mrange
%                 disp(long_seiz_mat(s,1));
%                 disp(long_seiz_mat(s,2));
%                 disp(montages(m));
%                 disp(correlations(c));
%                 disp(filterings(f));
%                 testing_measures_mat(long_seiz_mat{s,1},[long_seiz_mat{s,2} patient_suffix],montages{m},correlations{c},filterings{f},thresholds(c));
%             end
%         end
%     end
% end

% %% Calculate graph edit distance periodicities
% 
% experiments = {'bipolar__ICA__cross-corr';
%                'bipolar__ICA__cross-corr_no_symmetric'; 
%                'bipolar__ICA__wpli';
%                'bipolar__ICA__coherence_freq_bands';
%                };
% patient_suffix = '_ica';
%           
% thresholds  = [0.65; 
%                0.20; %0.25; %0.35; 
%                0.8;
%                0.65
%               ];
% 
%            
% for e = 1
%     for patient=[1:3 5:6 8:9]
%         tic
%         display(num2str(thresholds(e)))
%         periodicity_netsw_edit_distance(long_seiz_mat{patient,1},[long_seiz_mat{patient,2} patient_suffix],experiments{e},thresholds(e));
%         toc
%     end
% end

%% Calculate power periodicites

srates = [200; 200; 200; 200; 200; 200; 
          500; 500; 500; 500; 500];

for patient=[4]
    tic
%     datafile = [long_seiz_mat{patient,1} '/' long_seiz_mat{patient,2} '_ica_data__bipolar__ICA.mat']
    periodicity_power_per_band(long_seiz_mat{patient,1},long_seiz_mat{patient,2});
    toc
end
