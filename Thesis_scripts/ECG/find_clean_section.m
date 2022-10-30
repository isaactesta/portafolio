% USAGE:    find_clean_section
%
% DESCRIPTION
% Finds a clean (artefact-free) block of data x, set currently at 2
% seconds sampled at 500 Hz.

% Initialisations
if exist('verbose') == 0,
    verbose = logical(0);
end
bl = 2*fs; % Block length is 2 s (fs = 500 Hz)
learn_range = [];
data_start = 1; data_end = data_start+bl-1;
validation_criterion = 25;
test_criterion = 40;
ac_count = 0;

while (size(learn_range) == [0 0] & data_end < len - 10*bl)

  % Set time limits for analysis
    data_start = data_end+1; data_end = data_start+bl-1;
    validation1_start = round(data_start+bl/3); validation1_end = validation1_start+2*bl-1;
    validation2_start = validation1_end+1; validation2_end = validation1_end+2*bl;
    test_start = validation2_end+1; test_end = validation2_end+2*bl;

    % Divide time series using those limits
    a = bpf(data_start:data_end);
    b = bpf(validation1_start:validation1_end);
    c = bpf(validation2_start:validation2_end);
    d = bpf(test_start:test_end);
    
    % Calculate correlations
    aa = xcorr(a,a); ab = xcorr(a,b); ac = xcorr(a,c);
   
    % Validation sets:
    if prox(max(ab),max(aa),validation_criterion) & prox(max(ac),max(aa),validation_criterion)
      % Test set:
      ad = xcorr(a,d);
      if prox(max(ad),max(aa),test_criterion),
        % A good segment to use has been found
        learn_range = data_start:data_end;
        %figure; subplot(2,1,1); plot (aa); subplot(2,1,2); plot(a);
        %figure; subplot (3,1,1); plot (b); subplot (3,1,2); plot (c); subplot (3,1,3); plot (d);
        %figure; subplot (3,1,1); plot (ab); subplot (3,1,2); plot (ac); subplot (3,1,3); plot (ad);
        %figure; plot (a); title (num2str(pat_no));
        %disp(['Section found in ' num2str(data_end/bl-1) ' attempts. Maxima:']);
        %disp([max(aa) max(ab) max(ac) max(ad)]);
        %disp([sum(aa.*aa) sum(ab.*ab) sum(ac.*ac) sum(ad.*ad)]); 
      end
    elseif data_start > 45 * fs;
        % Lower the standards, since this is a difficult tachogram
	ac_count = ac_count + 1;
        test_criterion = 50;
        validation_criterion = 30;
    end
end
if ac_count > 0 & verbose,
    eval (['!echo Difficult to find a clean stretch of RR intervals: Adjusted criteria ' num2str(ac_count) ' times.']);
end

if size(learn_range) == [0 0],
    if verbose,
        !echo Suitable clean section could not be found.
    end
    learn_range = bl+1:2*bl; % Select range arbitrarily
end
