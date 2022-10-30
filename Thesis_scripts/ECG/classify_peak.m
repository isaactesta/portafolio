% A peak has been identified in the BPF data
% Classify as a QRS complex, or noise

%format bank; disp([SPKI recent_A1'])
%last_k = k; used to be this


if (peak_amp > ThF * possible_half),

    % This would be a QRS complex, according to pure Hamilton & Tompkins
    % However, now we do a morphology check: Added in November 2003.
    % Otherwise, the algorithm continues to produce QRS times during
	% long periods of junk recording.  Many patients (e.g. 3132) suffer.
    
    % Exclude small or wide QRS complexes, respectively:
    if possible_half == 1 & tw <= 0.12,
    	morph_check
    else
        meets_morphology = 1;
        messy = 0;
        %possible_half
    end


    if meets_morphology,
        % It is a QRS complex
        RR = peak_index - last_peak;
        if possible_half ~= 1,
            % An important tweak, to avoid getting stuck in the 1.66 regime ad infinitum
            recent_NPKI = -sort(-recent_NPKI); % Replace the largest value with a small one:
            recent_NPKI = [recent_NPKI(2:8); mean(recent_NPKI(4:8))*0.8];
            NPKI = median(recent_NPKI);
            NPKF = median(recent_NPKF);
        end
        if RR > 0,
            % Update amplitude and timing arrays
            qrs_count = qrs_count+1;
            qrs_amp(qrs_count) = peak_amp;
            qrs_index(qrs_count) = peak_index;
            if messy == 2,
                %qrs_messy(qrs_count-1) = 0;
                messy = 0;
                ardl0 = t(peak_index+refractoriness);
                ardl = [ardl round(ardl0*10)/10];
            end
            qrs_messy(qrs_count) = messy;
            recent_SPKI = [recent_SPKI(2:8); max_mwi];
            recent_SPKF = [recent_SPKF(2:8); peak_amp];
            SPKI = median(recent_SPKI);
            SPKF = median(recent_SPKF);
            
            % Update RR interval average
            recent_A1 = [recent_A1(2:8); RR];
            A1 = mean (recent_A1)/fs;
            A2 = A1;
            last_peak = peak_index;
             if possible_half == 0.3,
                % These beats never had a fiducial point, therefore guess:
                last_fp = peak_index + wl_n;
          else
                % The normal case:
                last_fp = fid_pt(fp);
             end
            possible_half = 1;

            k = peak_index + refractoriness;

	else
            % This never occurs
            !echo RR negative.
            RR, pau
        end
        next_k = peak_index + refractoriness;
    
    else
        %if t(max_m)>54 & t(max_m)<60,
        %  disp([0 t(max_m) peak_amp ThF ThF * possible_half])
        %end
        % Does not meet morphology; check for artefact poisoning
        artefact_poisoning = logical(0);
        if (qrs_count > 8 & sum(qrs_messy(qrs_count-7:qrs_count))>0 & (k - peak_index > 2*fs)),
            % An artefact recently stopped the algorithm from detecting QRS complexes for 2 seconds
            artefact_poisoning = logical(1);
        end
        if length_artefact > 3 & qrs_count > 8 & sum(qrs_messy(qrs_count-7:qrs_count-1))>0,
            % A somewhat recent artefact has occurred, and now morphology problems exist
            artefact_poisoning = logical(1);
        end
        if artefact_poisoning,
            ap_count = ap_count+1;
            start_point_artefact(ap_count) = k;
            if ap_count > 2,
               if (k - start_point_artefact(ap_count-2)) < 300*fs,
                   % This has been called twice in the last 5 minutes
                   artefact_poisoning = logical(0);
               end
            end
        end
        if artefact_poisoning,
           % An artefact occurred recently: reset everything, if possible
           if length(data)-peak_index > 300*fs,
              if morph_verbose
                  !echo Artefact area has caused problems. Reloading data....
                  format bank
                  disp([t(k) k A2]);
              end
              old_tk = t(k);
              archived_x = x; archived_mwi = mwi; archived_bpf = bpf; archived_len = len;
              archived_k = k; archived_dff = dff; 
              x = data(k:end); lp1;
              % Now that it is reset, reload the data to continue:
              x = archived_x; mwi = archived_mwi; bpf = archived_bpf; len = archived_len;
              dff = archived_dff;
              % As a bonus, get to skip over some data:
              k = archived_k + learn_range(end/2); % Cannot start at beginning of learn_range, b/c MWI lags BPF
              if morph_verbose,
                  disp(['Skipped: ' num2str(old_tk) ' to ' num2str(t(k))]);
              end
              peak_index = k-round(fs); % Cannot use A2*256, as this can be a poor estimate (e.g., 3100, ECG1, backwards, sends the algorithm too far back and duplicates findings)
              last_peak = peak_index;
              % Morph re-initialisations:
			  morph_first_time = logical(1); % So that the morphology checker in classify_peak.m can restart
			  positive_streak = logical(1); % Again, for morph_check.m
			  artefact_region = logical(0); % For 'messy' variable, plus debugging purposes
           end
           artefact_poisoning = logical(0);
        end
        next_k = peak_index + round(refractoriness/2);
    end
else
    % It is noise 
    % Note this is the H&T definition of noise, i.e., of low amplitude.
    % High amplitude noise is dealt with above in morph_check.m
    noise_count = noise_count+1;
    noise_amp(noise_count) = peak_amp;
    noise_index(noise_count) = peak_index;
    recent_NPKI = [recent_NPKI(2:8); mwi(fid_pt(fp))];
    recent_NPKF = [recent_NPKF(2:8); peak_amp];
    NPKI = median(recent_NPKI);
    NPKF = median(recent_NPKF);
    next_k = peak_index + round(refractoriness/2);
end

% Update thresholds
ThI = NPKI + threshold_coefficient * (SPKI - NPKI);
ThF = NPKF + threshold_coefficient * (SPKF - NPKF);


% Prepare k for continuation down the ECG
last_k = peak_index; k = next_k;

