% compute joint entropy for two signals using a windowed approach

function [win_joint_entropy] = windowed_entropy(signal1,signal2,window)

j = 1;
for i=1:length(signal1)-window
    temp1 = signal1(i:i+window);
    temp2 = signal2(i:i+window);
    win_joint_entropy(j) = condentropy(temp1,temp2);
    j = j+1;
end

end