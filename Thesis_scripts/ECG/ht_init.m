% Initialisations for Hamilton (Pan) & Tomkins QRS detection
% Input - fs = sampling frequency
fs=200; %--> change sampling rate i add it Maria Anastasiadou
% Timing data
wl_n = round(0.160*fs); % Integration window width
cl_n = round(0.175*fs); % Time at which to force a fiducial point
nsr_start = -round(0.225*fs); nsr_end = -round(0.125*fs); % Normal search range
asr_start = -round(0.250*fs); asr_end = -round(0.150*fs); % Abnormal search range
threshold_coefficient = 0.189; % Used for peak detection
refractoriness = round(0.200*fs); % Impossible to have a second QRS complex in this time
probation = round(0.360*fs); % QRS complexes under probation are scrutinised more carefully
tw = 0.100; % This will be updated later; it is a default typical width of QRS complex and is meaningless here

% Other initialisations
morph_first_time = logical(1); % So that the morphology checker in classify_peak.m can begin
positive_streak = logical(1);  % Again, for morph_check.m
artefact_region = logical(0);  % For 'messy' variable, plus debugging purposes
length_artefact = 0;           % For morph_check.m
ap_count = 0;                  % For morph_check.m and classify_peak.m
beats_since_last_update = 0;   % For morph_check.m
