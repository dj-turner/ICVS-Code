function [optimalLConeSensShift, optimalShift] = EstimatingOptimalLConeSpectSensShift(coneFuns,rgy,device,graphs)
%% INITIALISATION
% set constants
testNum = 101; % number of shifts to test
testStep = 1; % step between tested shifts

testMaxVal = ((testNum-1)/2)*testStep;       % Max. shift to be tested
testInts = -testMaxVal:testStep:testMaxVal;  % Array of shift values to be tested

LEDs = ["red","green","yellow"];   % LEDs
LEDsChar = ['R','G','Y'];          % Character labels for each LED
coneCols = ['r','g','b'];
wvls = 400:5:700;             % Wavelengths data tested

% normalise cone fundamentals to have equal height
unnormalisedConeFuns = coneFuns;
coneFuns = CurveNormalisation(coneFuns,"height");

%% LOAD DEVICE CALIBRATION DATA
% load calibration data
addpath("data\");
calTbl = load("CalibrationResults.mat");
calTbl = calTbl.calibrationTable;

% save most recent SPD data from the correct device and max. device setting in a structure
primarySpds = struct;
for led = 1:length(LEDs)
    idx = strcmpi(calTbl.Device, device+" band") & calTbl.InputValue == 255 & calTbl.LED == LEDs(led);
    ledTbl = calTbl(idx,:);
    ledVals = table2array(ledTbl(end,"LambdaSpectrum"))';
    wvlVals = table2array(ledTbl(end,"Lambdas"))';
    primarySpds.(LEDs(led)) = ledVals(ismember(wvlVals,wvls));
end

%% TESTING SHIFTED L-CONES
lConeFits = NaN(testNum,1);
auc = struct;
% Setting up graph
if strcmp(graphs,"yes")
    f = NewFigWindow;
    xlim([wvls(1),wvls(end)]);
    ylim([0,1]);
    title("Tested Shifted L-Cone Peak Spectral Sensitivities");
    xlabel("Wavelength (nm)");
    ylabel("Relative Spectral Sensitivity");
    NiceGraphs;
end
for i = 1:testNum
    % Shifting the l-cone
    testExpLConeFuns = (spline(wvls+testInts(i),coneFuns(:,1),wvls))';
    for led = 1:length(LEDs)
        % Thomas and mollon method for predictin excictation to l- and M-
        % cones caused by each LED
        auc.(LEDsChar(led)) = primarySpds.(LEDs(led)) .* rgy(led)... 
            .* coneFuns(:,2) .* testExpLConeFuns;
    end
    % Total excitation values
    valY = sum(auc.Y);
    valRG = sum(auc.R) + sum(auc.G);
    % Difference between Y excitation and R+G excitation (perfect match
    % should be 0!)
    lConeFits(i) = valY-valRG;
    % Plotting shifted L-cone curve on a plot
    if strcmp(graphs,"yes")
        hold on
        plot(wvls,testExpLConeFuns,'LineWidth',1,'Color',[0 1 1 .3])
        hold off
    end
end

%% PLOTTING FIT SCORES
if strcmp(graphs,"yes")
    NewFigWindow; 
    hold on
    plot(testInts,lConeFits,'Color','r','LineWidth',3,...
        'Marker','o','MarkerEdgeColor','w','MarkerSize',3);
    plot(testInts,zeros(height(lConeFits),1),'Color','c',...
        'LineStyle','--','LineWidth',3)
    xlim([-testMaxVal,testMaxVal])
    ylim([-abs(max(lConeFits)),abs(max(lConeFits))]);
    xlabel("L-cone Spectral Sensitivity shift (nm)");
    ylabel("Excitation of L+M Difference (Y-(R+G))");
    hold off
    NiceGraphs
end

%% FINDING OPTIMAL SHIFT VALUE
optimalShift = spline(lConeFits,testInts',0);

% Generating L-cone spectral sensitivity for optimal shift
optimalLConeSensShift = (spline(wvls+optimalShift,unnormalisedConeFuns(:,1),wvls))';

%% PLOTTING OPTIMISED L-CONE
if strcmp(graphs,"yes")
    normOptimalLConeSensShift = CurveNormalisation(optimalLConeSensShift,"height");
    figure(f);
    hold on
    for cone = 1:3, plot(wvls,coneFuns(:,cone),'LineWidth',5,'Color',coneCols(cone)); end
    plot(wvls,normOptimalLConeSensShift,'LineWidth',3,'Color','m');
    lgdlabs = [repmat("", [1 testNum-1]), "Tested Shifts", "Original L-cone Prediction",...
        "M-cone Prediction", "S-cone Prediction", "Optimal L-Cone Prediction"];
    legend(lgdlabs,'Location','northeast','TextColor','w','FontSize',12);
    hold off
end


end