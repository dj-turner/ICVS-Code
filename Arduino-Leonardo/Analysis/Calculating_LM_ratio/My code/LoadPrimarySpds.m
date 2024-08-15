function primarySpds = LoadPrimarySpds(devices)

% load calibration data
addpath("data\");
calTbl = load("CalibrationResults.mat");
calTbl = calTbl.calibrationTable;

LEDs = ["red","green","yellow"];
wvls = 400:5:700; 

% save most recent SPD data from the correct device and max. device setting in a structure
primarySpds = struct;
for device = 1:numel(devices)
    for led = 1:length(LEDs)
        idx = strcmpi(calTbl.Device, devices(device)+" band") & calTbl.InputValue == 255 & calTbl.LED == LEDs(led);
        ledTbl = calTbl(idx,:);
        ledVals = table2array(ledTbl(end,"LambdaSpectrum"))';
        wvlVals = table2array(ledTbl(end,"Lambdas"))';
        primarySpds.(devices(device)).(LEDs(led)) = ledVals(ismember(wvlVals,wvls));
    end
end

end