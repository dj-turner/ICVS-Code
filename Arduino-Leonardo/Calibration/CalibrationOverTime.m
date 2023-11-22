function CalibrationOverTime(dt)

% Loads all Calibration data taken out of test mode
load('CalibrationResults.mat');

% selects only data where the input was at max. value, and the relevant
% variables
graphTbl = calibrationTable(calibrationTable.InputValue == 255,...
    ["Date", "LED", "Luminance"]);

% list of led colours to cycle through
LEDs = ["red", "green", "yellow"];

% pulls the number of figures open and adds 1
figNum = get(gcf,'Number') + 1;
% opens a new figure in the specified window number
fig = figure(figNum);

% creates a tiled layout for the graphs
t = tiledlayout(1, length(LEDs));
% sets the title as the inputted date and time
title(t, dt, 'Interpreter', 'none');

% for each LED...
for colour = 1:length(LEDs)
    % makes a table with only the values for the specified LED colour
    colourTbl = graphTbl(strcmp(graphTbl.LED, LEDs(colour)), :);
    % converts date and time data in table to DateTime format
    dates = datetime(colourTbl.Date);

    % tells matlab to move to the next tile in the tiled chart layout
    nexttile
    % plots the dates against the luminance values in the matching colour
    plot(dates, colourTbl.Luminance,...
        'Marker', 'x', 'MarkerEdgeColor', 'k',...
        'Color', LEDs(colour));
    % sets the title to contain the LED colour
    title(strcat("LED: ", LEDs(colour)));
end

% maximises figure
fig.WindowState = 'maximized';
% saves graph
exportgraphics(t, strcat(pwd, "\graphs\", "TimeGraph", "_", dt, ".JPG"))

end
