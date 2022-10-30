% Wrapper file for Mark Ebden's QRS Detector
% October 2004

% 1. Select ECG in one of two ways
if 1==0,
   % A) If you want to use SMP data directly:
   ecg = 0;
   pat_no = 3154; % Set patient number
else
   % B) If you want to use your own ECG data, uncomment the next line
   %ecg = (your mx2 ECG matrix, sampled at 256 Hz)
   %      The first column is the timestamps mesaured in seconds.
   %      The second column is the electric potential in arbitrary units.
   ecg = easy_ecg (256, 600);   % Simple artificial ECG
   pat_no = 0;
end

% 2. Create RR time series
!echo sample_usage.m First Step: Find QRS peaks.

[qrs_times, amp, qrs_messy] = find_qrs_peaks_mark (ecg, pat_no);

!echo sample_usage.m Second Step: Process results.

[hr, t, rej, qrs_times, qm, d, r] = preprocess (qrs_times, qrs_messy, 3);
    
% 3. Graph the results
!echo sample_usage.m Third Step: Graph results.
u2 = find (rej == 0); u = find (rej > 0);
new_fig
plot (t(u2), 60*hr(u2),'k.')
plot (qrs_times, 40*ones(size(qrs_times)), 'b.')
plot (t(u), 40*rej(u), 'y.')
plot (t(u), 60*hr(u), 'y.')

