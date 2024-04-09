% clear up
clc; clear; close all;

[scW, scH] = Screen('WindowSize',0);

%%
% Link data
ptptIdTbl = readtable("Ptpt_ID_Links.xlsx");
ptptIdTbl = convertvars(ptptIdTbl, ptptIdTbl.Properties.VariableNames, 'string');

% Possible var names
taskNames = ["RLM_Leo", "HFP_Leo", "RLM_Anom", "HFP_Uno"];

data = struct;
monthMeans = struct;
monthNs = struct;

%%
% Allie's data
aData = load("data-A.mat"); aData = aData.hfpTable;
aDataDemo = readtable("newDataDemo-A.xlsx");

ptptIDs = unique(string(aData.ptptID));

data.Allie = NaN(height(ptptIDs), 2);
for ptpt = 1:height(aData)
    idx1 = contains(string(aDataDemo.ID), ptptIDs(ptpt));
    idx2 = table2array(aDataDemo(strcmp(string(aDataDemo.ID),ptptIDs(ptpt)),"CVD"));
    if sum(idx1) == 1 && idx2 == 0
        month = table2array(aDataDemo(idx1,"MOB"));
        logRG = log(table2array(aData(ptpt, "meanTestAmp")) ./ 1024);
        data.Allie(ptpt,:) = [month logRG];
    end
end

idx = sum(isnan(data.Allie),2) ~= width(data.Allie);
data.Allie = data.Allie(idx,:);
data.Allie = array2table(data.Allie, "VariableNames", ["Month", "HFP_Uno_logRG"]);

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Allie, taskNames, "Allie");

%%
% Dana's data
vars = ["Month", "RLM_Red_1", "RLM_Green_1", "RLM_MixLight_1", "HFP_Leo_Red_1", "HFP_Leo_Green_1", "HFP_Uno_Red_1"];
dData = readtable("data-B.xlsx", 'Sheet','Matlab_Data');
ptptIDs = unique(string(dData.PPcode));
data.Dana = array2table(NaN(length(ptptIDs), length(vars)), 'VariableNames', vars);
for ptpt = 1:length(ptptIDs)
    donePreviousStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl);
    idx = strcmp(string(dData.PPcode), ptptIDs(ptpt))...
          & table2array(sum(dData(strcmp(dData.PPcode,ptptIDs(ptpt)), "HRR_Pass"))) > 0 ...
          & dData.Study == 1.1 ...
          & donePreviousStudy == 0;
    ptptData = dData(idx,vars);
    if ~isempty(ptptData)
        data.Dana(ptpt,:) = mean(ptptData(2:end, :), 'omitmissing');
    end
end

data.Dana.RLM_Leo_logRG = log(data.Dana.RLM_Red_1 ./ data.Dana.RLM_Green_1);
data.Dana.HFP_Leo_logRG = log(data.Dana.HFP_Leo_Red_1 ./ data.Dana.HFP_Leo_Green_1);
data.Dana.RLM_Anom_logRG = log(data.Dana.RLM_MixLight_1);
data.Dana.HFP_Uno_logRG = log(data.Dana.HFP_Uno_Red_1 ./ 1024);

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Dana, taskNames, "Dana");

%%
% Josh's data
jData = readtable("data-DJ.xlsx", "VariableNamingRule","preserve");

demoVars = ["PP", "Code", "Birth Month", "Country of Birth", "Ethnicity", "Plates"];
jDataDemo = jData(~isnan(jData.PP), demoVars);
jDataDemo = convertvars(jDataDemo, ["Code", "Country of Birth", "Plates"], 'string');

rlmVars = ["RLM_Red", "RLM_Green", "RLM_Yellow"];
hfpVars = ["HFP_RedValue", "HFP_GreenValue"];
vars = [rlmVars, hfpVars];

ptptIDs = unique(jDataDemo.Code);

