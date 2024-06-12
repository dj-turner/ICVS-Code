% function to plot cone absoptance spectra

function plotConeAbsorptance(wavelengths,aL,aM,aS)

plot(wavelengths, aL, 'r');
hold on;
plot(wavelengths, aM, 'g');
plot(wavelengths, aS, 'b');
xlabel('Wavelength (nm)');
ylabel('Cone absorptance spectra');
title('a,cones');

end