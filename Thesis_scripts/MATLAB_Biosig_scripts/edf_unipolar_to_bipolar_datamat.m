function edf_unipolar_to_bipolar_datamat(edffile,matfile)
    [EDFdata, header] = ReadEDF(edffile);
    data = edfdata_to_bipolar(EDFdata);
    evstart = [];
    evend = [];
    starttime=header.starttime;
    
    save(matfile,'data','evstart','evend','starttime','-v7.3');
end