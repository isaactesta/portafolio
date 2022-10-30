%importEEG Imports EEG data that have been exported from Wave
%
% IMPORTANT: Need to have replaced all strings in the file (e.g. 'AMP's) 
%   with numbers (e.g. -1) before running this function.
%
% INPUT:
%   filename    : The input file
%   headerlines : (Optional) The number of headerlines in the input file.
%                 Default is 0.
%
% OUTPUT:
%   data    : The actual (numerical) data. Columns are channels (1-36)
%   indices : The time moments (h:m:s.ms), when each row was recorded. 
%
% Manolis Christodoulakis @2011

function [data,indices] = importEEG(filename,headerlines);
    txt=fopen(filename);
    
    if (nargin==1)
        headerlines = 0;
    end
   
    %                       d  t eb 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 ` tr     
    textData=textscan(txt,'%*s%s%*u%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%n%*s','headerlines',headerlines);
    %textData=textscan(txt,'%*s%*s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%*s','headerlines',headerlines);

    indices = textData{1};
    data    = cell2mat(textData(2:end));
    
    clear textData;
    fclose(txt);  
end