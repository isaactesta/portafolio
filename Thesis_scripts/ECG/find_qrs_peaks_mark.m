%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Description:
% A QRS detector based upon the algorithm of Pan, Hamilton and Tompkins:
%
%   1. J. Pan \& W. Tompkins - A real-time QRS detection algorithm 
%   IEEE Transactions on Biomedical Engineering, vol. BME-32 NO. 3. 1985.
%   2. P. Hamilton \& W. Tompkins. Quantitative Investigation of QRS 
%   Detection  Rules Using the MIT/BIH Arrythmia Database. 
%   IEEE Transactions on Biomedical Engineering, vol. BME-33, NO. 12.1986.
%
% NOTES:
% Gari Clifford's original version did not contain:
% Refractory period, adaptive thresholding of any sort (mean, median, or
% iterative), probationary period (200 - 360 ms), or RR interval averaging
% of either type, or paired thresholding (two sets, one for BPF data and
% one for MWI data - just MWI data are thresholded, then the maxima are
% found in the BPF data).
%
% Written by M. Ebden (mebden@robots.ox.ac.uk)
% Special thanks to G. Clifford (gari@robots.ox.ac.uk) for original code
% (C) Oxford University 2004
%
% USAGE:
% [qrs_times, qrs_amp, qrs_messy] = find_qrs_peaks_mark (ecg, pat_no, inverted)
%       ecg = 256-Hz data in an mxn matrix
%             n >= 2, i.e. ecg has at least two columns
%             (first is time vector in seconds, subsequent columns are ECG voltages)
%    pat_no = Falls Clinic patient number
%             (optional; if it is included, and ecg is 1x1, then ECG is loaded elsewhere)
%  inverted = 1 if QRS have positive deflection, -1 if negative (optional)
% qrs_times = an event series of QRS timings, in seconds
%   qrs_amp = the amplitudes of the QRS complexes identified in qrs_times
% qrs_messy = 0's and 1's indicating the confidence of QRS complexes
% NB: When a QRS complex is labelled as 'messy' (=1), a region of artefact
% ended immediately before it.  The region began around the time of the previous
% beat, which should be ignored, and often, one or two beats prior to that one
% should be ignored as well.  The current beat can be considered valid in
% the majority of circumstances.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [qrs_times, qrs_amp, qrs_messy] = find_qrs_peaks_mark (ecg, pat_no, inverted,srate)
samp_freq=srate;%--> change sampling rate i add it Maria Anastasiadou

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% 2. Initialisations  %%%%%%%%%%%%%%%%%%%%%%%%%

fqpm_graphing = logical(0);          verbose = logical(0);
if verbose,
    !echo Finding QRS peaks....
end
if exist('pat_no') == 0,
    pat_no = 0;
end
ht_init % Loads initialisations for this file
if pat_no > 0 & size(ecg)==[1 1],
    load_ecg
else
    ecg_number = 1;
end
%u = find(ecg(:,1) > 1800 & ecg(:,1) < 2300); ecg = ecg(u,:); % Truncate
data = ecg(:,ecg_number+1); t = ecg(:,1);
x = data; len = length(x);
if verbose,
    eval (['!echo Patient ' num2str(pat_no) ': ECG of approximately ' num2str(round(len/samp_freq/60)) ' minutes.']);
end
if ~prox(diff(t([1 2])), 1/samp_freq, 20) | len < 256*360,
    skip_ecg = 1;
    !echo Ensure ecg is an mx2 matrix, with the first column comprised of 256-Hz
    !echo timestamps measured in seconds.  Length should be more than five minutes.
else
    skip_ecg = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% 3. Preprocess the data %%%%%%%%%%%%%%%%%%%%%%%%%%

% Part (a): 'Learning phases' - thoughtful initialisations that
%           prepare the algorithm

% Learning phase 0: Check lead inversion
if skip_ecg == 0,
    lp0
end
if skip_ecg == 1,
    !echo Cannot analyse this ECG without making a change to the code. Stop here.
    qrs_times = [];
    qrs_amp = [];
    qrs_messy = [];
