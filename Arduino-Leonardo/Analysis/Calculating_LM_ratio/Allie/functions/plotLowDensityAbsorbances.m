% function to plot low-optical density spectral absorbances of
% photopigments

function plotLowDensityAbsorbances(wavelengths,AL,AM,AS)

plot(wavelengths, AL, 'r');
hold on;
plot(wavelengths, AM, 'g');
plot(wavelengths, AS, 'b');
xlabel('Wavelength (nm)');
ylabel('Low-optical density absorptance');
title('A,cones');

end