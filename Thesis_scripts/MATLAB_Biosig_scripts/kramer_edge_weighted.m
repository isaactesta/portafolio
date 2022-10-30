%KRAMER_EDGE_WEIGHTED Computes the correlation between x and y as described by Kramer et. al 2008
% x and y are time series that are cross-correlated using windows of 1 sec.
%
% OUTPUT
%   maxcor : The maximum correlation between x and y
%            Note that maxcor is the maximum only within a limited lag
%            range.
%   maxlag : The lag at which the maxcor occurred
%
% Manolis Christodoulakis @ 2012

function [maxcor,maxlag]=kramer_edge_weighted(x,y)

    SRATE = 200;            % Sampling rate, 200Hz
    WINDOW = 1;             % 1s windows
    SHIFT = 0.5;            % 0.5s shift between consecutive windows
    MAXLAGS = 0.25;         % maximum lag for xcorr (in seconds)
    MAXACCEPTEDLAG=0.15;    % maxcor will be accepted only if it occurred
                            % within this time lag (CURRENTLY IGNORED)

    n = size(x);            % Number of rows of each signal
    m = size(y);    

    if (n~=m)
        warning('The datasets must be of equal size');
        return;
    end

    maxcor = 0;             % Initially, there is no correlation
    maxlag = 0;
    for i=1:SHIFT*SRATE:n-WINDOW*SRATE+1
        j=min(i+WINDOW*SRATE-1,n);

        % Compute the correlations (unbiased, need to normalise)
        %[cors,lags] = xcorr(x(i:j)-mean(x(i:j)),y(i:j)-mean(y(i:j)),...
        %               MAXLAGS*SRATE,'unbiased');

        % Normalize
        %cors = cors./(std(x(i:j))*std(y(i:j)));

        % Compute the correlation coefficients (normalized)
        [cors,lags] = xcorr(x(i:j)-mean(x(i:j)),y(i:j)-mean(y(i:j)),...
                       MAXLAGS*SRATE,'coeff');

        [current_maxcor,maxindex]=max(abs(cors));
        current_maxlag = lags(maxindex);

        if (current_maxcor>maxcor)
            maxcor = current_maxcor;
            maxlag = current_maxlag;
        end
    end

end