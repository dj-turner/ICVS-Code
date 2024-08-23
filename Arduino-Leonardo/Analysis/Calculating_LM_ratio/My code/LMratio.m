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
vLambda = table2array(readtable("CIE_sle_photopic.csv"));
vLambda = vLambda(ismember(vLambda(:,1),400:5:700),2);

%% SET CONSTANTS
% Sets default age to the rounded mean age, for ptpts where we don't have age data
defaultAge = round(mean(dataTbl.age,'omitmissing'));

% Set valid aVal Range
validAValRange = [0,5];

%% CONE RATIO
% Calculating cone ratio for each ptpt
for ptpt = 1%:height(dataTbl)
    
    % If the participant didn't do the HFP task, skips and continues to next ptpt
    if strcmp(dataTbl.devCombHFP(ptpt),""), continue; end

    % Extract participant code
    ptptID = dataTbl.ptptID(ptpt);

    % graphs for some ptpts?
    %if ismember(ptptID,["AAA","JAA"]), g = "yes"; else, g = "no"; end
    %g = "no";
    g = "yes";
    
    % pulls age, defaults it or rounds it appropriately
    ptptAge = dataTbl.age(ptpt);
    if isnan(ptptAge), ptptAge = defaultAge; elseif ptptAge < 20, ptptAge = 20; elseif ptptAge > 80, ptptAge = 80; end

    % pulls Rayleigh match data
    rlmVals = [dataTbl.rlmRed(ptpt), dataTbl.rlmGreen(ptpt), dataTbl.rlmYellow(ptpt)];
    rlmDev = dataTbl.leoDev(ptpt);

    % use participant's age to estimate cone fundamentals (small pupil)
    [coneFuns.(ptptID), ~] = ConeFundamentals(age = ptptAge, fieldSize = 1, normalisation = "area",...
        graphs = g, rlmRGY = rlmVals, rlmDevice = rlmDev);

    % pulls device name to look up values
    hfpDev = dataTbl.devCombHFP(ptpt);

    % Allie's code to calculate a
    aValAllie = FindLMratioAllie(deviceVals.(hfpDev).r.LumMax, deviceVals.(hfpDev).g.LumMax,...
        deviceVals.(hfpDev).r.Lambda, deviceVals.(hfpDev).g.Lambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, dataTbl.combHFP(ptpt));

    % My code to calculate a (NOT WORKING YET...)
    aValDana = FindLMratioDana(... 
        [dataTbl.hfpRed(ptpt),dataTbl.hfpGreen(ptpt)],...
         deviceVals.(hfpDev), coneFuns.(ptptID), g);

    % work out percentage of fovea that is l/ms/s-cones based on pred. ratio
    [coneProportion, foveaDensity] = FindConeProportionsAndDensities(aValAllie);
    
    % save values to data table
    dataTbl.aValAllie(ptpt) = aValAllie;
    dataTbl.aValDana(ptpt) = aValDana;
    dataTbl.coneProportionL(ptpt) = coneProportion.l;
    dataTbl.coneProportionM(ptpt) = coneProportion.m;
    dataTbl.foveaDensityL(ptpt) = foveaDensity.l;
    dataTbl.foveaDensityM(ptpt) = foveaDensity.m;
end

save("LMratioData.mat", "dataTbl");

idx = dataTbl.aValDana >= 0 & dataTbl.aValDana <= 5;
validAValsDana = dataTbl.aValDana(idx);

disp(newline +... 
    "Dana Valid aVals..." + newline +... 
    "Percent Valid = " + round(100*(numel(validAValsDana)/height(dataTbl)),1) + "%" + newline +...
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

nexttile(3,[1 1])
histogram(aValTbl.aValDana,'BinWidth',.1,'EdgeColor','w','FaceColor','m');
xlim([0,5]); ylim([0,20]);
xlabel("a Value"); ylabel("Count");
title("Dana");
NiceGraphs(f);

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
    histogram(groupData,'BinWidth',.1,'EdgeColor','w','FaceColor',cols(group),'FaceAlpha',1);
    xlabel("a Value"); ylabel("Count");
    xlim([0 5]);
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
end

%% MY FUNCTION
function a = FindLMratioDana(hfpRG, devVals, coneFuns, graphs)

% Use default values is vars have not been entered
if ~exist("coneFuns",'var'), [coneFuns,~] = ConeFundamentals(normalisation = "area"); end
if ~exist("graphs",'var'), graphs = "no"; end

% Set constants
LEDs = ['r','g'];
cones = ['L','M'];
x = coneFuns.wavelengths;

for light = 1:length(LEDs), l = LEDs(light);
    % Calculate radiance of light at given setting
    lightRadiance = hfpRG(light) .* devVals.(l).RadMax;
    lightSpd = CurveNormalisation(devVals.(l).SpdMax,"area",lightRadiance);
    for cone = 1:length(cones), c = cones(cone);
        y = lightSpd .* coneFuns.(lower(c)+"Cones");
        sens.(strcat(l,c)) = sum(y);
    end
end

a = (sens.rM-sens.gM)./(sens.gL-sens.rL);

%graphs
if strcmpi(graphs, "yes")
    f = NewFigWindow;

    hold on
    title("Spectral Sensitivities");
    xlabel("Wavelength (nm)");

    yyaxis left
    plot(x, coneFuns.lCones, "LineWidth", 3, "LineStyle", '-', "Color", 'r');
    plot(x, coneFuns.mCones, "LineWidth", 3, "LineStyle", '-', "Color", 'g');
    plot(x, coneFuns.sCones, "LineWidth", 3, "LineStyle", '-', "Color", 'b');
    ylabel("Cone Fundamentals");

    yyaxis right
    plot(x, devVals.r.SpdMax, "LineWidth", 1, "LineStyle", '-', "Color", 'r');
    plot(x, devVals.g.SpdMax, "LineWidth", 1, "LineStyle", '-', "Color", 'g');
    ylabel("LEDs");

    hold off
    l = legend(["L-Cones", "M-Cones", "S-Cones", "Red LED", "Green LED"]);
    NiceGraphs(f,l);
end
end

%%
function [cProp, cDensity] = FindConeProportionsAndDensities(a)
cProp = struct;
cProp.s = .05;
cProp.l = (a/(a+1))*(1-cProp.s);
cProp.m = (1/(a+1))*(1-cProp.s);

% From Sarah Regan's DPhil Thesis:
% "This can be calculated for an observer by taking a published estimate 
% of foveal cone density (168,162 cones/mm2)
% (Zhang, Godara, Blanco, Griffin, Wang, Curcio & Zhang, 2015)"
foveaConeDensityZhang = 168162;
cDensity = struct;
cDensity.l = cProp.l * foveaConeDensityZhang;
cDensity.m = cProp.m * foveaConeDensityZhang;
cDensity.s = cProp.s * foveaConeDensityZhang;
end

