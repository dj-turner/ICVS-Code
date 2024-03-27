close all; clear; clc;

colours = ["red", "green", "yellow"];
fig = 0;

lineColours = [1, 0, 0;...
               1, .25, 0;...
               1, .6, 0;...
               .6, 1, 0;...
               0, 1, 0;...
               0, 1, .4;...
               0, 1, .9;...
               0, .25, 1;...
               .25, 0, 1;...
               .5, 0, 1;...
               .9, 0, 1];

%load new calibration data
newData = load("CalibrationResults.mat", "calibrationTable");
newData = newData.calibrationTable;
newDataDate = "26-Mar-2024";
newData = newData(startsWith(string(newData.DateTime), newDataDate),:);

% load icvs data
addpath("ICVS_Summer_School\");
icvsData = struct;

icvsGroups = 8;

for group = 1:icvsGroups
    for led = 1:length(colours)
        fileName = strcat("calibration_data_", colours(led), "_group", num2str(group), ".mat");
        icvsData.(strcat(colours(led), num2str(group))) = load(fileName);
    end
end

%%
icvsRG = NaN(1,icvsGroups);
for group = 1:icvsGroups
    redValue = icvsData.(strcat("red", num2str(group))).output_lum(end);
    greenValue = icvsData.(strcat("green", num2str(group))).output_lum(end);
    icvsRG(group) = redValue / greenValue;
end

newDevices = unique(newData.Device);
newRG = NaN(1,length(newDevices));
for device = 1:length(newDevices)
    idx = strcmp(newData.Device, newDevices(device)) & newData.InputValue == 255;
    currentData = newData(idx,:);
    redValue = table2array(currentData(strcmp(currentData.LED, "red"),"Luminance"));
    greenValue = table2array(currentData(strcmp(currentData.LED, "green"),"Luminance"));
    newRG(device) = redValue / greenValue;
end

fig = fig + 1;
f = figure(fig);

allRG = [icvsRG, newRG];
b = bar(allRG);
b.FaceColor = 'flat';
for bar = 1:length(allRG)
    b.CData(bar,:) = lineColours(bar,:);
end
set(gca, 'xticklabel', ["G1", "G2", "G3", "G4", "G5", "G6", "G7", "G8", "Josh", "Mitch", "Test"]);

xlabel("Device");
ylabel("Max red lum / Max green lum");

%%

fig = fig + 1;
f = figure(fig);
t = tiledlayout(2,length(colours));

newData255 = newData(newData.InputValue == 255,:);
for led = 1:length(colours)
    for group = 1:icvsGroups
        nexttile(led)
        x = icvsData.(strcat(colours(led), num2str(group))).requested_value .* 255;
        y = icvsData.(strcat(colours(led), num2str(group))).output_lum;
        SpectraPlot(x,y,lineColours(group,:))
        title(colours(led));

        nexttile(led+length(colours))
        x = icvsData.(strcat(colours(led), num2str(group))).wls;
        y = icvsData.(strcat(colours(led), num2str(group))).spd;
        SpectraPlot(x,y,lineColours(group,:))
    end
        
    % newData
    currentData = newData255(strcmp(newData255.LED, colours(led)),:);
    for device = 1:height(currentData)
        nexttile(led)
        idx = strcmp(newData.LED, colours(led)) & strcmp(newData.Device, newDevices(device));
        x = table2array(newData(idx,"InputValue"));
        y = table2array(newData(idx,"Luminance"));
        SpectraPlot(x,y,lineColours(icvsGroups+device,:))

        nexttile(led+length(colours))
        x = table2array(currentData(device,"Lambdas"));
        y = table2array(currentData(device,"LambdaSpectrum"));
        SpectraPlot(x,y,lineColours(icvsGroups+device,:))
    end
end

function SpectraPlot(xVals,yVals,lCol)
hold on
plot(xVals, yVals, 'LineWidth', 3, 'Color', lCol);
hold off
end
