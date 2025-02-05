% function to plot stages of cone fundamentals recosntruction

function generatePlots(wavelengths,fieldSizes,ages,AL,AM,AS,aL,aM,aS,Drmac,lens1st,lens2nd,qL,qM,qS,eL,eM,eS)

% plot peak optical density for field sizes 1:10
    % CIE 2006, Fig 5.2
    figure()
    subplot(3,2,1);
    plotPeakOpticalDensity(fieldSizes);
    
    % plot
    % CVRL, Photopigments, Pigment curvers estimated from psychophysics
    subplot(3,2,2);
    plotLowDensityAbsorbances(wavelengths,AL,AM,AS);
    
    %plot cone absorptance
    subplot(3,2,3);
    plotConeAbsorptance(wavelengths,aL,aM,aS);
    
    %plot for field sizes 1:10
    % CIE, 2006, Fig 5.1
    subplot(3,2,4);
    plotPeakMacularDensity(fieldSizes);
    
    % plot
    subplot(3,2,5);
    plotRelativeMacularDensity(wavelengths,Drmac);
    
    % plot
    subplot(3,2,6);
    plotLensDensity(wavelengths,ages,lens1st,lens2nd);
    
    % plot cone fundamentals (quanta)
    figure()
    plotConeFundamentals(wavelengths,qL,qM,qS);
    hold on;
    % plot SS cone fundamentals for comparison
    [ssWav,ssL,ssM,ssS] = getSSConeFundamentals;
    plotSSConeFundamentals(ssWav,ssL,ssM,ssS);
    title('Recostructued(-) vs SS (--)');
    
    %plot cone fundamentals (energy lin, normalized)
    figure()
    plotEnergyConeFundamentals(wavelengths,eL,eM,eS);
    hold on;
    % plot SS energy linear cone fundamentals for comparison
    [ssWav,ssEL,ssEM,ssES] = getSSEnergyLinearConeFundamentals;
    plotSSEnergyLinearConeFundamentals(ssWav,ssEL,ssEM,ssES);
    title('Recostructued(-) vs SS (--)');
    
end