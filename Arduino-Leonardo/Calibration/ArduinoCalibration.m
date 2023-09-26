% Clear everything before starting program
delete(instrfindall)

% Clear all extra variables from the workspace
clearvars;

% Loading and setting up the arduino device - Do not touch this code!
a = OpenArduinoPort;

% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(a,[0,0,0]);

% set constants
lights = ["red", "green", "yellow"];
levels = [0, 32, 64, 96, 128, 160, 192, 224, 255];

LEDs = struct;

for light = 1:length(lights)

    for LED = 1:length(lights)
        LEDs.(lights(LED)) = 0;
    end

    disp(" ");
    disp(strjoin(["Current testing light:", lights(light)], ' '));

    LEDs.(lights(light)) = 255;
    WriteLEDs(a, [LEDs.red, LEDs.green, LEDs.yellow]);

    input("Alignment light on! Please press RETURN when you are ready to start.");

    for level = 1:length(levels)

        LEDs.(lights(light)) = levels(level);

        WriteLEDs(a, [LEDs.red, LEDs.green, LEDs.yellow]);

        disp(strjoin(["Current", lights(light), "Value:", num2str(LEDs.(lights(light)))], ' '));

        SaveCalibrationResults(lights(light), LEDs.(lights(light)));
    end

    input("Current light finished! Press RETURN to continue: ");
end

% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(a,[0,0,0]);