jDataValues = NaN(length(ptptIDs), length(vars));
for ptpt = 1:length(ptptIDs)
    donePreviousStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl);
    idx = strcmp(jData.Code, ptptIDs(ptpt))... 
        & strcmp(jData.("Match Type"), "Best")...
        & donePreviousStudy == 0;
    ptptData = jData(idx,:);

    if ~isempty(ptptData)
        idx = strcmp(table2array(ptptData(1, "Plates")), "P");
        if idx
            ptptData = ptptData(2:end,:);
            rlmData = table2array(mean(ptptData(ptptData.RLM_ConfidenceRating > 1, rlmVars), 'omitmissing'));
            hfpData = table2array(mean(ptptData(ptptData.HFP_ConfidenceRating > 1, hfpVars), 'omitmissing'));
            jDataValues(ptpt,:) = [rlmData hfpData];
        end
    end
end

jDataValues = array2table(jDataValues, 'VariableNames', vars);

data.Josh = [jDataDemo jDataValues];
data.Josh = renamevars(data.Josh,"Birth Month","Month");

data.Josh.RLM_Leo_logRG = log(data.Josh.RLM_Red ./ data.Josh.RLM_Green);
data.Josh.HFP_Leo_logRG = log(data.Josh.HFP_RedValue ./ data.Josh.HFP_GreenValue);

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Josh, taskNames, "Josh");

%%
% Mitch's RLM data
rlmVars = ["Red", "Green", "Yellow"];

mDataRLM = load("dataRLM-MT.mat","ParticipantMatchesRLM");
mDataRLM = mDataRLM.ParticipantMatchesRLM;
mDataRLM = mDataRLM(~contains(string(mDataRLM.ParticipantCode), "TEST"),:);

mDataDemo = readtable("dataDemo-MT.xlsx");

ptptIDs = unique(string(mDataRLM.ParticipantCode));
ptptIDs = ptptIDs(strlength(ptptIDs) == 3);

mitchDataRLM = NaN(length(ptptIDs), 4);
for ptpt = 1:length(ptptIDs)
    donePreviousStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl);
    idx = strcmp(string(mDataRLM.ParticipantCode), ptptIDs(ptpt))...
          & strcmp(mDataRLM.MatchType, "Best")... 
          & strcmp(string(table2array(mDataDemo(strcmp(mDataDemo.ParticipantCode, ptptIDs(ptpt)), "HRR"))), "Pass")...
          & mDataRLM.Trial ~= 1 & mDataRLM.ConfidenceRating > 1 ...
          & donePreviousStudy == 0;
    ptptData = mDataRLM(idx,:);
    if unique(ptptData.Session) > 1
        ptptData = ptptData(ptptData.Session == ptptData.Session(1),:);
    end
    if height(ptptData) > 4
        ptptData = ptptData(1:4,:);
    end
    mitchDataRLM(ptpt,2:4) = table2array(mean(ptptData(:,rlmVars)));

    mitchDataRLM(ptpt,1) = table2array(mDataDemo(strcmp(mDataDemo.ParticipantCode, ptptIDs(ptpt)),"BirthMonth"));
end

mitchDataRLM = array2table(mitchDataRLM, "VariableNames", ["Month", rlmVars]);
mitchDataRLM.RLM_Leo_logRG = log(mitchDataRLM.Red ./ mitchDataRLM.Green);

