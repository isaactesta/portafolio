% Bandpass Filter, Differentiate, Square and Integrate Signal
% Input - data and ht_init

%%%%%%%%% Bandpass filter the data %%%%%%%%%%%%%%%%%%%
x = x-mean(x);len = length(x); min_data = min(x);
if tw > 0.12,
    % Wide QRS complexes
    freq_range = [3 50];
else
    % Normal QRS complexes
    freq_range = [3 25];
end
Wn = (freq_range)/(fs/2); 
b = fir1(100,Wn,'bandpass');
% used to be 3-25 Hz, changed 17 Nov 2003
bpf = filtfilt(b,1,x);

%%%%%%%%% Differentiate the data %%%%%%%%%%%%%%%%%%%%
a = bpf; dff = zeros(size(a));
for n = 3:len-3;
  dff(n) = 0.125 * (-a(n-2) - 2*a(n-1) + 2*a(n+1) + a(n+2));
end
dff(1:2) = diff(a(1:3));
dff(end-1:end) = diff(a(end-2:end));
dff = dff*fs;

%%%%%%%%% Square the data %%%%%%%%%%%%%%%%%%%%%%%%%%%
sqr = dff.*dff;

%%%%%%%%% Integrate the data %%%%%%%%%%%%%%%%%%%%%%%%
% integration window size (sample frequency dependent):
d = ones(1,wl_n);
% 'integrate' window:
mwi = filter(d,1,sqr);
