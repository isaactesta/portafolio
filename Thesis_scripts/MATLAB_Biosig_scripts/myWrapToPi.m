function [wrapped] = myWrapToPi(data)
    
    wrapped = data - data/(2*pi);
    data(data>pi) = 2*pi-data(data>pi);
end