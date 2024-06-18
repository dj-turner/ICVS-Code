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
for var = 1:length(newVars)
    dataTbl.(newVars(var)) = nan(height(dataTbl), 1);
end

% Sets default age to the rounded mean age, for ptpts where we don't have age data
defaultAge = round(mean(dataTbl.age,'omitmissing'));

% Device values
deviceVals = LoadDeviceValues; 

% Cone Fundamentals and Cone Ratios
coneFuns = struct;

% Calculating cone ratio for each ptpt
for ptpt = 1:height(dataTbl)
    
    % If the participant didn't do a HFP task, skips and continues to next ptpt
    if strcmp(dataTbl.devCombHFP(ptpt), ""), continue; end

    % Extract participant code
    ptptID = dataTbl.ptptID(ptpt);
    
    % pulls age, defaults it or rounds it appropriately
    age = dataTbl.age(ptpt);
    if isnan(age), age = defaultAge; elseif age < 20, age = 20; elseif age > 80, age = 80; end

    % use participant's age to estimate cone fundamentals (2 deg, small pupil)
    coneFuns.(ptptID) = ConeFundamentals(age,2,"small","no");

    % pulls device name to look up values
    device = dataTbl.devCombHFP(ptpt);

    % Allie's code to calculate a
    aVal = FindLMratio(deviceVals.(device).rLumMax, deviceVals.(device).gLumMax,...
        deviceVals.(device).rLambda, deviceVals.(device).gLambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, dataTbl.combHFP(ptpt));

    % work out percentage of fovea that is l/ms/s-cones based on pred. ratio
    conePercent = FindConePercentages(aVal);
    foveaDensity = FindConeDensities(conePercent);
    
    % save values to data table
    dataTbl.aVal(ptpt) = aVal;
    dataTbl.conePercentL(ptpt) = conePercent.l;
    dataTbl.conePercentM(ptpt) = conePercent.m;
    dataTbl.foveaDensityL(ptpt) = foveaDensity.l;
    dataTbl.foveaDensityM(ptpt) = foveaDensity.m;
end

save("LMratioData.mat", "dataTbl");

%%
% Display mean cone ratio in sample (would expect a value of around 2!)
disp(dataTbl(:,["ptptID", "devCombHFP", "combHFP", "aVal", "conePercentL", "conePercentM"]));

%%
function devVals = LoadDeviceValues
devVals = struct;
    % Lab-based device (from Allie's values)
    devVals.uno.gLumMax = 594.3295;
    devVals.uno.rLumMax = 962.7570;
    devVals.uno.gLambda = 545;
    devVals.uno.rLambda = 630;
    % Yellow Arduino device (from Josh's calibration results)
    devVals.leo_y.gLumMax = 54.92;
    devVals.leo_y.rLumMax = 168.6;
    devVals.leo_y.gLambda = 542;
    devVals.leo_y.rLambda = 626;
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
function cPercent = FindConePercentages(a)
cPercent = struct;
cPercent.s = .05;
cPercent.l = (a/(a+1))*(1-cPercent.s);
cPercent.m = (1/(a+1)) *(1-cPercent.s);
end

%%
function cDensity = FindConeDensities(cPercent)
% From Sarah Regan's DPhil Thesis:
% "This can be calculated for an observer by taking a published estimate 
% of foveal cone density (168,162 cones/mm2)
% (Zhang, Godara, Blanco, Griffin, Wang, Curcio & Zhang, 2015)"
foveaConeDensityZhang = 168162;
% use cone percentages to estimate fovea densities of each cone type
cDensity = struct;
cones = string(fieldnames(cPercent));
for cone = 1:numel(cones)
    cDensity.(cones(cone)) = cPercent.(cones(cone)) * foveaConeDensityZhang;
end
end


