% function peaks = find_peaks(x,thr)
%
% Description: To find peaks in signal 'x' about a specified threshold
%
% x - Nx1 array 
% thr - threshold value as percentage of maximum value
% inverted - 1 means negative peaks, 0 means positive peaks
 


function peaks = find_peaks(x,thr,fs)

graphic = logical(0);
verbose = logical(0);

if nargin < 2
  thr = 2.36*mean(x);
  fs = 500;
end

% Initialisation
a = 0;
peaks = [];
N = length(x);
pkcnt = 0;
offset = 0.01*N;

% Find first peak limits
% sidx = find(x(offset:N)>thr,1,'first');
% if isempty(sidx), error('Initial threshold too large'); end
% sidx = sidx + offset;
% eidx = find(x(sidx:N)<thr,1,'first');
% if isempty(sidx), error('No local maximum with current threshold'); end
% eidx = sidx + eidx;

% Find first maxima
%xstart = x(1:2*fs);
%tps = find(xstart(1:end-2)<=xstart(2:end-1) &xstart(2:end-1)>=xstart(3:end))+1;
tps = find(x(1:end-2)<=x(2:end-1) & x(2:end-1)>=x(3:end))+1;
pkidx = tps(find(x(tps)>thr,1,'first'));
amps = thr;

while ~isempty(pkidx)
  if verbose, fprintf('%d: thr %f, peak = %d\n',pkcnt,thr,pkidx);end
  a = x(pkidx);
  peaks = [peaks pkidx];
  pkcnt = pkcnt + 1;
  
  % Adjust list of turning points
  tps = tps(tps>pkidx);

  % Estimate threshold
  if a >= 2*amps
    amps = a;
    thr = 0.3*amps;
  else
    amps = 0.875*amps + 0.125*a;
    thr = 0.3*amps;
  end

  % Search for next maximum
  pkidx = tps(find(x(tps)>thr,1,'first'));
end

if graphic,
  figure;
  plot(x); hold on;
  v = axis;
  line([v(1) v(2)],[thr thr],'Color','r');
  plot(peaks,x(peaks),'g.');
end


return