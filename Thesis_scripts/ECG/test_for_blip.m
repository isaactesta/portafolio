% Good for long periods of poor ECG where some false beats picked up; e.g. 3012, 3013, etc.
if k < length(qrs_times),
   if (max(RR(k-2:k-1)) > 4 & RR(k) > 2) | (RR(k-1) > 2 & RR(k) > 4),
      %disp(qrs_times(k)), pau
      if verbose,
          K = k; blip_kill
      end
      over_erasure_check = 1;
      erased_beats_strin = [erased_beats_strin qrs_times(k)];
      beats_destroyed = beats_destroyed + 1;
      destruction(beats_destroyed) = qrs_times(k);
      qrs_times = [qrs_times(1:k-1); qrs_times(k+1:end)];
      qrs_messy = [qrs_messy(1:k-1); qrs_messy(k+1:end)];
      k = k - 1;
   end
end