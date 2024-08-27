function data = LoadData

warning('off','MATLAB:table:ModifiedAndSavedVarnames')

addpath("data\");
addpath("data\dataHFP-MT");
addpath("scripts\");
addpath("scripts\functions\");
addpath("tables\");

studyPriorityOrder = ["Josh", "Mitch", "Dana", "Allie"];
monthTimeFrame = 8;

%%% Link data
ptptIdTbl = readtable("Ptpt_ID_Links.xlsx");
ptptIdTbl = convertvars(ptptIdTbl, ptptIdTbl.Properties.VariableNames, 'string');

varOrder = ["Name", strcat("PtptID", studyPriorityOrder)];
ptptIdTbl = ptptIdTbl(:,varOrder);

%% Key data
keyTbl = readtable("KeyData.xlsx");
keyTbl = convertvars(keyTbl, ["Type", "Category"], 'string');

%% Genetics Data
geneTbl = readtable("GeneticsData.xlsx");
geneTbl = convertvars(geneTbl, ["OPN1LWExon3", "ptptID", "OPN1LW180Prediction"], 'string');

%% Possible var names
taskNames = ["RLM_Leo", "HFP_Leo", "RLM_Anom", "HFP_Uno"];

data = struct;
monthMeans = struct;
monthNs = struct;
seasonMeans = struct;
seasonNs = struct;

dataVars = ["study", "ptptID", "sex", "age", "month", "year", "ethnicity", "country", "geneOpsin", "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG", "leoDev", "rlmRed", "rlmGreen", "rlmYellow", "hfpRed", "hfpGreen"];
numVars = ["age", "month", "year", "ethnicity", "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG", "rlmRed", "rlmGreen", "rlmYellow", "hfpRed", "hfpGreen"];
strVars = ["study", "ptptID", "sex", "country", "geneOpsin", "leoDev"];

%% Allie's data
aData = load("data-A.mat"); aData = aData.hfpTable;
aDataDemo = readtable("newDataDemo-A.xlsx");

ptptIDs = unique(string(aData.ptptID));

data.Allie = strings(height(ptptIDs), length(dataVars));

study = "A";
age = NaN;
rg1 = NaN;
rg2 = NaN;
rg3 = NaN;
country = "";
geneOpsin = "";
leoDev = "n/a";
rlmR = NaN;
rlmG = NaN;
rlmY = NaN;

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
        hfpR = rg4; hfpG = 1;
        data.Allie(ptpt,:) = [study, ptptID, sex, age, month, year, ethnicity, country, geneOpsin, rg1, rg2, rg3, rg4, leoDev, rlmR, rlmG, rlmY, hfpR, hfpG];
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
leoDev = "yellow";

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
        studyMonth = ptptData.RLM_Date2; if isnan(studyMonth), studyMonth = ptptData.HFP_Date2; end
        studyYear = ptptData.RLM_Date1; if isnan(studyMonth), studyMonth = ptptData.HFP_Date1; end
        if studyMonth == 0 || studyYear == 0 
            age = NaN;
        else
            age = studyYear - year; if month > studyMonth, age = age - 1; end
        end
        ethnicity = ptptData.Ethnicity;
        geneRow = find(strcmpi(geneTbl.ptptID, ptptID));
        if ~isempty(geneRow), geneOpsin = geneTbl.OPN1LW180Prediction(geneRow); else, geneOpsin = ""; end
        rg1 = ptptData.RLM_Red_1 / ptptData.RLM_Green_1;
        rg2 = ptptData.HFP_Leo_Red_1 ./ ptptData.HFP_Leo_Green_1;
        rg3 = ptptData.RLM_MixLight_1;
        rg4 = ptptData.HFP_Uno_Red_1 ./ 1024;
        rlmR = ptptData.RLM_Red_1;
        rlmG = ptptData.RLM_Green_1;
        rlmY = ptptData.RLM_Yellow_1;
        hfpR = ptptData.HFP_Leo_Red_1 ./ 256;
        hfpG = ptptData.HFP_Leo_Green_1 ./ 256;
        if isnan(hfpR) || isnan(hfpG), hfpR = rg4; hfpG = 1; end
        data.Dana(ptpt,:) = [study, ptptID, sex, age, month, year, ethnicity, country, geneOpsin, rg1, rg2, rg3, rg4, leoDev, rlmR, rlmG, rlmY, hfpR, hfpG];
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
leoDev = "yellow";

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
            studyMonth = ptptData.HFP_DateTime_2(1);
            studyYear = ptptData.HFP_DateTime_1(1);
            if studyMonth == 0 || studyYear == 0
                age = NaN;
            else
                age = studyYear - year; if month > studyMonth, age = age - 1; end
            end
            ethnicity = ptptData.Ethnicity(1);
            country = string(ptptData.("Country of Birth")(1));
            geneRow = find(strcmpi(geneTbl.ptptID, ptptID));
            if ~isempty(geneRow), geneOpsin = geneTbl.OPN1LW180Prediction(geneRow); else, geneOpsin = ""; end
            ptptValueData = mean(ptptData(2:end,["RLM_Red","RLM_Green","RLM_Yellow","HFP_RedValue","HFP_GreenValue"]),1,"omitmissing");
            rg1 = ptptValueData.RLM_Red ./ ptptValueData.RLM_Green;
            rg2 = ptptValueData.HFP_RedValue ./ ptptValueData.HFP_GreenValue;
            rlmR = ptptValueData.RLM_Red;
            rlmG = ptptValueData.RLM_Green;
            rlmY = ptptValueData.RLM_Yellow;
            hfpR = ptptValueData.HFP_RedValue ./ 256;
            hfpG = ptptValueData.HFP_GreenValue ./ 256;
            if isnan(hfpR) || isnan(hfpG), hfpR = rg4; hfpG = 1; end
            data.Josh(ptpt,:) = [study, ptptID, sex, age, month, year, ethnicity, country, geneOpsin, rg1, rg2, rg3, rg4, leoDev, rlmR, rlmG, rlmY, hfpR, hfpG];
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
leoDev = "green";

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
        geneRow = find(strcmpi(geneTbl.ptptID, ptptID));
        if ~isempty(geneRow), geneOpsin = geneTbl.OPN1LW180Prediction(geneRow); else, geneOpsin = ""; end

        idx = strcmp(string(mDataRLM.ParticipantCode),ptptID)...
              & strcmp(string(mDataRLM.MatchType), "Best")...
              & mDataRLM.Trial > 1;
        ptptDataRLM = mean(mDataRLM(idx,["Red","Green","Yellow"]),1);
        rg1 = ptptDataRLM.Red ./ ptptDataRLM.Green;

        studyMonth = table2array(mDataRLM(idx,"DateTime"));
        if isempty(studyMonth) | studyMonth == 0 
            age = NaN;
        else
            studyMonth = studyMonth(1,2);
            studyYear = table2array(mDataRLM(idx,"DateTime"));
            studyYear = studyYear(1,1);
            age = studyYear - year; if month > studyMonth, age = age - 1; end
        end

        idx = strcmp(string(mDataHFP.trialID),ptptID)...
              & mDataHFP.trialNum > 1;
        ptptDataHFP = table2array(mean(mDataHFP(idx,"meanTestAmpSetting")));
        rg4 = ptptDataHFP ./ 1024;
        rlmR = ptptDataRLM.Red;
        rlmG = ptptDataRLM.Green;
        rlmY = ptptDataRLM.Yellow;
        hfpR = rg4; hfpG = 1;
        data.Mitch(ptpt,:) = [study, ptptID, sex, age, month, year, ethnicity, country, geneOpsin, rg1, rg2, rg3, rg4, leoDev, rlmR, rlmG, rlmY, hfpR, hfpG];
    end
end

idx = (sum(ismissing(data.Mitch),2) + sum(strcmp(data.Mitch, ""),2)) ~= width(data.Mitch);
data.Mitch = data.Mitch(idx,:);
data.Mitch = array2table(data.Mitch, "VariableNames", dataVars);
data.Mitch = convertvars(data.Mitch, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Mitch, taskNames, "Mitch");

%% log data
resNames = string(fieldnames(monthMeans));
newVars = strcat(taskNames, "_rawRG");
newLogVars = strcat(taskNames, "_logRG");
% log values
for task = 1:length(taskNames)
    for res = 1:length(resNames)
        data.(resNames(res)).(newVars(task)) = data.(resNames(res)).(strcat(taskNames(task),"_RG"));
        data.(resNames(res)).(newLogVars(task)) = log(data.(resNames(res)).(strcat(taskNames(task),"_RG")));
    end
end
dataVars = [dataVars, newVars, newLogVars];
numVars = [numVars, newVars, newLogVars];

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
        varName = strcat(combTasks(task,1), "_", combTasks(task,var), "_rawRG");
        idx_data = ~isnan(data.all.(varName));
        idx_empty = isnan(data.all.(combVar));
        idx = idx_data & idx_empty;
        data.all.(combVar)(idx) = data.all.(varName)(idx);
        data.all.(devCombVar)(idx) = lower(combTasks(task,var));    
    end
    
    dataVars = [dataVars, combVar, devCombVar]; %#ok<AGROW>
    numVars = [numVars, combVar]; %#ok<AGROW>
    strVars = [strVars, devCombVar]; %#ok<AGROW>
end

% labelling correct leo deivces
yellowStudies = ["D1","D2","J"];
greenStudies = "M";
idx = ismember(data.all.study,yellowStudies) & strcmp(data.all.devCombRLM,"leo");
data.all.devCombRLM(idx) = "yellow";
idx = ismember(data.all.study,yellowStudies) & strcmp(data.all.devCombHFP,"leo");
data.all.devCombHFP(idx) = "yellow";
idx = ismember(data.all.study,greenStudies) & strcmp(data.all.devCombRLM,"leo");
data.all.devCombRLM(idx) = "green";
idx = ismember(data.all.study,greenStudies) & strcmp(data.all.devCombHFP,"leo");
data.all.devCombHFP(idx) = "green";

CalculateWeatherData;

warning('on','MATLAB:table:ModifiedAndSavedVarnames');

end