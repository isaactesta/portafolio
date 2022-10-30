function [qrs_times, i] = RR (e)
% Example usage of the QRS detector
% - e is an mx2 ECG vector (first column is time stamps, second data)
% - qrs_times is the list of QRS times, in seconds
% - these occur approximately at indices i within the e matrix's first column

t = e(:,1); x = e(:,2);
T = (t(1,1):1/200:t(end))'; X = interp1 (t, x, T);
ecg = [T X];
[qrs_times, amp, qrs_messy] = find_qrs_peaks_mark (ecg, 0);
[hr, t2, rej, qrs_times, qm, d, r] = preprocess (qrs_times, qrs_messy, 3);
i = zeros(size(qrs_times));
for k = 1:length(qrs_times),
  [the_min, i(k)] = min(abs(t-qrs_times(k)));
end

