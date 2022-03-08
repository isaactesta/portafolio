%Estimation of Alpha values using lsqnonlin
% Uses fit and prior values obtained from L_curve script

global fit
global prior

fit = fit;
prior = prior;

alpha_0 = 2.5e-8; %Value obtained from Ratio of Traces

prior_0 = 2.1e-14;
fit_0 = 8.2e-23;

estimated = lsqnonlin(@myfun,[fit_0 prior_0])

function F = myfun(a)
    global fit
    global prior
    
    p = max(a(2));
    F = a(1)./max(a(1) + a(2)./p);

end

% F = fit./max(fit + prior./p);