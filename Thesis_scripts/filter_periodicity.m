% filter_periodicity
% Period is the periodicity to be filtered
% lSignal is the hours of recordnig
% Uses Zero-Phase Filter to obtained filtered signal


function [filt_period] = filter_periodicity(period, signal, srate,lSignal)

range = [period-1 period+1]; % Create Range for Bandpass Filter
t_delay = length(signal)/lSignal;
r = srate./(range*t_delay);

[A,B,C,D] = ellip(20,1,40,r/(srate/2));
% Can change the filter order, passband ripple and stopban attenuation

[sos,g] = ss2sos(A,B,C,D);
filt_period = filtfilt(sos,g,signal); % Zero-Phase Filter

end