function RunColourVisionStudy(taskType, taskNumber)

% Sets current folder as the working directory
workingDir = strcat(pwd, '\');
cd(workingDir);   

% Sets the task directory based on the inputted task code
taskDir = strcat(workingDir, taskType, '-Code\');
addpath(taskDir);

% Sets the save directory to save the data
% If the correct save folder doesn't exist, creates one to save data to
saveFolder = strcat(workingDir, 'Saved-Data\');
if ~exist(saveFolder, 'dir')
    mkdir(workingDir,'Saved-Data');
end    
saveDir = strcat(saveFolder, taskType, '\');    
if ~exist(saveDir, 'dir')
    mkdir(saveFolder,taskType);
end                                                                                                           
addpath(saveDir);

% Turns off annoying warning that is irrelevant for this task
warning('off','instrument:instrfindall:FunctionToBeRemoved');

% Clears all opened devices
delete(instrfindall);

% Runs the task code based on the inputted task
% Rayleigh Match
if strcmp(taskType, 'RLM')                          
    ptptID = ArduinoRayleighMatch(taskNumber);
% Heterochromatic Flicker Photometry
elseif strcmp(taskType, 'HFP')
    ptptID = ArduinoHeterochromaticFlickerPhotometry(taskNumber);
% Displays an error message and exits the program if any other code is entered
else
    error("Invalid task: Please enter 'RLM' or 'HFP' as the task type!");
end

% Finds the save table name for the current task
tableFileName = strcat('ParticipantMatches', taskType, '.mat');

try
    % Imports the current table under the name "fullTable"
    fullTable = importdata(tableFileName);
    % Creates "currentTable", which only contains rows that match the current ptptID
    currentTable = fullTable(strcmp(fullTable.ParticipantCode, ptptID), :);   
    if isempty(currentTable)
        disp(strcat("No data to save! No rows in ", tableFileName, " match the current participant ID"));
    else
        % Creates the full path and save name for the current participant
        tablePathAndName = strcat(saveDir, taskType, '_', ptptID, '.xlsx');        
        % Saves the current participant's results as an .xlsx file
        writetable(currentTable, tablePathAndName);
    end

catch
    disp(strcat("No data to save! Cannot find ", tableFileName));
end

% Removes extra paths
rmpath(taskDir, saveDir);

% Clears variables
clear;

% Clears devices
delete(instrfindall)

% Turns irrelevant warning back on
warning('on','instrument:instrfindall:FunctionToBeRemoved');

% Checks that ListenChar = 0;
ListenChar(0);

end
