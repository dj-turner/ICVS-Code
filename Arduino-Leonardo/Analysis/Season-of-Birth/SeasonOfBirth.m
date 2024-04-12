% clear up
clc; clear; close all;

[scW, scH] = Screen('WindowSize',0);

%%
% Link data
ptptIdTbl = readtable("Ptpt_ID_Links.xlsx");
ptptIdTbl = convertvars(ptptIdTbl, ptptIdTbl.Properties.VariableNames, 'string');

% Key data
keyTbl = readtable("KeyData.xlsx");
keyTbl = convertvars(keyTbl, ["Type", "Category"], 'string');

% Possible var names
taskNames = ["RLM_Leo", "HFP_Leo", "RLM_Anom", "HFP_Uno"];

data = struct;
monthMeans = struct;
monthNs = struct;
seasonMeans = struct;
seasonNs = struct;

dataVars = ["study", "ptptID", "sex", "month", "year", "ethnicity", "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG"];
numVars = ["month", "year", "ethnicity", "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG"];
strVars = ["study", "ptptID", "sex"];

%%
% Allie's data
aData = load("data-A.mat"); aData = aData.hfpTable;
aDataDemo = readtable("newDataDemo-A.xlsx");

ptptIDs = unique(string(aData.ptptID));

data.Allie = strings(height(ptptIDs), length(dataVars));

study = "A";
rg1 = NaN;
rg2 = NaN;
rg3 = NaN;

for ptpt = 1:height(aData)
    idx1 = contains(string(aDataDemo.ID), ptptIDs(ptpt));
    idx2 = table2array(aDataDemo(strcmp(string(aDataDemo.ID),ptptIDs(ptpt)),"CVD"));
    if sum(idx1) == 1 && idx2 == 0
        ptptID = ptptIDs(ptpt);
        sex = upper(string(table2array(aDataDemo(idx1,"Gender"))));
        if strcmp(sex,"X"), sex = ""; end
        month = table2array(aDataDemo(idx1,"MOB"));
        dob = char(table2array(aDataDemo(idx1,"DOB")));
        if ~isempty(dob), year = str2double(dob(end-3:end)); else, year = NaN; end
        ethnicity = table2array(aDataDemo(idx1,"Ethnicity"));
        rg4 = table2array(aData(ptpt,"meanTestAmp") ./ 1024);
        data.Allie(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, rg1, rg2, rg3, rg4];
    end
end

idx = (sum(ismissing(data.Allie),2) + sum(strcmp(data.Allie, ""),2)) ~= width(data.Allie);
data.Allie = data.Allie(idx,:);
data.Allie = array2table(data.Allie, "VariableNames", dataVars);
data.Allie = convertvars(data.Allie, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Allie, taskNames, "Allie");

%%
% Dana's data
dData = readtable("data-B.xlsx", 'Sheet','Matlab_Data');
ptptIDs = unique(string(dData.PPcode));
data.Dana = strings(length(ptptIDs), length(dataVars));
for ptpt = 1:length(ptptIDs)
    donePreviousStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl);
    idx = strcmp(string(dData.PPcode), ptptIDs(ptpt))...
          & table2array(sum(dData(strcmp(dData.PPcode,ptptIDs(ptpt)), "HRR_Pass"))) > 0 ...
          & dData.Match_Type == 1 ...
          & donePreviousStudy == 0;
    ptptData = dData(idx,:);
    if ~isempty(ptptData)
        ptptID = string(table2array(ptptData(1,"PPcode")));
        ptptData.PPcode = [];
        sex = string(table2array(ptptData(1,"Sex")));
        ptptData.Sex = [];
        ptptData = mean(ptptData(2:end,:), 'omitmissing');
        if ptptData.Study == 1.1, study = "D1"; else, study = "D2"; end
       month = ptptData.Month;
        year = ptptData.Year;
        ethnicity = ptptData.Ethnicity;
        rg1 = ptptData.RLM_Red_1 / ptptData.RLM_Green_1;
        rg2 = ptptData.HFP_Leo_Red_1 ./ ptptData.HFP_Leo_Green_1;
        rg3 = ptptData.RLM_MixLight_1;
        rg4 = ptptData.HFP_Uno_Red_1 ./ 1024;
        data.Dana(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, rg1, rg2, rg3, rg4];
    end
