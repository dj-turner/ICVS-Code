%% Setup
[scW, scH] = Screen('WindowSize',0);
monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
seasonVars = ["Spring", "Summer", "Autumn", "Winter"];
msRowNames = strings(1,length(resNames)*length(taskNames));
for res = 1:length(resNames) 
    for task = 1:length(taskNames)
        row = (res-1)*length(resNames) + task;
        msRowNames(row) = strcat(taskNames(task), "-", resNames(res));
    end
end

monthArray = struct2cell(monthMeans);
monthArray = vertcat(monthArray{:});
idx = sum(isnan(monthArray),2) ~= 12;
monthTbl = array2table(monthArray(idx,:), "RowNames", msRowNames(idx), "VariableNames", monthVars);

seasonArray = struct2cell(seasonMeans);
seasonArray = vertcat(seasonArray{:});
idx = sum(isnan(seasonArray),2) ~= 4;
seasonTbl = array2table(seasonArray(idx,:), "RowNames", msRowNames(idx), "VariableNames", seasonVars);

monthLabs = strings(length(taskNames),12);
seasonLabs = strings(length(taskNames),4);
colourCodes = struct;

for task = 1:length(taskNames)
    taskTbl = monthTbl(contains(monthTbl.Properties.RowNames,taskNames(task)),:);
    currentResNames = string(extractAfter(taskTbl.Properties.RowNames, "-"));
    for month = 1:12
        mLab = strcat(monthVars(month), " (");
        for res = 1:length(currentResNames)
            mLab = strcat(mLab, "n", currentResNames(res), " = ", num2str(monthNs.(currentResNames(res))(task,month)));
            if res == length(currentResNames), mLab = strcat(mLab, ")");
            else, mLab = strcat(mLab, ", ");
            end
        end
        monthLabs(task,month) = mLab;
    end
    for season = 1:4
        sLab = strcat(seasonVars(season), " (");
        for res = 1:length(currentResNames)
            sLab = strcat(sLab, "n", currentResNames(res), " = ", num2str(seasonNs.(currentResNames(res))(task,season)));
            if res == length(currentResNames), sLab = strcat(sLab, ")");
            else, sLab = strcat(sLab, ", ");
            end
        end
        seasonLabs(task,season) = sLab;
    end
    colourCodes.(taskNames(task)) = FindColours(currentResNames);
end

%% Monthly graphs
for task = 1:length(taskNames)
    f = figure(task);
    idx = startsWith(monthTbl.Properties.RowNames, taskNames(task));
    spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabs(task,:)), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', colourCodes.(taskNames(task)), 'FillOption', 'on', 'FillTransparency', .3);
    title(taskNames(task), 'Interpreter', 'none');
    rNames = string(extractAfter(monthTbl.Properties.RowNames(idx), "-"));
    legend(rNames);

    rem = mod(task,2);
    if rem == 0, f.Position = [scW/2 -25 scW/2 scH/2]; input("Press ENTER to continue");
    else, f.Position = [scW/2 scH/2 scW/2 scH/2];
    end
end
close all

%% Seasonal graphs
for task = 1:length(taskNames)
    f = figure(task);
    idx = startsWith(seasonTbl.Properties.RowNames, taskNames(task));
    spider_plot(table2array(seasonTbl(idx,:)), 'AxesLabels', cellstr(seasonLabs(task,:)), 'AxesLimits',...
    [repmat(table2array(min(seasonTbl(idx,:), [], "all")), [1 4]); repmat(table2array(max(seasonTbl(idx,:), [], "all")), [1 4])],...
    'Color', colourCodes.(taskNames(task)), 'FillOption', 'on', 'FillTransparency', .3);
    title(taskNames(task), 'Interpreter', 'none');
    rNames = string(extractAfter(seasonTbl.Properties.RowNames(idx), "-"));
    legend(rNames);

    rem = mod(task,2);
    if rem == 0, f.Position = [scW/2 -25 scW/2 scH/2]; input("Press ENTER to continue");
    else, f.Position = [scW/2 scH/2 scW/2 scH/2];
    end
end

close all