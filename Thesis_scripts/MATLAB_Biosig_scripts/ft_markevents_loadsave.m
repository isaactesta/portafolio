function [cfg] = ft_markevents_loadsave(patient,file,outdir,data,blocksize)
%
% Manolis Christodoulakis @ 2013

    % Old type or new type input data?
    if ~isempty(strfind(file,'.txt'))
        ext = '.txt';
    elseif ~isempty(strfind(file,'.edf'))
        ext = '.edf';
    else
        error('Unknown file extension');
    end
    
    % Check existence of annotations
    cfgfile = [outdir '/' patient '/'  strrep(file,ext,'_seizures-and-artifacts.mat')];
    if (exist(cfgfile, 'file'))
        load(cfgfile,'cfg');
        newcfg = 0;
    else
        cfg = [];
        cfg.continuous  = 'yes';
        cfg.viewmode = 'vertical';
        cfg.blocksize = blocksize;
        cfg.selectfeature = 'seizure';
        cfg  = ft_databrowser(cfg,data);
        newcfg = 1;
    end

    % Mark artifacts around events
    cfg.selectfeature = 'artifacts';
    cfg.blocksize = blocksize;
    cfg = ft_databrowser(cfg,data);

    if newcfg && isempty(cfg.artfctdef.seizure.artifact) && isempty(cfg.artfctdef.artifacts.artifact)
        disp('No events have been marked. Exiting without save.');
    else
        % Save
        disp('Saving...');
        if (~exist([outdir '/' patient], 'dir'))
            mkdir([outdir '/' patient]);
        end
        save(cfgfile, 'cfg');
        disp(' Done!');

    end
end