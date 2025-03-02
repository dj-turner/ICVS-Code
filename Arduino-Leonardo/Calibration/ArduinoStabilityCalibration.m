function ArduinoStabilityCalibration(lights,timePerLightSeconds)
%--------------------------------------------------------------------------
% MATLAB RESET
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');
delete(instrfindall); %#ok<INSTFA>
close all; 

%--------------------------------------------------------------------------
% ADD PATHS
addpath(strcat(pwd,'\functions\'));

%--------------------------------------------------------------------------
% SET CONSTANTS
if ~exist("lights", 'var'), lights = "yellow"; end
if ~exist("timePerLightSeconds", 'var'), timePerLightSeconds = 600; end

%--------------------------------------------------------------------------
% CREATING VARIABLES TO STORE VALUES
% Creates empty structure to store LED input values
LEDs = struct;
% Creates empty array for current LED for luminance values - to use in figures
luminanceValues = NaN(1000, length(lights));
timeValues = NaN(1000, length(lights));
 
%--------------------------------------------------------------------------
% SETTING UP DEVICES
% Arduino
% Loading and setting up the arduino device - Do not touch this code!
arduino = OpenArduinoPort;
% Display the arduino port
disp(strjoin(["Using port", arduino.Port, "for the Arduino device!"]));
% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(arduino, [0,0,0]);

% PR670
% Find all available ports
availablePorts = serialportlist;
% Remove the arduino port from the list
availablePorts = availablePorts(~strcmp(availablePorts,arduino.Port));
% Set the PR670 port as the last on the list
portPR670 = char(availablePorts(end));
% Display the pr670 port
disp(strjoin(["Using port", portPR670, "for the PR670!"]));

%--------------------------------------------------------------------------
% USER INPUTS
% Debug Mode
debugMode = NaN;
while debugMode ~= 0 && debugMode ~= 1
    debugMode = input("Debug mode? (0 = off, 1 = on): ");
end

% Arduino Device Label
validDeviceNums = [0 1 2];
deviceNum = NaN;
while ~ismember(deviceNum, validDeviceNums)
    deviceNum = input("Which Arduino? (1 = Josh's yellow band device, 2 = Mitch's green band device, 0 = Other): ");
    % Assigns correct device label depending on entered number
    switch deviceNum
        case 1, deviceLabel = "Yellow Band";
        case 2, deviceLabel = "Green Band";
        case 0, deviceLabel = string(input("Input Device Label: ", 's'));
        otherwise, disp("Invalid input! Please read the options and try again.")
    end
end

%--------------------------------------------------------------------------
% GRAPH SETUP
% Initialise graphs
% Graph window
fig = figure('WindowState', 'minimized');
tiledGraph = tiledlayout(1,length(lights));
% Calculate date and time
dtString = string(datetime);
% Reformat into valid file name
charRep = [":", "."; "-", "."; " ", "_"];
for rep = 1:height(charRep), dtString = strrep(dtString, charRep(rep,1), charRep(rep,2)); end
% Set device and date and time as tiled chart title
title(tiledGraph, deviceLabel, 'Interpreter', 'none');
subtitle(tiledGraph, dtString, 'Interpreter', 'none');

%--------------------------------------------------------------------------
% TESTING LOOP
% For each of the LEDs...
for light = 1:length(lights)

    %----------------------------------------------------------------------
    % LED SETUP AND ALIGNMENT
    % Set all light values to 0 in the LED value structure
    LEDs.red = 0; LEDs.green = 0; LEDs.yellow = 0;
    % Display which light we're currently calibrating
    disp(" ");
    disp(strcat("Current testing light: ", lights(light)));
    % Set current test light value to max
    LEDs.(lights(light)) = 255;
    % Write LED values to the arduino device
    WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);
    % Wait for user to press RETURN to continue (for light alignment) if
    % positions either haven't been set or if it changes
    pauseTime = [];
    if light == 1
        beep
        pauseTime = input("First testing light is on! Please enter pause time (in seconds), then press RETURN when you are ready to start: ");
    elseif ~isequal(sort([lights(light),lights(light-1)]),["green","red"])
        beep
        pauseTime = input("Need to realign the Arduino! Please enter pause time (in seconds), then press RETURN when you are ready to start: ");
    end
    if ~isempty(pauseTime), pause(pauseTime); end

    %----------------------------------------------------------------------
    % TAKING THE MEASUREMENT
    totalTime = 0;
    measurementNum = 0;
    % Turns off the monitor
    MonitorPower('off', debugMode)
    while totalTime < timePerLightSeconds
        tic;
        % PR670 MEASUREMENTS
        % Tries to take PR670 measurements using defined port
        try
            [luminance,~,~] = MeasurePR670(portPR670,"lum");
        % if this doesn't work, displays error and quits
        catch
            %turns on the monitor
            MonitorPower('on', debugMode);
            disp(lasterror); %#ok<LERR>
            PrepareToExit(arduino);
            return
        end

        %------------------------------------------------------------------
        % SAVE RESULTS
        measurementNum = measurementNum + 1;
        % saves luminance values for plotting
        luminanceValues(measurementNum,light) = luminance;

        %------------------------------------------------------------------
        % EXITING PROGRAM (DEBUG MODE ONLY)
        % if on test mode, gives option to exit program (otherwise automatically continues)
        if debugMode
            % asks for input
            i = input("Press RETURN to continue (or type ""exit"" to exit the program): ", 's');
            % if exit is typed, exits program
            if strcmpi(i, "exit"), PrepareToExit(arduino); return; end
        end

        %------------------------------------------------------------------
        % TIME TAKEN
        time = toc;
        totalTime = totalTime + time;
        timeValues(measurementNum,light) = totalTime;
    end

    % turns monitor back on
    MonitorPower('on', debugMode);

    %----------------------------------------------------------------------
    % DRAWING GRAPHS
    nexttile(light)
    idx = ~isnan(luminanceValues(:,light));
    x = timeValues(idx,light);
    y = luminanceValues(idx,light);
    plot(x,y,... 
        'Color','k','LineWidth',3,...
        'Marker','x','MarkerEdgeColor',lights(light),'MarkerSize',20)
    xlim([min(x) max(x)]);
    xlabel("Time (seconds)");
    ylim([min(y) max(y)]);
    ylabel("Luminance (cd/m2)");
    title(strcat("Luminance: ", upper(lights(light))))k
    grid on

    %----------------------------------------------------------------------
    % ENDING MESSAGES
    disp(strcat(upper(lights(light)), " light finished! Measurements taken = ", string(sum(idx)),... 
        ", Total time = ", string(round(totalTime,1)), " seconds!"));
    if light < length(lights), disp("Next light starting!..."); else, disp("All finished!"); end
end

%--------------------------------------------------------------------------
% SAVING DATA
% trimming NaNs
sumNaN = sum(isnan(luminanceValues),2);
idx = sumNaN < length(lights);
calTbl = array2table([timeValues(idx,:), luminanceValues(idx,:)],...
    "RowNames", string(1:sum(idx)),...
    "VariableNames", ["Time_" + lights, "Luminance_" + lights]);

saveFilePath = pwd + "\CalibrationStabilityResults\Cal_" + dtString + ".mat";
save(saveFilePath,"calTbl");
disp(calTbl);

%--------------------------------------------------------------------------
% SAVING GRAPHS
% maximises figure
fig.WindowState = 'maximized';
% saves graphs as .JPG file
switch debugMode 
    case 0, graphPrefix = "Graph"; 
    case 1, graphPrefix = "TestGraph"; 
end
graphFilePath = pwd + "\graphs\" + graphPrefix + "_Stability_" + deviceLabel + "_" + dtString + ".JPG";
exportgraphics(tiledGraph, graphFilePath);

%--------------------------------------------------------------------------
% SHUT DOWN AND EXIT
% prepares to exit
PrepareToExit(arduino);
% beeps to let user know the program has finished
beep

end