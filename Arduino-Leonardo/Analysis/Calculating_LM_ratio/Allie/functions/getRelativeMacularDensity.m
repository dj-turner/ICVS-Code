%function to calculate the relative macular pigment density

function [Drmac] = getRelativeMacularDensity

macPigRelative = csvread('macPigRelative_5.csv');
Drmac = macPigRelative(:,2);

end