% Input: data is a 2-s segment of the ECG
% Output: invd is 1 if not inverted, -1 if inverted, 0 if not sure.

function invd = robust_inversion_check (data, pat_no);

%ecg0 = ecg;
not_done = logical(1);
attempts = 0;
while not_done & attempts < 3,
        
	inv_verbose = logical(1);
	not_done = logical(0);
	% Prepare data
	samp_freq = 256;
	x = data;
	if exist('pat_no') ~= 0,
		initialisations; u = find(t>quiet_time(1));
		xst = u(1);
	else
                xst = 1;
	end
        the_range = (xst:xst+samp_freq*300)+attempts*samp_freq*300;
	x = x(the_range);
	
	x = x-mean(x); len = length(x); min_data = min(x);
	freq_range = [0.5 35];
	Wn = (freq_range)/(samp_freq/2); b = fir1(100,Wn,'bandpass');
	bpf = filtfilt(b,1,x);
	
	find_clean_section_for_invc
	bpf = bpf(learn_range);
        ecg = bpf;
	
	% Check inversion
	samp_freq = 256;
	d = length(ecg);
	if d < samp_freq*2,
           !echo Fatal problem: Clean section is not two seconds
           pau
           break
	elseif d > samp_freq*2,
           !echo Trimming ecg input....
           ecg = ecg(1:samp_freq*2);
	end
	
	[the_max1 max_index1] = max(ecg);
	[the_min1 min_index1] = min(ecg);
	if the_max1 > -the_min1,
           the_guide = the_max1;
	else
           the_guide = -the_min1;
	end
	
	%figure;
	plot (ecg); hold on;
	if the_max1>-2*the_min1,
          if(inv_verbose)
            !echo Not inverted, based on R
          end
          invd = 1;
	elseif -the_min1>2*the_max1,
          if(inv_verbose)
            !echo Inverted, based on R
          end
          invd = -1;
	else
          if the_guide == the_max1,
        	[the_max2 max_index2] = max(ecg(1:samp_freq));
          else
            [the_min2 max_index2] = min(ecg(1:samp_freq));
            the_max2 = -the_min2;
          end
        
	  if the_guide>1.2*the_max2 & max_index1<samp_freq*1.5,
            if(inv_verbose)
               !echo Interesting ECG
               disp([the_max1        the_max2]);
               %figure; plot (ecg, 'r'); hold on;
            end
            [the_max2 max_index2] = max(ecg);
          end
		
	  start1 = max_index2+round(0.14*samp_freq);
	  end1 = max_index2+round(0.24*samp_freq);
	  max_concavity = -1e6; min_concavity = 1e6;
          minn = 0; maxn = 0;
	  for k = start1:end1,
            window1 = k:k+round(0.16*samp_freq);
            lw = length(window1);
            P = polyfit (1:lw,ecg(window1)',2);
            concavity = P(1);
            if concavity > max_concavity,
                max_concavity = concavity;
                maxn = k+round(lw/2);
            end
            if concavity < min_concavity,
                min_concavity = concavity;
                minn = k+round(lw/2);
            end
	  end
          if inv_verbose,
    	     format short; disp([max_concavity min_concavity maxn minn])
             plot (maxn, 0, '.r'); plot (minn, 0, '.k');
          end
	  if max_concavity>-1.7*min_concavity & max_concavity > 0.0001,
            if(inv_verbose)
                !echo Inverted, based on T
            end
            invd = -1;
          elseif -min_concavity>1.7*max_concavity & min_concavity < -0.0001,
            if(inv_verbose)
                !echo Not inverted, based on T
            end
            invd = 1;
          else
            if(inv_verbose)
                !echo Not sure
                not_done = logical(1);
                attempts = attempts + 1;
                hold off
            end
            invd = 0;
          end
        end
 	if invd == 1,
          yo = pat_no;
	elseif invd == -1,
          yo = pat_no + 0.1;
	else
          yo = pat_no + 0.2;
	end
end
hold on; title([yo])
