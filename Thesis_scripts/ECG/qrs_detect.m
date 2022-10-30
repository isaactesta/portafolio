% USAGE: qrs_times = qrs_detect(data,fs,lead)
%
% Description: QRS detector proposed by Li et al.
%
% data - Nx12 ecg data
%
% qrs_times - times of R peaks
% 
% Copyright (c) Thomas Brennan (2007)

function [qrs_times,ff] = qrs_detect(data,fs,lead,wavelet)

graphic = logical(1);
verbose = logical(1);

if nargin < 2
  fs = 500;
  lead = 2;
  wfun = 'gaus1';
end

% Initialisation
nearness = 10;

% Input variables
[N,d] = size(data);
if d>1,  data = data(:,lead); end
t = 1/fs:1/fs:N/fs;
wl = round(0.01*fs);

% Undecimated wavelet decomposition and phase correction
W = uwt(data,7,'gaus1',1);

[N,d] = size(W);

% Remove edge effects
W = [zeros(N*0.01,d); W(round(N*0.01):end-round(N*0.01)-1,:); zeros(N*0.01,d)];

% Peak detection of wavelet coefficients
%if verbose, fprintf('Level 5\n');end
peaks = find_peaks(abs(W(:,4)));

% Initialise peak structure
npeaks = zeros(4,length(peaks));
npeaks(4,:) = peaks;

for j = 3:-1:1,
    if verbose, fprintf('Level %d\n',j);end
    npeaks(j,:) = find_more_peaks(W(:,j),npeaks(j+1,:),W(npeaks(j+1,:),j+1),nearness);
    npeaks = npeaks(:,find(npeaks(j,:)));
end

% Remove zeros from npeaks
npeaks = npeaks(:,find(npeaks(1,:)));

% Calculate Lipshitz exponent
alpha = zeros(size(npeaks));
for j = 1:3
    alpha(j,:) = log2(abs(W(npeaks(j+1,:),j+1))) - log2(abs(W(npeaks(j,:),j)));
end

% Retain R-peaks with alpha' > 1
alphap = (alpha(1,:)+alpha(2,:))/2
idx = find(alphap > 1);
rpeaks = npeaks(1,idx);

if 0,
    fpeaks = npeaks(1,:)
    a = (alpha(1,:))/2
    rpeaks
end

% Redundant peak detection
difpeaks = diff(rpeaks);

n = 1;
pkcnt = 1;
%rrs = fs;
while n<length(rpeaks)
    if verbose, fprintf('%d: %d ->',n,rpeaks(n));end
    if W(rpeaks(n),1) < 0 
        if difpeaks(n) < 0.12*fs %0.2*mean(rrs)
            num_peaks = sum(rpeaks(n+1:end)<rpeaks(n)+0.120*fs);
            if num_peaks > 2
                [a,p] = min(W(rpeaks(n:n+num_peaks)));
                n = n+p-1;
            end
            %divx = diff(W(rpeaks(n):rpeaks(n+1)));
            zc = find(W(rpeaks(n):rpeaks(n+1),1).*W(rpeaks(n)+1:rpeaks(n+1)+1,1)<=0);
            if isempty(zc)
                n = n + 1;
                if verbose, fprintf('Redundant (stationary zc)\n'); end
                continue;
            elseif length(zc) > 3 %find(W(rpeaks(n)+zc(1):rpeaks(n+1),1) < 0)
                n = n + 1;
                if verbose, fprintf('Redundant (multiple zc)\n'); end
                continue;
            else
                zc = zc(1);
            end
            qrs_times(pkcnt) = rpeaks(n)+zc(1);
            if verbose, fprintf(' R-peak = %d\n',qrs_times(pkcnt)); end
            n = n+2;
            %if pkcnt > 2, rrs = [rrs qrs_times(pkcnt)-qrs_times(pkcnt-1)];
            %else, rrs = qrs_times(pkcnt); end
            while n<length(rpeaks) && (rpeaks(n) - qrs_times(pkcnt))<0.5*fs %0.5*mean(rrs)
                fprintf('%d, ',rpeaks(n));
                n = n+1;
            end
            pkcnt = pkcnt + 1;
        else
            n = n+1;
            if verbose, fprintf('Redundant (isolated)\n');end
        end
    else
       n = n+1;
       if verbose, fprintf('Redundant (positive)\n');end
    end
end

if graphic,

  ff = figure;

  fs = 500;
  t = 1/fs:1/fs:length(data)/fs;
  subplot(5,1,1);
  plot(data,'k');hold on;
  axis tight;
  v = axis;
  %for i = 1:length(qrs_times)
  %    line([qrs_times(i) qrs_times(i)],[v(3) v(4)],'Color','b');
  %end
  plot(qrs_times,data(qrs_times),'b.');
  text(0,v(4),'x(t)','FontSize',12);
  set(gca,'YTick',[],'Visible','off');
  
  for j = 1:3
    subplot(5,1,j+1);
    plot(W(:,j),'k');hold on;
    plot(npeaks(j,:),W(npeaks(j,:),j),'b.');
    axis tight;
    v = axis;
    %line([v(1) v(2)], [2.36*mean(abs(W(:,j))) 2.36*mean(abs(W(:,j)))],'Color','r');
    text(0,v(4),sprintf('W_{2^%d}',j),'FontSize',12);
    set(gca,'YTick',[],'Visible','off');
  end

  j=4;
  subplot(5,1,j+1);
  plot(abs(W(:,j)),'k');hold on;
  plot(npeaks(j,:),abs(W(npeaks(j,:),j)),'b.');
  axis tight;
  v = axis;
  %line([v(1) v(2)], [2.36*mean(abs(W(:,j))) 2.36*mean(abs(W(:,j)))],'Color','r');
  text(0,v(4),sprintf('W_{2^%d}',j),'FontSize',12);
  set(gca,'YTick',[],'Visible','off');

  %print(ff, '-depsc2', '-adobecset', '../Pubs/Figure/results_qrs_detect_twave.eps' );
end

