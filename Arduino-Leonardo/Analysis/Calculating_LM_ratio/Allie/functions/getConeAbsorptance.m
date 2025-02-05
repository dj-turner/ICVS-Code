% function to calculate cone absorptance spectra 

function [aL,aM,aS]=getConeAbsorptance(AL,AM,AS,DmaxL,DmaxM,DmaxS);

aL = 1-10.^(-DmaxL.*AL);
aM = 1-10.^(-DmaxM.*AM);
aS = 1-10.^(-DmaxS.*AS);

end