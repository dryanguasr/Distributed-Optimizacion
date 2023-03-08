function [KLDiv] = KLDivergence(P,Q)
%KLDIVERGENCE  the Kullback–Leibler divergence is a measure of how one probability distribution is different from a second
%    it is the expectation of the logarithmic difference between the probabilities P and Q, 
%    where the expectation is taken using the probabilities P.
%    The Kullback–Leibler divergence is defined only if for all x, Q(x)=0 implies P(x)=0 (absolute continuity). 
%    Whenever P(x) is zero the contribution of the corresponding term is interpreted as zero
KLDiv = 0;
for i = 1:1:size(P,2)
    if(P(i)~=0 && Q(i)~=0)
        KLDiv = KLDiv + P(i)*log(P(i)/(Q(i)));
    end
end    
end