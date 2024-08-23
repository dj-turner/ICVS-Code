function devVals = LoadDeviceValues

wavelengths = 400:5:700;

%% MAXWELLIAN-VIEW DEVICE
load(strcat('C:\Users\',getenv('USERNAME'),'\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Calibration\CalResultsUno.mat'));
fns = string(fieldnames(calUno));
idx = max(str2double(extractAfter(fns,"cal")));
cal = calUno.(fns(idx));

idx = ismember(cal.none.Spect(:,1),wavelengths);
backgroundLight = (cal.none.Spect(idx,2));

lights = ['r','g'];

for light = 1:length(lights), l = lights(light);
    devVals.uno.(l).Lambda = cal.(l).Peak;
    devVals.uno.(l).LumMax = cal.(l).Lum;
    
    devVals.uno.(l).SpdMax = (cal.(l).Spect(idx,2)) - backgroundLight;
    devVals.uno.(l).SpdMax(devVals.uno.(l).SpdMax < 0) = 0;
end

%% ARDUINO DEVICES
arduinoDevices = ["yellow","green"];
[ledLambda,lumMax] = LoadPrimarySpds(arduinoDevices);

for device = 1:length(arduinoDevices), d = arduinoDevices(device);
    lights = string(fieldnames(ledLambda.(d)));
    for light = 1:length(lights), l = lights(light);
        devVals.(d).(l).Lambda = wavelengths(ledLambda.(d).(l) == max(ledLambda.(d).(l)));
        devVals.(d).(l).LumMax = lumMax.(d).(l);
        devVals.(d).(l).SpdMax = ledLambda.(d).(l);
    end
end

%% ALL DEVICES: RADIANCE
wavelengths = 400:5:700;

addpath("tables\");
vLambda = table2array(readtable("CIE_sle_photopic.csv"));
vLambda = vLambda(ismember(vLambda(:,1),wavelengths),2);

allDevices = string(fieldnames(devVals));

for device = 1:length(allDevices), d = allDevices(device);
    lights = string(fieldnames(devVals.(d)));
    for light = 1:length(lights), l = lights(light);
        devVals.(d).(l).k = devVals.(d).(l).LumMax / sum(vLambda .* devVals.(d).(l).SpdMax);
        devVals.(d).(l).RadMax = sum(devVals.(d).(l).k .* devVals.(d).(l).SpdMax);
    end
end

end
