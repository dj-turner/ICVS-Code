function participatedBefore = CheckPreviousParticipation(ppID,idList)

participatedBefore = 0;
idList = table2array(idList(:,contains(idList.Properties.VariableNames, "ID")));
idx = strcmp(ppID, idList);
[row,col] = find(idx);
if ~isempty(row) && col > 1
    prevIdList = idList(row,1:col-1);
    idx = ~strcmp(prevIdList, "");
    if sum(idx) > 0
        participatedBefore = 1;
    end
end

end