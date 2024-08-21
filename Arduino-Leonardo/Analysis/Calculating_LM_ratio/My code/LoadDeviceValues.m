function devVals = LoadDeviceValues
% Conversion constant: full width half maximum to standard deviation
fwhm2std = 1 / 2.35482004503;
wavelengths = 400:5:700;

%% MAXWELLIAN-VIEW DEVICE
radStd = 10 * fwhm2std;

devVals.uno.r.Lambda = 630;
devVals.uno.g.Lambda = 545;
devVals.uno.r.LumMin = 10 ^ 2.39;
devVals.uno.g.LumMin = 10 ^ 2.77;
devVals.uno.r.LumMax = 10 ^ 2.99;
devVals.uno.g.LumMax = 10 ^ 2.77;

devVals.uno.r.Spd = normpdf(wavelengths,devVals.uno.r.Lambda,radStd)';
devVals.uno.g.Spd = normpdf(wavelengths,devVals.uno.g.Lambda,radStd)';

%% ARDUINO DEVICES
arduinoDevices = ["yellow","green"];
[ledLambda,lumMax] = LoadPrimarySpds(arduinoDevices);

for device = 1:length(arduinoDevices)
    d = arduinoDevices(device);

    devVals.(d).r.LumMin = 0;
    devVals.(d).g.LumMin = 0;
    devVals.(d).r.LumMax = lumMax.(d).r;
    devVals.(d).g.LumMax = lumMax.(d).g;
    devVals.(d).r.Spd = ledLambda.(d).r;
    devVals.(d).g.Spd = ledLambda.(d).g;

    devVals.(d).r.Lambda = wavelengths(ledLambda.(d).r == max(ledLambda.(d).r));
    devVals.(d).g.Lambda = wavelengths(ledLambda.(d).g == max(ledLambda.(d).g));
end

end
