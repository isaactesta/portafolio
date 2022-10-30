function annot = plot_mat_annot(filename,plot_start_time,scale)
% PLOT_MAT_ANNOT Plot part of data from mat file in order to annotate
% (with Lefteris)
%
%   plot_start_time is given [hours min sec ms] and it calculates 
%       rows automatically based on the srate saved in the file
% 
%   if the data is not in bipolar format, then the necessary part is
%       convreted to bipolar
%
% Manolis Christodoulakis @ 2015

    % Open the file for reading
    mat = matfile(filename)
    [nlines nchans] = size(mat,'data');
    
    % Calculate rows to load
    mat.starttime
    indx  = time_diffs_to_index(plot_start_time,mat.starttime,mat.srate)
    time_frame = 20*60;
    min(indx+time_frame*mat.srate-1,nlines)
    lines = indx:min(indx+time_frame*mat.srate-1,nlines);
    
    % Convert to bipolar
%     if strcmp(mat.montage,'bipolar')
%         bipolar = filtered_data(lines,1:18);
    if mat.srate == 200
        bipolar = xltek_to_bipolar(mat.data(lines,1:nchans));
    elseif mat.srate == 500
        bipolar = nicolet_to_bipolar(mat.data(lines,1:nchans));
    end
    
    plot_EEG_data(bipolar,scale,1:18,lines,mat.srate,'bipolar')
    %global ANNOT
    %annot = indx + ANNOT
end