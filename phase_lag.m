% Compute Phase-locking values between two signals
% Will compute the phase lag index between two signals

% Written by Isaac Testa




function [PLI] = phase_lag(phase1,phase2)

N = length(phase1);

diff = phase1-phase2;
s = sum(sign(diff));
PLI = abs(s/N);
end