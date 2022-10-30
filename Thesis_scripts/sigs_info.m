function [LF,ENV,COH,order,seiz,parts,start,fin] = sigs_info(sub)

PATH_SUBS = 'E:\Isaac_D2\Interactions\Trials_lab\Subject';
PATH_DATE = 'E:\Isaac_D2\M2_codes\subjects_process\Subject';

delta = load(strcat(PATH_SUBS,num2str(sub, '%02d'),'\Periods\Delta_full_res.mat'));
theta = load(strcat(PATH_SUBS,num2str(sub, '%02d'),'\Periods\Theta_full_res.mat'));
alpha = load(strcat(PATH_SUBS,num2str(sub, '%02d'),'\Periods\Alpha_full_res.mat'));
beta = load(strcat(PATH_SUBS,num2str(sub, '%02d'),'\Periods\Beta_full_res.mat'));
gamma = load(strcat(PATH_SUBS,num2str(sub, '%02d'),'\Periods\Gamma_full_res.mat'));

load(strcat(PATH_DATE,num2str(sub, '%02d'),'\Full\Dates.mat'))
load(strcat(PATH_DATE,num2str(sub, '%02d'),'\Full\time_differences.mat'))
% load(strcat(PATH_DATE,num2str(sub, '%02d'),'\Full\total_sleep_signals.mat'))
load(strcat(PATH_DATE,num2str(sub, '%02d'),'\Full\total_seiz_signals.mat'))
load(strcat(PATH_SUBS,num2str(sub, '%02d'),'\Periods\num_parts'))

LF = {delta.full_LF;theta.full_LF;alpha.full_LF;beta.full_LF;gamma.full_LF};
ENV = {delta.full_ENV; theta.full_ENV; alpha.full_ENV; beta.full_ENV; gamma.full_ENV};
COH = {delta.full_COH; theta.full_COH; alpha.full_COH; beta.full_COH; gamma.full_COH};

order = ["Delta" "Theta" "Alpha" "Beta" "Gamma"]
parts = 1:num_parts

seiz = total_seizhours{1};

parts_total_length = zeros(num_parts,1);
parts_total_length(1) = parts_length(1);

for i=2:num_parts
    parts_total_length(i,1) = parts_length(i)+parts_total_length(i-1);
    seiz = [seiz total_seizhours{i} + parts_total_length(i-1)];
end

start = record_start(parts(1));
fin = end_times(parts(end));

end