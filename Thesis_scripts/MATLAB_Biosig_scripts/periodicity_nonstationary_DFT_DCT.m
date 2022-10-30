function stnry_per = periodicity_nonstationary_DFT_DCT(x,fs,N,wsize,o)
% Calculates the periodicity of a nonstationary signal using short-time DFT
% and DCT
% Input:
%   x       is the signal
%   fs      is the sampling frequency
%   N       is the desired window size for the short-time DFT
%   wsize   is the desired window size, within which the non-stationary
%           algorihtm is applied
%   o       is the overalp of the windows
%
% Reference:
%   Parthasarathy, Srinivasan, Sameep Mehta, and Soundararajan Srinivasan. 
%   "Robust periodicity detection algorithms." Proceedings of the 15th ACM 
%   international conference on Information and knowledge management. 
%   ACM, 2006.
%
% Manolis Christodoulakis @ 2014

    T = size(x,1);
    autocorr_sum = zeros(1,wsize-N+1);
    %for i=1:wsize-o:T
    for i=1:wsize-o:T-wsize+1
        fprintf('x(%d:%d)\n',i,min(i+wsize-1,T));
        xloc = x(i:min(i+wsize-1,T));
        autocorr_sum = autocorr_sum + ...
            periodicity_stationary_DFT_DCT(xloc,fs,N);
    end
    
    figure
    plot((1:size(autocorr_sum,2))*5/3600,autocorr_sum)
    ylabel ('Autocorrelation')
    xlabel('Autocorrelation Lags (Hours)')
    title ('Summed Autocorrelation - Non-Stationary')
    grid on
    
end