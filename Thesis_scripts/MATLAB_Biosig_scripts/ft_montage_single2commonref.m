function averageref_data = ft_montage_single2commonref(data)
%FT_MONTAGE_SINGLE2COMMONREF Changes the data montage to average reference
%
% Manolis Christodoulakis @ 2013

    cfg = [];
    cfg.reref       = 'yes';
    cfg.refchannel  = 'all';
    %cfg.channel    = {'all','-AC1','-AC2','-Ref','-AC26'}; 
    averageref_data = ft_preprocessing(cfg,data);
end

