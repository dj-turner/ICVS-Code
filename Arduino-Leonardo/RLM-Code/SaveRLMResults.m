function SaveRLMResults(ptptID, sessionNumber, trialNumber, matchType, red, green, yellow, lambda, lambdaDelta, yellowDelta, confidenceRating)

%% Define constants
% record current date and time
CurrentDateAndTime=round(clock);

varNames = {'ParticipantCode', 'Session', 'Trial', 'MatchType', 'DateTime', 'Red', 'Green', ...
        'Yellow', 'Lambda', 'LambdaDelta', 'YellowDelta', 'ConfidenceRating'};

saveFilePath = strcat(pwd, '\Saved-Data\RLM\ParticipantMatchesRLM.mat');

matchTypes = ["Best", "MaxLambda", "MinLambda"];

%% Load file
if ~exist(saveFilePath, 'file')
    % create new table if one doesn't exist
    ParticipantMatchesRLM=table.empty(0,length(varNames));
    ParticipantMatchesRLM.Properties.VariableNames = varNames;
else
    % Load Structure File
    load('ParticipantMatchesRLM.mat');
end

%% new participant results
newResults=table({ptptID}, sessionNumber, trialNumber, {char(matchTypes(matchType))}, CurrentDateAndTime, ... 
    red, green, yellow, lambda, lambdaDelta, yellowDelta, confidenceRating,...
    'VariableNames', varNames);

%% new table
ParticipantMatchesRLM=[ParticipantMatchesRLM; newResults];

%% save file
save(saveFilePath, 'ParticipantMatchesRLM');
clear;

end
