% Preprocess an uneven tachogram:
%  - Correction of Type A or B detection errors
%  - Shifting of ectopic beats
%  - Cubic splines interpolation
%  - Smoothing of dubious areas of tachogram

% ibi = inter-beat interval, hr = heart rate
% move_ectopics = 0 or 1 (if 1, algorithm will re-align ectopics to approximately correct positions)

function [hr, t, rejected_beats, qrs_times, qrs_messy, destruction, restoration] = preprocess (qrs_times, qrs_messy, Fs, move_ectopics)

if size(qrs_times) == 0,
    !echo The vector qrs_times is null. Ensure qrs_times is a valid time series.
    return; %break
end
% 1. Initialisations
if exist('move_ectopics') == 0,
    move_ectopics = 1;
end
pat_no = 0; fc = logical(0);

history = 9*Fs;
do_continue = logical(1); first_time = logical(1); sa = 0;
!echo Preprocessing tachogram....

% 2. Remove artefacts and fill in missing beats

% (a) handle_gross
reposition_allowed = logical(move_ectopics); % Decide whether to allow ectopics to remain where they are
call_handle_gross

% (b) post-processing
% Link beats together
k = 2;
while k < length(qrs_times)-1,
   if qrs_messy(k) == 1,
       while(qrs_messy(k) == 1 & k < length(qrs_times)-1),
          qrs_messy(k-1) = 1;
          k = k + 1;
       end
       qrs_messy(k) = 1;
   end
   k = k + 1;
end

if 1==0,
    for k = 3:length(qrs_times)-1,
        if qrs_messy(k) == 0 & qrs_messy(k+1) == 1,
            if qrs_messy(k-2) == 1 & qrs_messy(k-1) == 0,
                qrs_messy(k) = 1; qrs_messy(k-1) = 1;
            end
            if qrs_messy(k-1) == 1,
                qrs_messy(k) = 1;
            end
        end
    end
end

% 3. Convert from uneven to even sampling
%!echo Resampling tachogram....
history = 9*Fs;
[bhr, shr, t, troubles] = resampler (qrs_times, qrs_messy, Fs);

% 4. Find zeros at the start of the time series
%shr_orig = shr; t_orig = t;
%good_points = find(shr~=0);
%t = t(good_points); shr = shr(good_points);
num_zeros = 0; k = 1;
while (shr(k) == 0),
    num_zeros = num_zeros +1;
    k = k + 1;
end
shr(1:num_zeros) = shr(num_zeros+1:2*num_zeros); % Added Nov 2003; didn't see any harm
% 4. Smooth the abrupt changes
while do_continue,
    
    % (a) Find the areas
    aberrant = zeros(length(shr), 1);
    for k = history+1+num_zeros:length(shr),
        sk = shr(k-history:k-1);
        beat_ratio1 = shr(k) / prctile(sk,20);
        beat_ratio2 = shr(k) / prctile(sk,80);
        if beat_ratio1 < 0.7 | beat_ratio2 > 1.3,
            % >30% Deviation occurs from what used to be "beat to beat",
            % but what is now sample to sample.
            % Reject as dubious
            aberrant(k) = 1;
        end
    end
    %stem (t, -aberrant);
    % (b) Link groups together to form even larger groups
    for k = 3+num_zeros:length(shr)-1,
        if aberrant(k) == 0 & aberrant(k+1) == 1,
            if aberrant(k-2) == 1 & aberrant(k-1) == 0,
                aberrant(k) = 1; aberrant(k-1) = 1;
            end
            if aberrant(k-1) == 1,
                aberrant(k) = 1;
            end
        end   
    end
    sa = sum(aberrant);
    psa = round(100*sa/length(shr));
    
    if first_time,
        rejected_beats = aberrant;
        first_time = logical(0);
        saved_sa = sa;
        if sa > 0,
            eval (['!echo ' num2str(sa/Fs) ' seconds of data rejected: ' num2str(psa) ' per cent of the time series.']);
        else
            !echo No data rejected.
            do_continue = logical(0);
        end
    else
        eval (['!echo ' num2str(sa/Fs) ' seconds of data re-examined.']);
        %if saved_sa <= sa,
            do_continue = logical(0);
            !echo At least some of the data could not be corrected.
        %end
        saved_sa = sa;
    end
    
    % (c) Ensure the final two samples are valid
    if aberrant(end) == 1,
        % Preserve the final solid sample; otherwise,
        % things get messy in (d)
        j = 1;
        while (aberrant(end-j) == 1),
            j = j + 1;
        end
        aberrant(end) = 0;
        aberrant(end-1) = 0;
        shr(end) = shr(end-j);
        shr(end-1) = shr(end-j);
    end  
        
    % (d) Replace data with boring HRs
    k = history+1+num_zeros;
    if move_ectopics == 1,
      while k < length(shr)-2,
        j = 0;
        if (aberrant(k) == 1),
            % The start of an aberrant sample group
            j = 1;
            while (aberrant(k+j) == 1 & k+j+2 < length(shr)),
                % Step deeper into the affected sample group
                j = j + 1;
            end
            % Now things have settled down, so go back and
            % squash all aberrant samples in the group
            shr_avg = median ([shr(k-1) shr(k-2) shr(k-3) shr(k+j) shr(k+j+1)]);
            for m = 0:j-1,
                shr(k+m) = shr_avg;
            end
        end
        k = k + j + 1;
      end
    end
    %plot_them;
    %sa = 0; % TEMP!  Might as well, since the editing of shr has been deactivated above
end

hr = shr;
u = find(shr < 0);
hr(u) = mean(hr);
rejected_beats(u) = 1;

% 5. Identify problem areas in the tachogram:

% a. In preprocess.m, handle_gross.m, morph_check.m, etc.
qrs_rejects = [];
u = find (qrs_messy > 0);
for k = 1:length(u),
    the_st = max (u(k)-1,1); the_e = min (u(k)+1,length(qrs_messy));
    qrs_rejects = [qrs_rejects; [qrs_times(the_st) qrs_times(the_e)]];
end

% b. In handle_gross.m's restoration, destruction
for k = 1:length(restoration)-1,
    if restoration(k+1) - restoration (k) < 2, % Within 2 seconds
        qrs_rejects = [qrs_rejects; [restoration(k)-1 restoration(k)+1]];
    end
end
%Destruction removed on 16 June, b/c e.g. 3100 around 145, or 292, lots more:
%for k = 1:length(destruction)-1,
%    if destruction(k+1) - destruction (k) < 2, % Within 2 seconds
%        qrs_rejects = [qrs_rejects; [destruction(k)-1 destruction(k)+1]];
%    end
%end

% c. In preprocess.m (rejected_beats)
% This is done already

% d. In resampler.m (troubles)
rejected_beats(troubles.synch == 1) = 1;
for k = 1:length(troubles.asynch),
    tak = troubles.asynch(k);
    rejected_beats(abs(t-tak)<1) = 1; % Reject anything within 1 second of 'troubles'
end

% e. Now collate a through d:
for k = 1:size(qrs_rejects,1),
    u = find (t >= qrs_rejects (k,1) & t <= qrs_rejects (k,2));
    rejected_beats (u) = 1;
end

% f. Finally, a simple check:
u = find (hr > 3*mean(hr));
rejected_beats(u) = 1;