end

idx = (sum(ismissing(data.Dana),2) + sum(strcmp(data.Dana, ""),2)) ~= width(data.Dana);
data.Dana = data.Dana(idx,:);
data.Dana = array2table(data.Dana, "VariableNames", dataVars);
data.Dana = convertvars(data.Dana, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Dana, taskNames, "Dana");

%%
% Josh's data
jData = readtable("data-DJ.xlsx", "VariableNamingRule","preserve");

ptptIDs = unique(jData.Code);

data.Josh = strings(length(ptptIDs), length(dataVars));

study = "J";
rg3 = NaN;
rg4 = NaN;

for ptpt = 1:length(ptptIDs)
    donePreviousStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl);
    idx = strcmp(jData.Code, ptptIDs(ptpt))... 
        & strcmp(jData.("Match Type"), "Best")...
        & donePreviousStudy == 0;
    ptptData = jData(idx,:);
    if ~isempty(ptptData)
        idx = strcmp(table2array(ptptData(1, "Plates")), "P");
        if idx
            ptptID = string(table2array(ptptData(1,"Code")));
            sex = string(table2array(ptptData(1,"Sex")));
            month = ptptData.("Birth Month")(1);
            year = ptptData.("Birth Year")(1);
            ethnicity = ptptData.Ethnicity(1);
            
            ptptValueData = mean(ptptData(2:end,["RLM_Red","RLM_Green","HFP_RedValue","HFP_GreenValue"]),1,"omitmissing");
            rg1 = ptptValueData.RLM_Red ./ ptptValueData.RLM_Green;
            rg2 = ptptValueData.HFP_RedValue ./ ptptValueData.HFP_GreenValue;

            data.Josh(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, rg1, rg2, rg3, rg4];
        end
    end
end

idx = (sum(ismissing(data.Josh),2) + sum(strcmp(data.Josh, ""),2)) ~= width(data.Josh);
data.Josh = data.Josh(idx,:);
data.Josh = array2table(data.Josh, "VariableNames", dataVars);
data.Josh = convertvars(data.Josh, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Josh, taskNames, "Josh");

%%
% Mitch's RLM data
mDataRLM = load("dataRLM-MT.mat","ParticipantMatchesRLM");
mDataRLM = mDataRLM.ParticipantMatchesRLM;
mDataRLM = mDataRLM(~contains(string(mDataRLM.ParticipantCode), "TEST"),:);

mDataDemo = readtable("dataDemo-MT.xlsx");

ptptIDs = unique(string(mDataDemo.ParticipantCode));
ptptIDs = ptptIDs(strlength(ptptIDs) == 3);

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
end
%%
% Combine
data.Mitch = strings(length(ptptIDs), length(dataVars));

study = "M";
rg2 = NaN;
rg3 = NaN;

for ptpt = 3:length(ptptIDs)
    ptptID = ptptIDs(ptpt);
    donePreviousStudy = CheckPreviousParticipation(ptptID, ptptIdTbl);
    hrrPass = strcmpi(string(table2array(mDataDemo(strcmp(string(mDataDemo.ParticipantCode), ptptID),"CVD"))), "No");
    if donePreviousStudy == 0 & hrrPass == 1
        ptptDataDemo = mDataDemo(strcmp(string(mDataDemo.ParticipantCode), ptptID),:);
        if ~isempty(ptptDataDemo)
            sex = string(ptptDataDemo.Sex);
            month = ptptDataDemo.BirthMonth;
            year = ptptDataDemo.BirthYear;
            ethnicity = ptptDataDemo.Ethnicity;
        end

        idx = strcmp(string(mDataRLM.ParticipantCode),ptptID)...
              & strcmp(string(mDataRLM.MatchType), "Best")...
              & mDataRLM.Trial > 1;
        ptptDataRLM = mean(mDataRLM(idx,["Red","Green"]),1);
        rg1 = ptptDataRLM.Red ./ ptptDataRLM.Green;

        idx = strcmp(string(mDataHFP.trialID),ptptID)...
              & mDataHFP.trialNum > 1;
        ptptDataHFP = table2array(mean(mDataHFP(idx,"meanTestAmpSetting")));
        rg4 = ptptDataHFP ./ 1024;

        data.Mitch(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, rg1, rg2, rg3, rg4];
    end
end

