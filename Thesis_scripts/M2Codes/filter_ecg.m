function [filt_ecg] = filter_ecg(ECG,srate)

Fs = srate;                            % Sampling Frequency (Hz)
Fn = Fs/2;                          % Nyquist Frequency (Hz)
Fco = [0.5 60];                            % Cutoff Frequency (Hz)
wsn = [0.1 75];
Wp = Fco/Fn;                        % Normalised Cutoff Frequency (rad)
Ws = wsn/Fn;                        % Stopband Frequency (rad)
Rp =  5;                            % Passband Ripple (dB)
Rs = 20;                            % Stopband Ripple (dB)
[n,Wn]  = buttord(Wp,Ws,Rp,Rs);     % Calculate Filter Order
[b,a]   = butter(n,Wn);             % Calculate Filter Coefficients


filt_ecg = filter(b,a,ECG);

end