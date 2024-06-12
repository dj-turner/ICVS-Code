%function to plot peak macular desnity as function of field size

function plotPeakMacularDensity(fieldSizes)

plot(fieldSizes,0.485.*exp(-fieldSizes./6.132),'k');
xlabel('Field size (degrees)');
ylabel('Peak optical density');
title('D,max,macula');
ylim([0,0.5]);

end