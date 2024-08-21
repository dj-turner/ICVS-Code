function [primarySpds, maxLums] = LoadPrimarySpds(devices)

% load calibration data
addpath("data\");
calTbl = load("CalibrationResults.mat");
calTbl = calTbl.calibrationTable;

LEDs = ["red","green","yellow"];
LEDlabs = ['r','g','y'];
wvls = 400:5:700; 

% save most recent SPD data from the correct device and max. device setting in a structure
for device = 1:numel(devices)
    for led = 1:length(LEDs)
        idx = strcmpi(calTbl.Device, devices(device)+" band") & calTbl.InputValue == 255 & calTbl.LED == LEDs(led);
        ledTbl = calTbl(idx,:);

        ledVals = table2array(ledTbl(end,"LambdaSpectrum"))';
        wvlVals = table2array(ledTbl(end,"Lambdas"))';
        primarySpds.(devices(device)).(LEDlabs(led)) = ledVals(ismember(wvlVals,wvls));

        maxLums.(devices(device)).(LEDlabs(led)) = ledTbl.Luminance(end);
    end
end

end