% Learning Phase 0: Check lead inversion (performed only once, unlike lp1 for some patients)

x = x(1:ceil(len/2));
ecg_preprocess; 
find_clean_section; 
bpf = bpf(learn_range); mwi = mwi(learn_range);


if (exist('inverted')==1)
  ric = inverted;
else
  if (verbose)
    !echo Estimating inversion
  end
  [ric, the_max1, the_min1] = robust_inversion_check(bpf); % 2nd and 3rd parameters used just to override ric
end

if (ric == -1)
  %!echo Inverted ECG.
  data = -data; 
  x = -x;
elseif (ric == 0)
  skip_ecg = 1;
  if (1 == 0) 
    beeps;
    inverted = input('Enter 1 or -1 for positive or negative QRS deflection, 0 to cancel: ');
    ric = inverted;
    if ric ~= 0,
      skip_ecg = 0;
    end
    !echo Continuing the calculations
  end
  if (1 == 1)
    if the_max1>-the_min1,
      inverted = 1;
    else
      inverted = -1;
    end
    ric = inverted;
    skip_ecg = 0;
  end
end
