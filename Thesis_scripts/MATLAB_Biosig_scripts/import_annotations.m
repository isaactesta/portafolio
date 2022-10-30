%IMPORT_ANNOTATIONS Imports the annotations of events from file
%
% OUTPUT
%   annot : Cell array with two columns, time and event title
%
% Manolis Christodoulakis @ 2012

function [annot] = import_annotations(filename);
    % Number of headerlines above annotations
    headerlines=5;

    f=fopen(filename);

    % Data appear in two columns: time (h:m:s.ms) followed by event title
    annot=textscan(f,' %d:%d:%2d.%d %[^\n]','headerlines',headerlines);
    
    %clear textData;
    fclose(f);
end