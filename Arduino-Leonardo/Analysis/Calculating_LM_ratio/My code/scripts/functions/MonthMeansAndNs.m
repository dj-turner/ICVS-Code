function [mMeans,mNs] = MonthMeansAndNs(mMeans,mNs,data,tasks,name)

mMeans.(name) = NaN(length(tasks),12);
mNs.(name) = NaN(length(tasks),12);

for task = 1:length(tasks)
    for month = 1:12
        idx_x = data.month == month;
        idx_y = strcmp(data.Properties.VariableNames, strcat(tasks(task), "_RG"));
        mData = data(idx_x, idx_y);
        if ~isempty(mData)
            mNs.(name)(task,month) = height(mData(~isnan(table2array(mData(:,1))),:));
            mMeans.(name)(task,month) = table2array(mean(mData, "omitmissing"))';
        end
    end
end

end