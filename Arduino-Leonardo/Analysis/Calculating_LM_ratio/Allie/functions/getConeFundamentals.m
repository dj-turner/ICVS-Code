% function to calculate cone fundamentals (cone absorptance spectra * transmittance at
% every wavelength)

function [L,M,S] = getConeFundamentals(aL,aM,aS,Dmaxmac,Drmac,Docul)

l = aL.*10.^(-(Dmaxmac.*Drmac)-Docul);
m = aM.*10.^(-(Dmaxmac.*Drmac)-Docul);
s = aS.*10.^(-(Dmaxmac.*Drmac)-Docul);
% normalise cone fundamentals
L = l./max(l);
M = m./max(m);
S = s./max(s(1:23)); %find max for s cones in region without NaN values

end