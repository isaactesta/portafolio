%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% THE QRS TIME SERIES TIDIER
%
% File: handle_gross.m
% Author: Mark Ebden
% Date: 2003
%
% DESCRIPTION
% Inputs a series of QRS times (qrs_times) and, optionally,
% an index of which QRS times are deemed problematic (qrs_messy).
%
% USAGE
% Usage is usually as follows at the Matlab prompt:
% handle_gross; handlegross
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CHANGE SINCE LAST RUN ON FC:
%   - Added an aggresive blip remover (appears in 2 spots below, test_for_blip)

verbose = logical(0);
destruction = []; restoration = []; warning off;
k = 0; history_beats = 10;
beats_restored = 0;
beats_destroyed = 0;
alternating_check = 0; over_erasure_check = 0; over_repositioning_check = 0;
qrs_messy2 = []; denom = 0; denom_beats = zeros(history_beats,1);
if exist('reposition_allowed') == 0,
    reposition_allowed = logical(1);
end
RR = diff(qrs_times); % _Needed_ once at beginning, then updates later on

if verbose,
    !echo Removing simple problems from the tachogram....
end
if length(qrs_times) ~= length(qrs_messy),
    if verbose,
        !echo Ignoring qrs_messy.
    end
    qrs_messy = zeros(size(qrs_times));
