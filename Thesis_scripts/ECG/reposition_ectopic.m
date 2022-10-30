% Deal with an ectopic: destroy and reposition

if yes_reposition & k < length(qrs_times)-1,
	new_time = (qrs_times(k+2)+qrs_times(k))/2;
	if verbose,
       eval (['!echo ' num2str(qrs_times(k)) ': Ectopic at ' num2str(qrs_times(k+1)) ' moved to ' num2str(new_time) '.']);
	end
	beats_destroyed = beats_destroyed + 1;
	beats_restored = beats_restored + 1;
	destruction(beats_destroyed) = qrs_times(k+1);
	restoration(beats_restored) = new_time;
    erased_ectopics_strin = [erased_ectopics_strin qrs_times(k+1)];
    restored_ectopics_strin = [restored_ectopics_strin new_time];
	qrs_times = [qrs_times(1:k); new_time; qrs_times(k+2:end)];
    % Label next 2.6 seconds (60/70*3, as per Malik I believe) as messy
    % However, 2.6 can be reduced to 1.8, since preprocess will extend the range by approx one beat, later
    time_k = k+1;
    while time_k < length(qrs_times) & qrs_times(time_k) < (1.8+qrs_times(k+1)),
        qrs_messy2 = [qrs_messy2; qrs_times(time_k)];
        time_k = time_k + 1;
    end
    %time_from_now = time_k-(k+1);
    %if length(qrs_messy)-k > time_from_now,  % Before 16 June, this was the way to identify artefact.  qrs_messy2 used instead, to avoid skipping easy problems immed after ectopics (eg 3134, near 140)
    %	qrs_messy = [qrs_messy(1:k); ones(time_from_now,1); qrs_messy(k+time_from_now+1:end)];
    %end
    over_repositioning_check = 3;
else
    if verbose,
       %eval (['!echo ' num2str(qrs_times(k)) ': Ectopic at ' num2str(qrs_times(k+1)) ' will not be moved, either because of its preceding beats or because it is too close to the end.']);
	end
end