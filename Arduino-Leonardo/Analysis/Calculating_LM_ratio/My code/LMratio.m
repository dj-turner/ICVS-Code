%%
clc; clear; close all;

% sarah's thesis have a reference: work out cone density X
% add RLM to cone funs X
% radiance not luminance! X
% use LED curve instead of rLumMax, etc. X

%% LOAD DATA
data = LoadData; dataTbl = data.all;

% Load Device Values
deviceVals = LoadDeviceValues;

% Load Vlambda
vLambda = table2array(readtable("linCIE2008v2e_5.csv"));
vLambda = vLambda(ismember(vLambda(:,1),400:5:700),2);

%% SET CONSTANTS
% Sets default age to the rounded mean age, for ptpts where we don't have age data
defaultAge = round(mean(dataTbl.age,'omitmissing'));

% Set valid aVal Range
validAValRange = [0,5];

%% CONE RATIO
% Calculating cone ratio for each ptpt
for ptpt = 1:height(dataTbl)
    
    % If the participant didn't do a HFP task, skips and continues to next ptpt
    if strcmp(dataTbl.devCombHFP(ptpt),""), continue; end

    % Extract participant code
    ptptID = dataTbl.ptptID(ptpt);

    % graphs for some ptpts?
    if strcmpi(ptptID,"JAA"), g = "yes"; else, g = "no"; end
    %g = "no";
    
    % pulls age, defaults it or rounds it appropriately
    ptptAge = dataTbl.age(ptpt);
    if isnan(ptptAge), ptptAge = defaultAge; elseif ptptAge < 20, ptptAge = 20; elseif ptptAge > 80, ptptAge = 80; end

    % pulls Rayleigh match data
    rlmVals = [dataTbl.rlmRed(ptpt), dataTbl.rlmGreen(ptpt), dataTbl.rlmYellow(ptpt)];
    rlmDev = dataTbl.leoDev(ptpt);

    % use participant's age to estimate cone fundamentals (small pupil)
    [coneFuns.(ptptID), ~] = ConeFundamentals(age = ptptAge, fieldSize = 2, normalisation = "area",...
        graphs = g, rlmRGY = rlmVals, rlmDevice = rlmDev);

    % pulls device name to look up values
    hfpDev = dataTbl.devCombHFP(ptpt);

    % Allie's code to calculate a
    aValAllie = FindLMratioAllie(deviceVals.(hfpDev).r.LumMax, deviceVals.(hfpDev).g.LumMax,...
        deviceVals.(hfpDev).r.Lambda, deviceVals.(hfpDev).g.Lambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, dataTbl.combHFP(ptpt));

    % My code to calculate a (NOT WORKING YET...)
    aValDana = FindLMratioDana(coneFuns.(ptptID),... 
        [dataTbl.hfpRed(ptpt),dataTbl.hfpGreen(ptpt)],... 
         deviceVals.(hfpDev),... 
         g);

    % work out percentage of fovea that is l/ms/s-cones based on pred. ratio
    [conePercent, foveaDensity] = FindConePercentagesAndDensities(aValAllie);
    
    % save values to data table
    dataTbl.aValAllie(ptpt) = aValAllie;
    dataTbl.aValDana(ptpt) = aValDana;
    dataTbl.conePercentL(ptpt) = conePercent.l;
    dataTbl.conePercentM(ptpt) = conePercent.m;
    dataTbl.foveaDensityL(ptpt) = foveaDensity.l;
    dataTbl.foveaDensityM(ptpt) = foveaDensity.m;
end

save("LMratioData.mat", "dataTbl");

idx = dataTbl.aValDana >= 0 & dataTbl.aValDana <= 5;
validAValsDana = dataTbl.aValDana(idx);

disp(newline +... 
    "Dana Valid aVals..." + newline +... 
    "Percent Valid = " + (100 * (numel(validAValsDana)/height(dataTbl))) + "%" + newline +...
    "Mean = " + round(mean(validAValsDana),2) + newline +...
    "Std = " + round(std(validAValsDana),2));

%% HISTOGRAMS
idx = ~strcmp(dataTbl.devCombHFP,"");
vars = ["ptptID","aValAllie","aValDana","hfpRed","hfpGreen"];
aValTbl = dataTbl(idx,vars);
%disp(aValTbl);

f = NewFigWindow;
t = tiledlayout(2,2);

nexttile(1,[1 1])
h=histogram(aValTbl.aValAllie,'BinWidth',.1,'EdgeColor','w','FaceColor','c');
xlim([0,5]); ylim([0,20]);
xlabel("a Value"); ylabel("Count");
title("Allie");
NiceGraphs(f);
ax = gca; ax.Title.Color = 'c';

nexttile(3,[1 1])
histogram(aValTbl.aValDana,'BinWidth',.1,'EdgeColor','w','FaceColor','m');
xlim([0,5]); ylim([0,20]);
xlabel("a Value"); ylabel("Count");
title("Dana");
NiceGraphs(f);
ax = gca; ax.Title.Color = 'm';

nexttile(2,[2 1])
hold on
histogram(aValTbl.aValAllie,'BinWidth',.1,'EdgeColor','w','FaceColor','c','FaceAlpha',.5);
histogram(aValTbl.aValDana,'BinWidth',.1,'EdgeColor','w','FaceColor','m','FaceAlpha',.5);
hold off
xlim([0,5]); ylim([0,20]);
xlabel("a Value"); ylabel("Count");
title("Comparison");
NiceGraphs(f);

