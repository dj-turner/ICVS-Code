%function to get low-optical density spectral absorbances of photopgiments, Acone(lambda)

function [AL,AM,AS] = getLowDensityAbsorbances

ssabance_5 = csvread('ssabance_5.csv');
absL = ssabance_5(3:63,2);
absM = ssabance_5(3:63,3);
absS = ssabance_5(3:63,4);
% linearise and normalise low-optical density spectral absorbances
ABSL = 10.^(absL);
ABSM = 10.^(absM);
ABSS = 10.^(absS);
AL = ABSL/max(ABSL);
AM = ABSM/max(ABSM);
AS = ABSS/max(ABSS);

end