%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% THE TACHOGRAM RESAMPLER
%
% File: resampler.m
% Author: Mark Ebden
% Date: November 2002
%
% DESCRIPTION
% Inputs an unevenly-sampled tachogram, and calculates
% instantaneous HR for an arbitrarily high re-sampling
% frequency.  The result is evenly sampled.
% Based on reference M117, by Berger et al.
%
% USAGE
% Usage is as follows at the Matlab prompt:
%    [bhr, shr, t, troubles] = resampler (tachogram_source, Fs)
% where:
%   - tachogram_source is one of two things:
%        A four-digit patient number, or
%        A tachogram vector, listing QRS peak times
%   - Fs is the sampling frequency
% and:
%   - bhr is the Berger et al heart rate
%   - shr is the cubic splines interpolated HR
%   - t is the corresponding time vector
%   - troubles is a vector which is 1 where cubic splines
%     encountered difficulty
%
% e.g. of use:   resampler (3105, 5)
%                resampler (my_RR_tachogram, 2)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bhr, shr, t, troubles] = resampler (tachogram_source, messy, Fs)
%tachogram_source = qrs_times;  Fs = 4;

%%%%%%%%%%%%%%%%%%%%% INITIALISATION %%%%%%%%%%%%%%%%%%%%%

% Run two important scripts, for a sanity check and initialisation:
if size(tachogram_source) == [0 0],
  !echo Invalid use of resampler.m
end
if (tachogram_source(1) == '3')
    pat_no = str2num(tachogram_source);
    %check_arguments( 2, nargin, pat_no);
    if (best_threshold(pat_no) <= 0)
      !echo Tachogram analysis has not been performed on this patient.
      return;
    end
    % Load the tachogram
    %eval (['load /data/smp/processing/mark/tachograms/' num2str(pat_no)]);
    qrs_times = load_tachogram (pat_no, 'ebden', 0)
    initialisations
else
    qrs_times = tachogram_source;
    %check_arguments(2, nargin, 1);
end

%%%%%%%%%%%%%%%%%%% DATA ANALYSIS %%%%%%%%%%%%%%%%%%%%%%

number_of_beats = length (qrs_times);
end_time = floor(qrs_times(end));
N = end_time*Fs;
RR = zeros(N,1);
shr = zeros(N,1);
bhr = zeros(N,1);
t = 1/Fs:1/Fs:end_time;
width = 2/Fs;  % How wide is the window, in seconds

% Calculate RR intervals:
interval = [diff(qrs_times); qrs_times(end)-qrs_times(end-1)];

% Remove messy sections with benign interpolation:
um = find(messy>0);
for k = 1:length(um),
    n = 10; RR_estimate = 1;
    while n<um(k),
        if messy(um(k)-n) == 0,
            RR_estimate = interval(um(k)-n);
            n = um(k);
        else
            n = n + 1;
        end
    end
    interval(um(k)) = RR_estimate;
