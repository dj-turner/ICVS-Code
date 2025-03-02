%%% Link data
ptptIdTbl = readtable("Ptpt_ID_Links.xlsx");
ptptIdTbl = convertvars(ptptIdTbl, ptptIdTbl.Properties.VariableNames, 'string');

varOrder = ["Name", strcat("PtptID", studyPriorityOrder)];
ptptIdTbl = ptptIdTbl(:,varOrder);

%% Key data
keyTbl = readtable("KeyData.xlsx");
keyTbl = convertvars(keyTbl, ["Type", "Category"], 'string');

%% Possible var names
taskNames = ["RLM_Leo", "HFP_Leo", "RLM_Anom", "HFP_Uno"];

data = struct;
monthMeans = struct;
monthNs = struct;
seasonMeans = struct;
seasonNs = struct;

dataVars = ["study", "ptptID", "sex", "month", "year", "ethnicity", "country", "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG", "leoDev"];
numVars = ["month", "year", "ethnicity", "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG"];
strVars = ["study", "ptptID", "sex", "country", "leoDev"];

%% Allie's data
aData = load("data-A.mat"); aData = aData.hfpTable;
aDataDemo = readtable("newDataDemo-A.xlsx");

ptptIDs = unique(string(aData.ptptID));

data.Allie = strings(height(ptptIDs), length(dataVars));

study = "A";
rg1 = NaN;
rg2 = NaN;
rg3 = NaN;
country = "";
leoDev = "n/a";

for ptpt = 1:height(aData)
    donePreviousStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl);
    idx1 = contains(string(aDataDemo.ID), ptptIDs(ptpt));
    idx2 = table2array(aDataDemo(strcmp(string(aDataDemo.ID),ptptIDs(ptpt)),"CVD"));
    if sum(idx1) == 1 && idx2 == 0 && donePreviousStudy == 0
        ptptID = ptptIDs(ptpt);
        sex = upper(string(table2array(aDataDemo(idx1,"Gender"))));
        if strcmp(sex,"X"), sex = ""; end
        month = table2array(aDataDemo(idx1,"MOB"));
        dob = char(table2array(aDataDemo(idx1,"DOB")));
        if ~isempty(dob), year = str2double(dob(end-3:end)); else, year = NaN; end
        ethnicity = table2array(aDataDemo(idx1,"Ethnicity"));
        rg4 = table2array(aData(ptpt,"meanTestAmp") ./ 1024);
        data.Allie(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, country, rg1, rg2, rg3, rg4, leoDev];
    end
end

idx = (sum(ismissing(data.Allie),2) + sum(strcmp(data.Allie, ""),2)) ~= width(data.Allie);
data.Allie = data.Allie(idx,:);
data.Allie = array2table(data.Allie, "VariableNames", dataVars);
data.Allie = convertvars(data.Allie, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Allie, taskNames, "Allie");

%% Dana's data
dData = readtable("data-B.xlsx", 'Sheet','Matlab_Data');
ptptIDs = unique(string(dData.PPcode));
data.Dana = strings(length(ptptIDs), length(dataVars));

country = "";
leoDev = "y";

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
        data.Dana(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, country, rg1, rg2, rg3, rg4, leoDev];
    end
end

idx = (sum(ismissing(data.Dana),2) + sum(strcmp(data.Dana, ""),2)) ~= width(data.Dana);
data.Dana = data.Dana(idx,:);
data.Dana = array2table(data.Dana, "VariableNames", dataVars);
data.Dana = convertvars(data.Dana, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Dana, taskNames, "Dana");

%% Josh's data
jData = readtable("data-DJ.xlsx", "VariableNamingRule","preserve");

ptptIDs = unique(jData.Code);

data.Josh = strings(length(ptptIDs), length(dataVars));

study = "J";
rg3 = NaN;
rg4 = NaN;
leoDev = "y";

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
            country = string(ptptData.("Country of Birth")(1));
            
            ptptValueData = mean(ptptData(2:end,["RLM_Red","RLM_Green","HFP_RedValue","HFP_GreenValue"]),1,"omitmissing");
            rg1 = ptptValueData.RLM_Red ./ ptptValueData.RLM_Green;
            rg2 = ptptValueData.HFP_RedValue ./ ptptValueData.HFP_GreenValue;

            data.Josh(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, country, rg1, rg2, rg3, rg4, leoDev];
        end
    end
end

