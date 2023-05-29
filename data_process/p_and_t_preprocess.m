
%%%%%%%%% Bandpass filter the data %%%%%%%%%%%%%%%%%%%
x = x-mean(x);len = length(x); min_data = min(x);
if tw > 0.12,
    % Wide QRS complexes
    freq_range = [3 50];
else
    % Normal QRS complexes
    freq_range = [3 25];
end
Wn = (freq_range)/(samp_freq/2); b = fir1(100,Wn,'bandpass');
% used to be 3-25 Hz, changed 17 Nov 2003
bpf = filtfilt(b,1,x);

%%%%%%%%% Differentiate the data %%%%%%%%%%%%%%%%%%%%
a = bpf; dff = zeros(size(a));
for n = 3:len-3;
    dff(n) = 0.125 * (-a(n-2) - 2*a(n-1) + 2*a(n+1) + a(n+2));
end
dff(1:2) = diff(a(1:3));
dff(end-1:end) = diff(a(end-2:end));
dff = dff*samp_freq;

%%%%%%%%% Square the data %%%%%%%%%%%%%%%%%%%%%%%%%%%
sqr = dff.*dff;

%%%%%%%%% Integrate the data %%%%%%%%%%%%%%%%%%%%%%%%
% integration window size (sample frequency dependent):
d = [ones(1,wl_n)];
% 'integrate' window:
mwi = filter(d,1,sqr);

% median-filter it and compare (optional):
if 1==0,
    mdf = medfilt1(ins,10);
    figure; hold on
    plot(ins, 'k.');
    plot (mdf,'r.-');
end
