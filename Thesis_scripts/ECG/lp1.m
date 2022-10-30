% Learning Phase 1 for find_qrs_peaks_mark.m
% Operates on the data contained in vector x

%verbose = logical(1);
ecg_preprocess; 
find_clean_section;
bpf = bpf(learn_range); 
mwi = mwi(learn_range);

[SPKF, Si] = max(bpf); SPKI = max(mwi); NPKF = 0.2 * SPKF; NPKI = 0.2 * SPKI;
recent_SPKF = ones(8,1)*SPKF; recent_NPKF = 0.2 * recent_SPKF;
recent_SPKI = ones(8,1)*SPKI; recent_NPKI = 0.2 * recent_SPKI;
ThF = recent_NPKF(1) + 0.189*(recent_SPKF(1)-recent_NPKF(1));
ThI = recent_NPKI(1) + 0.189*(recent_SPKI(1)-recent_NPKI(1));

% New for P&T: adjust integration width
k = Si; forward_wait = 0;
while (k < length(bpf) & bpf(k) > 0)
   k = k + 1;
end

if k < length(bpf)
  Si_end = k;
else
  forward_wait = 1;
end

k = Si;
while (k > 1 & bpf(k) > 0)
  k = k - 1;
end

if (k > 1)
  Si_start = k;
else
  Si_start = Si - (Si_end - Si);
end

if (forward_wait == 1)
  Si_end = Si + (Si - Si_start);
end

typical_width = (Si_end - Si_start)*1.1; % 1.1 because zero-crossing not quite accurate
tw = typical_width / fs;
if tw > 0.12, % 120ms is a normal's widest
  if verbose, 
    !echo Wide QRS complexes detected. 
  end
  typical_width = typical_width * 1.5; % An extra boost doesn't hurt
  tw = round(typical_width / fs);
  wl_n = round(typical_width*4/3); % 4/3 = 160/120
  cl_n = round(wl_n*175/160);
  nsr_start = -round(225/160*wl_n); nsr_end = -round(125/160*wl_n);
  asr_start = -round(250/175*wl_n); asr_end = -round(150/175*wl_n);
  refractoriness = max (refractoriness, typical_width);
  probation = max(refractoriness+80, probation);
end