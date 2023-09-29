function SaveCalibrationResults(testMode, light, level, lum, spect, peak)

% Define constants
% record current date and time
dt = string(datetime);
date = extractBefore(dt, " ");
time = extractAfter(dt, " ");

% Define variable names for table
varNames = {'Date', 'Time', 'LED', 'Value', 'Luminance', 'Lambdas', 'LambdaSpectrum', 'PeakLambda'};

% testMode
if testMode == 0
    fileName = 'CalibrationResults.mat';
elseif testMode == 1
    fileName = 'CalibrationResults_test.mat';
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
newResults=table(date, time, light, level, lum, spect(1,:), spect(2,:), peak, 'VariableNames', varNames);

%% new table
calibrationTable=[calibrationTable; newResults];

%% save file
save(saveFilePath, 'calibrationTable');

end
