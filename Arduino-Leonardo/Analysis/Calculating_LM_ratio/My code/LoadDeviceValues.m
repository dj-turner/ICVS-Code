function devVals = LoadDeviceValues(devices,graphs)

if ~exist("graphs",'var'), graphs = false; end

repoPath = FindRepoPath;

wavelengths = 400:5:700;
if ~exist("devices",'var') | strcmpi(devices,"all"), devices = ["uno","yellow","green"]; else, devices = lower(devices); end

%% MAXWELLIAN-VIEW DEVICE
if ismember("uno",devices)

    load(repoPath + "Arduino-Leonardo\Calibration\CalResultsUno.mat");
    fns = string(fieldnames(calUno)); 
    cal = calUno.(fns(end)); 
    idx = ismember(cal.r.Spect(:,1),wavelengths);   
    lights = ['r','g'];
    %allieLums = [2.39, 2.99; 2.77, 2.77];
    
    for light = 1:length(lights), l = lights(light);
        devVals.uno.(l).Lambda = cal.(l).Peak;
        devVals.uno.(l).Lum = cal.(l).Lum;
        %devVals.uno.(l).LumMin = 10 ^ allieLums(light,1);
        %devVals.uno.(l).LumMax = 10 ^ allieLums(light,2);
        devVals.uno.(l).Spd = cal.(l).Spect(idx,2);
    end

end

%% ARDUINO DEVICES
arduinoDevices = devices(~strcmp(devices,"uno"));

load(repoPath + "Arduino-Leonardo\Calibration\CalibrationResults.mat")

if ~isempty(arduinoDevices)
    lights = ['r','g','y'];
    lumEqu = FindLedEquations(calibrationTable,arduinoDevices,graphs);
    [ledLambda,lumMax] = LoadPrimarySpds(arduinoDevices);
    for device = 1:length(arduinoDevices), d = arduinoDevices(device);
        % Predicting relative red/green/yellow lum using equation
        devVals.(d).r.Lum = lumMax.(d).r;
        devVals.(d).g.Lum = lumEqu.(d).g.m .* lumMax.(d).r + lumEqu.(d).g.c;
        devVals.(d).y.Lum = lumEqu.(d).y.m .* lumMax.(d).r + lumEqu.(d).y.c;

        for light = 1:length(lights), l = lights(light);
            devVals.(d).(l).Lambda = wavelengths(ledLambda.(d).(l) == max(ledLambda.(d).(l)));
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
        devVals.(d).(l).Rad = sum(devVals.(d).(l).k .* devVals.(d).(l).Spd);
    end
    devVals.(d).kRG = devVals.(d).r.k / devVals.(d).g.k;
    if ismember(d,arduinoDevices), devVals.(d).kRY = devVals.(d).r.k / devVals.(d).y.k; end
end

end
