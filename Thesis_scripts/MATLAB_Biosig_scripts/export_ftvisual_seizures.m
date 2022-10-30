function nseizures_exported = export_ftvisual_seizures(matfile, min_before, min_after, nseizures_before)
%export_ftvisual_seizures Exports an area around every seizure in the matfile
%   
%   Requires the existence of a file with the same name as the data file
%   (matfile) followed by '_seizures-and-artifacts', where the seizures are
%   saved in a cfg data structure.
%
%   If not enough data is available before or after a seizure, this will be
%   reflected in the output filename. If additional seizures occur in the
%   requested range, these will be annotated too.
%
%   TO BE CONTINUED **********************
%
% Manolis Christodoulakis @ 2013

    if nargin<4
        nseizures_before = 0;
    end
%     nseizures_exported = nseizures_before;
    
    % Load the data and the cfg data structure containing the seizures
    % positions
    load(matfile);
    load(strrep(matfile,'_data.mat','_seizures-and-artifacts.mat'));
    fulldata = data;
    clear data;
    
    %SRATE = 500;
    srate = fulldata.fsample;

    % Process each seizure in turn (note the increments of size 2)
    i = 1;
    while (i<size(cfg.artfctdef.seizure.artifact,1))
        loc_min_before = min_before;
        loc_min_after = min_after;
        
        % Identify the seizure start and end (in samples)
        seizstart = cfg.artfctdef.seizure.artifact(i,1);
        seizend = cfg.artfctdef.seizure.artifact(i+1,1);
        disp(['Seizure at sec ' num2str(seizstart/srate)]);
        
        % Identify the seconds (trials) to be included in the file
        % This is provisional; if more than one seizures occur in this
        % range, the range will be further extended until we get
        % min_before minutes before the first seizure and min_after
        % minutes after the end (or until exhaustion of the file)
        % NOT IMPLEMENTED YET
        num_secs_in_file = size(fulldata.trial,2)
        sec_start = max(1,floor(seizstart/srate-min_before*60));
        sec_end = min(floor(seizstart/srate+min_after*60),num_secs_in_file);
        disp(['Initial range of sec.: ' num2str(sec_start) ' - ' num2str(sec_end)]);
        
        % Find all events occurring in the current range
        allevstart = floor(cfg.artfctdef.seizure.artifact(1:2:end,1)/srate);
        allevend = floor(cfg.artfctdef.seizure.artifact(2:2:end,1)/srate);

        evstart = allevstart(allevstart>=sec_start & allevstart<=sec_end)
        evend = allevend(allevend>=sec_start & allevend<=sec_end)
        while (evstart(1)-sec_start+1)/60 < min_before && sec_start>1
            sec_start = max(1,floor(evstart(1)-min_before*60));
            disp(['Earlier event at ' num2str(evstart(1))]);
            disp(['New range: ' num2str(sec_start) ' - ' num2str(sec_end)]);
            evstart = allevstart(allevstart>=sec_start & allevstart<=sec_end);
            evend = allevend(allevend>=sec_start & allevend<=sec_end);
        end
        
        while (sec_end-evstart(end)+1)/60 < min_after && sec_end<num_secs_in_file
            sec_end = min(floor(evstart(end)+min_after*60),num_secs_in_file);
            disp(['Later event at ' num2str(evstart(end))]);
            disp(['New range: ' num2str(sec_start) ' - ' num2str(sec_end)]);
            evstart = allevstart(allevstart>=sec_start & allevstart<=sec_end);
            evend = allevend(allevend>=sec_start & allevend<=sec_end);
        end
        
        % Get out the data
        cut_cfg = [];
        cut_cfg.trials = sec_start : sec_end;
        ftdata = ft_redefinetrial(cut_cfg,fulldata);
        data = cell2mat(ftdata.trial);
        clear ftdata;
        
        % Calculate the correct location of events in the exported data
        evstart = evstart - sec_start + 1;
        evend   = evend - sec_start + 1;
        
        % Set the actual, exported, boundaries
        loc_min_before = round((seizstart/srate-sec_start+1)/6) / 10;
        if (loc_min_before < min_before)
            warning('Not enough data before seizure');
        end
        loc_min_after = round((sec_end-seizstart/srate+1)/6) / 10;
        if (loc_min_after < min_after)  
            warning('Not enough data after seizure');
        end
        
        first = nseizures_before + (i+1)/2;
        last  = nseizures_before + (i+1)/2+size(evstart,1)-1;
        if size(evstart,1)>1
            seizure_name = [num2str(first) '-' num2str(last)];
        else
            seizure_name = num2str(first);
        end
        
        % If more than one seizure is included, skip the next
        i = i + 2*size(evstart,1);
        
        % Save to file
        [path, filename] = fileparts(matfile);
        day_num = char(regexp(filename,'(?!Day\s*)\d+','match'));
        out_file = [path '/seizure_' seizure_name '_Day_' day_num '_[-' num2str(loc_min_before) 'min_+' num2str(loc_min_after) 'min].mat'];
        disp(['File exported at: ' out_file]);
        save(out_file,'data','evstart','evend');
    end
    nseizures_exported = last;
    disp(['Num of seizures exported so far: ' num2str(nseizures_exported)]);
end