%% Group Comparison
groupID.Allie = "A";
groupID.Dana = "B";
groupID.Josh = ["D","J"];
groupID.Mitch = ["M","T"];

groups = string(fieldnames(groupID));

cols = ['b','m','r','g'];

f = NewFigWindow;
tiledlayout(2,2);
for group = 1:length(groups), g = groupID.(groups(group));
    idx = startsWith(aValTbl.ptptID,g);
    groupData = aValTbl.aValDana(idx);
    groupMeans.(groups(group)) = mean(groupData,'omitmissing');

    nexttile
    histogram(groupData,'BinWidth',.1,'EdgeColor','w','FaceColor',cols(group),'FaceAlpha',.25);
    xlabel("a Value"); ylabel("Count");
    NiceGraphs(f);
end

%% ALLIE'S FUNCTION
function a = FindLMratioAllie(rLumMax, gLumMax, rLambda, gLambda, lambdas, lSS, mSS, rgSetting)
% specify rSetting
% derive a that would have produced a luminance match
stepSize = lambdas(2)-lambdas(1);
rLambda = round(rLambda/stepSize)*stepSize;
gLambda = round(gLambda/stepSize)*stepSize;

VFss = (1.980647 .* lSS + mSS);

sensToRFromM = rgSetting.*mSS(lambdas == rLambda).*rLumMax.*VFss(lambdas == gLambda);
sensToGFromM = mSS(lambdas==gLambda).*gLumMax.*VFss(lambdas==rLambda);
sensToGFromL = lSS(lambdas==gLambda).*gLumMax.*VFss(lambdas==rLambda);
sensToRFromL = rgSetting.*lSS(lambdas==rLambda).*rLumMax.*VFss(lambdas == gLambda);

a = (sensToRFromM-sensToGFromM)./(sensToGFromL-sensToRFromL);
%disp("aValAllie = " + a);
end

%% MY FUNCTION
function a = FindLMratioDana(coneFuns, hfpRG, devVals, graphs)

% vLambda
vLambda = (1.980647 .* coneFuns.lCones) + coneFuns.mCones;
vLambda = CurveNormalisation(vLambda,"height");

LEDs = ['r','g'];
cones = ['L','M'];

for light = 1:length(LEDs), l = LEDs(light);
    % Find luminance values at match setting
    hfpLum.(l) = hfpRG(light) .* (devVals.(l).LumMax - devVals.(l).LumMin) + devVals.(l).LumMin;
    
    %Convert luminance values to radiance values
    k.(l) = hfpLum.(l) / sum(vLambda .* devVals.(l).Spd);
    hfpRad.(l) = sum(k.(l) .* devVals.(l).Spd);

    %Scale SPD so area = radiance
    spd.(l) = CurveNormalisation(devVals.(l).Spd, "area", hfpRad.(l), coneFuns.wavelengths);

    % Calculate cone sensitivities to the light
    for cone = 1:length(cones), c = cones(cone);
        sens.(strcat(l,c)) = trapz(coneFuns.wavelengths, spd.(l) .* coneFuns.(lower(c)+"Cones"));
    end
end

a = (sens.rM-sens.gM)./(sens.gL-sens.rL);
%disp("aValDana = " + a);

%graphs
if strcmpi(graphs, "yes")
    f = NewFigWindow;

    hold on
    title("Spectral Sensitivities");
    x = coneFuns.wavelengths;
    xlabel("Wavelength (nm)");

    yyaxis left
    plot(x, coneFuns.lCones, "LineWidth", 3, "LineStyle", '-', "Color", 'r');
    plot(x, coneFuns.mCones, "LineWidth", 3, "LineStyle", '-', "Color", 'g');
    plot(x, coneFuns.sCones, "LineWidth", 3, "LineStyle", '-', "Color", 'b');
    ylabel("Cone Fundamentals");

    yyaxis right
    plot(x, spd.r, "LineWidth", 1, "LineStyle", '-', "Color", 'r');
    plot(x, spd.g, "LineWidth", 1, "LineStyle", '-', "Color", 'g');
    ylabel("LEDs");

    hold off
    l = legend(["L-Cones", "M-Cones", "S-Cones", "Red LED", "Green LED"]);
    NiceGraphs(f,l);
end

end

%%
function [cPercent, cDensity] = FindConePercentagesAndDensities(a)
cPercent = struct;
cPercent.s = .05;
cPercent.l = (a/(a+1))*(1-cPercent.s);
cPercent.m = (1/(a+1))*(1-cPercent.s);

% From Sarah Regan's DPhil Thesis:
% "This can be calculated for an observer by taking a published estimate 
% of foveal cone density (168,162 cones/mm2)
% (Zhang, Godara, Blanco, Griffin, Wang, Curcio & Zhang, 2015)"
foveaConeDensityZhang = 168162;
cDensity = struct;
cDensity.l = cPercent.l * foveaConeDensityZhang;
cDensity.m = cPercent.m * foveaConeDensityZhang;
cDensity.s = cPercent.s * foveaConeDensityZhang;
end

