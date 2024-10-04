clc; clear; close all;
addpath("tables\");

% wavelengths
wvls = 400:5:700;
% load table
spectralAbsorbance = table2array(readtable("ssabance_5.csv"));
% Only include defined wavelengths
idx = ismember(spectralAbsorbance(:,1), wvls);
spectralAbsorbance = spectralAbsorbance(idx,2:end);
% Raise to the 10th power
spectralAbsorbance = 10 .^ spectralAbsorbance; 

% Load ptpt data
data = LoadData;
dataTbl = data.all;
ptpt = "TAA";
idx = strcmpi(dataTbl.ptptID,ptpt);
rgy = [dataTbl.rlmRed(idx),dataTbl.rlmGreen(idx),dataTbl.rlmYellow(idx)];
device = dataTbl.rlmDevice(idx);
deviceValues = LoadDeviceValues(device); deviceValues = deviceValues.(device);


redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0

%% m-cone
testInts = -5:1:5;
testSteps = 0:.02:1;
coneNum = 2;
coneCols = ['r','g'];

f = NewFigWindow;
diffVals = NaN(numel(testInts),numel(testSteps),numel(testSteps),coneNum);
optY = NaN(numel(testSteps),1);
testSpectAbs = NaN(height(spectralAbsorbance),numel(testInts),coneNum);
hold on
for cone = 1:coneNum
    for i = 1:length(testInts)
        testSpectAbs(:,i,cone)  = pchip(wvls+testInts(i),spectralAbsorbance(:,cone),wvls);
    
        a = 0; 
        for lambdaStep = 1:length(testSteps), lambda = testSteps(lambdaStep);
            a = a+1;
            [r,g] = SetRedAndGreen(lambda,redAnchor,greenAnchor);
            excRed = trapz(deviceValues.r.Spd .* r .* testSpectAbs(:,i,cone));
            excGreen = trapz(deviceValues.g.Spd .* g .* testSpectAbs(:,i,cone));
            excRG = excRed + excGreen;
    
            b = 0;
            for yellowStep = 1:length(testSteps), yellow = testSteps(yellowStep);
                b = b+1;
                excYellow = trapz(deviceValues.y.Spd .* yellow .* testSpectAbs(:,i,cone));
                diffVals(i,b,a,cone) = excRG - excYellow;
            end
    
            optY(a) = pchip(diffVals(i,:,a,cone),testSteps,0);
        end
        rgb = cone==1:3;
        if testInts(i) == 0
            plot(testSteps,optY,'Marker','none','MarkerEdgeColor','w','LineStyle','--','Color',[rgb,1],'LineWidth',3)
        else
            plot(testSteps,optY,'Marker','none','Color',[rgb,.5])
        end
    end
end

xlim([.5 .7]); ylim([.4 .6]);
xlabel("Lambda Setting"); ylabel("Yellow Setting");
studies = floor(dataTbl.study);
for study = 0:3
    switch study
        case 0, colour = 'b';
        case 1, colour = 'm';
        case 2, colour = 'r';
        case 3, colour = 'g';
    end
    idx = studies == study;

    x = dataTbl.rlmRG(idx);
    y = dataTbl.rlmYellow(idx);
    textShift = .001;
    scatter(x,y,50,...
        'Marker','o','MarkerEdgeColor','w','MarkerFaceColor',colour,'MarkerEdgeAlpha',1,'MarkerFaceAlpha',.35);
    % text(x+textShift,y+textShift,string(dataTbl.ptptNum(idx)),'FontSize',4)
end
hold off
l = legend([repmat("",[1,numel(testInts)*coneNum]),... 
    ["Allie","Dana","Josh","Mitch"] + "'s Data"]);
NiceGraphs(f,l);

%%
lambdaVals = 0:.01:1;
plotG = NaN(numel(lambdaVals),1);
plotR = NaN(numel(lambdaVals),1);
plotY = NaN(numel(lambdaVals),1);
for lambda = 1:length(lambdaVals)
    [plotR(lambda),plotG(lambda)] = SetRedAndGreen(lambdaVals(lambda),redAnchor,greenAnchor);
    plotY(lambda) = lambdaVals(lambda);
end

plotG = plotG .* deviceValues.g.Lum;
plotR = plotR .* deviceValues.r.Lum;
plotY = plotY .* deviceValues.y.Lum;

f = NewFigWindow;
hold on
plot(lambdaVals,plotG,'Marker','none','Color','g','LineWidth',3);
plot(lambdaVals,plotR,'Marker','none','Color','r','LineWidth',3);
plot(lambdaVals,plotY,'Marker','none','Color','y','LineWidth',3);
plot(lambdaVals,plotR+plotG,'Marker','none','Color','w','LineWidth',3);
hold off
xlim([0 1]);
ylim([0 max([plotY;plotR+plotG])]);
xlabel("Lambda/Yellow value input");
ylabel("Output luminance value (cd/m2)");
NiceGraphs(f);

