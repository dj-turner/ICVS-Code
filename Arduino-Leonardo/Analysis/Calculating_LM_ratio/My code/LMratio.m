%%
clc; clear; close all;

% sarah's thesis have a reference: work out cone density X
% radiance not luminance!
% use LED curve instead of rLumMax, etc.

% Load data
warning('off','MATLAB:table:ModifiedAndSavedVarnames')
data = LoadData;
warning('on','MATLAB:table:ModifiedAndSavedVarnames')
dataTbl = data.all;

%%
% Make new variable to store LM ratio value in
newVars = ["aVal", "conePercentL", "conePercentM", "foveaDensityL", "foveaDensityM"];
for var = 1:length(newVars), dataTbl.(newVars(var)) = nan(height(dataTbl), 1); end

% Sets default age to the rounded mean age, for ptpts where we don't have age data
defaultAge = round(mean(dataTbl.age,'omitmissing'));

% Device values
deviceVals = LoadDeviceValues; 

%%

% Cone Fundamentals and Cone Ratios
coneFuns = struct;

% Calculating cone ratio for each ptpt
for ptpt = 1:height(dataTbl)
    
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
    aVal = FindLMratio(deviceVals.(hfpDev).rLumMax, deviceVals.(hfpDev).gLumMax,...
        deviceVals.(hfpDev).rLambda, deviceVals.(hfpDev).gLambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, dataTbl.combHFP(ptpt));

    % work out percentage of fovea that is l/ms/s-cones based on pred. ratio
    [conePercent, foveaDensity] = FindConePercentagesAndDensities(aVal);
    
    % save values to data table
    dataTbl.aVal(ptpt) = aVal;
    dataTbl.conePercentL(ptpt) = conePercent.l;
    dataTbl.conePercentM(ptpt) = conePercent.m;
    dataTbl.foveaDensityL(ptpt) = foveaDensity.l;
    dataTbl.foveaDensityM(ptpt) = foveaDensity.m;
end

save("LMratioData.mat", "dataTbl");
%%
idx = dataTbl.aVal>0 & dataTbl.aVal <=5;
validAVals = dataTbl.aVal(idx);
percentValid = round(100 * (numel(validAVals) / numel(dataTbl.aVal)),1);
histogram(validAVals,'BinWidth',.2)

%%
% Display mean cone ratio in sample (would expect a value of around 2!)
disp(dataTbl(:,["ptptID", "devCombHFP", "combHFP", "aVal", "conePercentL", "conePercentM"]));

%%
function devVals = LoadDeviceValues
% Conversion constant: full width half maximum to standard deviation
fwhm2stddev = 1 / 2.35482004503;
wavelengths = 400:5:700;
% Device value stucture
devVals = struct;
    % Lab-based device (from Allie's values)
    devVals.uno.gLumMax = 594.3295;
    devVals.uno.rLumMax = 962.7570;
    devVals.uno.gLambda = 545;
    devVals.uno.rLambda = 630;
    devVals.uno.rRadMin = 10 ^ 2.39;
    devVals.uno.rRadMax = 10 ^ 2.99;
    devVals.uno.rRadStd = 10 * fwhm2stddev;
    devVals.uno.gRadMin = 10 ^ 2.77;
    devVals.uno.gRadMax = devVals.uno.gRadMin;
    devVals.uno.gRadStd = 10 * fwhm2stddev;
    devVals.uno.rMaxGaussian = normpdf(wavelengths, devVals.uno.rLambda, devVals.uno.rRadStd);
    devVals.uno.gMaxGaussian = normpdf(wavelengths, devVals.uno.gLambda, devVals.uno.gRadStd);
    % Yellow Arduino device (from Josh's calibration results)
    devVals.yellow.gLumMax = 54.92;
    devVals.yellow.rLumMax = 168.6;
    devVals.yellow.gLambda = 542;
    devVals.yellow.rLambda = 626;
    devVals.yellow.rRadMin = NaN;
    devVals.yellow.rRadMax = NaN;
    devVals.yellow.rRadStd = NaN;
    devVals.yellow.gRadMin = NaN;
    devVals.yellow.gRadMax = NaN;
    devVals.yellow.gRadStd = NaN;
    % Green Arduino Device (from Mitch's calibration results)
    devVals.green.gLumMax = NaN;
    devVals.green.rLumMax = NaN;
    devVals.green.gLambda = NaN;
    devVals.green.rLambda = NaN;
    devVals.green.rRadMin = NaN;
    devVals.green.rRadMax = NaN;
    devVals.green.rRadStd = NaN;
    devVals.green.gRadMin = NaN;
    devVals.green.gRadMax = NaN;
    devVals.green.gRadStd = NaN;
end

%%
% ALLIE'S FUNCTION
function a = FindLMratio(rLumMax, gLumMax, rLambda, gLambda, lambdas, lSS, mSS, rgSetting)
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

