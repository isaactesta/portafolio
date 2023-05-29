% Compute Phase-locking values between two signals
% Will compute the phase locking value between two signals according:

% Lachaux JP, Rodriguez E, Martinerie J, Varela FJ. 
% Measuring phase synchrony in brain signals. Hum Brain Mapp. 1999;8(4)

% If the phase difference varies little across the trials, PLV is close to 1
% Otherwise is close to zero

% Written by Isaac Testa

% Add to check if signals are same length

function [PLV] = phase_locking(phase1,phase2)

N = length(phase1);

diff = phase1-phase2;
e = exp(1i*diff);
PLV = abs(sum(e))/N;

end