function SaveCalibrationResults(debugMode, device, light, level, lum, spect, peak)

% Define constants
% record current date and time
dt = datetime;

% Define variable names for table
varNames = {'Device', 'DateTime', 'LED', 'InputValue', 'Luminance', 'Lambdas', 'LambdaSpectrum', 'PeakLambda'};

% testMode
if debugMode == 0, fileName = 'CalibrationResults.mat';
elseif debugMode == 1, fileName = 'CalibrationResults_test.mat';
end

% Defines path to .mat file
saveFilePath = strcat(pwd, '\', fileName);

%% Load file
if ~exist(saveFilePath, 'file')
    % create new table if one doesn't exist
    calibrationTable = table.empty(0,length(varNames));
    calibrationTable.Properties.VariableNames = varNames;
else
    % Load Structure File
    load(fileName);
end

%% new participant results
newResults = table(device, dt, light, level, lum, spect(1,:), spect(2,:), peak, 'VariableNames', varNames);

%% new table
calibrationTable = [calibrationTable; newResults];

%% save file
save(saveFilePath, 'calibrationTable');

end
