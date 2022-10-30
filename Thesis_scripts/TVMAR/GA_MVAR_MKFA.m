%---------------------------------------------------------------------------------------------------------------------
% Copyright (c) 2019 Kyriaki Kostoglou
% PhD Supervisor: Georgios Mitsis, Associate Professor, Bioengineering Department, McGill University, Montreal, Canada
% Biosignals and Systems Analysis Lab
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the % % "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, % distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to % the following conditions:
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% The Software is provided "as is", without warranty of any kind.
%---------------------------------------------------------------------------------------------------------------------

%Function that initiates the GA optimization of the MVAR model hyperparameters based on the proposed KF (MKFA) 

function [XMKFA, JMKFA]=GA_MVAR_MKFA(Y,param)

metric=param.metric;
ignore=param.ignore;
ga_opts=param.ga_opts;
M=param.M;
pmax=param.pmax;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Y:          MxN matrix (each time series is placed in a row)
% metric:     Fitness function (1 for multivariate AIC, 2 for multivariate BIC)
% ignore:     Number of samples to ignore due to initialization of the estimators (i.e. conventional/proposed KF)
% ga_opts:    GA options
% pmax:       Maximum MVAR model order to be considered when optimizing with the GA 
% M:          Number of MVAR time-series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n\n--------Initiating GA MVAR model optimization based on the proposed KF --------\n\n') 
h = @(X) MVAR_MKFA(X,Y,metric,ignore);                                     
%In case you want to use mex files for faster runtime type instead: h = @(X) MVAR_MKFA_mex(X,Y,metric,ignore);
nvars=2+M+M*M*pmax;              %Number of hyperparameters optimized by the GA (p,R1 -> vector of size M*M*p,R2 -> vector of size M, P0)
LB=[1 zeros(1,M*M*pmax)  0.5*ones(1,M*M*pmax) 0];                             
UB=[pmax 1*ones(1,M*M*pmax) 1*ones(1,M*M*pmax) 1 ];   

warning('off','all')
tic;
[XMKFA, JMKFA] = ga(h, nvars,[],[],[],[],LB,UB,[],[1],ga_opts);            %XMKFA: Optimized Hyperparameters returned by the GA  
                                                                           %JMKFA: Obtained value of the fitness function 
timeMKFA=toc;
fprintf('\n-------- Optimization Completed - Total time: %f seconds --------',timeMKFA) 