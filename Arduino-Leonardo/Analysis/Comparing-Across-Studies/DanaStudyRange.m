% Read in data table
tbl = readtable("data-B.xlsx", 'Sheet', 'Matlab_Data');

% Convert participant ID from type cell to string
tbl = convertvars(tbl, "PPcode", 'string');

% Set x axis index to only those that completed the HFP task
idx = tbl.HFP == 1 & ~isnan(tbl.HFP_Uno_Red_1);

% Set relevant variables for analysis
vars = ["PPno", "PPcode", "Match_Type", "HFP_Uno_Red_1", "HFP_Uno_Red_2", "HFP_Uno_Red_3"];

% Subset the data table to only include relevant information
tbl = tbl(idx, vars);

% Make a list of all the participant IDs of relevant participants
ptpts = unique(tbl.PPcode);

% Create empty table to store calculated mean values
meanValues = NaN(length(ptpts),5);

% For each participant...
for ptpt = 1:length(ptpts)

    % Extract current participant ID
    ptptCode = ptpts(ptpt);

    % Filter table to only include current participant's data
    ptptTbl = tbl(strcmp(tbl.PPcode, ptptCode),:);

    % For each match type... (1 = best, 2 = max, 3 = min)
    for match = 1:3

        % Filter participant data to only include current match type
        matchTbl = ptptTbl(ptptTbl.Match_Type == match,:);

        % if the table isn't empty...
        if ~isempty(matchTbl)

            % Take the mean of all HFP uno trials and save as an array
            matchValues = table2array(matchTbl(:,startsWith(matchTbl.Properties.VariableNames, "HFP_Uno_Red")));

            % Save mean of all trials (omitting any NaN values) in the mean values table
            meanValues(ptpt, match) = mean(matchValues,"all","omitmissing");
        end
    end
end

% Calculate positive error bar lengths using best and max matches
meanValues(:,4) = meanValues(:,2) - meanValues(:,1);

% Calculate negative error bar lengths using best and min matches
meanValues(:,5) = meanValues(:,1) - meanValues(:,3);

% Set index to only include participants that completed min/max trials
idx = sum(isnan(meanValues),2)==0;

% Subset mean values for only relevant participants
meanValuesMinMax = meanValues(idx,:);

% Subset participant ID list to only relevant participants
ptpts = ptpts(idx,:);

% Set x value to participant number in order of participantion
x = 1:height(meanValuesMinMax);

% Set y values to mean best matches
bestY = meanValuesMinMax(:,1);

% Calculate middle values from mix/max settings
middleY = mean(meanValuesMinMax(:,2:3),2);

% Set negative error bar to mean min matches
errNeg = meanValuesMinMax(:,5);

% Set positive error ba rto mean max matches
errPos = meanValuesMinMax(:,4);

% set graph overlay to on
hold on

% Draw error bars
errorbar(x, bestY, errNeg, errPos,...
    'LineStyle', 'none', 'Color', 'r', 'LineWidth', 2,...  
    'Marker', 'none');

% Draw best match
scatter(x, bestY, 100, 'k', 'x', 'LineWidth', 2);

% plot median values with a blue x
scatter(x, middleY, 100, 'b', 'x', 'LineWidth', 2);

% Set y axis limits to min/max possible values
ylim([0 1024]);

% Set x limits so all participants display away from the graph edges
xlim([0 height(meanValuesMinMax)+1]);

% Add test to each best match marker with the relevant participant ID
text(x+.05, bestY, ptpts);

% Set graph title
title("Dana's HFP Data with Best & Min/Max Settings");

% Set graph x axis label
xlabel("Participant Number");

%Set graph y axis label
ylabel("Mean Setting in Device Units");

% add legend to explain different markers
lgd = legend(["Min/Max Matching Range", "Best Match", "Min/Max Mean"]);

% Set legend font size to 20
lgd.FontSize = 20;

% set graph overlay to off
hold off