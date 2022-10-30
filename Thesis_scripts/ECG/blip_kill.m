% Called by handle_gross

eval (['!echo ' num2str(qrs_times(k)) ': ' num2str(beater-1) ' blip at ' num2str(qrs_times(K)) ' removed, denom = ' num2str(denom) '.']);
ee = min (11, k-1);
if k-ee>0,
    qee = qrs_messy(k-ee:k+1);
    if sum (qee) > 0,
       format bank
       disp([[RR(k-ee:k+1) qee qrs_times(k-ee:k+1)]]);
    end
end