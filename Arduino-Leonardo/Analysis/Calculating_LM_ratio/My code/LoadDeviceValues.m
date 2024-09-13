function devVals = LoadDeviceValues(devices,lumVals)

wavelengths = 400:5:700;
if ~exist("devices",'var'), devices = ["uno","yellow","green"]; else, devices = lower(devices); end
lumRGY = ones(1,3); try lumRGY(1:length(lumVals)) = lumVals; catch; end

%% MAXWELLIAN-VIEW DEVICE
if ismember("uno",devices)

    load(strcat('C:\Users\',getenv('USERNAME'),'\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Calibration\CalResultsUno.mat'));
    fns = string(fieldnames(calUno)); 
    cal = calUno.(fns(end)); 
    %cal.r.Spect = cal.r.Spect'; 
    %cal.g.Spect = cal.g.Spect';
    idx = ismember(cal.r.Spect(:,1),wavelengths);   
    lights = ['r','g'];
    %allieLums = [962.7570, 594.3295];
    
    for light = 1:length(lights), l = lights(light);
        devVals.uno.(l).Lambda = cal.(l).Peak;
        devVals.uno.(l).LumMax = cal.(l).Lum;
        %devVals.uno.(l).LumMax = allieLums(light);
        devVals.uno.(l).Lum = devVals.uno.(l).LumMax .* lumRGY(light);
        devVals.uno.(l).Spd = cal.(l).Spect(idx,2);
    end

end

%% ARDUINO DEVICES
arduinoDevices = devices(~strcmp(devices,"uno"));

load(strcat('C:\Users\',getenv('USERNAME'),'\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Calibration\CalibrationResults.mat'))

if ~isempty(arduinoDevices)
    lights = ['r','g','y'];
    rgEqu = FindRedGreenLedEquation(calibrationTable);
    [ledLambda,lumMax] = LoadPrimarySpds(arduinoDevices);
    for device = 1:length(arduinoDevices), d = arduinoDevices(device);
        % Predicting relative red/green lum using equation
        devVals.(d).r.LumMax = lumMax.(d).r;
        devVals.(d).g.LumMax = rgEqu.(d).m .* lumMax.(d).r + rgEqu.(d).c;
        devVals.(d).y.LumMax = lumMax.(d).y;

        for light = 1:length(lights), l = lights(light);
            devVals.(d).(l).Lambda = wavelengths(ledLambda.(d).(l) == max(ledLambda.(d).(l)));
            devVals.(d).(l).Lum = devVals.(d).(l).LumMax .* lumRGY(light);
            devVals.(d).(l).Spd = ledLambda.(d).(l);
        end
    end
end

%% ALL DEVICES: RADIANCE
addpath("tables\");
vLambda = table2array(readtable("CIE_sle_photopic.csv"));
vLambda = vLambda(ismember(vLambda(:,1),wavelengths),2);

for device = 1:length(devices), d = devices(device);
    lights = string(fieldnames(devVals.(d)));
    for light = 1:length(lights), l = lights(light);
        devVals.(d).(l).k = devVals.(d).(l).Lum / sum(vLambda .* devVals.(d).(l).Spd);
        devVals.(d).(l).Rad = devVals.(d).(l).k * sum(devVals.(d).(l).Spd);
    end
    devVals.(d).kRG = devVals.(d).r.k / devVals.(d).g.k;
end

end
