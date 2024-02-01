%--------------------------------------------------------------------------
% MATLAB RESET
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');
delete(instrfindall)
clc; clear; close all; 

%--------------------------------------------------------------------------
% SET CONSTANTS
lights = ["red", "green", "yellow"];                    % LEDs to calibrate (in order!)
levels = [0, 32, 64, 96, 128, 160, 192, 224, 255];      % Input values to test (in order!)

%--------------------------------------------------------------------------
% ADD PATHS
addpath(strcat(pwd, '\functions\'));
 
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
% CREATING VARIABLES
% Creates empty structure to store LED input values
LEDs = struct;
% Creates empty array for current LED for luminance values - to use in figures
plotLuminance = NaN(length(levels), length(lights));

%--------------------------------------------------------------------------
% GRAPH SETUP
% Initialise graphs
fig = figure('WindowState', 'minimized');
tiledGraph = tiledlayout(2, length(lights));
% Calculate date and time
dtString = string(datetime);
% Reformat into valid file name
charRep = [":", "."; "-", "."; " ", "_"];
for rep = 1:height(charRep), dtString = strrep(dtString, charRep(rep,1), charRep(rep,2)); end
% Set device and date and time as tiled chart title
title(tiledGraph, deviceLabel, 'Interpreter', 'none');
subtitle(tiledGraph, dtString, 'Interpreter', 'none');

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
    if deviceNum == 0, deviceLabel = string(input("Input Device Label: ", 's'));
    elseif deviceNum == 1, deviceLabel = "Yellow Band";
    elseif deviceNum == 2, deviceLabel = "Green Band";
    end
end

%--------------------------------------------------------------------------
% TESTING LOOP
% For each of the LEDs...
for light = 1:length(lights)
    %----------------------------------------------------------------------
    % LED SETUP AND ALIGNMENT
    % Set all light values to 0 in the LED value structure
    for i = 1:length(lights), LEDs.(lights(i)) = 0; end
    % Display which light we're currently calibrating
    disp(" ");
    disp(strcat("Current testing light: ", lights(light)));
    % Set current test light value to max
    LEDs.(lights(light)) = 255;
    % Write LED values to the arduino device
    WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);
    % Wait for user to press RETURN to continue (for light alignment)
    beep
    input("Alignment light on! Please press RETURN when you are ready to start.");
    % For each input level...
    for level = 1:length(levels)
        %------------------------------------------------------------------
        % LED SETUP
        % Set the current testing light to the current level value in in the struct
        LEDs.(lights(light)) = levels(level);
        % Write defined LED values to the device
        WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);
        % Tells the user which LED and level we're currently testing
        disp(strcat("Current ", lights(light), " value: ", num2str(levels(level))));
        % Pauses to make sure the LEDs have had time to change
        pause(.5);

        %------------------------------------------------------------------
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
            disp(lasterror);
            PrepareToExit(arduino);
            return
        end
        % turns monitor back on
        MonitorPower('on', debugMode);

        %------------------------------------------------------------------
        % SAVE RESULTS 
        % Saves results to .mat file
        SaveCalibrationResults(debugMode, deviceLabel, lights(light), levels(level), luminance, spectrum, spectrumPeak);
        % saves luminance values for plotting
        plotLuminance(level, light) = luminance;
        % saves spectrum data if this is the max luminance in the list to plot
        if levels(level) == max(levels), plotSpectrum = spectrum; end

        %------------------------------------------------------------------
        % EXITING PROGRAM (DEBUG MODE ONLY)
        % if on test mode, gives option to exit program (otherwise automatically continues)
        if debugMode == 1
            % asks for input
            i = input("Press RETURN to continue (or type ""exit"" to exit the program)", 's');
            % if exit is typed, exits program
            if strcmpi(i, "exit"), PrepareToExit(arduino); return; end
        end
    end

    %----------------------------------------------------------------------
    % DRAWING GRAPHS
    % Luminance
    % ROW 1: x = input value, y = luminance
    nexttile(light)
    plot(levels, plotLuminance(:,light), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([0, max(levels)]);
    xlabel("Input value");
    ylim([0, max(plotLuminance(:,light))]);
    ylabel("Luminance");
    title(strcat("Luminance: ", upper(lights(light))));

    % Spectrum
    % ROW 2: x = wavelengths, y = spectral sensitivity at final input value
    nexttile(light + length(lights))
    plot(plotSpectrum(1,:), plotSpectrum(2,:), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([min(plotSpectrum(1,:)), max(plotSpectrum(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(plotSpectrum(2,:))]);
    ylabel("Spectral Sensitivity");
    title(strcat("Spectrum: ", upper(lights(light))));

    %----------------------------------------------------------------------
    % ENDING MESSAGE
    if light < length(lights), disp("Next light starting!..."); else, disp("All finished!"); end
end

%--------------------------------------------------------------------------
% SAVING GRAPHS & EXITING
% maximises figure
fig.WindowState = 'maximized';
% saves graphs as .JPG file
if debugMode == 0, graphPrefix = "Graph"; elseif debugMode == 1, graphPrefix = "TestGraph"; end
exportgraphics(tiledGraph, strcat(pwd, "\graphs\", graphPrefix, "_", deviceLabel, "_", dtString, ".JPG"))
% generates and saves "over time" graph
if debugMode == 0, CalibrationOverTime(deviceLabel, dtString); end
% prepares to exit
PrepareToExit(arduino);
% beeps to let user know the program has finished
beep

%--------------------------------------------------------------------------
% FUNCTIONS
function PrepareToExit(a)   
% a = arduino device
% Reset all lights to off before closing
WriteLEDs(a,[0,0,0]);
% Clear everything before ending program
delete(instrfindall);
clear all; %#ok<CLALL>
warning('on', 'instrument:instrfindall:FunctionToBeRemoved');
end


function MonitorPower(dir, dMode)
% dir = direction of power switch ('on' or 'off')
% dMode = debug mode (0 = off, 1 = on)
% if not in debug mode, turn the monitor on/off
if dMode == 0, WinPower('monitor', dir);
    % if monitor is being turned off, pause for 1 second
    if strcmpi(dir, 'off'), pause(1); end
end
end
