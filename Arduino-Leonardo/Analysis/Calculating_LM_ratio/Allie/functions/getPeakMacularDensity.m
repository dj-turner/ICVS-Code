% function to calculate peak optical density of macular pigment as function of field
% size, D,max,macula(fs)

function [Dmaxmac] = getPeakMacularDensity(fs)

Dmaxmac = 0.485.*exp(-fs./6.132);

end