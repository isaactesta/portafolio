function ftdata = ft_singular2ftdata(data,fs)
%FT_SINGULAR2FTDATA Constructs an FT-format data structure containing the data
%
%   data    is the input matrix; can be either channel x time or 
%           time x channel - the smallest dimension is considered to be the
%           channel
%   fs      the sampling rate
%
% Manolis Christodoulakis @ 2013

    % Determine number of channels and number of samples
    nsamples        = max(size(data));
    nchannels       = min(size(data));
    
    % Rotate to get channels in rows
    if size(data,1) ~= nchannels
        data = data';
    end
    
    % Assign labels
    ftdata          = [];
    ftdata.fsample  = fs;
    ftdata.label    = {'AC1'; 'AC2'; 'Ref'; 'Fp1'; 'F7'; 'T3'; 'T5'; 'O1'; 'F3'; 'C3'; 'P3'; 'Fz'; 'Cz'; 'Pz'; 'F4'; 'C4'; 'P4'; 'Fp2'; 'F8'; 'T4'; 'T6'; 'O2'; 'AC23'; 'AC24'; 'AC25'; 'AC26'};
    if nchannels == 24
        ftdata.label = ftdata.label(1:24);
    end
    
    % Copy the data and the associated time info
    ftdata.trial{1} = data(1:min(26,nchannels),:);
    ftdata.time{1}  = (0:1/ftdata.fsample:(nsamples-1)/ftdata.fsample);
end