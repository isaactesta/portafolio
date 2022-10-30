function export_ftvisual_wholefile(matfile)
%export_ftvisual_wholefile Exports the whole file and event annotations
%   
%   Requires the existence of a file with the same name as the data file
%   (matfile) followed by '_seizures-and-artifacts', where the seizures are
%   saved in a cfg data structure.
%
% Manolis Christodoulakis @ 2014

    % Load the data and the cfg data structure containing the seizures'
    % positions
    load(matfile);
    load(strrep(matfile,'_data.mat','_seizures-and-artifacts.mat'));
    fulldata = data;
    clear data;
    
    % Read various info from the file
    srate = fulldata.fsample;
    startdate = fulldata.hdr.orig.T0(1:3);  % Array: year, month, date
    % startdate = [str2num(header.startdate(7:8));str2num(header.startdate(4:5));str2num(header.startdate(1:2))];
    starttime = fulldata.hdr.orig.T0(4:6);  % Array: hours, min, sec
    % starttime = [str2num(header.starttime(1:2));str2num(header.starttime(4:5));str2num(header.starttime(7:8))];
    channel_label = fulldata.label;
    if ~isempty(strfind(fulldata.label(1),'-Ref'))
        montage = 'reference';
    else
        montage = 'bipolar';
    end
    
    % Export events (in SAMPLES)
    %evstart = floor(cfg.artfctdef.seizure.artifact(1:2:end,1)/srate);
    %evend = floor(cfg.artfctdef.seizure.artifact(2:2:end,1)/srate);
    evstart = cfg.artfctdef.seizure.artifact(1:2:end,1);
    evend = cfg.artfctdef.seizure.artifact(2:2:end,1);
    assert(isequal(size(evstart),size(evend)),...
        'Error: evstart and evend sizes do not match!');

    % Get out the data
    cut_cfg = [];
    data = cell2mat(fulldata.trial);

    % Save to file
    [path, filename] = fileparts(matfile);
    out_file = [path '/seizure_' filename '.mat'];
    save(out_file,'data','srate','startdate','starttime','evstart',...
        'evend','montage','channel_label','-v7.3');
end

