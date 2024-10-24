function completeDataTbl = LMratio(validAValRange, rlmAdjustment, defaultAgeMode, graphPtpts) 
%%
%clc; clear; close all;
AddAllToPath; 
 
%% LOAD DATA
data = LoadData; dataTbl = data.all;

% Load Device Values
deviceVals = LoadDeviceValues("all");

% wavelengths
%wavelengths = 400:5:700;

% Load vLambda
%vLambda = table2array(readtable("CIE_sle_photopic.csv"));
%vLambda = vLambda(ismember(vLambda(:,1),wavelengths),2);

%% SET CONSTANTS
% Sets default age to the rounded median age, for ptpts where we don't have age data
if ~exist("defaultAgeMode",'var'), defaultAgeMode = "median"; end
defaultAge = table2array(stat(dataTbl.age,defaultAgeMode,"all"));
 
% Set valid aVal Range
if ~exist("validAValRange",'var'), validAValRange = [0.5,10]; end

% RLM Adjustment (logical)
if ~exist("rlmAdjustment",'var')
    rlmAdjustment = false; 
elseif ~islogical(rlmAdjustment)
    rlmAdjustment = logical(rlmAdjustment); 
end
rlmVals = NaN(1,3);
rlmDev = "N/A";

% graphs for some ptpts?
if ~exist("graphPtpts",'var')
    graphPtpts = "NONE";
elseif strcmpi(graphPtpts,"all")
    graphPtpts = dataTbl.ptptID';
end

%% CONE RATIO
% Finds participants with complete HFP data
completeHfpData = ~isnan(dataTbl.hfpRed) & ~isnan(dataTbl.hfpGreen);
completeDataTbl = dataTbl(completeHfpData,:);

% Calculating cone ratio for each ptpt
for ptpt = 1:height(completeDataTbl) %find(strcmp(dataTbl.ptptID,"JAA")) 

    % Extract participant code
    ptptID = completeDataTbl.ptptID(ptpt);

    g = ismember(ptptID,graphPtpts);
    
    % pulls age, defaults it or rounds it appropriately
    ptptAge = completeDataTbl.age(ptpt);
    if isnan(ptptAge), ptptAge = defaultAge; elseif ptptAge < 20, ptptAge = 20; elseif ptptAge > 80, ptptAge = 80; end

    % pulls Rayleigh match data
    if rlmAdjustment
        rlmVals = [completeDataTbl.rlmRed(ptpt), completeDataTbl.rlmGreen(ptpt), completeDataTbl.rlmYellow(ptpt)];
        rlmDev = completeDataTbl.rlmDevice(ptpt);
    end

    % pulls gene opsin
    l180Opsin = completeDataTbl.geneOpsin(ptpt);

    % use participant's age to estimate cone fundamentals (small pupil)
    [coneFuns.(ptptID), ~] = ConeFundamentals(age = ptptAge, fieldSize = 2,... 
        normalisation = "area", graphs = g, rlmRGY = rlmVals, rlmDevice = rlmDev, geneOpsin = l180Opsin);

    % pulls device name to look up values
    hfpVals = struct("r",completeDataTbl.hfpRed(ptpt),"g",completeDataTbl.hfpGreen(ptpt));
    hfpDev = completeDataTbl.hfpDevice(ptpt);

    % Allie's code to calculate a
    aValAllie = FindLMratioAllie(deviceVals.(hfpDev).r.Lum, deviceVals.(hfpDev).g.Lum,...
        deviceVals.(hfpDev).r.Lambda, deviceVals.(hfpDev).g.Lambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, completeDataTbl.hfpRed(ptpt));

    % My code to calculate a (NOT WORKING YET...)
    aValDana = FindLMratioDana(hfpVals, hfpDev, coneFuns.(ptptID), g);
    
    % work out percentage of fovea that is l/m/s-cones based on pred. ratio
    [coneProportion, foveaDensity] = FindConeProportionsAndDensities(aValDana);
    
    % save values to data table
    completeDataTbl.aValAllie(ptpt) = aValAllie;
    completeDataTbl.aValDana(ptpt) = aValDana;
    completeDataTbl.coneProportionL(ptpt) = coneProportion.l;
    completeDataTbl.coneProportionM(ptpt) = coneProportion.m;
    completeDataTbl.foveaDensityL(ptpt) = foveaDensity.l;
    completeDataTbl.foveaDensityM(ptpt) = foveaDensity.m;
    try
        completeDataTbl.shiftSA(ptpt) = coneFuns.(ptptID).spectAbsShift;
        completeDataTbl.shiftPSS(ptpt) = coneFuns.(ptptID).peakSpectSensShift;
    catch
    end

end

%%
idx = completeDataTbl.aValDana >= min(validAValRange) & completeDataTbl.aValDana <= max(validAValRange);
completeDataTbl.validRatio = idx;
validAValsDana = completeDataTbl.aValDana(idx);

data.analysis = completeDataTbl;%(idx,:);

switch rlmAdjustment
    case false, fileName = "LMratioData.mat";
    case true, fileName = "LMratioData_rlmAdj.mat";
end
save(fileName, "data");

disp(newline +... 
    "Dana Valid aVals..." + newline +... 
    "Percent Valid = " + round(100*(numel(validAValsDana)/height(completeDataTbl)),1) + "%" + newline +...
    "Mean = " + round(mean(validAValsDana),2) + newline +...
    "Std = " + round(std(validAValsDana),2));

