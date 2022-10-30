function migrate_copy(infile,outfile)
    load(infile,'evend','evstart','montage','srate','startdate','starttime');
    save(outfile,'-v7.3','-append','evend','evstart','montage','srate','startdate','starttime');
end