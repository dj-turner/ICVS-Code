function devVals = LoadDeviceValues(devices,lumVals)

wavelengths = 400:5:700;
if ~exist("devices",'var'), devices = ["uno","yellow","green"]; end
lumRGY = ones(1,3); try lumRGY(1:length(lumVals)) = lumVals; catch; end

%% MAXWELLIAN-VIEW DEVICE
if sum(ismember(devices,"uno"))

    load(strcat('C:\Users\',getenv('USERNAME'),'\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Calibration\CalResultsUno.mat'));
    fns = string(fieldnames(calUno)); 
    cal = calUno.(fns(end));
    
    idx = ismember(cal.r.Spect(:,1),wavelengths);   
    lights = ['r','g'];
    
    for light = 1:length(lights), l = lights(light);
        devVals.uno.(l).Lambda = cal.(l).Peak;
        devVals.uno.(l).Lum = cal.(l).Lum * lumRGY(light);
        devVals.uno.(l).Spd = CurveNormalisation(cal.(l).Spect(idx,2),"height");
    end

end

%% ARDUINO DEVICES
arduinoDevices = devices(~strcmp(devices,"uno"));
lights = ['r','g','y'];

if ~isempty(arduinoDevices)
    [ledLambda,lumMax] = LoadPrimarySpds(arduinoDevices);
    for device = 1:length(arduinoDevices), d = arduinoDevices(device);
        for light = 1:length(lights), l = lights(light);
            devVals.(d).(l).Lambda = wavelengths(ledLambda.(d).(l) == max(ledLambda.(d).(l)));
            devVals.(d).(l).Lum = lumMax.(d).(l) * lumRGY(light);
            devVals.(d).(l).Spd = CurveNormalisation(ledLambda.(d).(l),"height"); 
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
