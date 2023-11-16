% Clear everything before starting program
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');
delete(instrfindall)
clc; clear; close all; 

%--------------------------------------------------------------------------
% INITIALISATION
% set constants
lights = ["red", "green", "yellow"];                    % LEDs to calibrate (in order!)
levels = [0, 32, 64, 96, 128, 160, 192, 224, 255];      % Input values to test (in order!)

%--------------------------------------------------------------------------
% add folder path to required functions
addpath(strcat(pwd, '\functions\'));

% Loading and setting up the arduino device - Do not touch this code!
arduino = OpenArduinoPort;
% Display the arduino port
disp(strjoin(["Using port", arduino.Port, "for the Arduino device!"]));

% Finding the PR670 port
% Find all available ports
availablePorts = serialportlist;
% Remove the arduino port from the list
availablePorts = availablePorts(~strcmp(availablePorts,arduino.Port));
% Set the PR670 port as the last on the list
portPR670 = char(availablePorts(end));
% Display the pr670 port
disp(strjoin(["Using port", portPR670, "for the PR670!"]));

% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(arduino, [0,0,0]);

% Creates empty structure to store LED input values
LEDs = struct;

% GRAPH SETUP
% initialise graphs
fig = figure('WindowState', 'minimized');
tiledGraph = tiledlayout(2, length(lights));
% calculate date and time
dt = string(datetime);
% reformat into valid file name
charRep = [":", "."; "-", "."; " ", "_"];
for rep = 1:height(charRep), dt = strrep(dt, charRep(rep,1), charRep(rep,2)); end
% set date and time as tiled chart title
title(tiledGraph, dt, 'Interpreter', 'none');

% creates empty array for current LED for luminance values - to use in figures
plotLumData = NaN(length(levels), length(lights));

% will only move on if either 0 or 1 is entered for the testMode
while ~exist("testMode", 'var') || (testMode ~= 0 && testMode ~= 1)
    testMode = input("Test mode? (0 = off, 1 = on): ");
end

%--------------------------------------------------------------------------
% TESTING LOOP

% For each of the LEDs...
for light = 1:length(lights)

    % Set all light values to 0 in the LED value structure
    LEDs.red = 0; LEDs.green = 0; LEDs.yellow = 0;

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

        % Set the current testing light to the current level value in in the struct
        LEDs.(lights(light)) = levels(level);

        % Write defined LED values to the device
        WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);

        % Tells the user which LED and level we're currently testing
        disp(strcat("Current ", lights(light), " value: ", num2str(levels(level))));

        % Pauses to make sure the LEDs have had time to change
        pause(.5);

        %------------------------------------------------------------------
        % TAKES PR670 MEASUREMENTS
        % Turns off the monitor
        MonitorPower('off', testMode)

        % Tries to take PR670 measurements using defined port
        try
            [luminance, spectrum, spectrumPeak] = MeasurePR670(portPR670);

        % if this doesn't work, displays error and quits
        catch
            %turns on the monitor
            MonitorPower('on', testMode)
            disp(lasterror);
            PrepareToExit(arduino);
            return
        end

        % turns monitor back on
        MonitorPower('on', testMode);

        %------------------------------------------------------------------
        % Saves results to .mat file
        SaveCalibrationResults(testMode, lights(light), levels(level), luminance, spectrum, spectrumPeak);

        % saves luminance values for plotting
        plotLumData(level, light) = luminance;

        % if on test mode, gives option to exit program (otherwise automatically continues)
        if testMode == 1
            % asks for input
            i = input("Press RETURN to continue (or type ""exit"" to exit the program)", 's');
            % if exit is typed, exits program
            if strcmpi(i, "exit"), PrepareToExit(arduino); return; end
        end
    end

    % DRAWING GRAPHS
    % ROW 1: x = input value, y = luminance
    nexttile(light)
    plot(levels, plotLumData(:,light), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([0, max(levels)]);
    xlabel("Input value");
    ylim([0, max(plotLumData(:,light))]);
    ylabel("Luminance");
    title(strcat("Luminance: ", upper(lights(light))));

    % ROW 2: x = wavelengths, y = spectral sensitivity at final input value
    nexttile(light + length(lights))
    plot(spectrum(1,:), spectrum(2,:), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([min(spectrum(1,:)), max(spectrum(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(spectrum(2,:))]);
    ylabel("Spectral Sensitivity");
    title(strcat("Spectrum: ", upper(lights(light))));

    % Displays ending message
    if light < length(lights), disp("Next light starting!..."); elseif light == length(lights), disp("All finished!"); end
end

%--------------------------------------------------------------------------
% SAVING & EXITING

% maximises figure
fig.WindowState = 'maximized';

% saves graphs as .JPG file
if testMode == 0, graphPrefix = "Graph"; elseif testMode == 1, graphPrefix = "TestGraph"; end
exportgraphics(tiledGraph, strcat(pwd, "\graphs\", graphPrefix, "_", dt, ".JPG"))

% prepares to exit
PrepareToExit(arduino);

% beeps to let user know the program has finished
beep

% END OF SCRIPT

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


function MonitorPower(dir, tMode)
% dir = direction of power switch ('on' or 'off')
% tMode = testing mode (0 = off, 1 = on)

% if not in test mode, turn the monitor on/off
if tMode == 0
    WinPower('monitor', dir)
    % if monitor is being turned off, pause for 1 second
    if strcmpi(dir, 'off')
        pause(1);
    end
end
end
