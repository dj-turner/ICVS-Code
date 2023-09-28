function SaveCalibrationResults(light, level, lum, spect, peak)

% Define constants
% record current date and time
dt = string(datetime);
date = extractBefore(dt, " ");
time = extractAfter(dt, " ");

% Define variable names for table
varNames = {'Date', 'Time', 'LED', 'Value', 'Luminance', 'Lambdas', 'LambdaSpectrum', 'PeakLambda'};

% Defines path to .mat file
saveFilePath = strcat(pwd, '\CalibrationResults.mat');

%% Load file
if ~exist(saveFilePath, 'file')
    % create new table if one doesn't exist
    CalibrationResults = table.empty(0,length(varNames));
    CalibrationResults.Properties.VariableNames = varNames;
else
    % Load Structure File
    load('CalibrationResults.mat');
end

%% new participant results
newResults=table(date, time, light, level, lum, spect(1,:), spect(2,:), peak, 'VariableNames', varNames);

%% new table
CalibrationResults=[CalibrationResults; newResults];

%% save file
save(saveFilePath, 'CalibrationResults');

end
