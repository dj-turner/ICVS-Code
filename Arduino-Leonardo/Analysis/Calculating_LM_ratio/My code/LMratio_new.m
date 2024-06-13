%%
clc; clear; close all;

% Load data
data = LoadData;
dataTbl = data.all;

%%
% Make new variable to store LM ratio value in
dataTbl.aVal = nan(height(dataTbl), 1);

% Sets default age to the rounded mean age, for ptpts where we don't have age data
defaultAge = round(mean(dataTbl.age,'omitmissing'));

% Device values
deviceVals = struct;
    % Lab-based device (from Allie's values)
    deviceVals.uno.gLumMax = 594.3295;
    deviceVals.uno.rLumMax = 962.7570;
    deviceVals.uno.gLambda = 545;
    deviceVals.uno.rLambda = 630;
    % Yellow Arduino device (from Josh's calibration results)
    deviceVals.leo_y.gLumMax = 54.92;
    deviceVals.leo_y.rLumMax = 168.6;
    deviceVals.leo_y.gLambda = 542;
    deviceVals.leo_y.rLambda = 626; 

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
    coneFuns.(ptptID) = ConeFundamentals(age);

    % pulls device name to look up values
    device = dataTbl.devCombHFP(ptpt);

    % Allie's code to calculate a
    dataTbl.aVal(ptpt) = FindaFromSetting(deviceVals.(device).rLumMax, deviceVals.(device).gLumMax,...
        deviceVals.(device).rLambda, deviceVals.(device).gLambda, coneFuns.(ptptID).wavelengths,...
        coneFuns.(ptptID).lCones, coneFuns.(ptptID).mCones, dataTbl.combHFP(ptpt));
end

% Display mean cone ratio in sample (would expect a value of around 2!)
disp(dataTbl(:,["combHFP","aVal"]));
% range = [mean(aVals,'omitmissing')-3*std(aVals), mean(aVals,'omitmissing')+3*std(aVals)];
% histogram(aVals(aVals >= range(1) & aVals <= range(2)), 50);

%%
% ALLIE'S FUNCTION
function a = FindaFromSetting(rLumMax, gLumMax, rLambda, gLambda, lambdas, lSS, mSS, rgSetting)
% specify rSetting
% derive a that would have produced a luminance match
stepSize = lambdas(2)-lambdas(1);
rLambda = round(rLambda/stepSize)*stepSize;
gLambda = round(gLambda/stepSize)*stepSize;

% % VFe = (a .* l + m) ./ 2.87090767;

VFss = (1.980647 .* lSS + mSS);

sensToRFromM = rgSetting.*mSS(lambdas == rLambda).*rLumMax.*VFss(lambdas == gLambda);
sensToGFromM = mSS(lambdas==gLambda).*gLumMax.*VFss(lambdas==rLambda);
sensToGFromL = lSS(lambdas==gLambda).*gLumMax.*VFss(lambdas==rLambda);
sensToRFromL = rgSetting.*lSS(lambdas==rLambda).*rLumMax.*VFss(lambdas == gLambda);

a = (sensToRFromM-sensToGFromM)./(sensToGFromL-sensToRFromL);

end

