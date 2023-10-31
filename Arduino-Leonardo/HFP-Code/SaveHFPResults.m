function SaveHFPResults(PPcode, sessionNumber, trialNumber, rValInit, trialResultsRed, greenValue)

% Define constants
avgNum = 4;

% record current date and time
CurrentDateAndTime=round(clock);

redMean = mean(trialResultsRed((length(trialResultsRed) - avgNum + 1):length(trialResultsRed)));

varNames = {'ParticipantCode', 'Session', 'Trial', 'DateTime', 'InitialRed', 'RedValues', 'RedMean', 'GreenValue'};

saveFilePath = strcat(pwd, '\Saved-Data\HFP\ParticipantMatchesHFP.mat');

%% Load file
if ~exist(saveFilePath, 'file')
    % create new table if one doesn't exist
    ParticipantMatchesHFP=table.empty(0,length(varNames));
    ParticipantMatchesHFP.Properties.VariableNames = varNames;
else
    % Load Structure File
    load('ParticipantMatchesHFP.mat');
end

%% new participant results
newResults=table({PPcode}, sessionNumber, trialNumber, CurrentDateAndTime, rValInit,...
    trialResultsRed, redMean, greenValue, 'VariableNames', varNames);

%% new table
ParticipantMatchesHFP=[ParticipantMatchesHFP; newResults];

%% save file
save(saveFilePath, 'ParticipantMatchesHFP');
clear;

end
