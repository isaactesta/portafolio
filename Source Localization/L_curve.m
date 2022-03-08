% L curve and alpha value minimization
% J values were obtained from MNE implementation

J_all = cat(3, J1,J2,J3,J4,J5,J6,J7,J8,J9,J10);

fit = zeros(size(J_all,3),1);
prior = zeros(size(J_all,3),1);

for i=1:size(J_all,3)
    [fit(i),prior(i)] = L_fit(G,Msimul,J_all(:,:,i));
end

figure()
plot(prior,fit,'Marker','o','LineWidth',1)
title('L-Curve')
grid
xlabel('Prior')
ylabel('Fit')


function [fit,prior] = L_fit(G,M,J)

nDipoles = size(G,2);
gchannels = size(M,1);

W = eye(gchannels,nDipoles);

fit = norm(M - G*J);
fit = fit^2;

prior = norm(W*J);
prior = prior^2;

end