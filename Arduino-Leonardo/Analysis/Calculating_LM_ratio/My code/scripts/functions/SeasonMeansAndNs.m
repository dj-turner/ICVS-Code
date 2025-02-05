function [sMeans,sNs] = SeasonMeansAndNs(sMeans,sNs,data,tasks,name)

sMeans.(name) = NaN(length(tasks),4);
sNs.(name) = NaN(length(tasks),4);

seasons = ["spring", "summer", "autumn", "winter"];

for task = 1:length(tasks)
    for season = 1:4
        idx_x = strcmp(data.season, seasons(season));
        idx_y = strcmp(data.Properties.VariableNames, strcat(tasks(task), "_RG"));
        sData = data(idx_x, idx_y);
        if ~isempty(sData)
            sNs.(name)(task,season) = height(sData(~isnan(table2array(sData(:,1))),:));
            sMeans.(name)(task,season) = table2array(mean(sData, "omitmissing"))';
        end
    end
end

end
