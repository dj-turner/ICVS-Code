% function to plot peak Optical Densities as function of field size

function plotPeakOpticalDensity(fieldSizes)

plot(fieldSizes, 0.38+0.54.*exp(-fieldSizes./1.333), 'r');
hold on;
plot(fieldSizes, 0.38+0.54.*exp(-fieldSizes./1.333), 'g');
plot(fieldSizes, 0.30+0.45.*exp(-fieldSizes./1.333), 'b');
xlabel('Field size (degrees)');
ylabel('Peak optical density');
title('D,max,cones');
ylim([0,0.8]);

end