function [icoh F] = imaginary_coherence(x,y,fs)
%IMAGINARY_COHERENCE The imaginary part of the coherence between x and y
%   
% Manolis Christodoulakis @ 2012

[Pxy,F] = cpsd(x,y,[],[],[],fs);
[Pxx,f] = pwelch(x,[],[],[],fs);
[Pyy,f] = pwelch(y,[],[],[],fs);

coherency = Pxy ./ sqrt(Pxx .* Pyy);
%mscoh = abs(coherency);
% mscoh = (abs(Pxy).^2) ./ sqrt(Pxx .* Pyy);
icoh = imag(coherency);

end

