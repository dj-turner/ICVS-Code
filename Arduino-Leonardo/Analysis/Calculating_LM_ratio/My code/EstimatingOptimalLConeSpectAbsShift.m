function [optimalLConeSpectAbsShift, optimalShift] = EstimatingOptimalLConeSpectAbsShift(spectAbs,rgy,device,graphs)
%% INITIALISATION
% set constants
testNum = 101; % number of shifts to test
testStep = 1; % step between tested shifts

testMaxVal = ((testNum-1)/2)*testStep;       % Max. shift to be tested
testInts = -testMaxVal:testStep:testMaxVal;  % Array of shift values to be tested

LEDs = ["red","green","yellow"];   % LEDs
LEDsChar = ['R','G','Y'];          % Character labels for each LED
coneCols = ['m','g','b'];
wvls = 400:5:700;             % Wavelengths data tested

% normalise cone fundamentals to have equal height
unnormalisedSpectAbs = spectAbs;
spectAbs = CurveNormalisation(spectAbs,"height");

%% LOAD DEVICE CALIBRATION DATA
primarySpds = LoadPrimarySpds(device); primarySpds = primarySpds.(device);

%% TESTING SHIFTED L-CONES
lConeSpectAbsFits = NaN(testNum,1);
auc = struct;
% Setting up graph
if strcmp(graphs,"yes")
    f = NewFigWindow;
    xlim([wvls(1),wvls(end)]);
    ylim([0,1]);
    title("Tested Shifted L-Cone Peak Spectral Absorbances");
    xlabel("Wavelength (nm)");
    ylabel("Relative Spectral Absorbance");
    NiceGraphs;
end
for i = 1:testNum
    % Shifting the l-cone
    testLSpectAbs = (pchip(wvls+testInts(i),spectAbs(:,1),wvls))';
    for led = 1:length(LEDs)
        % Thomas and mollon method for predictin excictation to l- and M-
        % cones caused by each LED
        auc.(LEDsChar(led)) = primarySpds.(LEDs(led)) .* rgy(led)... 
            .* spectAbs(:,2) .* testLSpectAbs;
    end
    % Total excitation values
    valY = sum(auc.Y);
    valRG = sum(auc.R) + sum(auc.G);
    % Difference between Y excitation and R+G excitation (perfect match
    % should be 0!)
    lConeSpectAbsFits(i) = valY-valRG;
    % Plotting shifted L-cone curve on a plot
    if strcmp(graphs,"yes")
        hold on
        plot(wvls,testLSpectAbs,'LineWidth',1,'Color',[0 1 1 .3])
        hold off
    end
end

%% PLOTTING FIT SCORES
if strcmp(graphs,"yes")
    NewFigWindow; 
    hold on
    plot(testInts,lConeSpectAbsFits,'Color','r','LineWidth',3,...
        'Marker','o','MarkerEdgeColor','w','MarkerSize',3);
    plot(testInts,zeros(height(lConeSpectAbsFits),1),'Color','c',...
        'LineStyle','--','LineWidth',3)
    xlim([-testMaxVal,testMaxVal])
    ylim([-max(abs(lConeSpectAbsFits)),max(abs(lConeSpectAbsFits))]);
    xlabel("L-cone Spectral Absorbance shift (nm)");
    ylabel("Excitation of L+M Difference (Y-(R+G))");
    hold off
    NiceGraphs
end

%% FINDING OPTIMAL SHIFT VALUE
optimalShift = pchip(lConeSpectAbsFits,testInts',0);

% Generating L-cone spectral sensitivity for optimal shift
optimalLConeSpectAbsShift = (pchip(wvls+optimalShift,unnormalisedSpectAbs(:,1),wvls))';

%% PLOTTING OPTIMISED L-CONE
if strcmp(graphs,"yes")
    normOptimalLConeSensShift = CurveNormalisation(optimalLConeSpectAbsShift,"height");
    figure(f);
    hold on
    for cone = 1:3, plot(wvls,spectAbs(:,cone),'LineWidth',5,'Color',coneCols(cone)); end
    plot(wvls,normOptimalLConeSensShift,'LineWidth',3,'Color','r');
    lgdlabs = [repmat("", [1 testNum-1]), "Tested Shifts", "Original L-cone Prediction",...
        "M-cone Prediction", "S-cone Prediction", "Optimal L-Cone Prediction"];
    legend(lgdlabs,'Location','northeastoutside','TextColor','w','FontSize',12);
    hold off
end

end