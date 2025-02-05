% function to calculate peak optical density of visual pigments as a function of field size, D,max,cones(fs)

function [DmaxL, DmaxM, DmaxS] = getPeakOpticalDensity(fs)

DmaxL = 0.38+0.54.*exp(-fs./1.333);
DmaxM = 0.38+0.54.*exp(-fs./1.333);
DmaxS = 0.30+0.45.*exp(-fs./1.333);

end