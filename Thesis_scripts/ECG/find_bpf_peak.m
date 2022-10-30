% MWI fiducial mark index is simply j+k:
% Now find peak in BPF data
fp = fp + 1; fid_pt(fp) = j + k;
max_bpf = min_data; max_m = 1;
for m = sr+j+k,
   if bpf(m) > max_bpf,
      max_bpf = bpf(m);
      max_m = m;
   end
end

% Now find centre of mass instead!
wh = round(wl_n/2);
if max_m < len-wh,
    cstart = max(max_m-wh,1);
    CoM_range = cstart:(max_m+wh);
    CoM_sum = CoM_range*bpf(CoM_range);
    CoM = round(CoM_sum/sum(bpf(CoM_range)));
    %if abs(CoM-max_m)>100,
    %    !echo Differential between mean and CoM
    %    max_m
    %    pau
    %end
end

% Timing check: refractoriness and T wave slope, where applicable
meets_timing = 0;
if max_m > last_k + refractoriness,
    if max_m > last_k + probation | qrs_count == 0,
        meets_timing = 1;
    else
        if max_m <= length(dff) & last_k <= length(dff) & max_m-wl_n/2 > 0 & last_k-wl_n/2 > 0,
            % Compare slope of possible T wave with previous QRS complex
            Tslope_range = round(max_m-wl_n/2):max_m;
            QRSslope_range = round(last_k-wl_n/2):last_k;
            Twave_slope = max(dff(Tslope_range)); QRS_slope = max(dff(QRSslope_range));
            if Twave_slope > 0.5 * QRS_slope,
                meets_timing = 1;
            end
        else
            meets_timing = 1;
        end
    end
end

if meets_timing == 1,
    %disp([1 t(max_m)])
    peak_index = max_m; peak_amp = max_bpf;
    classify_peak
else
    %disp([0 t(max_m)])
end

