% Clear everything before starting program
warning('off', 'instrument:instrfindall:FunctionToBeRemoved');
delete(instrfindall)
clear;

addpath(strcat(pwd, '\functions\'));

% Loading and setting up the arduino device - Do not touch this code!
arduino = OpenArduinoPort;

% define PR670 port
portPR670 = 'COM8';

% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(arduino, [0,0,0]);

% set constants
lights = ["red", "green", "yellow"];                % LEDs to calibrate
levels = [32, 64, 96, 128, 160, 192, 224, 255];     % Input values to test

% Creates empty structure to store LED input values
LEDs = struct;

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
        input("Alignment light on! Please press RETURN when you are ready to start.");
    end

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
        [luminance, spectrum, spectrumPeak] = measurePR670(portPR670);

        % Saves results to .mat file
        SaveCalibrationResults(lights(light), levels(level), luminance, spectrum, spectrumPeak);
    end

    % Asks user for input to begin next test light (unless this is the last one!)
    if light ~= length(lights)
        input("Current light finished! Press RETURN to continue: ");
    end
end

% Reset all lights to off before closing
WriteLEDs(arduino,[0,0,0]);

% Clear everything before ending program
delete(instrfindall);
clear;
warning('on', 'instrument:instrfindall:FunctionToBeRemoved');
