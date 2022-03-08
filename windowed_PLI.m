% Compute Phase Locking values using a windowed approach
% Will use phase_locking.m function
% Window refers to size of the window used to compute, will use overlapping
% winows


function [win_pli] = windowed_PLI(phase1,phase2,window)

j=1;
for i=1:1:length(phase1)-window
    temp1 = phase1(i:i+window);
    temp2 = phase2(i:i+window);
    win_pli(j) = phase_lag(temp1,temp2);
    j = j+1;
end

end