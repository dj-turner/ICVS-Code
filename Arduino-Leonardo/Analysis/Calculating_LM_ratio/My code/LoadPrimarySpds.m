function [primarySpds, maxLums] = LoadPrimarySpds(devices)

% load calibration data
addpath("data\");
load(strcat('C:\Users\',getenv('USERNAME'),'\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Calibration\CalibrationResults.mat'));

LEDs = ["red","green","yellow"];
LEDlabs = ['r','g','y'];
wvls = 400:5:700; 

% save most recent SPD data from the correct device and max. device setting in a structure
for device = 1:numel(devices)
    for led = 1:length(LEDs)
        idx = strcmpi(calibrationTable.Device, devices(device)+" band")... 
            & calibrationTable.InputValue == 255 ... 
            & calibrationTable.LED == LEDs(led); %#ok<USENS>
        ledTbl = calibrationTable(idx,:);

        ledVals = table2array(mean(ledTbl(:,"LambdaSpectrum")))';
        wvlVals = table2array(ledTbl(end,"Lambdas"))';
        primarySpds.(devices(device)).(LEDlabs(led)) = ledVals(ismember(wvlVals,wvls));

        maxLums.(devices(device)).(LEDlabs(led)) = mean(ledTbl.Luminance);
    end
end

end