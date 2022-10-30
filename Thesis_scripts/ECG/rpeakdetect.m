function [hrv, R_t, R_amp, R_index, S_t, S_amp]  = rpeakdetect(data,samp_freq,thresh,win)

% [hrv, R_t, R_amp, R_index, S_t, S_amp]  = rpeakdetect(data, samp_freq, thresh,win); 
% R_t == RR points in time, R_amp == amplitude
% of R peak in bpf data & S_amp == amplitude of 
% following minmum. sampling frequency (samp_freq = 256Hz 
% by default) only needed if no time vector is 
% specified (assumed to be 1st column or row). 
% The 'triggering' threshold 'thresh' for the peaks in the 'integrated'  
% waveform is 0.2 by default. 
%
% Written by G. Clifford gari@robots.ox.ac.uk
% (C) Oxford University 2001
%
% A QRS detector bsed upon that of Pan, Hamilton and Tompkins:
% J. Pan \& W. Tompkins - A real-time QRS detection algorithm 
% IEEE Transactions on Biomedical Engineering, vol. BME-32 NO. 3. 1985.
% P. Hamilton \& W. Tompkins. Quantitative Investigation of QRS 
% Detection  Rules Using the MIT/BIH Arrythmia Database. 
% IEEE Transactions on Biomedical Engineering, vol. BME-33, NO. 12.1986.
% 
% Similar results reported by the authors above were achieved, without
% having to tune the thresholds on the MIT DB. An online version in C
% has also been written.
%
% Please distribute (and modify) freely, commenting
% where you have added modifications. 
% The author would appreciate correspondence regarding
% corrections, modifications, improvements etc.
%
% gari@robots.ox.ac.uk

%%%%%%%%%%% make win default to unity
if nargin < 4
   win = 1.0;
end
%%%%%%%%%%% make threshold default 0.2 -> this was 0.15 on MIT data 
if nargin < 3
   thresh = 0.2;
end
%%%%%%%%%%% make sample frequency default 256 Hz 
if nargin < 2
   samp_freq = 256
end

%%%%%%%%%%% check format of data %%%%%%%%%%
[a b] = size(data);
if(a>b)
 len =a;
end
if(b>a)
 len =b;
end

%%%%%%%%%% if there's no time axis - make one 
if (a | b == 1);
% make time axis 
  tt = 1/samp_freq:1/samp_freq:ceil(len/samp_freq);
  t = tt(1:len);
  x = data;
end
%%%%%%%%%% check if data is in columns or rows
if (a == 2) 
  x=data(:,1);
  t=data(:,2); 
end
if (b == 2)
  t=data(:,1);
  x=data(:,2); 
end

%%%%%%%%% bandpass filter data - assume 256hz data %%%%%
 % remove mean
 x = x-mean(x);
 bpf = filter_smp(x); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%% differentiate data %%%%%%%%%%%%%%%%%%%%%%%%%%%
 dff = diff(bpf);  % now it's one datum shorter than before

%%%%%%%%% square data    %%%%%%%%%%%%%%%%%%%%%%%%%%%
 sqr = dff.*dff;   %
 len = len-1; % how long is the new vector now? -> 
%%%%%%%%% integrate data    %%%%%%%%%%%%%%%%%%%%%%%%%
 d = [ones(1,round(win*256*7/samp_freq))];
 % find the delay in the filter
 delay = round((length(d)-1)/2);
 % and 'integrate'
 mdf = medfilt1(filter(d,1,sqr),10);

%%%%%%%%% segment search area %%%%%%%%%%%%%%%%%%%%%%%
 %%%% first find the highest bumps in the data %%%%%% 
 max_h = max (mdf(round(len/4):round(3*len/4)));

 %%%% then build an array of segments to look in %%%%%
 %thresh = 0.2;
 poss_reg = mdf>(thresh*max_h);

%%%%%%%%% and find peaks %%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%% find indices into boudaries of each segment %%%
 left  = find(diff([0 poss_reg'])==1); % remember to zero pad at start
 right = find(diff([poss_reg' 0])==-1); % remember to zero pad at end
 
 %%%% loop through all possibilities  
 for(i=1:length(left))
    [maxval(i) maxloc(i)] = max( bpf(left(i)-delay:right(i)-delay) );
    [minval(i) minloc(i)] = min( bpf(left(i)-delay:right(i)-delay) );
    maxloc(i) = maxloc(i)-1-delay+left(i); % add offset of present location
    minloc(i) = minloc(i)-1-delay+left(i); % add offset of present location
 end

 R_index = maxloc;
 R_t   = t(maxloc);
 R_amp = maxval;
 S_amp = minval;   %%%% Assuming the S-wave is the lowest
                   %%%% amp in the given window
 S_t   = t(minloc);

%%%%%%%%%% check for lead inversion %%%%%%%%%%%%%%%%%%%
 % i.e. do minima precede maxima?
 if (minloc(length(minloc))<maxloc(length(minloc))) 
  R_t   = t(minloc);
  R_amp = minval;
  S_t   = t(maxloc);
  S_amp = maxval;
 end

%%%%%%%%%%%%
hrv  = diff(R_t);
resp = R_amp-S_amp; 

