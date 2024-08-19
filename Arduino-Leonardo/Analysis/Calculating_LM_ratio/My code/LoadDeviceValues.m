function devVals = LoadDeviceValues
% Conversion constant: full width half maximum to standard deviation
fwhm2std = 1 / 2.35482004503;
wavelengths = 400:5:700;
% Device value stucture
devVals = struct;
    % Lab-based device (from Allie's values)
    devVals.uno.g.LumMax = 594.3295;
    devVals.uno.r.LumMax = 962.7570;
    devVals.uno.g.Lambda = 545;
    devVals.uno.r.Lambda = 630;
    devVals.uno.r.RadMin = 10 ^ 2.39;
    devVals.uno.r.RadMax = 10 ^ 2.99;
    devVals.uno.g.RadMin = 10 ^ 2.77;
    devVals.uno.g.RadMax = devVals.uno.g.RadMin;
    radStd = 10 * fwhm2std;

    devVals.uno.r.Spd = normpdf(wavelengths,devVals.uno.r.Lambda,radStd)';
    devVals.uno.g.Spd = normpdf(wavelengths,devVals.uno.g.Lambda,radStd)';
    
    % Yellow Arduino device (from Josh's calibration results)
    devVals.yellow.g.LumMax = 225.9;
    devVals.yellow.r.LumMax = 953.6;
    devVals.yellow.g.Lambda = 540;
    devVals.yellow.r.Lambda = 625;
    
    % Green Arduino Device (from Mitch's calibration results)
    devVals.green.g.LumMax = 554.6;
    devVals.green.r.LumMax = 2525;
    devVals.green.g.Lambda = 545;
    devVals.green.r.Lambda = 625;

% Calculating the spds for the LEDs in the Leonardo Devices
devices = string(fieldnames(devVals));
leoDevices = devices(~strcmpi(devices,"uno"));
leds = ["red","green"]; ledChars = ['r','g'];
spds = LoadPrimarySpds(leoDevices);
for device = 1:length(leoDevices)
    for led = 1:length(leds)
        ledSpd = spds.(leoDevices(device)).(leds(led));
        devVals.(leoDevices(device)).(ledChars(led)).RadMin = 0;
        devVals.(leoDevices(device)).(ledChars(led)).RadMax = max(ledSpd);
        devVals.(leoDevices(device)).(ledChars(led)).Spd = ledSpd;
    end
end


end
