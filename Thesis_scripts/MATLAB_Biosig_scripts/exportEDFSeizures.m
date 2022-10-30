function nseizures_exported = exportEDFSeizures(edf, min_before, min_after, nseizures_before)
%exportEDFSeizures Exports an area around a seizure
%   
%   Requires the edf file to contain 'start' and 'end' events to annotate
%   the start and end of seizures. All seizures will be exported as
%   separate .mat files.
%
%   If not enough data is available before or after a seizure, this will be
%   reflected in the output filename

    SRATE = 500;
    if nargin<4
        nseizures_before = 0;
    end

    % Import everything from the input file
    [EDFdata, header] = ReadEDF(edf);

    % Convert data to matrix (21 columns/channels)
    EDFdata = cell2mat(EDFdata(1:21));
    rows = size(EDFdata,1)

    % Get start/end events
    start_sec       = header.annotation.starttime(find(strcmp(header.annotation.event','start')))
    start_event_row = floor(start_sec * SRATE)
    if (size(start_sec,1)==0)
        error('No ''start'' events found!');
    end

    end_sec         = header.annotation.starttime(find(strcmp(header.annotation.event','end')))
    end_event_row   = floor(end_sec * SRATE)
    if (size(end_sec,1)==0)
        error('No ''end'' events found!');
    end
    
    if (size(end_sec,1)~=size(start_sec,1))
        error('The number of ''start'' events does not match the number of ''end'' events in the EDF file!');
    end


    % Find boundaries of data
    first_data_row  = max(1,floor((start_sec-min_before*60)*SRATE))
    last_data_row   = min(floor((start_sec+min_after*60)*SRATE)-1,rows)
    
    % Save everything to mat file(s)
    nseizures_exported = nseizures_before;
    for i=1:size(start_sec)
        % Get out the data
        data = EDFdata(first_data_row(i):last_data_row(i),:);
        
        % Get the location of events (within the partial/event file) in
        % seconds
        evstart = (start_event_row(start_event_row>=first_data_row(i) & start_event_row<=last_data_row(i)) - first_data_row(i)) / SRATE
        evend   = (end_event_row(end_event_row>=first_data_row(i) & end_event_row<=last_data_row(i)) - first_data_row(i)) / SRATE
        
        % In case not enough data is available, set boundaries accordingly
        if (first_data_row(i)==1)
            min_before = round(start_sec/6) / 10;
            warning('Not enough data before seizure');
        end
        if (last_data_row(i)==rows)
            min_after  = round((rows/SRATE - start_sec)/6) / 10;
            warning('Not enough data after seizure');
        end
        
        % Save to file
        first = nseizures_exported + 1;
        last  = first + size(evstart,1) - 1;
        nseizures_exported = nseizures_exported + size(evstart,1);
        if first~=last
            seizure_name = [num2str(first) '-' num2str(last)];
        else
            seizure_name = num2str(first);
        end
        [path, filename] = fileparts(edf);
        day_num = char(regexp(filename,'(?!Day\s*)\d+','match'));
        out_file = [path '/seizure_' seizure_name '_Day_' day_num '_[-' num2str(min_before) 'min_+' num2str(min_after) 'min].mat'];
        disp(['File exported at: ' out_file]);
        save(out_file,'data','evstart','evend');
        
%         save(['seizure_' num2str(start_sec(i)) '_[-' num2str(min_before) 'min_+' num2str(min_after) 'min].mat'],...
%              'data','evstart','evend');
    end

end

