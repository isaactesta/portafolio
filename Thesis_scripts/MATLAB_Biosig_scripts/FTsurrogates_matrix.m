% Copyright Nicoletta Nicolaou, October 2009
% Edited by Manolis Christodoulakis, 2012 
%       Addition: to support data given in matrix where columns are the
%       channels
%
%Generate surrogate data by the method of phase randomisation. This
%surrogate data is for the null hypothesis that all structure in the time
%series is given by the autocorrelation function, or equivalently, by the
%Fourier power spectrum. Such surrogate data have been used in many studies
%to assess the significance of phase synchronisation values, e.g.:
%   Sweeney-Reed C.M., Nasuto S.J., J. Computational Neuroscience,
%   23:79-111, 2007
%The method is based on the following steps:
%   (1) FT the data
%   (2) multiply the complex amplitude with random phases
%   (3) obtain the surrogate data by inverse FT
%For more details see:
%   Theiler J., et al, Physica D, 58:77-94, 1992.
%Input:
%   x: original time series 
%Output:
%   xs: surrogate time series, with randomised phases
function xs=FTsurrogates_matrix(x);

m=repmat(mean(x),size(x,1),1);
x=x-m;
%FT the data
X=fft(x);
%obtain random phases from real FT of random data - easier than estimating
%random phases and then correcting for -theta(-f)
theta=angle(fft(randn(size(x))));
%multiply the complex amplitudes of X by exp(i*theta)
y=abs(X).*exp(sqrt(-1).*theta);
%get surrogate data by IFT
xs=real(ifft(y));
%add the mean back to the data
xs=xs+m;