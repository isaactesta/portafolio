% Creates N seconds of a 60-bpm ECG sampled at sf Hz, stored in z.
function z = easy_ecg (sf, N)

% sf = 256; N = 2;
n = round(sf*.05); t = (1/sf:1/sf:N)';
x = sin(2*pi*9*t(1:n)); y = zeros(sf-n, 1);
z = [t repmat([x;y],N,1)];

