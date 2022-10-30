% Locate the proper 'ei' numerical range for ECG loading

if pat_no >= 0 & pat_no < 300,
  channel = '7-9';
elseif pat_no > 1110 & pat_no < 1307,
  channel = '7-9';
elseif pat_no > 1532 & pat_no < 3000,
  channel = '4-6';
elseif pat_no >= 3000 & pat_no <= 3001,
  channel = '19-21';
elseif pat_no >= 3002 & pat_no <= 3011,
  channel = '24-26';
elseif pat_no >= 3012 & pat_no <= 3017,
  channel = '3-5';
elseif pat_no < 3166 & pat_no >= 3100,
  channel = '24-26';
elseif pat_no < 3197 & pat_no >= 3166,
  channel = '9-11';
else
  channel = '7-9';
end

if pat_no >= 1000,
	p_string = num2str(pat_no);
elseif pat_no < 10,
	p_string = ['000' num2str(pat_no)];
elseif pat_no < 100,
	p_string = ['00' num2str(pat_no)];
else
	p_string = ['0' num2str(pat_no)];
end
