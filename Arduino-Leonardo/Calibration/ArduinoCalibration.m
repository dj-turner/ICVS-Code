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
lights = ["red", "green", "yellow"];                % LEDs to calibrate
levels = [0, 32, 64, 96, 128, 160, 192, 224, 255];     % Input values to test

% Creates empty structure to store LED input values
LEDs = struct;

% initialise graphs
figure;
tiledGraph = tiledlayout(2, length(lights));
dt = string(datetime);
dt = strrep(dt, ":", ".");
dt = strrep(dt, " ", "_");
title(tiledGraph, dt, 'Interpreter', 'none');

% test mode
beep
testMode = input("Test mode? 0/1: ");

% For each of the LEDs...
for light = 1:length(lights)

    % Set all light values to 0 in the LED structure
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

        % Wait for user to press RETURN to continue 9for light alignment)
        beep
        input("Alignment light on! Please press RETURN when you are ready to start.");
    end

    plotLum = NaN(length(levels), 2);

    % For each input level...
    for level = 1:length(levels)

        % Set the current testing light to the current level value in in the struct
        LEDs.(lights(light)) = levels(level);

        % Write defined LED values to the device
        WriteLEDs(arduino, [LEDs.red, LEDs.green, LEDs.yellow]);

        % Tells the user which LED and level we're currently testing
        disp(strjoin(["Current", lights(light), "value:", num2str(levels(level))], ' '));

        % Pauses to make sure the LEDs ahve had time to change
        pause(.5);

        % Measures the spectrum and luminance using the PR670
        WinPower('monitor', 'off')
        pause(1);
        try
            [luminance, spectrum, spectrumPeak] = measurePR670(portPR670);
        catch
            WinPower('monitor', 'on')
            newPortNum = input("Potentially wrong port number entered! Please check and enter the port number here: ");
            newPortPR670 = char(strcat('COM', num2str(newPortNum)));
            WinPower('monitor', 'off')
            pause(1);
            try
                [luminance, spectrum, spectrumPeak] = measurePR670(newPortPR670);
                portPR670 = newPortPR670;
            catch
                WinPower('monitor', 'on')
                disp("Still not working! Exiting program...");
                return
            end
        end
        WinPower('monitor', 'on')

        % Saves results to .mat file
        SaveCalibrationResults(lights(light), levels(level), luminance, spectrum, spectrumPeak);

        % saves luminance values for plotting
        plotLum(level, :) = [levels(level), luminance];

        if testMode == 1
            beep
            i = input("Press RETURN to continue (or type ""exit"" to exit the program)", 's');
            if strcmpi(i, "exit")
                PrepareToExit(arduino)
                return
            end
        end
    end

    % draws graphs
    % luminance
    nexttile(light)
    plot(plotLum(:,1), plotLum(:,2), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([0, max(plotLum(:,1))]);
    xlabel("Input value");
    ylim([0, max(plotLum(:,2))]);
    ylabel("Luminance");
    title(strjoin(["Luminance:", upper(lights(light))], ' '));

    % spectral
    nexttile(light + length(lights))
    plot(spectrum(1,:), spectrum(2,:), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', lights(light))
    xlim([min(spectrum(1,:)), max(spectrum(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(spectrum(2,:))]);
    ylabel("Spectral Sensitivity");
    title(strjoin(["Spectrum:", upper(lights(light))], ' '));

    % Asks user for input to begin next test light (unless this is the last one!)
    if light ~= length(lights)
        disp("Next light starting!...");
    else
        disp("All finished!");
    end
end

exportgraphics(tiledGraph,strcat(pwd, "\graphs\Graph_", dt, ".JPG"))
PrepareToExit(arduino)
beep

%--------------------------------------------------------------------------
function PrepareToExit(a)
% Reset all lights to off before closing
WriteLEDs(a,[0,0,0]);

% Clear everything before ending program
delete(instrfindall);
clear;
warning('on', 'instrument:instrfindall:FunctionToBeRemoved');
end