end
% Substitute wild swings
N2 = 25; messy2 = messy;
k = N2;
while k < length(interval)-1,
    ub = interval(1:k); mb = messy(1:k);
    ub = ub(find(mb==0));
    stp = max (1, length(ub)-N2);
    beats = ub(stp:end); % i.e., last N2-1 beats that are not messy
    variance_precedent = abs(prctile(beats,20)-prctile(beats,80));
    current_deviation = abs(interval(k)-interval(k-1));
    if current_deviation > min(1,max(0.1,2.5*variance_precedent)),% Must be at least 130 ms diff. to reject; Reject always if more than 1 s difference
        interval(k) = median(beats);
        messy2(k) = 1;
        k = k + 1; % Necessary for example for 3007, 3002; otherwise prolonged replacements occur
        %disp([qrs_times(k) current_deviation variance_precedent beats(end*2/3:end)']);        pau
    end
    k = k + 1;
end
messy = messy | messy2;

if 1==0,
    current_beat = 0;
	for n = 1:N
       % See what KIND of beat this is: (i), (ii), or (iii)
	
       % (i) The last beat
       if (n+1)/Fs > end_time
          % There are no more QRS complexes to be found
          break
       end
	
       % (ii) The first beat
       if ((qrs_times(1) >= (n-1)/Fs) & qrs_times(1) < n/Fs)      
          % The first beat occurred in the first half of the window
          beats_per_half_window = 1;
          while (qrs_times(1 + beats_per_half_window) < n/Fs),
             beats_per_half_window = beats_per_half_window + 1;
          end
          current_beat = beats_per_half_window;
	
          % And now we are initialised for a normal loop next time
	
       % (iii) A beat in between
       elseif current_beat > 0
	
          % PART A: Find how many beats our window has (integer)
          beats_per_window = 0;
          while ((qrs_times(current_beat+beats_per_window+1) >= (n-1)/Fs) & (qrs_times(current_beat+beats_per_window+1) < (n+1)/Fs)),
             beats_per_window = beats_per_window + 1;
          end
	
          % PART B: Count the RR intervals in this window (rational number),
          %         in preparation for later calculating the instantaneous HR.
          if (beats_per_window == 0)
          % This window occurs entirely within a beat-to-beat interval.  Hence,
          % divide the window width by the current interval length to get a fraction
          % of an RR, then divide by the width to get a rate.  Net result: 1/interval.
             RR(n) = width/interval(current_beat);
          else
             % Otherwise, it's more complicated, because new beats occurred.
             % Do the calculation in three parts:
             % 1. First take the (integer number) of the middle intervals
               if (beats_per_window > 1)
                 RR(n) = beats_per_window-1;
               end
             % 2. Add the time from the start of the window to the first new beat
               b = qrs_times(current_beat+1) - (n-1)/Fs;
               I_first = interval(current_beat);
               RR(n) = RR(n) + b/I_first;
             % 3. And then add the time from the last beat in the window to
             %    the end of the window
               c = (n+1)/Fs - qrs_times(current_beat+beats_per_window);
               I_last = interval(current_beat+beats_per_window);
               RR(n) = RR(n) + c/I_last;
          end
	
          % PART C: Prepare for the next loop
          % Finally, update the beat count in preparation for the next window.
          % This should be the last beat before the next window begins.
          while (qrs_times(current_beat + 1) < n/Fs),
             current_beat = current_beat + 1;
          end
	
       end
	end
    
    % Finally, use RR to get instantaneous HR:
    bhr = (RR./width);
        
	% ...and then clean up the HR and the time matrix:
	bhr (end) = bhr (end-1);
	num_of_leading_zeros = 0;
	while (bhr(num_of_leading_zeros+1) == 0),
      num_of_leading_zeros = num_of_leading_zeros + 1;
	end
	
	bhr(1:num_of_leading_zeros) = NaN;
	bhr = [bhr(2:end); bhr(end)];
end

% Now calculate cubic splines
%hr_simple = 1./ ([interval(1); interval(1:end-1)]);
%u0 = find (diff(qrs_times)> 5);
%troubles_asynch = qrs_times(u0);

hr_simple = 1./interval;

% Identify problematic areas
u = find(hr_simple>0.2 & hr_simple < 5);
u1 = find(hr_simple<=0.2 | hr_simple >= 5);
if size(u1) > 0,
    u2 = u1+1;
    if u2(end) > length(qrs_times),
        u2 = u2(1:end-1);
    end
else
    u2 = [];
end
troubles.asynch = qrs_times([u1; u2]);
troubles.asynch = sort(troubles.asynch);

% No longer needed:
hr_simple2 = hr_simple; qrs_times2 = qrs_times;
if 1==0,
	ci = 1; ok_area = 1;
	while ci < length(qrs_times2),
        if qrs_times2(ci+1) - qrs_times2(ci) > 5,
            % Gap needs to be filled in time series, so that cubic splines won't error out
            qrs_times2 = [qrs_times2(1:ci); qrs_times2(ci)+1; qrs_times2(ci+1:end)];
            hr_simple2 = [hr_simple2(1:ci); hr_simple2(ci); hr_simple2(ci+1:end)];
            ok_area = 0;
        else
            if ok_area == 0,
                qrs_times2 = [qrs_times2(1:ci); qrs_times2(ci)+1; qrs_times2(ci)+1; qrs_times2(ci)+1; qrs_times2(ci+1:end)];
            end
            ok_area = 1;
        end
        ci = ci + 1;
	end
end       
%hr_simple2(u1) = mean(hr_simple(u)); qrs_times2 (u1) = mean(qrs_times(u)); CAUSES PROBLEM
%size(hr_simple2), size(qrs_times2)
%figure; plot (hr_simple2);
%figure; plot (qrs_times2, ones(size(qrs_times2)), '.');
uu = diff(qrs_times2); sum (uu<=0);
hr_simple2 = hr_simple2(uu > 0);
qrs_times2 = qrs_times2(uu > 0);

if 1==0, % No longer need this section! Only good to combat 'absisscae must be distinct' error
	for yy = 1:length(qrs_times2)-1,
        for yo = yy+1:length(qrs_times2),
            if qrs_times2(yy) >= qrs_times2(yo),
                yy, yo
                qrs_times2(yy), qrs_times2(yo)
            end
        end
	end
end

% Perform the spline operation:
t = t(t>=qrs_times(1));
N = length(t);
%disp([qrs_times2(1:10) qrs_times2(end-9:end)])
%disp([t(1) t(end)])
shr = spline (qrs_times2, hr_simple2, t);
%shr(1:num_of_leading_zeros) = 0;
u = find(shr <= 0.2 | shr >= 5); % Not really necessary any more
shr(u) = mean(shr); % Not really necessary any more
troubles.synch = zeros(size(shr)); troubles.synch(u) = 1;
if exist('troubles.asynch') == 0,
    troubles.asynch = [];
end
% Label any gaps (detected as long RR intervals) as regions to be ignored
% A) Asynchronous cases
tsk = 1; tq = 0;
while tq < length(qrs_times) & tsk < length(t),
    tq = tq+1; bad_beat = 0;
    if size(troubles.asynch,1) > 0 & sum(find(troubles.asynch == qrs_times(tq))) > 0,
        bad_beat = 1;
    end
    while tsk < length(t) & t(tsk) < qrs_times(tq),
        troubles.synch(tsk) = troubles.synch(tsk) | bad_beat;
        tsk = tsk + 1;
    end
end
% B) Synchronous cases
synch_index = zeros(size(shr));
detect_range = 6; % in seconds
erase_range = round(detect_range*Fs)-1; % in index counts
for k = 1:N,
    u = min(abs(t(k)-qrs_times));
    if u > detect_range, % This interpolation is more than 6 seconds away from any beat
        start_sik = max(1,k-erase_range); end_sik = min(N,k+erase_range);
        synch_index(start_sik:end_sik) = 1;
        %disp([start_sik k end_sik t(k)]), pau
    end
end
if sum(synch_index) > 0,
    for k = 1:N,
        if synch_index(k) == 1,
            if k > 6,
                if synch_index(k-1) == 0,
                    % First in a series
                    shr(k) = shr(k-6);
                else
                    shr(k) = shr(k-1);
                end
            else
                shr(k) = 1;
            end
        end
    end
end
troubles.synch = troubles.synch | synch_index;

%figure; plot (t, troubles.synch)

bhr = shr; % Since we are no longer calculating BHR
