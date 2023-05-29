% Extract Results from MKFA2

% LF = 0.04 - 0.15
% HF = 0.15 - 0.4

%LF band was commented out

% [S,f,HF,LF,mean_HF,mean_LF,max_HF,max_LF,HFband,LFband] = ext_res(resultsMKFA2);

function [S,f,HF,LF,mean_HF,mean_LF,max_HF,max_LF,HFband,LFband] = ext_res(resultsMKFA2)
f = resultsMKFA2.MVARmeasures.f;
SP = resultsMKFA2.MVARmeasures.SP;
S = SP{1,1};

% HF and LF
LF_IDX = find(f>0.04 & f<0.15);
HF_IDX = find(f>0.15 & f<0.4);

LF = S(LF_IDX,:);
HF = S(HF_IDX,:);

% Mean of each Index
mean_LF = mean(LF);
mean_HF = mean(HF);

% Max for HF and LF
m_hf = mean(HF,2);
[MH,IH] = max(m_hf);

m_lf = mean(LF,2);
[ML,IL] = max(m_lf);

f_HF_max = f(HF_IDX(IH));
f_LF_max = f(LF_IDX(IL));

max_HF = (HF(IH,:));
max_LF = (LF(IL,:));

% Max Band
HF_band = (HF(IH:IH+10,:));
LF_band = (LF(IL:IL+10,:));

HFband = mean(HF_band);
LFband = mean(LF_band);
end

