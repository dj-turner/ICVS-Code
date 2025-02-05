% function to convert cone fundamentals recosntructed in terms of quanta to
% cone fundamentals in terms of energy

function [eL,eM,eS] = quanta2Energy(wavelengths,l,m,s);

eL=zeros(length(wavelengths),1);
eM=zeros(length(wavelengths),1);
eM=zeros(length(wavelengths),1);
%multiply by wavelength to get energy
for i=1:length(wavelengths);
    eL(i) = l(i).*wavelengths(i);
    eM(i) = m(i).*wavelengths(i);
    eS(i) = s(i).*wavelengths(i);
end
%for s cone, set any Nan values to zero (i.e.values beyond 555nm)
eS(32:end)=0;
%normalize
eL=eL./max(eL);
eM=eM./max(eM);
eS=eS'./max(eS);

end