%% HISTOGRAMS
idx = ~strcmp(completeDataTbl.hfpDevice,"");
vars = ["study","ptptID","aValAllie","aValDana","validRatio","hfpRed","hfpGreen"];
aValTbl = completeDataTbl(idx,vars);
%disp(aValTbl);

f = NewFigWindow; 
tiledlayout(2,2);

nexttile(1,[1 1])
histogram(aValTbl.aValAllie,'BinWidth',.1,'EdgeColor','w','FaceColor','c');
xlim([floor(min(validAValRange)),ceil(max(validAValRange))]);
xlabel("a Value"); ylabel("Count");
title("Allie");
NiceGraphs(f);

nexttile(3,[1 1])
histogram(aValTbl.aValDana,'BinWidth',.1,'EdgeColor','w','FaceColor','m');
xlim([floor(min(validAValRange)),ceil(max(validAValRange))]);
xlabel("a Value"); ylabel("Count");
title("Dana");
NiceGraphs(f);

nexttile(2,[2 1])
hold on
histogram(aValTbl.aValAllie,'BinWidth',.1,'EdgeColor','w','FaceColor','c','FaceAlpha',.5);
histogram(aValTbl.aValDana,'BinWidth',.1,'EdgeColor','w','FaceColor','m','FaceAlpha',.5);
hold off
xlim([floor(min(validAValRange)),ceil(max(validAValRange))]);
xlabel("a Value"); ylabel("Count");
title("Comparison");
NiceGraphs(f);

%% Group Comparison
cols = ['b','m','r','g'];

f = NewFigWindow;
tiledlayout(2,2);
groups = unique(floor(aValTbl.study));

for g = min(groups):max(groups)
    idx = floor(aValTbl.study) == g;
    groupData = aValTbl.aValDana(idx);

    nexttile
    histogram(groupData,'BinWidth',.1,'EdgeColor','w','FaceColor',cols(g+(1-min(groups))),'FaceAlpha',1);
    xlabel("a Value"); ylabel("Count");
    xlim([floor(min(validAValRange)),ceil(max(validAValRange))]);
    NiceGraphs(f);
end

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
function a = FindLMratioDana(hfpVals, hfpDev, coneFuns, graphs)

% Use default values is vars have not been entered
if ~exist("coneFuns",'var'), [coneFuns,~] = ConeFundamentals(normalisation = "area"); end
if ~exist("graphs",'var'), graphs = false; end
 
devVals = LoadDeviceValues(hfpDev,graphs);

% Set constants
x = coneFuns.wavelengths;

rSpd = devVals.(hfpDev).r.Spd;
gSpd = devVals.(hfpDev).g.Spd;

switch hfpDev
    case "uno"
        rRad = devVals.(hfpDev).r.Rad * hfpVals.r;
        gRad = devVals.(hfpDev).g.Rad * hfpVals.g;
        rSpd = CurveNormalisation(rSpd, "height", rRad);
        gSpd = CurveNormalisation(gSpd, "height", gRad);
    case {"yellow", "green"}
        rSpd = rSpd .* hfpVals.r;
        gSpd = gSpd .* hfpVals.g;
    otherwise
        error("Invalid HFP device name!");
end

sens.rM = trapz(rSpd .* coneFuns.mCones);
sens.rL = trapz(rSpd .* coneFuns.lCones);
sens.gM = trapz(gSpd .* coneFuns.mCones);
sens.gL = trapz(gSpd .* coneFuns.lCones);

a = (sens.rM-sens.gM)./(sens.gL-sens.rL); 

%graphs
if graphs
    f = NewFigWindow;

    hold on
    title("Spectral Sensitivities");
    xlabel("Wavelength (nm)");

    yyaxis left
    plot(x, coneFuns.lCones, "LineWidth", 3, "LineStyle", '-', "Color", 'r');
    plot(x, coneFuns.mCones, "LineWidth", 3, "LineStyle", '-', "Color", 'g');
    plot(x, coneFuns.sCones, "LineWidth", 3, "LineStyle", '-', "Color", 'b');
    ylabel("Cone Fundamentals");
    ylim([0, max([coneFuns.lCones;coneFuns.mCones;coneFuns.sCones])]);

    yyaxis right
    plot(x, rSpd, "LineWidth", 1, "LineStyle", '-', "Color", 'r');
    plot(x, gSpd, "LineWidth", 1, "LineStyle", '-', "Color", 'g');
    ylabel("LEDs"); 
    ylim([0, max([rSpd;gSpd])]);

    hold off
    l = legend(["L-Cones", "M-Cones", "S-Cones", "Red LED", "Green LED"]);
    NiceGraphs(f,l);
end

end

%%
function [cProp, cDensity] = FindConeProportionsAndDensities(a)
cProp.s = .05;
cProp.l = (a/(a+1))*(1-cProp.s);
cProp.m = (1/(a+1))*(1-cProp.s);

% From Sarah Regan's DPhil Thesis:
% "This can be calculated for an observer by taking a published estimate 
% of foveal cone density (168,162 cones/mm2)
% (Zhang, Godara, Blanco, Griffin, Wang, Curcio & Zhang, 2015)"
foveaConeDensityZhang = 168162;
cDensity.l = cProp.l * foveaConeDensityZhang;
cDensity.m = cProp.m * foveaConeDensityZhang;
cDensity.s = cProp.s * foveaConeDensityZhang;
end

