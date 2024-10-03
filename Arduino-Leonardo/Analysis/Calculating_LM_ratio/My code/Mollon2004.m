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
testInts = -25:1:25;
testSteps = 0:.02:1;

f = NewFigWindow;
diffVals = NaN(numel(testInts),numel(testSteps),numel(testSteps));
optY = NaN(numel(testSteps),1);
hold on
for i = 1:length(testInts)+1
    if i == length(testInts)+1
        testSpectAbs(:,i) = spectralAbsorbance(:,2);
    else
        testSpectAbs(:,i)  = pchip(wvls+testInts(i),spectralAbsorbance(:,1),wvls);
    end

    a = 0; 
    for lambdaStep = 1:length(testSteps), lambda = testSteps(lambdaStep);
        a = a+1;
        [r,g] = SetRedAndGreen(lambda,redAnchor,greenAnchor);
        excRed = trapz(deviceValues.r.Spd .* r .* testSpectAbs(:,i));
        excGreen = trapz(deviceValues.g.Spd .* g .* testSpectAbs(:,i));
        excRG = excRed + excGreen;

        b = 0;
        for yellowStep = 1:length(testSteps), yellow = testSteps(yellowStep);
            b = b+1;
            excYellow = trapz(deviceValues.y.Spd .* yellow .* testSpectAbs(:,i));
            diffVals(i,b,a) = excRG - excYellow;
        end

        optY(a) = pchip(diffVals(i,:,a),testSteps,0);
    end
    if i == length(testInts)+1
        plot(testSteps,optY,'Marker','none','MarkerEdgeColor','w','LineStyle','--','Color','g','LineWidth',3)
    else
        plot(testSteps,optY,'Marker','x','MarkerEdgeColor','w')
    end
end

xlim([0 1]); ylim([0 1]);
xlabel("Lambda Setting"); ylabel("Yellow Setting");
for ptpt = 1:height(dataTbl)
    plot(dataTbl.rlmRG(ptpt),dataTbl.rlmYellow(ptpt),'Marker','o','MarkerSize',5,'MarkerEdgeColor','w','MarkerFaceColor','w')
end
hold off
l = legend(string(testInts));
NiceGraphs(f,l);

