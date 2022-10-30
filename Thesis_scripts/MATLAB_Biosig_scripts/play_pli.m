clear all;
close all;
test_wrong_wrap=1 %% switch if true test difference in estimation based on wrong phase wrapping
Fs=1000;%%s ample rate
sc=0.2; %% scaling of white noise component
t=0:1/Fs:50; %% time vec

x=sin(2*pi*10.*t)+ sc.*randn(size(t)); %% sinusoid at 10Hz
y=sin(2*pi*10.*t)+ sc.*randn(size(t)); %% sinusoid at 10Hz at same phase as x
% y=sin(2*pi*10.*t +pi)+ sc.*randn(size(t)); %% sinusoid at 10Hz at +pi
z=sin(2*pi*10.*t + pi/2) + sc.*randn(size(t)); %% sinusoid ar 10Hz shifted by pi/2

% %% remove dc
x= x-mean(x);
y=y-mean(y);
z=z-mean(z);

% get hilbert transform, in data need to BP filter first and discard initial and end segments
% these are the ohase differences betwwen two channles
phi1=angle(hilbert(x))-angle(hilbert(y));
phi2=angle(hilbert(z))-angle(hilbert(x));



% correct wrapping of phase differences to [-pi pi]
phi1w=wrapToPi(phi1);
phi2w=wrapToPi(phi2);


figure
subplot(2,1,1)
hist(phi1w)
title('dphi distribution 1-2')
set(gca,'xlim',[-pi pi])
subplot(2,1,2)
hist(phi2w)
title('dphi distribution 1-3')
set(gca,'xlim',[-pi pi])
if test_wrong_wrap
% wrong wrapping of phase differences- just checking impact of error on pli
% here
phi1w2=mod(phi1,2*pi)-pi;%% wrong
phi2w2=mod(phi2,2*pi)-pi;
end

% compute pli, signal 1 and 2 are phase locked at 0 so should get pli;s close to 0, signals 1 and 3 are phase locked at pi/2 so pli should be high
% increasing noise scaling should give intermediate values of pli but plv
% shoukd be much moire affected
% PLI
pli1=abs(mean(sign(phi1w)))
pli2=abs(mean(sign(phi2w)))
if test_wrong_wrap
% based on wrong wraping
pli12=abs(mean(sign(phi1w2)))
pli22=abs(mean(sign(phi2w2)))

diff_wrong_wrap1=pli1-pli12
diff_wrong_wrap2=pli2-pli22
end
% PLV phase locking value, This should decrease with noise as phase
% ditributions become broader

plv1=abs(mean(exp(1i.*phi1w)))
plv2=abs(mean(exp(1i.*phi2w)))