idx = (sum(ismissing(data.Josh),2) + sum(strcmp(data.Josh, ""),2)) ~= width(data.Josh);
data.Josh = data.Josh(idx,:);
data.Josh = array2table(data.Josh, "VariableNames", dataVars);
data.Josh = convertvars(data.Josh, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Josh, taskNames, "Josh");

%% Mitch's data
% Mitch's RLM data
mDataRLM = load("dataRLM-MT.mat","ParticipantMatchesRLM");
mDataRLM = mDataRLM.ParticipantMatchesRLM;
mDataRLM = mDataRLM(~contains(string(mDataRLM.ParticipantCode), "TEST"),:);

mDataDemo = readtable("dataDemo-MT.xlsx");

ptptIDs = unique(string(mDataDemo.ParticipantCode));
ptptIDs = ptptIDs(strlength(ptptIDs) == 3);

% Mitch's HFP data
mDataHFP_files=dir(fullfile('data\dataHFP-MT','*.mat'));
mitchDataHFP = NaN(height(ptptIDs),1);
for file = 1:length(mDataHFP_files)
    fileName = mDataHFP_files(file).name;
    currentFile = load(strcat(pwd, '\data\dataHFP-MT\', fileName));
    currentFile = currentFile.hfpData;
    currentFile = convertvars(currentFile, "trialID", 'string');
    currentID = extractBefore(extractAfter(fileName, 'HFP_'), '_');
    currentFile.trialID = repmat(currentID, [height(currentFile) 1]);
    if file == 1, mDataHFP = currentFile;
    else, mDataHFP = [mDataHFP; currentFile]; %#ok<AGROW>
    end
end
%
% Combine
data.Mitch = strings(length(ptptIDs), length(dataVars));

study = "M";
rg2 = NaN;
rg3 = NaN;
leoDev = "g";

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
            country = string(ptptDataDemo.CountryOfBirth);
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

        data.Mitch(ptpt,:) = [study, ptptID, sex, month, year, ethnicity, country, rg1, rg2, rg3, rg4, leoDev];
    end
end

idx = (sum(ismissing(data.Mitch),2) + sum(strcmp(data.Mitch, ""),2)) ~= width(data.Mitch);
data.Mitch = data.Mitch(idx,:);
data.Mitch = array2table(data.Mitch, "VariableNames", dataVars);
data.Mitch = convertvars(data.Mitch, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Mitch, taskNames, "Mitch");

%% log data
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

%% Season and ethnicity categories
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

%% all data combine
data.all = table.empty(0,length(dataVars));
data.all.Properties.VariableNames = dataVars;
for i = 1:length(resNames)
    data.all = [data.all; data.(resNames(i))];
end

studyIDs = unique(data.all.study);

% uk terms
ukTerms = ["United Kingdom", "UK", "England"];
idx = ismember(data.all.country, ukTerms);
data.all.country(idx) = "UK";

%% combine tasks
combTasks = ["RLM", "Leo", "Anom";...
             "HFP", "Leo", "Uno"];

for task = 1:height(combTasks)
    combVar = strcat("comb", combTasks(task,1));
    devCombVar = strcat("devComb", combTasks(task,1));

    data.all.(combVar) = NaN(height(data.all), 1);
    data.all.(devCombVar) = strings(height(data.all), 1);
    
    for var = 2:width(combTasks)
        varName = strcat(combTasks(task,1), "_", combTasks(task,var), "_logRG");
        idx = ~isnan(data.all.(varName));
        data.all.(combVar)(idx) = data.all.(varName)(idx);
        devName = lower(combTasks(task,var));
        if strcmp(devName, "leo")
            data.all.(devCombVar)(idx) = strcat(devName, "_", data.all.leoDev(idx));
        else
            data.all.(devCombVar)(idx) = devName;
        end
    end
    
    dataVars = [dataVars, combVar, devCombVar]; %#ok<AGROW>
    numVars = [numVars, combVar]; %#ok<AGROW>
    strVars = [strVars, devCombVar]; %#ok<AGROW>
end

%% study stats
studies = unique(data.all.study);
studyStats = NaN(length(studies),4);

for i = 1:length(studies)
    idx = strcmp(data.all.study, studies(i)) & ~isnan(data.all.combHFP);
    studyTbl = data.all(idx,:);
    studyN = height(studyTbl);
    studyMean = mean(studyTbl.combHFP);
    studyStd = std(studyTbl.combHFP);
    studySe = studyStd / sqrt(studyN);
    studyStats(i,:) = [studyN, studyMean, studyStd, studySe];
end
studyStats = array2table(studyStats, "RowNames", studies, "VariableNames", ["n", "mean", "std", "se"]);

CalculateWeatherData;