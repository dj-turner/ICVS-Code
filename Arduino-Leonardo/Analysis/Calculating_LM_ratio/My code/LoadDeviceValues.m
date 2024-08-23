function devVals = LoadDeviceValues
% Conversion constant: full width half maximum to standard deviation
fwhm2std = 1 / 2.35482004503;
wavelengths = 400:5:700;

%% MAXWELLIAN-VIEW DEVICE
lumStd = 10 * fwhm2std;

devVals.uno.r.Lambda = 630;
devVals.uno.g.Lambda = 545;
devVals.uno.r.LumMin = 10 ^ 2.39;
devVals.uno.g.LumMin = 10 ^ 2.77;
devVals.uno.r.LumMax = 10 ^ 2.99;
devVals.uno.g.LumMax = 10 ^ 2.77;

% Change this to use measured spectral power distibution? (for min and max)
devVals.uno.r.SpdMin = CurveNormalisation(normpdf(wavelengths,devVals.uno.r.Lambda,lumStd)',"height",devVals.uno.r.LumMin);
devVals.uno.g.SpdMin = CurveNormalisation(normpdf(wavelengths,devVals.uno.g.Lambda,lumStd)',"height",devVals.uno.g.LumMin);
devVals.uno.r.SpdMax = CurveNormalisation(normpdf(wavelengths,devVals.uno.r.Lambda,lumStd)',"height",devVals.uno.r.LumMax);
devVals.uno.g.SpdMax = CurveNormalisation(normpdf(wavelengths,devVals.uno.g.Lambda,lumStd)',"height",devVals.uno.g.LumMax);

%% ARDUINO DEVICES
arduinoDevices = ["yellow","green"];
[ledLambda,lumMax] = LoadPrimarySpds(arduinoDevices);

for device = 1:length(arduinoDevices), d = arduinoDevices(device);
    lights = string(fieldnames(ledLambda.(d)));
    for light = 1:length(lights), l = lights(light);
        devVals.(d).(l).Lambda = wavelengths(ledLambda.(d).(l) == max(ledLambda.(d).(l)));
        devVals.(d).(l).LumMin = 0;
        devVals.(d).(l).LumMax = lumMax.(d).(l);
        devVals.(d).(l).SpdMin = zeros([length(wavelengths),1]);
        devVals.(d).(l).SpdMax = ledLambda.(d).(l);
    end
end

%% ALL DEVICES: RADIANCE
wavelengths = 400:5:700;
vLambda = table2array(readtable("CIE_sle_photopic.csv"));
vLambda = vLambda(ismember(vLambda(:,1),wavelengths),2);

allDevices = string(fieldnames(devVals));

for device = 1:length(allDevices), d = allDevices(device);
    lights = string(fieldnames(devVals.(d)));
    for light = 1:length(lights), l = lights(light);
        devVals.(d).(l).k = devVals.(d).(l).LumMax / sum(vLambda .* devVals.(d).(l).SpdMax);
        devVals.(d).(l).RadMin = sum(devVals.(d).(l).k .* devVals.(d).(l).SpdMin);
        devVals.(d).(l).RadMax = sum(devVals.(d).(l).k .* devVals.(d).(l).SpdMax);
    end
end

end
