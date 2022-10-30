function nseiz_exported = export_seizures_matfile(patient, min_before, min_after, bipolar)
%export_seizures_matfile Exports an area around every seizure in the matfile
%
% Manolis Christodoulakis @ 2015

    if nargin<1, error('Please specify the patient number'); end
    if nargin<2, error('Please specify number of minutes before/after seizure to be extracted'); end
    if nargin<3, min_after = min_before; end
    if nargin<4, bipolar   = 1; end
    
    % Load the data
    load patient_datafiles
    mat            = matfile(datafiles{patient});
    allseizstart   = mat.seizstart;
    allseizend     = mat.seizend;
    srate          = mat.srate;
    montage        = mat.montage;
    filtering      = mat.filtering;
    channel_labels = mat.channel_labels;
    [ndata,nchans] = size(mat,'data');
    
    % Export seizure(s)
    while ~isempty(allseizstart)
        % Get the data
        i          = 1; 
        start      = max(1,allseizstart(i,1)-srate*60*min_before);
        finish     = min(ndata,allseizstart(i,1)+srate*60*min_after-1);
        data       = mat.data(start:finish,1:nchans);
        
        if bipolar && ~strcmp(montage,'bipolar')
            if srate==200, [data,channel_labels] = xltek_to_bipolar(data);
            else           [data,channel_labels] = nicolet_to_bipolar(data); end
            montage = 'bipolar';
        end
        
        % Fix the location of the seizure(s)
        indices    = find(allseizstart>=start & allseizstart<=finish &...
                          allseizend>=start   & allseizend<=finish);
        seizstart  = allseizstart(indices) - start + 1;
        seizend    = allseizend(indices)   - start + 1;
        starttime  = time_add_index(mat.starttime,start-1,srate);
        startdate  = mat.startdate;
        
        % Save with appropriate filename
        indstr     = num2str(indices(1));
        if size(indices)>1, indstr = [indstr '-' num2str(indices(end))]; end
        
        if bipolar, filename = strrep(datafiles{patient},'.mat', '_bipolar.mat');
        else        filename = datafiles{patient}; end
        filename   = strrep(filename, '.mat', ['_seiz_' indstr ...
             '_[-' num2str(min_before) '_+' num2str(min_before) '].mat']);
        save(filename,'data','srate','montage','filtering',...
             'channel_labels','seizstart','seizend','startdate','starttime');
        
        % Continue with the remaining
        rem_indices  = find(allseizstart<start & allseizstart>finish-srate*3*60 &...
                          allseizend<start   & allseizend>finish-srate*2*60);
        allseizstart = allseizstart(rem_indices);
        allseizend   = allseizend(rem_indices);
    end
end