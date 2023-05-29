%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: E:\Isaac_D2\periodicities_part2.xlsx
%    Worksheet: Select worksheet to import
%    Sheet: 'LF', 'ENV', or 'COH'
%    Add Patients as finished processing
%

%% Set up the Import Options and import the data
function [periods] = importexcel(sheet)
opts = spreadsheetImportOptions("NumVariables", 13);

% Specify sheet and range
opts.Sheet = sheet;
opts.DataRange = "A6:M10";

% Specify column names and types
opts.VariableNames = ["VarName1", "Sub02", "Sub03", "Sub04", "Sub05", "Sub06", "Sub07", "Sub08", "Sub09", "Sub10", "Sub14", "Sub21", "Sub24"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify variable properties
opts = setvaropts(opts, ["VarName1", "Sub02", "Sub03", "Sub04", "Sub05", "Sub06", "Sub07", "Sub08", "Sub09", "Sub10", "Sub14", "Sub21", "Sub24"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["VarName1", "Sub02", "Sub03", "Sub04", "Sub05", "Sub06", "Sub07", "Sub08", "Sub09", "Sub10", "Sub14", "Sub21", "Sub24"], "EmptyFieldRule", "auto");

% Import the data
periods = readtable("E:\Isaac_D2\periodicities_part2.xlsx", opts, "UseExcel", false);

clear opts
end