else
    % Learning phase 1: Initialise thresholds etc.
    if verbose,
        !echo Learning ECG morphology....
    end
    lp1
		
	% Learning phase 2: Cancelled for now, integrated in #4 below slickly
	recent_A1 = zeros(8,1);
		
	% Part (b): For the remainder of the program
	if verbose,
            !echo Preprocessing data using morphology information....
	end
	x = data;
	p_and_t_preprocess
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%% 4. Peak Detection and Decision Rules %%%%%%%%%%%%%
	
	% Easy initialisations
	normal_search_range = nsr_start:nsr_end; abnormal_search_range = asr_start:asr_end;
	if pat_no ~= 3149,
            k = -asr_start+1; % 3149 route diverted with this if statement on 19 May 2004, b/c of patient 16265
	else
            k = -asr_start+1+learn_range(1); % added learn_range in Nov 03 b/c of patient 3149
	end
	
	last_k = -refractoriness; last_peak = 0;
	qrs_count = 0; noise_count = 0; possible_half = 1; saved_q = 0; tk_n = 1;
	fp = 0; fid_pt = zeros(round(len/samp_freq*3),1); last_fp = 0;
	qrs_amp = fid_pt; qrs_index = fid_pt; noise_amp = fid_pt; noise_index = fid_pt; qrs_messy = fid_pt;
	ardl = [];
    
	% Loop through the entire ECG:
	if verbose,
            !echo Detecting QRS complexes....
	end
	while k < len-wl_n-1,
            k=k+1;
            time_keeper = k/(samp_freq*600);
            if (time_keeper>tk_n),
                if verbose,
                    disp(['  ' num2str(round(time_keeper*10)) ' minutes and ' num2str(qrs_count - saved_q) ' beats processed.']) % Every ten minutes
                end
                saved_q = qrs_count; tk_n = tk_n + 1;
            end
            % Check to see if MWI Threshold was reached
            if mwi(k) > ThI*possible_half & (k-last_k) > refractoriness,
               j = 1; max_mwi = mwi(k+j); too_long = 0;
               % Check to see if the halfway point in the descent was reached
               while (k+j<len) & (mwi(k+j) > 0.5 * max_mwi) & (too_long == 0),
                 j = j + 1;
                 if mwi(k+j)>max_mwi,
                    max_mwi = mwi(k+j);
                    % Ensure it isn't artefact:
                    if max_mwi > 10 * SPKI,
                        % Artefact: take k over the hill without recognising any beats
                        % disp(['   Artefact: ' num2str([t(k+j) SPKI max_mwi])])
                        k = k + j; j = 1;
                        while (k<len) & (mwi(k) > ThI*0.95),
                            k = k + 1;
                        end
                        last_fp = k; % This is for the benefit of the 1.66 checker
                    end
                 end    
                 % Check to see if too much time has passed
                 if j > cl_n,
                    if 0 & last_fp>0 & t(round(k+j))-t(round(last_fp))>1.7*A2, % very useful, e.g. 16272 at 2480 seconds
                        too_long = 1;
                        %disp([ThI k j t(k) t(k+j) mwi(k+j)])
                        sr = abnormal_search_range;
                        find_bpf_peak
                    end
                 end
               end
               if too_long == 0 & j > 1, % j>1 test b/c of artefact possibility
                 % The halfway point was indeed reached
                 sr = normal_search_range;
                 find_bpf_peak
               end
            
            else
               % Ensure 166% of RR interval estimate has not passed
               if recent_A1(1) == 0,
                 u = find(recent_A1>0);
                 if sum(u) > 0, % This if statement avoids warnings about divide by 0
                    A2 = mean(recent_A1(u))/samp_freq;
                 end
               end
               if recent_A1(7) > 0,
                 %disp ([A2 k last_k]);
                 if (((k-last_k)/samp_freq) > 1.66 * A2)
                   %disp ([A2 t(k)])
                   the_count = qrs_count;
                   sk = round(last_k+refractoriness);
                   k_range = sk:k;
                   max_mwi = max(mwi(k_range));
                   if max_mwi > ThI*0.3,
                     possible_half = 0.3;
                     [peak_amp, peak_index] = max(bpf(k_range));
                     peak_index = peak_index + sk - 1;
                     %format bank; disp([t(last_k) t(sk) t(k) peak_amp ThF last_fp k ThI*0.3]);
                     classify_peak
                     %!echo 
                   end
                   if qrs_count == the_count,
                      % 1.66 x A2 have passed, but no beat has been found
                      % Leave a refractory period because of sk later on.
                      last_k = k-refractoriness; last_fp = k;
                      % Note if last_k = k, we miss beats near the 1.66 border
                      % These 2 lines debugged that problem:
                      %format bank; disp([t(k) peak_amp ThF ThI max_mwi last_fp last_k]);
                      %figure; plot (t,mwi/max_mwi,'k'); hold on; plot (t,bpf,'r');
                   end
                 end
               end
            end
	end
	if verbose
        if ardl ~= [],
           eval (['!echo Artefact region designation lifted at these points:' num2str(ardl)]);         
        end
        disp(['  ' num2str(round(time_keeper*10)) ' minutes and ' num2str(qrs_count - saved_q) ' beats processed.'])
	end
	
	% Eliminate trailing zeros
	fid_pt = fid_pt(find(fid_pt>0));
	qrs_index = qrs_index(find(qrs_index > 0));
	qrs_amp = qrs_amp(find(qrs_index > 0));
	qrs_messy = qrs_messy(find(qrs_index > 0));
	noise_index = noise_index(find(noise_index > 0));
	noise_amp = noise_amp(find(noise_index > 0));
	qrs_times = t(qrs_index);
	if length(qrs_times)~=length(qrs_messy),
           !echo Length mismatch
           disp([length(qrs_times) length(qrs_messy)]);
           pause
	end
	sq_t = sort(qrs_times);
	if qrs_times ~= sq_t | sum(diff(sq_t)==0)>0,
          !echo Poor QRS:
          for lqq = 2:length(qrs_times),
            if qrs_times(lqq) <= qrs_times(lqq-1),
                if lqq > 5 & lqq < length(qrs_times)-5,
                    disp([lqq-1 lqq qrs_times(lqq-4) qrs_times(lqq-3) qrs_times(lqq-2) qrs_times(lqq-1) qrs_times(lqq) qrs_times(lqq+1) qrs_times(lqq+2) qrs_times(lqq+3) qrs_times(lqq+4)]);
                else
                    disp([lqq-1 lqq qrs_times(lqq-1) qrs_times(lqq)]);
                end
            end
          end
          !echo Some QRS times are not in their proper order, or are duplicated.  Press any key
          pause
          u = find(diff(sq_t)>0);
          qrs_times = sort(sq_t(u));
	end
	
	if verbose,
          disp([num2str(length(qrs_times)) ' QRS complexes detected.'])
          !echo
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%% 6. Plot the graphs %%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if fqpm_graphing,
          if verbose,
            !echo Plotting results....
          end
          figure; subplot(2,1,1); hold on
          plot (t,bpf,'k-');
          plot (t(fid_pt'),bpf(fid_pt'),'b.');
          plot (t(qrs_index'),bpf(qrs_index'),'r.');
          plot (t(noise_index'),bpf(noise_index'),'c.');
          tm = find (qrs_messy>0);
          plot (qrs_times(tm),ones(length(tm)),'g.');    
          title (num2str(pat_no));
          ylabel ('bpf for fqpm')
        
          subplot(2,1,2);hold on
          plot (t,mwi,'k-');
          plot (t(fid_pt'),mwi(fid_pt'),'b.');
          plot (t(qrs_index'),mwi(qrs_index'),'r.');
          plot (t(noise_index'),mwi(noise_index'),'c.');
        
          %     reaxis (160, 205)
	end
	
	%if pat_no < 3300 & pat_no > 0,
	%   !echo Saving data....
	%   eval(['save /data/smp/processing/mark/tachograms/ebden/''' num2str(pat_no) ''' qrs_times qrs_amp qrs_messy;']);
	%end
end
