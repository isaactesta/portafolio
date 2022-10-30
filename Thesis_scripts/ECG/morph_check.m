% Morph_check
% Called by classify_peak.m
% Mark Ebden, Nov 2003

morph_verbose = logical(0);

messy = 0;
m_start = peak_index-round(typical_width*5);
m_end = peak_index+round(typical_width*5);
if m_start < 1 | m_end > length(bpf),
      % Beginning or end of the time series
      meets_morphology = 1;
else
      % The usual case: classify morphology properly
      morph_region = bpf(m_start:m_end);
      meets_morphology = 0;
	
      if morph_first_time, % First beat always passes morphology test
        old_morph_region = morph_region;
        old_morph_prod = cov(morph_region,old_morph_region); old_morph_prod = old_morph_prod (2,1);
        morph_first_time = logical(0);
        num_seconds = 0;
      end
      morph_prod = myCorr(morph_region,old_morph_region);
      %morph_prod = cov(morph_region,old_morph_region); morph_prod = morph_prod(2,1);
      %if prox (morph_prod, old_morph_prod, 15),
      if morph_prod > 0.5,
          % Reasonable correlation
          if peak_amp < 3*SPKF,
            % Good amplitude
            meets_morphology = 1;
            %!echo Good beat
            % disp([t(peak_index) morph_prod old_morph_prod])
            if artefact_region,
                messy = 1; artefact_region = logical(0); 
                if length_artefact < 2,
                    % Only one beat in the region
                    messy = 2;
                end
                if morph_verbose,
                    !echo Back to regular rhythm
                    disp([t(peak_index) morph_prod old_morph_prod])
                end
                length_artefact = 0;
            end
            positive_streak = logical(1); num_seconds = 0;
            %if prox (morph_prod, old_morph_prod, 5),
            if morph_prod > 0.75 | beats_since_last_update > 4, % Used to be 6 beats, but 3146 misses too many, eg at about 55
                % Excellent correlation, hence, use this QRS as the model to test the next
                old_morph_prod = morph_prod; old_morph_region = morph_region;
                beats_since_last_update = 0;
            else
                beats_since_last_update = beats_since_last_update + 1;
            end
          end
      else
          if morph_verbose,
            !echo Failed morphology check
            disp([t(peak_index) morph_prod old_morph_prod positive_streak])
          end
          if (positive_streak & morph_prod > 0.3) | morph_prod > 0.43,
            % Either a first offender, with not too terrible correlation, or
            % correlation even better but not a first offender
            positive_streak = logical(0);
            % Give it a second chance: look up to 1.2 s ahead in the time series
            % for an upcoming good correlation
            mk = round(fs/5); morph_prod_max = 0;
            final_mk = round(fs*1.2);
            if final_mk+peak_index+round(typical_width*5) < length(bpf), 
                while mk < final_mk,
                    mk = mk + 1;
                    m_start = peak_index+mk-round(typical_width*5);
                    m_end = peak_index+mk+round(typical_width*5);
                    new_morph_region = bpf(m_start:m_end);
                    morph_prod = myCorr(new_morph_region,morph_region);
                    %morph_prod = cov(morph_region,old_morph_region); morph_prod = morph_prod(2,1);
                    %if prox (morph_prod, old_morph_prod, 15),
                    if morph_prod > morph_prod_max,
                        morph_prod_max = morph_prod;
                        mk_max = mk;
                    end
                end
                morph_prod = morph_prod_max;
                mk = mk_max;
                if morph_prod > 0.8, % Used to be 0.5, changed for 3178.....
                    morph_prod2 = myCorr(morph_region,old_morph_region);
                    if morph_prod2 > 0.3,
                        if artefact_region,
                            messy = 1;
                        end
                        meets_morphology = 1;
                        if morph_verbose,
                            !echo Second chance granted because of this upcoming beat:
                            disp([t(peak_index+mk) morph_prod2 morph_prod old_morph_prod num_seconds])
                        end
                        num_seconds = num_seconds+1;
                        if num_seconds > 2,
                            old_morph_region = morph_region;
                            old_morph_prod = morph_prod;
                            num_seconds = 0;
                        end
                        mk = final_mk+1;
                    end
                    if morph_verbose,
                        pau
                    end
                end
            end
            if mk == final_mk,
                if morph_verbose,
                    !echo Second chance denied
                    disp([t(peak_index) morph_prod old_morph_prod])
                end
                length_artefact = length_artefact+1;
                
            end
        
        else
            % This is truly an artefact region
            if ~artefact_region,
                if morph_verbose,
                    !echo Artefact region begins
                    mk = round(fs/5);
                    disp([t(peak_index+mk) morph_prod old_morph_prod])
                end
                artefact_region = logical(1);
            end
            length_artefact = length_artefact+1;
            messy = 1; % Newly added
        end
      end
end
