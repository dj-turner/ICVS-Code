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
ptpt = "JAA";
idx = strcmpi(dataTbl.ptptID,ptpt);
rgy = [dataTbl.rlmRed(idx),dataTbl.rlmGreen(idx),dataTbl.rlmYellow(idx)];
device = dataTbl.rlmDevice(idx);
deviceValues = LoadDeviceValues(device); deviceValues = deviceValues.(device);


redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0

%% m-cone
testInts = -25:1:25;

f = NewFigWindow;
hold on
for i = 1:length(testInts)
    testLSpectAbs(:,i)  = pchip(wvls+testInts(i),spectralAbsorbance(:,1),wvls);

    tbl = nan(1001,1001);
    
    for lambda = 0:.001:1
        [red,green] = SetRedAndGreen(lambda,redAnchor,greenAnchor);
        r = trapz(deviceValues.r.Spd .* red .* testLSpectAbs(:,i));
        g = trapz(deviceValues.g.Spd .* green .* testLSpectAbs(:,i));
        rg = r + g;
        
        for yellow = 0:.001:1
            y = trapz(deviceValues.y.Spd .* yellow .* testLSpectAbs(:,i));
            diff = y-rg;
            a = round(lambda*100 + 1);
            b = round(yellow*100 + 1);
            tbl(b,a) = diff;
        end
    
    end

    tbl = abs(tbl);
    
    [r,c] = find(min(tbl));
    x = 0:.001:1;
    c = c ./ 1000;
    plot(x,c','Marker','none','Color','g','LineWidth',3);
    

end

xlim([0 1]); ylim([0 1]);
hold off
NiceGraphs(f);

