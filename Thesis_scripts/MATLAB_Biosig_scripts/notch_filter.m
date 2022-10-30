function y = notch_filter(x,fs,f0)
%notch_filter A simple notch filter
%
%   x   The data to be filtered, column-wise
%   fs  The sampling frequency
%   f0  The frequncy to remove (default 50)

    if nargin<3
        f0 = 50;
    end
    
    fn = fs/2;              % Nyquist frequency
    freqRatio = f0/fn;      % Ratio of notch freq. to Nyquist freq.
    notchWidth = 0.1;       % Width of the notch

    % Compute zeros
    zeros = [exp( sqrt(-1)*pi*freqRatio ), exp( -sqrt(-1)*pi*freqRatio )];

    % Compute poles
    poles = (1-notchWidth) * zeros;

%     figure;
%     zplane(zeros.', poles.');

    b = poly( zeros ); %# Get moving average filter coefficients
    a = poly( poles ); %# Get autoregressive filter coefficients

%    figure;
%    freqz(b,a,32000,fs)

    % Filter signal x
    y = filter(b,a,x);
end