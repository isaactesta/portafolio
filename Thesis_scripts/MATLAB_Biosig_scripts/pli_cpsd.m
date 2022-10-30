function p = pli_cpsd(x,y)

% %% remove dc
x=x-mean(x);
y=y-mean(y);

% get cross-spectrum and its imaginary part
cross_spectrum = cpsd(x,y);

cpsd_imag = imag(cross_spectrum);


% PLI
p = abs(mean(sign(cpsd_imag)));

end