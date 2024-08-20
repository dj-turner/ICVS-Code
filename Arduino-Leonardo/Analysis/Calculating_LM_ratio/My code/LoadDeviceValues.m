function devVals = LoadDeviceValues
% Conversion constant: full width half maximum to standard deviation
fwhm2std = 1 / 2.35482004503;
wavelengths = 400:5:700;

%% MAXWELLIAN-VIEW DEVICE
gLambda = 545;
rLambda = 630;
radStd = 10 * fwhm2std;

devVals.uno.g.LumMin = 10 ^ 2.77;
devVals.uno.g.LumMax = 10 ^ 2.77;
devVals.uno.r.LumMin = 10 ^ 2.39;
devVals.uno.r.LumMax = 10 ^ 2.99;
devVals.uno.r.Spd = normpdf(wavelengths,rLambda,radStd)';
devVals.uno.g.Spd = normpdf(wavelengths,gLambda,radStd)';

devVals.uno.r.Lambda = 630;
devVals.uno.g.Lambda = 545;

%% ARDUINO DEVICES
arduinoDevices = ["yellow","green"];
[ledLambda,maxLums] = LoadPrimarySpds(arduinoDevices);

for device = 1:length(arduinoDevices)
    d = arduinoDevices(device);

    devVals.(d).r.LumMin = 0;
    devVals.(d).g.LumMin = 0;
    devVals.(d).r.LumMax = maxLums.(d).r;
    devVals.(d).g.LumMax = maxLums.(d).g;
    devVals.(d).r.Spd = ledLambda.(d).r;
    devVals.(d).g.Spd = ledLambda.(d).g;

    devVals.(d).r.Lambda = wavelengths(ledLambda.(d).r == max(ledLambda.(d).r));
    devVals.(d).g.Lambda = wavelengths(ledLambda.(d).g == max(ledLambda.(d).g));
end

%% CALCULATING RADIANCE
Vlambda = table2array(readtable("linCIE2008v2e_5.csv"));
Vlambda = Vlambda(ismember(Vlambda(:,1),wavelengths),2);

allDevices = string(fieldnames(devVals));

for device = 1:length(allDevices)
    d = allDevices(device);

    constantRmin = devVals.(d).r.LumMin / sum(Vlambda .* devVals.(d).r.Spd);
    devVals.(d).r.RadMin = sum(constantRmin .* devVals.(d).r.Spd);

    constantRmax = devVals.(d).r.LumMax / sum(Vlambda .* devVals.(d).r.Spd);
    devVals.(d).r.RadMax = sum(constantRmax .* devVals.(d).r.Spd);

    constantGmin = devVals.(d).g.LumMin / sum(Vlambda .* devVals.(d).g.Spd);
    devVals.(d).g.RadMin = sum(constantGmin .* devVals.(d).g.Spd);

    constantGmax = devVals.(d).g.LumMax / sum(Vlambda .* devVals.(d).g.Spd);
    devVals.(d).g.RadMax = sum(constantGmax .* devVals.(d).g.Spd);
end

end
