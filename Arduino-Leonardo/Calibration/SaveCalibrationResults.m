function SaveRLMResults(light, level)

% Define constants
% record current date and time
CurrentDateAndTime=round(clock);

varNames = {'DateTime', 'LED', 'Value'};

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
newResults=table(CurrentDateAndTime, {light}, level, 'VariableNames', varNames);

%% new table
CalibrationResults=[CalibrationResults; newResults];

%% save file
save(saveFilePath, 'CalibrationResults');
clear;

end
