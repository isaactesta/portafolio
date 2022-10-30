function bipolar_data = ft_montage_single2bipolar(data)
%MONTAGE_SINGLE2BIPOLAR Changes the data montage to bipolar
%
% Manolis Christodoulakis @ 2013

    bipolar_montage = [];
    bipolar_montage.labelorg = data.label;
    bipolar_montage.labelnew = {'Fp1-F7','F7-T3','T3-T5','T5-O1','Fp2-F8','F8-T4','T4-T6','T6-O2','Fp1-F3','F3-C3','C3-P3','P3-O1','Fp2-F4','F4-C4','C4-P4','P4-O2','Fz-Cz','Cz-Pz','AC23-AC1','AC24-AC2','AC25-AC26'};
    bipolar_montage.tra = [
    % AC1 AC2 Ref Fp1 F7 T3 T5 O1 F3 C3 P3 Fz Cz Pz F4 C4 P4 Fp2 F8 T4 T6 O2 AC23 AC24 AC25 AC26
       0   0   0  +1  -1  0  0  0  0  0  0  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % Fp1-F7
       0   0   0   0  +1 -1  0  0  0  0  0  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % F7-T3
       0   0   0   0   0 +1 -1  0  0  0  0  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % T3-T5
       0   0   0   0   0  0 +1 -1  0  0  0  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % T5-O1
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0 +1  -1  0  0  0   0    0    0    0  % Fp2-F8
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0  0  +1 -1  0  0   0    0    0    0  % F8-T4
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0  0   0 +1 -1  0   0    0    0    0  % T4-T6
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0  0   0  0 +1 -1   0    0    0    0  % T6-O2
       0   0   0  +1   0  0  0  0 -1  0  0  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % Fp1-F3
       0   0   0   0   0  0  0  0 +1 -1  0  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % F3-C3
       0   0   0   0   0  0  0  0  0 +1 -1  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % C3-P3
       0   0   0   0   0  0  0 -1  0  0 +1  0  0  0  0  0  0  0   0  0  0  0   0    0    0    0  % P3-O1
       0   0   0   0   0  0  0  0  0  0  0  0  0  0 -1  0  0 +1   0  0  0  0   0    0    0    0  % Fp2-F4
       0   0   0   0   0  0  0  0  0  0  0  0  0  0 +1 -1  0  0   0  0  0  0   0    0    0    0  % F4-C4
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0 +1 -1  0   0  0  0  0   0    0    0    0  % C4-P4
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0 +1  0   0  0  0 -1   0    0    0    0  % P4-O2
       0   0   0   0   0  0  0  0  0  0  0 +1 -1  0  0  0  0  0   0  0  0  0   0    0    0    0  % Fz-Cz
       0   0   0   0   0  0  0  0  0  0  0  0 +1 -1  0  0  0  0   0  0  0  0   0    0    0    0  % Cz-Pz
      -1   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0  0   0  0  0  0  +1    0    0    0  % AC23-AC1
       0  -1   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0  0   0  0  0  0   0   +1    0    0  % AC24-AC2
       0   0   0   0   0  0  0  0  0  0  0  0  0  0  0  0  0  0   0  0  0  0   0    0   +1   -1  % AC25-AC26
    ];

    nchannels = size(data.trial{1,1},1);
    if nchannels==24
        bipolar_montage.tra = bipolar_montage.tra(1:20,1:24);
        bipolar_montage.labelnew = bipolar_montage.labelnew(1,1:20);
    end

    cfg = [];
    cfg.montage = bipolar_montage;
    bipolar_data = ft_preprocessing(cfg,data);
end

