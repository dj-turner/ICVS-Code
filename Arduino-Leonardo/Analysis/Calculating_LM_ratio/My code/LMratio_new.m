%%
% My code gives same values as allie's with same input
% my values seem to be lower on avergae than allie's - different method?
% where did the lms values come from? why are there 50 sets of them? how
% were they calculated? what do they represent?

% add folders
addpath("tables");

% Load data
dataTbl = readtable("Data-Pt1.2.xlsx", "Sheet", "MATLAB_Data", "VariableNamingRule", "preserve");
% lumFunc = readtable("linCIE2008v2e_5.csv");

% Filter data for participants thatc did the HFP task, including only their best matches
idx = dataTbl.HFP == 1 & dataTbl.Match_Type == 1;
dataTbl = dataTbl(idx,:);

% Extract ptpt codes of relevant ptpts
ptptCodes = string(unique(dataTbl.PPcode));

% Device values
deviceVals = struct;
    % Lab-based device
    deviceVals.lab.gLumMax = 594.3295;
    deviceVals.lab.rLumMax =  962.7570;
    deviceVals.lab.glambda = 545;
    deviceVals.lab.rlambda = 630;
    deviceVals.lab.rSettingVar = "HFP_Uno_Red_Mean";

% Cone Fundamentals and Cone Ratios
coneFuns = struct;
redSettings = nan(length(ptptCodes),1);
aVals = nan(length(ptptCodes),1);

% Calcualting cone ratio for each ptpt
for ptpt = 1:length(ptptCodes)
    % Extract participant code
    ptptCode = ptptCodes(ptpt);
    
    % create table containing only current ptpt's data
    idx = strcmp(string(dataTbl.PPcode), ptptCode);
    ptptTbl = dataTbl(idx,:);
    
    % use participant's age to estimate cone fundamentals
    age = ptptTbl.Age_HFP(1);
    if age < 20, age = 20; elseif age > 80, age = 80; end
    [coneFuns.(ptptCode), wavelengths] = ConeFundamentals(age);
        % coneFuns.(ptptCode) = load("multipleObservers.mat", "LMS_Std");
        % coneFuns.(ptptCode) = coneFuns.(ptptCode).LMS_Std;
        % wavelengths = 390:5:780;

    % Pull l&m cone spectal sensitivities
    lSS = coneFuns.(ptptCode)(:,1);
    mSS = coneFuns.(ptptCode)(:,2);

    % Pull participant's mean red setting (a decimal of max setting)
    redSettings(ptpt) = mean(ptptTbl.(deviceVals.lab.rSettingVar))/1024;

    % Allie's code to calculate a
    aVals(ptpt) = FindaFromSetting(deviceVals.lab.rLumMax, deviceVals.lab.gLumMax,...
        deviceVals.lab.rlambda, deviceVals.lab.glambda, wavelengths,...
        lSS, mSS, redSettings(ptpt));
end

% Display mean cone ratio in sample (would expect a value of around 2!)
disp(array2table([redSettings aVals], 'VariableNames', ["Red Settings", "Pred. Ratio"]));

%%
% ALLIE'S FUNCTION
function a = FindaFromSetting(rLumMax, gLumMax, rlambda, glambda, lambdas, l, m, rSetting)
% specify rSetting
% derive a that would have produced a luminance match

% % VFe = (a .* l + m) ./ 2.87090767;

VFss = (1.980647 .* l + m);

sensToRFromM = rSetting.*m(lambdas == rlambda).*rLumMax.*VFss(lambdas == glambda);
sensToGFromM = m(lambdas==glambda).*gLumMax.*VFss(lambdas==rlambda);
sensToGFromL = l(lambdas==glambda).*gLumMax.*VFss(lambdas==rlambda);
sensToRFromL = rSetting.*l(lambdas==rlambda).*rLumMax.*VFss(lambdas == glambda);

a = (sensToRFromM-sensToGFromM)./(sensToGFromL-sensToRFromL);

end

