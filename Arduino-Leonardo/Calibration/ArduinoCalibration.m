% Clear everything before starting program
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');
delete(instrfindall)
clc; clear; close all; 

% add folder path to required functions
addpath(strcat(pwd, '\functions\'));

% Loading and setting up the arduino device - Do not touch this code!
arduino = OpenArduinoPort;

% define PR670 port
portPR670 = 'COM10';

% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(arduino, [0,0,0]);

% set constants
lights = ["red", "green", "yellow"];                    % LEDs to calibrate
levels = [0, 32, 64, 96, 128, 160, 192, 224, 255];      % Input values to test

% Creates empty structure to store LED input values
LEDs = struct;

% GRAPH SETUP
% initialise graphs
figure;
tiledGraph = tiledlayout(2, length(lights));
% calculate date and time
dt = string(datetime);
% reformat into valid file name
dt = strrep(dt, ":", ".");
dt = strrep(dt, " ", "_");
% set date and time as tiled chart title
title(tiledGraph, dt, 'Interpreter', 'none');

% test mode
testMode = input("Test mode? 0/1: ");

% For each of the LEDs...
for light = 1:length(lights)

    % Set all light values to 0 in the LED value structure
    for LED = 1:length(lights)
        LEDs.(lights(LED)) = 0;
    end

    % Display which light we're currently calibrating
    disp(" ");
    disp(strjoin(["Current testing light:", lights(light)], ' '));

    % If the light is either red or yellow...
    if strcmp(lights(light), "red") || strcmp(lights(light), "yellow")

        % Set current test light value to max
        LEDs.(lights(light)) = 255;

        % Write LED values to the arduino device
        WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);

        % Wait for user to press RETURN to continue (for light alignment)
        beep
        input("Alignment light on! Please press RETURN when you are ready to start.");
    end

    % creates empty array for current LED for luminance values - to use in figures
    plotLumData = NaN(length(levels), 2);

    % For each input level...
    for level = 1:length(levels)

        % Set the current testing light to the current level value in in the struct
        LEDs.(lights(light)) = levels(level);

        % Write defined LED values to the device
        WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);

        % Tells the user which LED and level we're currently testing
        disp(strjoin(["Current", lights(light), "value:", num2str(levels(level))], ' '));

        % Pauses to make sure the LEDs have had time to change
        pause(.5);

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

        % Saves results to .mat file
        SaveCalibrationResults(testMode, lights(light), levels(level), luminance, spectrum, spectrumPeak);

        % saves luminance values for plotting
        plotLumData(level, :) = [levels(level), luminance];

        % if on test mode, gives option to exit program (otherwise automatically continues)
        if testMode == 1
            % asks for input
            i = input("Press RETURN to continue (or type ""exit"" to exit the program)", 's');
            % if exit is typed, exits program
            if strcmpi(i, "exit")
                PrepareToExit(arduino)
                return
            end
        end
    end

    % draws graphs for current test light
    % ROW 1: x = input value, y = luminance
    nexttile(light)
    plot(plotLumData(:,1), plotLumData(:,2), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([0, max(plotLumData(:,1))]);
    xlabel("Input value");
    ylim([0, max(plotLumData(:,2))]);
    ylabel("Luminance");
    title(strjoin(["Luminance:", upper(lights(light))], ' '));

    % ROW 2: x = wavelengths, y = spectral sensitivity at final input value
    nexttile(light + length(lights))
    plot(spectrum(1,:), spectrum(2,:), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([min(spectrum(1,:)), max(spectrum(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(spectrum(2,:))]);
    ylabel("Spectral Sensitivity");
    title(strjoin(["Spectrum:", upper(lights(light))], ' '));

    % Displays message
    if light ~= length(lights)
        disp("Next light starting!...");
    else
        disp("All finished!");
    end
end

% saves graphs as .JPG file
exportgraphics(tiledGraph,strcat(pwd, "\graphs\Graph_", dt, ".JPG"))

% prepares to exit
PrepareToExit(arduino)

% beeps to let user know the program has finished
beep

%--------------------------------------------------------------------------
function PrepareToExit(a)
% Reset all lights to off before closing
WriteLEDs(a,[0,0,0]);
% Clear everything before ending program
delete(instrfindall);
clear all; %#ok<CLALL>
warning('on', 'instrument:instrfindall:FunctionToBeRemoved');
end

%--------------------------------------------------------------------------
function MonitorPower(dir, tMode)
% if not in test mode, turn the monitor on/off
if tMode == 0
    WinPower('monitor', dir)
    % if monitor is turned off, pause for 1 second
    if strcmpi(dir, 'off')
        pause(1);
    end
end
end
