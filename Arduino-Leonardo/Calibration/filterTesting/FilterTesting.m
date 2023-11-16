clc; clear; close all;
addpath(strcat("C:\Users\", getenv('USERNAME'), "\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Calibration\functions"));

filterValues = struct;
conditions = ["filter", "nofilter"];

for i = 1:length(conditions)
    input("press RETURN to measure!", 's');
    PR670init('COM9');
    [luminance, spectrum, spectrumPeak] = measurePR670(portPR670);
    filterValues.(conditions(i)).lum = luminance;
    filterValues.(conditions(i)).spect = spectrum;
    filterValues.(conditions(i)).peak = spectrumPeak;
end

save('filter.mat','filterValues');
