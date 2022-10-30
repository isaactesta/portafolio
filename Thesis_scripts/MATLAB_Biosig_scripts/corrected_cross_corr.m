clear all; close all;
assymetr='both',% swiytch different signals 
% assymetr='0',% swiytch different signals 
% assymetr='non 0',% swiytch different signals 
%%: '0', 'non 0', 'both' %% of one use signals with non zro lag component too otherwise uyse signals with o lag only

%%% make some random signals correlated at 0 and non zero lags
t=[1:10000]';
z1=randn(size(t));z2=randn(size(t));z3=randn(size(t)+1000,1);

%ref signal
x = z1;

%%% 0 lag cortrelated signbal with x

rho=0.9; %% actual correlation coef
switch assymetr
    case '0'
        lag=0;
        y = rho*z1 + sqrt(1-rho^2)*z2; % x and y correlated at zero lag with 0.66 correlation
        
    case 'non 0'
        lag=1e3;
        %%% non zero lag (1000)
        
        w=rho.*[zeros(lag,1);x]+ sqrt(1-rho^2)*z3; %% correlated at lag 1000
        w=w(1:end-lag);
        
        y=w;
        
    case 'both'
        lag=1e3;
        %%% both
        z= sqrt(1-rho^2).*[zeros(lag,1);x]+ rho.*[x;zeros(lag,1)];%% has strong 0 lag component but also weaker non-zero lag component at lag 1000
        z=z(1:end-lag);
        
        y=z;
end

% demean
x=x-mean(x);
y=y-mean(y);
% plot signals
figure 
subplot(2,1,1)
plot(t,x,t,y)
legend('x','y')
title('original signals ')
subplot(2,1,2)
plot(t(1:end-lag),x(1:end-lag),t(1:end-lag),y(lag+1:end))
title('signals shifted by simulated lag ')
legend('x','y')
%%% compute crosscorr
[c,l]=xcov(y,x,'coef'); %% c is the cross-corralation coefficients across all lags, L is %all the lags [-lmax lmax]
%%% notthis is y -->x
figure
plot(l,c,'x-')
%%% this gets assymetric cross correl
C_corr=zeros(size(l)); %initialize

 

for k=1: length(l)


lag_var=l(k); %%this is the particular lag staring from the first one, which will be % negative (= -lmax)

C_corr(k)= c(l== lag_var)- c(l== - lag_var); %% for all lags from -lmax to lmax, subtract C of homologous lags (e.g. -10, -10)


end

hold on
plot(l,C_corr,'ro-')
legend('Cross','Corrected Cross')