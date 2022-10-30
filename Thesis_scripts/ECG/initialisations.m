%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% File: initialisations.m  -- Simplified version
% Author: Mark Ebden
% Date: November 2002 -- Simplified in October 2004
% 
% DESCRIPTION
% Initialises variables in the following categories:
%    - Matlab and data paths
%    - Graphing variables
%    - Data extraction variables
%    - Timing of events
%
% USAGE
% This script is called by at least the following programs:
% tilt.m, tilt_hrv.m, tilt_eval.m, tilt_eeg.m, and tilt_wv.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

GetRoot


if 1==0,
% Set arbitrary numbers on graphing limits for now:
y_top = -100000;
y_bottom = 100000;
xlimit1 = 100000;
xlimit2 = -100000;

% Simple initialisations for data extraction
starter = 0; % Not really needed
stop = 0;
end

shutdown = 1e10;
if pat_no >= 3100 & pat_no < 3300,
   % Falls Clinic patient
   fc = logical(1);
else
   fc = logical(0);
end
