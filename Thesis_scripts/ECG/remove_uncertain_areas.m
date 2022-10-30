function RR = remove_uncertain_areas (t, qrs, messy);

[temp, k] = min (abs(qrs(1)-t));
j = 2; RR = [];
lt = length(t);
while j < length(qrs)-1,
   old_k = k;
   while k < lt & t(k) < qrs(j),
       k = k + 1;
   end
   middle_k = k;
   while k < lt & t(k) < qrs(j+1),
       k = k + 1;
   end
   if sum(messy(old_k:k)) > 0,
       % Problem detected whilst reaching this beat
       %disp([qrs(j) old_k k t(old_k) t(k)])
   else
       RR = [RR; qrs(j)-qrs(j-1)];
   end
   j = j + 1; k = middle_k;
end
