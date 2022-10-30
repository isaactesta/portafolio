function [str]=patient_to_str(dir)

    if isStrFound(dir,'9fee1')
        str = 'Patient 1';
    elseif isStrFound(dir,'95a3a')
        str = 'Patient 2';
    elseif isStrFound(dir,'c840d')
        str = 'Patient 3';
    elseif isStrFound(dir,'bb167')
        str = 'Patient 4';
    elseif isStrFound(dir,'f84c1')
        str = 'Patient 5';
    elseif isStrFound(dir,'DP-98304')
        str = 'Patient 6';
    elseif isStrFound(dir,'GM-10837')
        str = 'Patient 7';
    elseif isStrFound(dir,'MV-5859')
        str = 'Patient 8';
    elseif isStrFound(dir,'RC-4337')
        str = 'Patient 9';
    elseif isStrFound(dir,'MC2-9672')
        str = 'Patient 10';
    elseif isStrFound(dir,'KC-11561')
        str = 'Patient 11';
    elseif isStrFound(dir,'KP-10753')
        str = 'Patient 12';
    elseif isStrFound(dir,'SN-10838')
        str = 'Patient 13';
%     elseif isStrFound(dir,'')
%         str = '';
%     elseif isStrFound(dir,'')
%         str = '';
%     elseif isStrFound(dir,'')
%         str = '';
    else
        str = dir;
    end
end

function found = isStrFound(str,pattern)
    found = ~isempty(strfind(str,pattern));
end