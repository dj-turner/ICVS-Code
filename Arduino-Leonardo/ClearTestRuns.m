% Define Taks to clean up
taskNames = ["rlm", "hfp"];
% Make sure names are upper case
taskNames = upper(taskNames);

% For each task...
for task = 1:length(taskNames)

    % Determine task name
    taskName = taskNames(task);

    % Determine name of save file to clean
    fileName = strcat("ParticipantMatches", taskName);
    
    % Determine path of save file to clean
    filePath = strcat(cd, "\Saved-Data\", taskName, "\", fileName, ".mat");
    
    % Load table to clean
    tbl = load(filePath);
    
    % Pull table from structure format
    tbl = tbl.(fileName);
    
    % Remove rows where the ptpt ID includes "TEST"
    tbl = tbl(~contains(tbl.ParticipantCode, "TEST"), :);
    
    % Assign table correct variable name
    assignin('base', fileName, tbl)
    
    % Save path to name
    save(filePath, fileName)

end
