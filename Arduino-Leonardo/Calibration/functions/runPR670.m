% Turns off the monitor
MonitorPower('off', testMode)

% TAKES PR670 MEASUREMENTS
% Tries to take PR670 measurements using defined port
try
    [luminance, spectrum, spectrumPeak] = measurePR670(portPR670);

% if this doesn't work, asks the user to check and enter the correct port number
catch
    %turns on the monitor
    MonitorPower('on', testMode)
    % saves number entered
    newPortNum = input("Potentially wrong port number entered! Please check and enter the port number here: ");
    % converts entered number to correct format
    newPortPR670 = char(strcat('COM', num2str(newPortNum)));
    % turns off monitor
    MonitorPower('off', testMode)

    % tries to take PR670 measurements with new port number
    try
        [luminance, spectrum, spectrumPeak] = measurePR670(newPortPR670);
        % if successful, sets the new port number as the defined port for future trials
        portPR670 = newPortPR670;

    % if the new port fails, exits
    catch
        % turns monitor on
        MonitorPower('on', testMode)
        %displays error message
        disp("Still not working! Exiting program...");
        % prepares to exit program
        PrepareToExit(arduino);
        % exits program
        return
    end
end

% turns monitor back on
MonitorPower('on', testMode)