%%
clc; clear; close all;

% sarah's thesis have a reference: work out cone density X
% add RLM to cone funs X
% radiance not luminance!
% use LED curve instead of rLumMax, etc.

% Set valid aVal Range
validAValRange = [0,5];

% Load data
warning('off','MATLAB:table:ModifiedAndSavedVarnames')
data = LoadData;
warning('on','MATLAB:table:ModifiedAndSavedVarnames')
dataTbl = data.all;

%%
% Make new variable to store LM ratio value in
% newVars = ["aVal", "conePercentL", "conePercentM", "foveaDensityL", "foveaDensityM"];
% for var = 1:length(newVars), dataTbl.(newVars(var)) = nan(height(dataTbl), 1); end

% Sets default age to the rounded mean age, for ptpts where we don't have age data
defaultAge = round(mean(dataTbl.age,'omitmissing'));

%%

% Cone Fundamentals and Cone Ratios
coneFuns = struct;

% Calculating cone ratio for each ptpt
for ptpt = 1%:height(dataTbl)
    
    % If the participant didn't do a HFP task, skips and continues to next ptpt
    if strcmp(dataTbl.devCombHFP(ptpt),""), continue; end

    % Extract participant code
    ptptID = dataTbl.ptptID(ptpt);
    
    % pulls age, defaults it or rounds it appropriately
    ptptAge = dataTbl.age(ptpt);
    if isnan(ptptAge), ptptAge = defaultAge; elseif ptptAge < 20, ptptAge = 20; elseif ptptAge > 80, ptptAge = 80; end

    % pulls Rayleigh match data
    rlmVals = [dataTbl.rlmRed(ptpt), dataTbl.rlmGreen(ptpt), dataTbl.rlmYellow(ptpt)];
    rlmDev = dataTbl.leoDev(ptpt);

    % use participant's age to estimate cone fundamentals (small pupil)
    [coneFuns.(ptptID), ~] = ConeFundamentals(age = ptptAge, fieldSize = 1, normalisation = "area",...
        rlmRGY = rlmVals, rlmDevice = rlmDev);

    % pulls device name to look up values
    hfpDev = dataTbl.devCombHFP(ptpt);

    % Allie's code to calculate a
    deviceVals = LoadDeviceValues;
    aValAllie = FindLMratioAllie(deviceVals.(hfpDev).r.LumMax, deviceVals.(hfpDev).g.LumMax,...
        deviceVals.(hfpDev).r.Lambda, deviceVals.(hfpDev).g.Lambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, dataTbl.combHFP(ptpt));

    % My code to calculate a (NOT WORKING YET...)
    aValDana = FindLMratioDana(coneFuns.(ptptID),... 
        [dataTbl.hfpRed(ptpt),dataTbl.hfpGreen(ptpt)],... 
         deviceVals.(hfpDev), "yes");
    %disp("aValAllie = " + aVal + ", aValDana = " +aValDana);

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
%%
idx = dataTbl.aValAllie > validAValRange(1) & dataTbl.aValAllie <= validAValRange(2);
validAVals = dataTbl.aValAllie(idx);
invalidAVals = dataTbl.aValAllie(~idx);
percentValid = round(100 * (numel(validAVals) / numel(dataTbl.aValAllie)),1);
validDataTbl = dataTbl(idx,:);

disp(percentValid + "% valid")
disp("Mean(a) = " + mean(validAVals) + ", Std(a) = " + std(validAVals));

histogram(validAVals,'BinWidth',.2)

%%
% Display mean cone ratio in sample (would expect a value of around 2!)
% disp(dataTbl(:,["ptptID", "devCombHFP", "combHFP", "aVal", "conePercentL", "conePercentM"]));

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

%disp([sensToRFromL, sensToRFromM, sensToGFromL, sensToGFromM]);

a = (sensToRFromM-sensToGFromM)./(sensToGFromL-sensToRFromL);
end

%% MY FUNCTION
function a = FindLMratioDana(coneFuns, hfpRG, devVals, graphs)

% VFss
VFss = 1.980647 .* coneFuns.lCones + coneFuns.mCones;

hfpRad.r = hfpRG(1) .* (devVals.r.RadMax - devVals.r.RadMin) + devVals.r.RadMin;
hfpRad.g = hfpRG(2) .* (devVals.g.RadMax - devVals.g.RadMin) + devVals.g.RadMin;

spd.r = hfpRad.r .* devVals.r.Spd;
spd.g = hfpRad.g .* devVals.g.Spd;

if strcmpi(graphs, "yes")
    x = coneFuns.wavelengths;
    NewFigWindow;
    hold on
    xlabel("Wavelength (nm)");

    yyaxis left
    plot(x, coneFuns.lCones, "LineWidth", 3, "LineStyle", '-', "Color", 'r');
    plot(x, coneFuns.mCones, "LineWidth", 3, "LineStyle", '-', "Color", 'g');
    plot(x, VFss, "LineWidth", 3, "LineStyle", '-', "Color", 'w');
    ylabel("Cone Fundamentals");

    yyaxis right
    plot(x, spd.r, "LineWidth", 1, "LineStyle", '-', "Color", 'r');
    plot(x, spd.g, "LineWidth", 1, "LineStyle", '-', "Color", 'g');
    ylabel("LED SPDs");

    hold off
    legend(["L-Cones", "M-Cones", "VFss", "Red LED", "Green LED"]);
    NiceGraphs;
end

% Sens to LED from cone
rL = trapz(spd.r .* coneFuns.lCones .* VFss);
gL = trapz(spd.g .* coneFuns.lCones .* VFss);
rM = trapz(spd.r .* coneFuns.mCones .* VFss);
gM = trapz(spd.g .* coneFuns.mCones .* VFss);

%disp([rM, gM, gL, rL]);

a = (rM - gM) ./ (gL - rL);

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