idx = (sum(ismissing(data.Mitch),2) + sum(strcmp(data.Mitch, ""),2)) ~= width(data.Mitch);
data.Mitch = data.Mitch(idx,:);
data.Mitch = array2table(data.Mitch, "VariableNames", dataVars);
data.Mitch = convertvars(data.Mitch, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Mitch, taskNames, "Mitch");

%%
resNames = string(fieldnames(monthMeans));
newVars = strcat(taskNames, "_logRG");
% log values
for task = 1:length(taskNames)
    for res = 1:length(resNames) 
        data.(resNames(res)).(newVars(task)) = log(data.(resNames(res)).(strcat(taskNames(task),"_RG")));
    end
end
dataVars = [dataVars, newVars];
numVars = [numVars, newVars];

%%
% Season and ethnicity categories
newCats = ["season", "month"; "ethnicGroup", "ethnicity"];

for res = 1:length(resNames)
    for cat = 1:height(newCats)
        catData = strings(height(data.(resNames(res))),1);
        for row = 1:height(catData)
            catVal = data.(resNames(res)).(newCats(cat,2))(row);
            if ~isnan(catVal) && catVal ~= 0
                idx = strcmp(keyTbl.Type, newCats(cat,1)) & keyTbl.Value == catVal;
                catData(row) = keyTbl.Category(idx);
            end
        end
        data.(resNames(res)).(newCats(cat,1)) = catData;
    end
    % monthSin and Cos
    [data.(resNames(res)).monthSin, data.(resNames(res)).monthCos] = SinCosMonth(data.(resNames(res)).month);
end

for res = 1:length(resNames)
    [seasonMeans, seasonNs] = SeasonMeansAndNs(seasonMeans, seasonNs, data.(resNames(res)), taskNames, resNames(res));
    [data.(resNames(res)).seasonSin, data.(resNames(res)).seasonCos] = SinCosSeason(data.(resNames(res)).season);
end

