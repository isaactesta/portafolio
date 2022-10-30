function stnry_per = periodicity_stationary_DFT_DCT(x,fs,N,starttime)
% Calculates the periodicity of a stationary signal using short-time DFT
% and DCT
% Input:
%   x       is the signal
%   fs      is the sampling frequency
%   N       is the desired window size for the short-time DFT
%
% Reference:
%   Parthasarathy, Srinivasan, Sameep Mehta, and Soundararajan Srinivasan. 
%   "Robust periodicity detection algorithms." Proceedings of the 15th ACM 
%   international conference on Information and knowledge management. 
%   ACM, 2006.
%
% Manolis Christodoulakis @ 2014
    
    % Calculate and plot the DFT
    [S,F,T,P] = spectrogram(x,kaiser(N),N-1,N,fs,'yaxis');
    
%     figure
%     surf(T,F,10*log10(P),'edgecolor','none');
%     axis tight,  view(0,90)
%     xlabel 'Time (s)', ylabel 'Frequency (Hz)'
%     title ('Spectrogram')
    
    % Discrete Cosine Transform of the DFT magnitude
    magnitude_S=abs(S);
    Discrete_cosine = dct(magnitude_S);  
    
    % Autocorrelation of DCT
    for i= 1:size(Discrete_cosine,1);
        [ACF_DCT(i,:),Lags(i,:),bounds(i,:)] = autocorr(Discrete_cosine(i,:),length(Discrete_cosine(i,:))-1,1,2);
    end

    % Sum of autocorrelation
    stnry_per = sum(ACF_DCT);
    fprintf('Size of the autocorr: %d x %d\n',size(stnry_per,1),size(stnry_per,2));

    figure
    plot((1:size(stnry_per,2))*5/3600,stnry_per)   
    ylabel('Autocorrelation')
    xlabel('Autocorrelation Lag (Hours)')
    if nargin<4
        window_start = '';
    else
        window_start = ['(window start at ' num2str(starttime) ')'];
    end
    title (['Summed Autocorrelation of DCT' window_start])
    grid on

end