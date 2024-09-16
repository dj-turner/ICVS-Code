function [optimalLConeSpectAbsShift, optimalShift] = EstimatingOptimalLConeSpectAbsShift(spectAbs,rgy,device,graphs)
% clc; clear; close all;
% data = LoadData; dataTbl = data.all;
% ptptID = "MAU";
% % Spectral absorbance
% % load table
% spectralAbsorbance = table2array(readtable("ssabance_5.csv"));
% % Only include defined wavelengths
% idx = ismember(spectralAbsorbance(:,1), 400:5:700);
% spectralAbsorbance = spectralAbsorbance(idx,2:end);
% % Raise to the 10th power
% spectralAbsorbance = 10 .^ spectralAbsorbance; 
% spectAbs = spectralAbsorbance;
% 
% row = find(strcmp(dataTbl.ptptID,ptptID));
% rgy = [dataTbl.rlmRed(row),dataTbl.rlmGreen(row),dataTbl.rlmYellow(row)];
% device = dataTbl.rlmDevice(row);
% graphs = true;

%% INITIALISATION
% set constants
fitVal = 1; % 0
maxTestShift = 25; % maximum shift to test
testStep = 1; % step between tested shifts
testInts = -maxTestShift:testStep:maxTestShift;  % Array of shift values to be tested

wvls = (400:5:700)';               % Wavelengths data tested
cones = ['L','M'];
LEDs = ['r','g','y'];           % Character labels for each LED

%% LOAD DEVICE CALIBRATION DATA
%[primarySpds,~] = LoadPrimarySpds(device); primarySpds = primarySpds.(device);
deviceVals = LoadDeviceValues;
for light = 1:length(LEDs), l = LEDs(light);
    primarySpds.(l) = CurveNormalisation(deviceVals.(device).(l).Spd, "height", deviceVals.(device).(l).LumMax);
end

%% TESTING SHIFTED L-CONES
testSpectAbs = struct("M",spectAbs(:,2));
testLSpectAbs = NaN(height(spectAbs(:,1)),numel(testInts));
lConeSpectAbsFits = NaN(numel(testInts),1);

for i = 1:numel(testInts)
    % Shifting the l-cone
    testSpectAbs.L = pchip(wvls+testInts(i),spectAbs(:,1),wvls);
    testLSpectAbs(:,i) = testSpectAbs.L;
    for cone = 1:length(cones), c = cones(cone);
        for led = 1:length(LEDs), l = LEDs(led);
            % Thomas and mollon method for predicting excitation to L- and M-
            % cones caused by each LED
            e.(c).(l) = trapz(primarySpds.(l) .* rgy(led) .* testSpectAbs.(c));
        end
    end
    eRatio.RG = (e.L.r + e.L.g)/(e.M.r + e.M.g);
    eRatio.Y = e.L.y/e.M.y;
    lConeSpectAbsFits(i) = eRatio.Y/eRatio.RG; 
    % lConeSpectAbsFits(i) = (e.L.y + e.M.y) - (e.L.r + e.M.r + e.L.g + e.M.g);
end

%% FINDING OPTIMAL SHIFT VALUE
optimalShift = pchip(lConeSpectAbsFits,testInts',fitVal);

% Generating L-cone spectral sensitivity for optimal shift
optimalLConeSpectAbsShift = pchip(wvls+optimalShift,spectAbs(:,1),wvls);

%% PLOTS
if graphs
    % Spectral Absorbances
    f1 = NewFigWindow;
    hold on
    % Tested L Spectral Absorbances
    for i = 1:numel(testInts)
        plot(wvls,testLSpectAbs(:,i),'LineWidth',1,'Color',[0 1 1 .3]);
    end
    % Standard L-, M-, and S-cone spectral absorbances
    colours = ['m','g','b'];
    for cone = 1:3, plot(wvls,spectAbs(:,cone),'LineWidth',5,'Color',colours(cone)); end
    % Optimal L-cone Spectral Absorbance
    normOptimalLConeSensShift = CurveNormalisation(optimalLConeSpectAbsShift,"height");
    plot(wvls,normOptimalLConeSensShift,'LineWidth',3,'Color','r');
    % Legend
    lgdlabs = [repmat("", [1 (2*maxTestShift/testStep)]), "Tested Shifts", "Original L-cone Prediction",...
        "M-cone Prediction", "S-cone Prediction", "Optimal L-Cone Prediction"];
    l1 = legend(lgdlabs,'Location','northeastoutside','TextColor','w','FontSize',12);
    % Axes and labels
    xlim([wvls(1),wvls(end)]);
    ylim([0,1]);
    title("Tested Shifted L-Cone Peak Spectral Absorbances");
    xlabel("Wavelength (nm)");
    ylabel("Relative Spectral Absorbance");
    % Presentation
    NiceGraphs(f1,l1);
    hold off

    % Excitation Fits
    f2 = NewFigWindow; 
    hold on
    % Tested L cone Spectral Absorbance Fits
    plot(testInts,lConeSpectAbsFits,'Color','r','LineWidth',3,...
        'Marker','o','MarkerEdgeColor','w','MarkerSize',3);
    % Reference Line at Perfect Match
    plot(testInts,repmat(fitVal,[height(lConeSpectAbsFits),1]),'Color','c',...
        'LineStyle','--','LineWidth',3) %#ok<RPMT1>
    % Axes and Labels
    xlim([-maxTestShift,maxTestShift])
    xlabel("L-cone Spectral Absorbance shift (nm)");
    ylabel("Excitation of L+M Difference (Y/(R+G))");
    % Presentation
    NiceGraphs(f2);
    hold off
end

end