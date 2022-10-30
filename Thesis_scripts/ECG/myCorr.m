% Pearson's R of two mx1 vectors
% If you need a 5x faster version, see my_fast_corr.mexsol (from C)
% Mark Ebden, copyright 2005

function r = myCorr (x,y);

xm = x-mean(x); ym = y-mean(y);
r = xm'*ym / sqrt(sum(xm.^2)*sum(ym.^2));
