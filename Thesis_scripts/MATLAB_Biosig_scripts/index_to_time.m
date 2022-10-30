function time = index_to_time(index,srate)
% Converts an integer to [hours mins secs msecs]
%
% Manolis Christodoulakis @ 2014

    h = floor(double(index)/(3600*srate));
    index = mod(index,3600*srate);
    
    m = floor(double(index)/(60*srate));
    index = mod(index,60*srate);
    
    s = floor(double(index)/srate);
    index = mod(index,srate);
    
    ms = double(index)*1000/srate;
    
    time = [h m s ms];

end