%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% File: load_ecg.m
% Author: Mark Ebden
% Date: November 2002
% 
% DESCRIPTION
% Extracts the ECG for a given patient number.
% Raw = directly from .MAD file
% Refined = time-stamping issue corrected, then result is
%           resampled at exactly 256 Hz and notch-filtered
% 5min = first 5 minutes of refined time series
%
% OUTPUTS
% 'ecg' is an mx4 matrix, with the first column being a
% 256-Hz monotonically increasing time vector, and the next
% 3 columns being the ECG data.
%
% USAGE
% This script is called by at least the following programs:
% tilt.m, tilt_hrv.m, tilt_eval.m, tilt_eeg.m, and tilt_wv.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Initialisations

GetRoot
addpath /projects/smp/tools/bin/matlab/
starter = 0; stop = 0; ecg =[];
max_freq = 305; min_freq = 5;%210;
filestart = [DataRoot 'ecgs/refined/'];
filename = [filestart num2str(pat_no) '.mat'];

% 2. Load the ECG in one of two ways

if exist(filename, 'file') == 2,
    % The easy way
    eval (['!echo Patient ' num2str(pat_no) ': Extracting archived ECG data from .MAT file....']);
    eval(['load ' [filestart num2str(pat_no)] ' ecg;']);
    % Omitted in this version of load_ecg:
    %[channel, ecg_number] = best_ecg (pat_no);
else
    % The hard way
    filestart2 = [DataRoot 'ecgs/raw/'];
    filename2 = [filestart2 num2str(pat_no) '.mat'];
    if exist(filename2, 'file') == 2,
        eval (['!echo Patient ' num2str(pat_no) ': Loading unrefined ECG data....']);
        eval(['load ' [filestart2 num2str(pat_no)] ' ecg;']);
    else    
        eval (['!echo Patient ' num2str(pat_no) ': Extracting ECG data from .MAD file....']);
        Get_SMP_Channel
        if (pat_no ~= 3154) % Exclude special cases
            %eval(['[ecg] = sei4 (''' p_string ''', ''0000'', ''' channel '''); ']);
            eval(['[ecg] = smp_extract (''' p_string ''', ''0000'', ' num2str(starter) ', ' num2str(stop) ', ''' channel ''');']);
        elseif (pat_no == 3154)
            !echo Extracting 0001 - Extra baseline is in 0000
            %eval(['[ecg] = sei4 (''' num2str(pat_no) ''', ''0001'', ''' channel '''); ']);
            eval(['[ecg] = smp_extract (''' num2str(pat_no) ''', ''0001'', ' num2str(starter) ', ' num2str(stop) ', ''' channel ''');']);
        end
        eval(['save ' [filestart2 num2str(pat_no)] ' ecg;']);
    end
    % Remove scraps at the end of the time series (unbelievably, required for an accurate mean frequency derivation)
    initialisations
    ut = find (ecg(:,1)<shutdown);
    ecg = ecg(ut,:);
    a = 1./diff(ecg(:,1));
    ta = ecg(1:end-1,1);
    % Optional: Display variance properties
    if 1==0
        j = 1; N = 768; u = []; um = []; uma = [];
	for k = N+1:N:length(a),
            u(j) = mean(a(k-N:k));
            um(j) = min(a(k-N:k));
            uma(j) = max(a(k-N:k));
            j = j + 1;
	end
	figure; hold on; title(pat_no)
        tu = ta(1:N:length(a)-N-1);
        plot (tu, u,'.'); %plot (tu, um,'.k'); plot (tu, uma,'.m')
        ylabel('ECG Frequency (Hz)'); xlabel ('Time (s)')
    end
    
    % Decide whether to treat the time series as one chunk or more than one
    if min(a) >= min_freq & max(a) <= max_freq,
        % Acceptable deviation occurred in SMP time stamps
        % a) Find mean frequency and convert to even sampling
        if 1==1,
          ecg_samp_freq = (size(ecg,1)-1)/(ecg(end,1)-ecg(1,1));
          t_256 = ecg(1,1):(1/ecg_samp_freq):ecg(end,1);
          u = min(length(ecg),length(t_256));
          t_256 = (t_256(1:u))';
          ecg_256 = ecg(1:u,2:4);
          ecg = [t_256 ecg_256];
        end
        % b) Resample at 256 Hz
        t256 = (ecg(1,1):(1/256):ecg(end,1))';
        ecg = interp1(ecg(:,1),ecg(:,2:4),t256);
        ecg = ecg_mains(ecg);
        ecg = [t256 ecg];
    else
        % Gaps occur
        disp([pat_no min(a) max(a)])
        %a_sort = sort(a);
        group_num = [];
        len = size(ecg,1);
        start_k = 1; k = 1;
        while k < len-1,
            te = (ecg(k+1,1)-ecg(k,1));
            if te < 1/max_freq | te > 1/min_freq,
                % Gap detected
                if k-start_k > 256*3,
                    group_num = [group_num; [start_k k]];
                    start_k = k+1;
                    sg = size(group_num,1);
                    if sg > 10,
                        !echo Too many gaps
                        group_num
                        pat_no
                        pau
                    end
                else
                    % Ignore small blocks
                    start_k = k+1;
                end
            end
            k = k + 1;
        end
        if k-start_k > 256*3,
            group_num = [group_num; [start_k k]];
        end
        sg = size(group_num,1);
        disp([num2str(sg) ' blocks detected for patient ' num2str(pat_no) '.  Gaps:']);
        format bank; disp([ecg(group_num(1:end-1,2),1) ecg(group_num(2:end,1),1)])
        O_ecg = ecg; M_ecg = [];
        for gn = 1:sg,
            ecg = O_ecg(group_num(gn,1):group_num(gn,2),:);
            ecg_samp_freq = (size(ecg,1)-1)/(ecg(end,1)-ecg(1,1));
            t_256 = ecg(1,1):(1/ecg_samp_freq):ecg(end,1);
            u = min(length(ecg),length(t_256));
            t_256 = t_256(1:u);
            ecg_256 = ecg(1:u,2:4);
            ecg = [t_256' ecg_256];
            % Resample at 256 Hz
            t256 = (ecg(1,1):(1/256):ecg(end,1))';
            ecg = interp1(ecg(:,1),ecg(:,2:4),t256);
            ecg = ecg_mains(ecg);
            ecg = [t256 ecg];
            M_ecg = [M_ecg; ecg];
            % Fill in the gap
            if gn < sg,
                % Not perfect but it will do; we don't know exact SMP time after gap anyway
                t_gap = ((t256(end)+1/256):(1/256):(O_ecg(group_num(gn+1,1))-1/256))';
                ecg = M_ecg(end,2)*ones(size(t_gap));
                M_ecg = [M_ecg; [t_gap ecg ecg ecg]];
            end
        end
        ecg = M_ecg;
    end

    % Save all the data
    eval(['save ' [DataRoot 'ecgs/refined/' num2str(pat_no) ] ' ecg;']);

%    Omitted in this generic version of load_ecg:
%    % Save the first 5 minutes of the best channel, separately
%    se = ecg;
%    [channel, ecg_number] = best_ecg (pat_no);
%    ecg = ecg(1:256*300,[1 ecg_number+1]);
%    eval (['save ' [DataRoot 'ecgs/5min/' num2str(pat_no) ] ' ecg;']);
%    ecg = se;

end

% 3. Report success

disp(['              Loaded approximately ' num2str(round(length(ecg)/256/60)) ' minutes.']);
