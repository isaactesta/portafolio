function p = pli(x,y)

% %% remove dc
x=x-mean(x);
y=y-mean(y);

% get hilbert transform, in data need to BP filter first and discard initial and end segments
% these are the ohase differences betwwen two channles
phi=angle(hilbert(x))-angle(hilbert(y));

% correct wrapping of phase differences to [-pi pi]
phi=wrap(phi);

% plot (phi);
% figure;
% hist (phi,30);

% PLI
p=abs(mean(sign(phi)));

end