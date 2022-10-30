function [ data ] = binarize( data, threshold )
%BINARIZE Data above the threshold are set to 1, else 0
%
% Manolis Christodoulakis @ 2012
    fprintf(['Binarizing data (threshold = ' num2str(threshold) ')... ']);
    
    data(data>threshold|data<-threshold)=1;
    data(data<1)=0;
    
    fprintf('Done!\n');

end

