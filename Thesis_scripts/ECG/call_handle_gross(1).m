% Used in preprocess.m

% a) Run the handle_gross routines
handle_gross; d1 = destruction; r1 = restoration;
handle_gross; destruction = sort ([d1; destruction]); restoration = sort ([r1; restoration]);

% b) Label ectopics and CRS as beats to avoid
RR_test = diff(qrs_times);
beat_ratios = [RR_test; RR_test(end)] ./ [RR_test(1); RR_test];
u = find(beat_ratios > 1.2 | beat_ratios < 0.8);
qrs_messy(u) = 1;