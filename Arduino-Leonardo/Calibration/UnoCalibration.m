addpath(strcat(pwd, '\functions\'));

portPR670 = 'COM5'; 
% Display the pr670 port
disp(strjoin(["Using port", portPR670, "for the PR670!"]));

debugMode = input("Debug mode? 0 = no, 1 = yes: ");

fileName = "CalResultsUno.mat";
if exist(fileName,'file')
    load(fileName);
    fns = string(fieldnames(calUno));
    fns = extractAfter(fns,"cal");
    lastNum = max(str2double(fns));
    trialNum = lastNum + 1;
else
    trialNum = 1;
end

s = strcat("cal",string(trialNum));
calUno.(s).dt = string(datetime);

LEDs = ["red","green"];

for light = 1:length(LEDs), l = LEDs(light);
    input("LED = " + l + ", press RETURN to start!");

    % PR670 MEASUREMENTS
    % Turns off the monitor
    MonitorPower('off', debugMode)
    % Tries to take PR670 measurements using defined port
    try
    [luminance, spectrum, spectrumPeak] = MeasurePR670(portPR670);
    % if this doesn't work, displays error and quits
    catch
        %turns on the monitor
        MonitorPower('on', debugMode);
        disp(lasterror); %#ok<LERR>
        PrepareToExit(arduino);
        return
    end
    % turns monitor back on
    MonitorPower('on', debugMode);

    % Save Results
    calUno.(s).(l).Lum = luminance;
    calUno.(s).(l).Spect = spectrum;
    calUno.(s).(l).Peak = spectrumPeak;
end

% Save structure
save(fileName,'calUno')

disp("All Done!");


