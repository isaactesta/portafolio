function qrs=fixqrs(ecg,qrs_index);
%searches for a peak around the peaks obtained from find_qrs_peak to
%compensate for the delay imposed by the different filtering steps.
%Written by Christina Orphanidou, November 2011.
qrs=[];
for i=1:length(qrs_index)
    di=length(ecg)-qrs_index(end);
    if di<2
        di=di;
    else di=2;
    end
m=max(ecg(qrs_index(i)-di:qrs_index(i)+di));
M=ecg(qrs_index(i)-di:qrs_index(i)+di);
a=find(M==m);
if length(a)>1
    a=min(a);
else
    a=a;
end
q=qrs_index(i)+a-3;
qrs=[qrs q];
end
