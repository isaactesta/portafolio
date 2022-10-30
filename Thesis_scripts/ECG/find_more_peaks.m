% USAGE: function peaks = find_peaks(x,thr,refrac,inverted)
%
% Description: To find peaks in signal 'x' about a specified threshold
%
% x - Nx1 array 
% thr - threshold value as percentage of maximum value
% refrac - minimum refactory period in samples
% inverted - 1 means negative peaks, 0 means positive peaks
% 
% Copyright (c) Thomas Brennan (2007)

function peaks = find_more_peaks(x,npeaks,pkvals,near)

graphic = logical(0);
verbose = logical(0);

if nargin < 3
  near = 10;
end

% Initialisation
%thr = var(x)+mean(x);
thr = mean(x);
amps = 0;
peaks = zeros(length(npeaks),1);
N = length(x);
pkcnt = 0;

for n = 1:length(npeaks)

    if verbose, fprintf('%d: ',n);end
    if pkvals(n) > 0
        [pkidx, a] = find_maxima(x,npeaks(n),near,thr);
        if verbose, fprintf('(+) ');end
    else
        [pkidx, a] = find_minima(x,npeaks(n),near,-1*thr);
        if verbose, fprintf('(-) ');end
    end
    
    if n>1
        if pkidx < peaks(n-1)
            if verbose, fprintf('peak = 0\n');end
            continue;
        else
            peaks(n) = pkidx;
            if verbose, fprintf('peak = %d\n',pkidx); end
        end
    elseif ~isempty(pkidx)
        peaks(n) = pkidx;
        if verbose, fprintf('peak = %d\n',pkidx); end
    else
        if verbose, fprintf('peak = 0\n');end
        continue;
    end
    
    % Estimate threshold
    if abs(a) >= 2*amps
        amps = abs(a);
    else
        amps = 0.875*amps + 0.125*abs(a);
    end
    thr = 0.2*amps;


end

if graphic,
  figure;
  plot(x); hold on;
  v = axis;
  line([v(1) v(2)],[thr thr],'Color','r');
  plot(peaks(find(peaks)),x(peaks(find(peaks))),'g.');
end

return