% function to plot relative macular pigment density

function plotRelativeMacularDensity(wavelengths,Drmac)

plot(wavelengths,Drmac,'k');
xlabel('Wavelength (lambda)');
ylabel('Relative macular pigment density');
title('D,mac,rel');


end