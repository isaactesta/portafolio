function [data] = ft_preprocess_loadsave(indir,patient,file,outdir,hp,lp)
%
% Manolis Christodoulakis @ 2013

    % Define the required preprocessing
    cfg = [];
    cfg.dataset = [indir '/' patient '/' file];
    cfg.continuous = 'no';
    cfg.hpfilter   = 'yes';
    cfg.hpfreq     = hp;
    cfg.lpfilter   = 'yes';
    cfg.lpfreq     = lp;

    % Check if the preprocessing has already been done
    reprocess = 1;
    dest = [outdir '/' patient '/'  strrep(file,'.edf','_data.mat')];
    if exist(dest,'file')
        disp('Loading data from file...');
        load(dest);
        
        % Is the saved preprocessing the same?
        reprocess = ~subcfg(cfg,data.cfg);
    end
    
    if reprocess
        disp('Preprocessing data...');
        data = ft_preprocessing(cfg);

        if (~exist([outdir '/' patient], 'dir'))
            mkdir([outdir '/' patient]);
        end
        save(dest, 'data','-v7.3');
    else
        disp('Data loaded from file...');
    end
end

function sub = subcfg(cfg1,cfg2)
% Checks whether all fields of cfg1 are contained in cfg2 with same values
     fields = fieldnames(cfg1);
     sub = 1;
     
     for i=1:size(fields)
         eval(['sub = sub && isfield(cfg2,''' fields{i} ''');']);
         if ~sub
             break;
         end

         eval(['sub = sub && isequal(cfg1.' fields{i} ',cfg2.' fields{i} ');']);
     end
end