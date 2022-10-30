function nseiz_exported = export_seiznets_matfile(patient, experiment, min_before, min_after)
%export_nets_matfile Exports an area from the nets file around every seizure
%
% Manolis Christodoulakis @ 2015

    if nargin<1, error('Please specify the patient number'); end
    if nargin<2, error('Please specify the experiment'); end
    if nargin<3, error('Please specify number of minutes before/after seizure to be extracted'); end
    if nargin<4, min_after = min_before; end

    % Load the data
    load patient_datafiles
    nets_fname     = [patient_dirs{patient} '/bipolar__ICA__' experiment '/nets.mat']; 
    nets_mat       = matfile(nets_fname);
    [nnodes,~,nnets,nfreq] = size(nets_mat,'nets_w5');
    info_mat       = matfile(datafiles{patient});
    srate          = info_mat.srate;
    montage        = 'bipolar';
    filtering      = 'ICA';
    win_size       = 5;
    nseiz_exported = 0;
    seizstart_wins = ceil(info_mat.seizstart./(srate*win_size));
    seizend_wins   = ceil(info_mat.seizend./(srate*win_size));
    nseiz          = size(seizstart_wins,1); 
    
    % Export nets around seizure(s)
    i = 1;
    while nseiz_exported<nseiz
        % Get the data
        seiz_win   = seizstart_wins(i,1);
        wins_permin= 60/win_size;
        start      = max(1,    seiz_win - min_before*wins_permin)
        finish     = min(nnets,seiz_win + min_after*wins_permin - 1)
        nets       = nets_mat.nets_w5(1:nnodes,1:nnodes,start:finish);

        % Fix the location of the seizure(s)
        indices    = find(seizstart_wins>=start & seizstart_wins<=finish &...
                          seizend_wins>=start   & seizend_wins<=finish)
        seizstart  = seizstart_wins(indices) - start + 1;
        seizend    = seizend_wins(indices)   - start + 1;

        
        % Save with appropriate filename
        indstr     = num2str(i);
        if numel(indices(indices>=i))>1, indstr = [indstr '-' num2str(indices(end,1))]; end
        
%         filename   = strrep(nets_fname, '.mat', ['_seiz_' indstr ...
%              '_[-' num2str(min_before) '_+' num2str(min_before) '].mat']);
        filename   = ['p' num2str(patient) '_nets_seiz_' indstr ...
              '_[-' num2str(min_before) '_+' num2str(min_before) '].mat'];
        save(filename,'nets','montage','filtering',...
             'seizstart','seizend','win_size');
        
        % Continue with the remaining
%         rem_indices  = find(allseizstart_wins<start & allseizstart_wins>finish-3*wins_permin &...
%                             allseizend_wins<start   & allseizend_wins>finish-2*wins_permin)
%         allseizstart_wins = allseizstart_wins(rem_indices);
%         allseizend_wins   = allseizend_wins(rem_indices);
        
        nseiz_exported = nseiz_exported + 1;
        i = i+1;
        for j=i:indices(end)
            if (seizstart_wins(j) < finish-3*wins_permin & ...
                seizend_wins(j) < finish-2*wins_permin)
                
                nseiz_exported = nseiz_exported + 1;
                i = i+1;
            end
        end
    end
end