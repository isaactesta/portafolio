
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% File: ecg_mains.m
% Author: Mark Ebden
% Date: July 2004
% Reliances: None
% 
% DESCRIPTION
% Removes mains interference (50 Hz) from ECG signal
%
% USAGE
% ecg should have the time vector as its first column, followed
% by N channels. Output y is same size as ecg.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = ecg_mains (ecg)

% Initialisations
N = size(ecg,2) - 1; % Number of ECG channels
Fs = 200; y = zeros(size(ecg));
y(:,1) = ecg(:,1);

% Design filter
Wn = ([47 53])/(Fs/2);
b = fir1(100,Wn,'stop');

% Filter the ECG
for ecg_i = 2:N+1
    y(:,ecg_i) = filtfilt(b,1,ecg(:,ecg_i));
end
