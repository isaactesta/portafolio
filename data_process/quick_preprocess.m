a = bpf; dff = zeros(size(a));
for n = 3:len-3;
    dff(n) = 0.125*samp_freq * (-a(n-2) - 2*a(n-1) + 2*a(n+1) + a(n+2));
end
dff(1:2) = diff(a(1:3))*samp_freq;
dff(end-1:end) = diff(a(end-2:end))*samp_freq;