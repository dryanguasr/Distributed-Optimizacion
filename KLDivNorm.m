function [KLDiv] = KLDivNorm(sigma1, mu1, sigma2, mu2)
%KLDIVNORM  Kullback–Leibler divergence between 2 univariate normal distributions
KLDiv = log(sigma1/sigma2) + (sigma1^2+(mu1-mu2)^2)/(2*sigma2^2) - 1/2;
end