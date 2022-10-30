function [str]=patient_to_str(dir)

    if isStrFound(dir,'9fee1')
        str = 'I.I.';
    elseif isStrFound(dir,'95a3a')
        str = 'M.C.';
    elseif isStrFound(dir,'c840d')
        str = 'T.K.';
    elseif isStrFound(dir,'bb167')
        str = 'H.E.';
    elseif isStrFound(dir,'f84c1')
        str = 'M.G.';
    elseif isStrFound(dir,'DP-98304')
        str = 'D.P.';
    elseif isStrFound(dir,'GM-10837')
        str = 'G.M.';
    elseif isStrFound(dir,'MV-5859')
        str = 'M.V.';
    elseif isStrFound(dir,'RC-4337')
        str = 'R.C.';
    elseif isStrFound(dir,'MC2-9672')
        str = 'M.C.2';
    elseif isStrFound(dir,'KC-11561')
        str = 'K.C.';
    elseif isStrFound(dir,'KP-10753')
        str = 'K.P.';
    elseif isStrFound(dir,'SN-10838')
        str = 'S.N.';
    elseif isStrFound(dir,'DK-2440')
        str = 'D.K.';
%     elseif isStrFound(dir,'')
%         str = '';
    else
        str = dir;
    end
end

function found = isStrFound(str,pattern)
    found = ~isempty(strfind(str,pattern));
end