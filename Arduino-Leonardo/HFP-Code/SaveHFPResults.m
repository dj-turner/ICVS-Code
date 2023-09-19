function SaveHFPResults(PPcode, sessionNumber, trialNumber, matchType, red, green, redInit, greenInit, rDelta, confidenceRating)

% Define constants
% record current date and time
CurrentDateAndTime=round(clock);

varNames = {'ParticipantCode', 'Session', 'Trial', 'MatchType', 'DateTime', 'RedValue', 'GreenValue', ...
        'InitialRedSetting', 'InitialGreenSetting', 'RedDelta', 'ConfidenceRating'};

saveFilePath = strcat(pwd, '\Saved-Data\HFP\ParticipantMatchesHFP.mat');

matchTypes = ["Best", "MaxRed", "MinRed"];

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
newResults=table({PPcode}, sessionNumber, trialNumber, {char(matchTypes(matchType))}, CurrentDateAndTime, ...
    red, green, redInit, greenInit, rDelta, confidenceRating,... 
    'VariableNames', varNames);

%% new table
ParticipantMatchesHFP=[ParticipantMatchesHFP; newResults];

%% save file
save(saveFilePath, 'ParticipantMatchesHFP');
clear;

end