dataVars = [dataVars, newCats(:,1)', "monthSin", "monthCos", "seasonSin", "seasonCos"];
numVars = [numVars, "monthSin", "monthCos", "seasonSin", "seasonCos"];
strVars = [strVars, newCats(:,1)'];

%%
% all data combine
data.all = table.empty(0,length(dataVars));
data.all.Properties.VariableNames = dataVars;
for i = 1:length(resNames)
    data.all = [data.all; data.(resNames(i))];
end

studyIDs = unique(data.all.study);

%%
% Radar graphs
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

%%

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

%%
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

%%
combTasks = ["RLM", "Anom", "Leo";...
             "HFP", "Uno", "Leo"];

for task = 1:height(combTasks)
    combVar = strcat("comb", combTasks(task,1));
    devCombVar = strcat("devComb", combTasks(task,1));

    data.all.(combVar) = NaN(height(data.all), 1);
    data.all.(devCombVar) = strings(height(data.all), 1);
    
    for var = 2:width(combTasks)
        varName = strcat(combTasks(task,1), "_", combTasks(task,var), "_logRG");
        idx = ~isnan(data.all.(varName));
        data.all.(combVar)(idx) = data.all.(varName)(idx);
        data.all.(devCombVar)(idx) = lower(combTasks(task,var));
    end
    
    dataVars = [dataVars, combVar, devCombVar]; %#ok<AGROW>
    numVars = [numVars, combVar]; %#ok<AGROW>
    strVars = [strVars, devCombVar]; %#ok<AGROW>
end

%%
% MODELS
modelVars = struct;

modelVars.noRLM = ["combHFP",... 
                "devCombHFP", "study", "sex", "seasonSin", "seasonCos", "ethnicGroup"];
modelVars.RLM = ["combHFP",... 
                "devCombHFP", "study", "sex", "seasonSin", "seasonCos", "ethnicGroup", "combRLM"];

modelFields = string(fieldnames(modelVars));
for model = 1:numel(modelFields)
    currentVars = modelVars.(modelFields(model));
    modelStrVars = currentVars(ismember(currentVars, strVars));
    modelNumVars = currentVars(ismember(currentVars, numVars));
    idxStr = strcmp(table2array(data.all(:,modelStrVars)), "");
    idxNum = isnan(table2array(data.all(:,modelNumVars)));
    idx = sum([idxStr,idxNum],2) == 0;
    modelData = data.all(idx,currentVars);
    
    modelStr = char(strjoin(currentVars, " + "));
    modelStr(regexp(modelStr, '+', 'once')) = "~"; 
    
    for var = 1:length(modelStrVars)
        modelData.(modelStrVars(var)) = categorical(modelData.(modelStrVars(var)));
    end
    
    lme = fitlme(modelData,modelStr) %#ok<NOPTS>
end

%%
% violin plots
violinData = struct;
vars = dataVars(endsWith(dataVars, "_RG"));

seasonColours = [0 1 0; 1 1 0; 1 0 0; 0 0 1];

t = tiledlayout(2,2);
for var = 1:length(vars)
    violinData.(vars(var)) = cell(1,4);
    for season = 1:length(seasonVars)
        idx = strcmpi(data.all.season, seasonVars(season));
        seasonData = data.all.(vars(var))(idx);
        violinData.(vars(var))(season) = {seasonData(~isnan(seasonData))};
    end
    nexttile
    violin(violinData.(vars(var)), 'xlabel', strcat(seasonVars), 'facecolor', seasonColours);
    title(vars(var),'Interpreter','none')
end


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

sinMonths = sin(2*pi*((inputMonths-1)/12));
cosMonths = cos(2*pi*((inputMonths-1)/12));

end

%%
function [sinSeasons,cosSeasons] = SinCosSeason(inputSeasons)

seasons = ["spring", "summer", "autumn", "winter"];
seasonNums = NaN(height(inputSeasons),1);

for row = 1:height(inputSeasons)
    if ~strcmp(inputSeasons(row), "")
        seasonNums(row) = find(strcmp(seasons, inputSeasons(row)));
    end
end

sinSeasons = sin(2*pi*((seasonNums-1)/4));
cosSeasons = cos(2*pi*((seasonNums-1)/4));

end

%%
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

%%
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






% %%
% mdls = struct;
% 
% for res = 1:length(resNames)
%     [data.(resNames(res)).monthSin, data.(resNames(res)).monthCos] = SinCosMonth(data.(resNames(res)).month);
%     for task = 1:length(taskNames)
%         if sum(contains(data.(resNames(res)).Properties.VariableNames, taskNames(task)))
%             mdlStr = strcat(taskNames(task), '_logRG', '~ monthSin + monthCos');
%             mdls.(resNames(res)).(taskNames(task)) = fitlm(data.(resNames(res)), mdlStr);
%         end
%     end
% end
% 
% %%
% for task = 1:length(taskNames)
%     mergedData.(taskNames(task)) = table.empty(0,3);
%     taskVars = [strcat(taskNames(task), "_logRG"), "monthSin", "monthCos"];
%     mergedData.(taskNames(task)).Properties.VariableNames = taskVars;
% 
%     for res = 1:length(resNames)
%         if sum(contains(data.(resNames(res)).Properties.VariableNames, (taskNames(task))))
%            mergedData.(taskNames(task)) = [mergedData.(taskNames(task)); data.(resNames(res))(:,taskVars)];
%         end
%     end
% 
%     mdlStr = strcat(taskNames(task), '_logRG ~ monthSin + monthCos');
%     mdls.merged.(taskNames(task)) = fitlm(mergedData.(taskNames(task)), mdlStr);
% end
% 
% %%
% graphParas = struct;
% for row = 1:height(seasonTbl)
%     rowName = strrep(string(seasonTbl.Properties.RowNames(row)), "-", "_");
%     x = 1:4;
%     y = table2array(seasonTbl(row,:));
%     idx = ~isnan(y); x = x(idx); y = y(idx);
% 
%     graphParas.(rowName) = sineFit(x,y);
%     movegui(1, [scW/2 scH/2]); movegui(2, [scW/2 50]);
%     figure(1); title(rowName, "Interpreter", "none"); subtitle("SINUS");
%     figure(2); title(rowName, "Interpreter", "none"); subtitle("FFT");
% 
%     taskName = extractBefore(string(seasonTbl.Properties.RowNames(row)), "-");
%     resName = extractAfter(string(seasonTbl.Properties.RowNames(row)), "-");
%     disp(taskName); disp(resName); %disp(mdls.(resName).(taskName)); disp(" ");
% 
%     input("Press ENTER to continue");
% end
% close all