% Mitch's HFP data
mDataHFP_files=dir(fullfile('dataHFP-MT','*.mat'));
mitchDataHFP = NaN(height(ptptIDs),1);
for file = 1:length(mDataHFP_files)
    fileName = mDataHFP_files(file).name;
    currentFile = load(strcat(pwd, '\dataHFP-MT\', fileName));
    currentFile = currentFile.hfpData;
    currentFile = convertvars(currentFile, "trialID", 'string');
    currentID = extractBefore(extractAfter(fileName, 'HFP_'), '_');
    currentFile.trialID = repmat(currentID, [height(currentFile) 1]);
    if file == 1, mDataHFP = currentFile;
    else, mDataHFP = [mDataHFP; currentFile]; %#ok<AGROW>
    end
    
    mitchDataHFP(strcmp(currentID, ptptIDs)) = table2array(mean(currentFile(currentFile.trialNum > 1, "logRG")));
end
mitchDataHFP = array2table(mitchDataHFP, "VariableNames", "HFP_Uno_logRG");
data.Mitch = [mitchDataRLM mitchDataHFP];

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Mitch, taskNames, "Mitch");

%%
% Radar graphs
resNames = string(fieldnames(monthMeans));
monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
monthRowNames = strings(1,length(resNames)*length(taskNames));
for res = 1:length(resNames) 
    for task = 1:length(taskNames)
        row = (res-1)*length(resNames) + task;
        monthRowNames(row) = strcat(taskNames(task), "-", resNames(res));
    end
end

monthArray = struct2cell(monthMeans);
monthArray = vertcat(monthArray{:});
idx = sum(isnan(monthArray),2) ~= 12;
monthTbl = array2table(monthArray(idx,:), "RowNames", monthRowNames(idx), "VariableNames", monthVars);

monthLabs = strings(length(taskNames),12);
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
    colourCodes.(taskNames(task)) = FindColours(currentResNames);
end

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

%%
mdls = struct;

for res = 1:length(resNames)
    [data.(resNames(res)).MonthSin, data.(resNames(res)).MonthCos] = SinCosMonth(data.(resNames(res)).Month);
    for task = 1:length(taskNames)
        if sum(contains(data.(resNames(res)).Properties.VariableNames, taskNames(task)))
            mdlStr = strcat(taskNames(task), '_logRG', '~ MonthSin + MonthCos');
            mdls.(resNames(res)).(taskNames(task)) = fitlm(data.(resNames(res)), mdlStr);
        end
    end
end

%%
for task = 1:length(taskNames)
    mergedData.(taskNames(task)) = table.empty(0,3);
    taskVars = [strcat(taskNames(task), "_logRG"), "MonthSin", "MonthCos"];
    mergedData.(taskNames(task)).Properties.VariableNames = taskVars;
    
    for res = 1:length(resNames)
        if sum(contains(data.(resNames(res)).Properties.VariableNames, (taskNames(task))))
           mergedData.(taskNames(task)) = [mergedData.(taskNames(task)); data.(resNames(res))(:,taskVars)];
        end
    end
    
    mdlStr = strcat(taskNames(task), '_logRG ~ MonthSin + MonthCos');
    mdls.merged.(taskNames(task)) = fitlm(mergedData.(taskNames(task)), mdlStr);
end

%%
graphParas = struct;
for row = 1:height(monthTbl)
    rowName = strrep(string(monthTbl.Properties.RowNames(row)), "-", "_");
    x = 1:12;
    y = table2array(monthTbl(row,:));
    idx = ~isnan(y); x = x(idx); y = y(idx);

    graphParas.(rowName) = sineFit(x,y);
    movegui(1, [scW/2 scH/2]); movegui(2, [scW/2 50]);
    figure(1); title(rowName, "Interpreter", "none"); subtitle("SINUS");
    figure(2); title(rowName, "Interpreter", "none"); subtitle("FFT");

    taskName = extractBefore(string(monthTbl.Properties.RowNames(row)), "-");
    resName = extractAfter(string(monthTbl.Properties.RowNames(row)), "-");
    disp(taskName); disp(resName); disp(mdls.(resName).(taskName)); disp(" ");

    input("Press ENTER to continue");
end
close all

%%
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

%%
function colArray = FindColours(nameList)

colArray = NaN(length(nameList), 3);
for name = 1:length(nameList)
    switch nameList(name)
        case "Allie", rgbCode = [0 0 1];
        case "Dana", rgbCode = [1 0 1];
        case "Josh", rgbCode = [1 0 0];
        case "Mitch", rgbCode = [0 1 0];
        otherwise, rgbCode = [0 0 0];
    end
    colArray(name,:) = rgbCode;
end

end

%%
function [sinMonths,cosMonths] = SinCosMonth(inputMonths)

cosMonths = cos(2*pi*(inputMonths/12));
sinMonths = sin(2*pi*(inputMonths/12));

end

%%
function [mMeans,mNs] = MonthMeansAndNs(mMeans,mNs,data,tasks,name)

mMeans.(name) = NaN(length(tasks),12);
mNs.(name) = NaN(length(tasks),12);

for task = 1:length(tasks)
    for month = 1:12
        mData = data(data.Month == month, strcmp(data.Properties.VariableNames, strcat(tasks(task), "_logRG")));
        if ~isempty(mData)
            mNs.(name)(task,month) = height(mData(~isnan(table2array(mData(:,1))),:));
            mMeans.(name)(task,month) = table2array(mean(mData, "omitmissing"))';
        end
    end
end

end
