% MNE for estimating J

nTime = 331;
nDipoles = 6002

% alpha = 0.005; % Value to change

G_t = transpose(G);

W = eye(nDipoles,nDipoles);
W_t = transpose(W);

p = W_t*W;
p1 = pinv(p);

p2 = G*p1*G_t;
I = eye(272,272);
p3 = inv(p2 + alpha*I);


% Estimation of Sources
J = p1*G_t*p3*Msimul;