end
while k < length(qrs_times)-2,
  k = k + 1;
  if k > length(qrs_messy), % Should not occur
      disp ([k      length(qrs_messy)      length(qrs_times)])
  end
  if alternating_check == 0,
      doubled_beats_check = [];
  elseif length (doubled_beats_check) > 3,
      if mean(diff(doubled_beats_check)) < 1.5, % Ensure the new HR will be realistic (won't be slower than 40 bpm)
          % Algorithm is inventing its own heart rate, at twice the real heart rate
          if verbose,
              eval (['!echo ' num2str(qrs_times(k)) ': Reducing heart rate by half, by erasing these beats: ' num2str(doubled_beats_check) '.']);
          end
          lak = length(doubled_beats_check);
          for ak = 1:lak,
              qrs_messy = qrs_messy (find (qrs_times~=doubled_beats_check(ak)));
              qrs_times = qrs_times (find (qrs_times~=doubled_beats_check(ak)));
          end
          k = k - lak; % Used to leave this line out to move along out of here, so that CSM patients don't suffer; used to use next line
          %k = k + 3; % But this line causes problems in 3100 around 10 seconds, and other problems; too many poor beats are skipped
          beats_restored = beats_restored - lak;
          restoration = restoration(1:end-lak);
          doubled_beats_check = [];
      else
          if verbose,
              eval (['!echo ' num2str(qrs_times(k)) ': Will not reduce heart rate here.']);
          end
          doubled_beats_check = [];
      end
  end
  alternating_check = max(alternating_check-1, 0); % Needed for 3177 for example.
  
  if over_erasure_check == 0,
     erased_beats_strin = [];
  elseif length (erased_beats_strin) > 3,
      % Algorithm may be inventing its own heart rate, at half the real heart rate
      % First check to see how bad the time series would be if we reinserted the beats
      for er_k = 1:3,
          min_er_dist(er_k) = min(erased_beats_strin(er_k)-qrs_times);
      end
      if min(min_er_dist) < 0.43, % Fine unless patient's heart rate exceeds 140 bpm
          if verbose,
              eval (['!echo ' num2str(qrs_times(k)) ': Will not double heart rate here.']);
          end
          erased_beats_strin = [];
      else
          if verbose,
              eval (['!echo ' num2str(qrs_times(k)) ': Doubling heart rate by restoring these beats: ' num2str(erased_beats_strin) '.']);
          end
          lak = length(erased_beats_strin);
          p1 = [qrs_times; erased_beats_strin'];
          p2 = [qrs_messy; ones(size(erased_beats_strin))'];
          orig_mat = [p1 p2];
          new_mat = sortrows (orig_mat);
          qrs_times = new_mat (:,1); qrs_messy = new_mat (:,2);
          beats_destroyed = beats_destroyed - lak;
          destruction = destruction(1:end-lak);
          erased_beats_strin = [];
          k = k + lak + 3; % To get out of the area
      end
  end
  over_erasure_check = 0;

  if over_repositioning_check == 0,
      erased_ectopics_strin = [];
      restored_ectopics_strin = [];
  elseif length (erased_ectopics_strin) > 3,
      % Algorithm is maintaining heart rate, but at a different rhythm
      if verbose,
          eval (['!echo ' num2str(qrs_times(k)) ': Undoing ectopic designation by restoring these beats: ' num2str(erased_ectopics_strin) '.']);
      end
      lak = length(erased_ectopics_strin);
      for ak = 1:lak,
          qrs_messy = qrs_messy (find (qrs_times~=restored_ectopics_strin(ak)));
          qrs_times = qrs_times (find (qrs_times~=restored_ectopics_strin(ak)));
      end
      p1 = [qrs_times; erased_ectopics_strin'];
      p2 = [qrs_messy; ones(size(erased_ectopics_strin))'];
      orig_mat = [p1 p2];
      new_mat = sortrows (orig_mat);
      qrs_times = new_mat (:,1); qrs_messy = new_mat (:,2);
      beats_destroyed = beats_destroyed - lak;
      beats_restored = beats_restored - lak;
      destruction = destruction(1:end-lak);
      restoration = restoration(1:end-lak);
      erased_ectopics_strin = [];
      k = k + lak;
  end
  over_repositioning_check = max(over_repositioning_check-1, 0);
  
  saved_denom = denom; advancing = 0;
  start_k = max (1, k-4); end_k = min (k+4, length(qrs_messy)); 
  % Downgraded from 10 & 2 to 4 and 4, not out of any specific trigger
  while(sum(qrs_messy(start_k:end_k)) > 1) & k < length(qrs_times)-1,
      k = k + 1;
      if k > 2,
          RR = diff(qrs_times); test_for_blip % Added this line later to catch a few more blips
      end
      advancing = 1;
      start_k = max (1, k-history_beats); end_k = min (k+2, length(qrs_messy));
  end

  if advancing == 0, % Not much messiness nearby
      RR = diff(qrs_times);
      RR = [RR; RR(end)];
      if k > history_beats,
          denom_beats = RR(k-history_beats:k-1);
      else
          denom_beats = RR(k+1:k+history_beats);
      end
      denom = max (median(denom_beats),60/240);
      denom = min (denom, 60/45);
  else % Messiness prevents reliable estimate
      denom = saved_denom;
  end
  if k>1,
      % Beat-to-beat comparison
      beat_ratio = RR(k) / RR(k-1);
  else
      % Compare current RR to the last 'history' (eg 10) beats
      beat_ratio = RR(k) / denom;
  end
  
  % To test whether ectopics need repositioning, later in the code:
  yes_reposition = logical(0);
  variance_precedent = abs(prctile(denom_beats,20)-prctile(denom_beats,80));
  %median(abs(diff(denom_beats)));
  if k < length(qrs_times) - 2,
      current_deviation = 2*abs((qrs_times(k+2)+qrs_times(k))/2-qrs_times(k+1));
  end
  if current_deviation > 5*variance_precedent & reposition_allowed
    yes_reposition = logical(1);
    if verbose,
        format short
        %disp([floor(qrs_times(k)/1000) mod(qrs_times(k),1000) current_deviation variance_precedent beat_ratio denom_beats' RR(k)]);
    end
  end
  % Now begin the assessment:
  beater = 2;
  if k > 2 & (RR(k) > 2 | RR(k-1) > 2),
      %disp([qrs_times(k) RR(k-1) RR(k) RR(k+1)])
      % Do nothing - the previous beat or two were in a spurious situation
      % But, this beat may even be deleted
      test_for_blip
  elseif prox (beat_ratio, 1, 20) & sum(qrs_messy(start_k:end_k)) > 1,
      % Ignore problematic areas if the region was previously defined as artefact
      qrs_messy2 = [qrs_messy2; qrs_times(k)];
  elseif beat_ratio < 0.8
    % >20% negative deviation occurs from beat to beat
    
    % First check two beats ahead, and reposition the next beat
    % if necessary; next beat is possibly an ectopic!
    if k < length(qrs_times)-2,
      beat_ratio_adjacence = (qrs_times(k+2)-qrs_times(k))/denom/2;
    else
      beat_ratio_adjacence = pi; % Any value outside the range
    end
    if beat_ratio_adjacence <= 1.2 & beat_ratio_adjacence >= 0.8, %Changed from sqrt1.2 and sqrt.8
       % Test against CRS (cardiorespiratory synchronisation):
       if current_deviation > 5*variance_precedent & reposition_allowed,
           yes_reposition = logical(1);
       end
       % If it is an ectopic: destroy and reposition
       reposition_ectopic
    elseif (k < length(qrs_times)-2 & k > 1),
      % Then, reject as artefact only if there exists a ''better'' beat next
      %beater_ratio1 = (qrs_times(k)-qrs_times(k-1))/denom;
      beater_ratio2 = (qrs_times(k+1)-qrs_times(k-1))/denom;
      avg_pos = (qrs_times(k+2)+qrs_times(k-1))/2;
      %if (abs(beater_ratio2 - 1) < abs(beater_ratio1 - 1)) & beater_ratio2 <= 1.2 & beater_ratio2 >= 0.8,
      if (abs(avg_pos-qrs_times(k+1)) < abs(avg_pos-qrs_times(k))) & beater_ratio2 <= 1.2 & beater_ratio2 >= 0.8,
        % The next beat is more plausible!  Erase the current one
        if verbose, K = k; blip_kill; end
        over_erasure_check = 1;
        erased_beats_strin = [erased_beats_strin qrs_times(k)];
        beats_destroyed = beats_destroyed + 1;
        destruction(beats_destroyed) = qrs_times(k);
        qrs_times = [qrs_times(1:k-1); qrs_times(k+1:end)];
        qrs_messy = [qrs_messy(1:k-1); qrs_messy(k+1:end)];
      else
        % This is the most plausible beat out of the two (this and the next),
        % so a future blip should be considered for discarding
        beater = 2;
        first_beater_ratio = (qrs_times(k+beater)-qrs_times(k))/denom;
        while beater < 20 & k+beater < length(RR),
           beater_ratio = (qrs_times(k+beater)-qrs_times(k))/denom;
           if beater_ratio <= 1.3 & beater_ratio >= 0.8,
             % One or more artefacts were inserted between two legit beats
             % Erase them
             if verbose,
                disp([beater_ratio qrs_times(k+beater) qrs_times(k) denom beater])
                K = k + 1;
                blip_kill
             end
             if beater == 2,
                over_erasure_check = 1;
                erased_beats_strin = [erased_beats_strin qrs_times(k+1)];
                %k = k + 1;
             end
             for ee = 1:beater - 1,
               beats_destroyed = beats_destroyed + 1;
               destruction(beats_destroyed) = qrs_times(k+ee);
             end
             qrs_times = [qrs_times(1:k); qrs_times(k+beater:end)];
             qrs_messy = [qrs_messy(1:k); qrs_messy(k+beater:end)];
             beater = 100;
           elseif first_beater_ratio > 1.8, 
             % Erase B(k+1) since B(k+2) is well positioned for interpolation
             if verbose,
                eval (['!echo ' num2str(qrs_times(k)) ': An interesting event at ' num2str(qrs_times(k+1)) ' will be removed and beater is ' num2str(beater) '.']);
             end
             beats_destroyed = beats_destroyed + 1;
             destruction(beats_destroyed) = qrs_times(k+1);
             qrs_times = [qrs_times(1:k); qrs_times(k+2:end)];
             qrs_messy = [qrs_messy(1:k); qrs_messy(k+2:end)];
             beater = 100;
             k = k - 1; % To re-evaluate this section
           end
           beater = beater + 1;
        end 
      end
    end
  elseif beat_ratio > 1.2 & beat_ratio < 10,
    % >20% positive deviation occurs from beat to beat
    
    % Check whether a region labelled as artefact exists here
    %if sum (qrs_messy(k-1:k+3) > 0),
        % Indeed, an artefact area is nearby
        % But what to do?
    %end
    % Now continue with the rest of the program
    
    % First check two beats ahead, and reposition the next beat
    % if necessary; next beat is possibly an ectopic, close !
    if k < length(qrs_times)-2,
      beat_ratio_adjacence = (qrs_times(k+2)-qrs_times(k))/denom/2;%%
    else
      beat_ratio_adjacence = pi; % Any value outside the range 
    end
    if beat_ratio_adjacence <= 1.2 & beat_ratio_adjacence >= 0.8,
       if current_deviation > 5*variance_precedent & reposition_allowed,
           yes_reposition = logical(1);
       end
       % If it is an ectopic: destroy and reposition
       reposition_ectopic
    else
     if k < length(qrs_times)-7,
      % Insert imaginary beat(s) to compensate if a suitable ratio exists
      beater = 1;
      beater_ratio = (qrs_times(k+beater)-qrs_times(k))/denom;%%
      while beater < 7,
        if beater_ratio <= (1.2)^(1/beater)*(beater+1) & beater_ratio >= (0.8)^(1/beater)*(beater+1),
          % Check if the next beat after that does even better:
          beater_ratio2 = (qrs_times(k+beater+1)-qrs_times(k))/denom;
          if abs(beater_ratio2 - 1) < abs(beater_ratio - 1),
             if verbose,
                eval (['!echo ' num2str(qrs_times(k)) ': Beater is boosted.']);
             end
             new_time = (qrs_times(k)*beater + qrs_times(k+2))/(beater+1);
             beats_restored = beats_restored + 1
             restoration(beats_restored) = new_time;
             beats_destroyed = beats_destroyed + 1;
             destruction(beats_destroyed) = qrs_times(k+1);
             qrs_times = [qrs_times(1:k); new_time; qrs_times(k+2:end)];
             qrs_messy = [qrs_messy(1:k); 0; qrs_messy(k+2:end)];
             %%eval (['!echo Misplaced beat at ' num2str(qrs_times(k+1)) ' was moved to ' num2str(new_time) ' with beater = ' num2str(beater) '.']);
          else
             new_time = (qrs_times(k)*beater + qrs_times(k+1))/(beater+1);
             ok_to_insert = 1;
             % We are now about to insert a beat.  One final check: (inspired by 3016's RSA-triggered insertions)
             if beater == 1 & k > 1,
                 RRi1 = new_time - qrs_times(k); RRi2 = qrs_times(k+1)-new_time; % inserted RRs
                 RRo1 = qrs_times(k)-qrs_times(k-1); RRo2 = qrs_times(k+2)-qrs_times(k+1); % adjacent RRs
                 if RRi1 < 0.75* RRo1 | RRi2 < 0.75 * RRo2,
                     ok_to_insert = 0;
                 end
             end
             if ok_to_insert,
                 qrs_times = [qrs_times(1:k); new_time; qrs_times(k+1:end)];
                 qrs_messy = [qrs_messy(1:k); 0; qrs_messy(k+1:end)];
                 if verbose,
                   eval (['!echo ' num2str(qrs_times(k)) ': Missing beat at ' num2str(new_time) ' was reintroduced with beater = ' num2str(beater) '.']);
                   disp([denom beat_ratio beater_ratio beater_ratio2 beat_ratio_adjacence]);
                 end
                 beats_restored = beats_restored + 1;
                 restoration(beats_restored) = new_time;
                 if beater == 1,
                     alternating_check = 3;
                     doubled_beats_check = [doubled_beats_check new_time];
                     k = k + 1;
                 end
             else
                 if verbose,
                   eval (['!echo ' num2str(qrs_times(k)) ': Putative missing beat at ' num2str(new_time) ' was not inserted.']);
                 end
             end
             beater = 10;
          end
        elseif beater_ratio > 10,
          if verbose,
              eval (['!echo ' num2str(qrs_times(k)) ': A long pause occurred.']);
          end
          beater = 10;
        end
        beater = beater + 1;
      end
      if beater > 6,
          if 1==0 & verbose,
              eval (['!echo ' num2str(qrs_times(k)) ': Beater exceeded.']);
          end
          qrs_messy(k) = 1;
      end
     end
    end
  elseif yes_reposition & ~prox (beat_ratio, 1, 20), % Changed from 12.5% on 16 June, to avoid 3100's 80.25 false ectopic and lots more
      % This beat is not extraordinary except that its RR interval is beyond expected variance
      reposition_ectopic
  end
end

restoration = (sort(restoration))';  destruction = (sort(destruction))';
%sum(qrs_messy)
for qk = 1:length(qrs_messy2),
    qrs_messy (qrs_times == qrs_messy2(qk)) = 1;
end
%sum(qrs_messy)

if verbose,
    per_rest = 100*length(restoration)/length(qrs_times);
    per_dest = 100*length(destruction)/length(qrs_times);
    eval (['!echo Approximately ' num2str(per_rest) ' per cent of beats were added and ' num2str(per_dest) ' were destroyed.']);
end
