% script to reconstruct cone fundamentals for observer of given age and at given field size
% CIE 2006, Section 5.2
function coneFun = reconstructingConeFundamentals(age, fs)
%need to know:
% - relative optical density of macular pigment
% - relative optical density of lens and other ocular media
% - relative low optical density absorbance spectra of photo pigments

% define wavelength range of recosntruction
% everything in 5nm spacing from 400nm to 700nm, because of data given
wavelengths = 400:5:700;

%calculate cone absoportance spectra aka fraction of incident light that is
%absorbed in the cones, a,cone

% calculate peak optical density of visual pigments as a function of field size, D,max,cones(fs)
% CIE 2006, Section 5.7
[DmaxL, DmaxM, DmaxS] = getPeakOpticalDensity(fs);

% import low-optical density spectral absorbances of photopgiments, Acone(lambda)
% CVRL
[AL,AM,AS] = getLowDensityAbsorbances;

% calculate cone absorptance spectra
% CIE 2006, Section 5.9
[aL,aM,aS]=getConeAbsorptance(AL,AM,AS,DmaxL,DmaxM,DmaxS);

% calculate peak optical density of macular pigment as function of field
% size, D,max,macula(fs)
% CIE, 2006, Section 5.3
[Dmaxmac] = getPeakMacularDensity(fs);

% import relative optical density of macular pigment, D,mac,rel(lambda)
[Drmac] = getRelativeMacularDensity;

% calculate optical density of lens as a function of age, D,r,ocul(lambda)
% CIE, Section 5.6
[Docul,lens1st,lens2nd] = getLensDensity(age);

% calculate cone fundamentals (cone absorptance spectra * transmittance at
% every wavelength)
% CIE 2006, Section 5.9
[qL,qM,qS] = getConeFundamentals(aL,aM,aS,Dmaxmac,Drmac,Docul);

% convert from quanta to energy
[eL,eM,eS] = quanta2Energy(wavelengths,qL,qM,qS);

% put into structure
coneFun = struct('wavelengths',wavelengths','qL',qL,'qM',qM,'qS',qS,'eL',eL,'eM',eM,'eS',eS);

end
