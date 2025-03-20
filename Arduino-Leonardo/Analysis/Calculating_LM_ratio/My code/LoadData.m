function data = LoadData

warning('off','MATLAB:table:ModifiedAndSavedVarnames')

addpath(genpath(pwd));

studyPriorityOrder = ["Josh", "Mitch", "Dana", "Allie"];

%%% Link data
ptptIdTbl = readtable("Ptpt_ID_Links.xlsx");
ptptIdTbl = convertvars(ptptIdTbl, ptptIdTbl.Properties.VariableNames, 'string');

%% Key data
keyTbl = readtable("Demographic-Data-Key.xlsx");
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

dataVars = ["study", "ptptID", "doneHigherPriorityStudy", "sex", "age", "month", "year", "ethnicity", "country", "continent", "hemisphere", "geneOpsin",... 
    "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG",... 
    "rlmRed", "rlmGreen", "rlmYellow", "rlmRG", "rlmMatchType", "rlmDevice", "hfpRed", "hfpGreen", "hfpMatchType", "hfpDevice",...
    "hfpDay", "hfpMinute"];
numVars = ["study", "doneHigherPriorityStudy", "age", "month", "year", "ethnicity",... 
    "RLM_Leo_RG", "HFP_Leo_RG", "RLM_Anom_RG", "HFP_Uno_RG",... 
    "rlmRed", "rlmGreen", "rlmYellow", "rlmRG", "hfpRed", "hfpGreen",...
    "hfpDay", "hfpMinute"];
strVars = ["ptptID", "sex", "country", "continent", "hemisphere", "geneOpsin", "rlmMatchType", "rlmDevice", "hfpMatchType", "hfpDevice"];

%% Allie's data
aData = load("data-A.mat"); aData = aData.hfpTable;
aDataDemo = readtable("Allie-Demographic-Cleanedup.xlsx");

ptptIDs = unique(string(aData.ptptID));

data.Allie = strings(height(ptptIDs), length(dataVars));

study = 0;
age = NaN;
rg1 = NaN;
rg2 = NaN;
rg3 = NaN;
country = "";
continent = "";
hemisphere = "";
geneOpsin = "";
rlmR = NaN;
rlmG = NaN;
rlmY = NaN;
rlmRG = NaN;
rlmMT = "n/a";
hfpMT = "staircase";
rlmD = "n/a";
hfpD = "uno";
hfpDay = NaN;
hfpMinute = NaN;

for ptpt = 1:height(aData)
    doneHigherPriorityStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl, studyPriorityOrder);
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
        hfpR = rg4; hfpG = 1;
        data.Allie(ptpt,:) = [study, ptptID, doneHigherPriorityStudy,... 
            sex, age, month, year, ethnicity, country, continent, hemisphere, geneOpsin,... 
            rg1, rg2, rg3, rg4, rlmR, rlmG, rlmY, rlmRG, rlmMT, rlmD, hfpR, hfpG, hfpMT, hfpD, hfpDay, hfpMinute];
    end
end

idx = (sum(ismissing(data.Allie),2) + sum(strcmp(data.Allie, ""),2)) ~= width(data.Allie);
data.Allie = data.Allie(idx,:);
data.Allie = array2table(data.Allie, "VariableNames", dataVars);
data.Allie = convertvars(data.Allie, numVars, 'double');

[monthMeans,monthNs] = MonthMeansAndNs(monthMeans, monthNs, data.Allie, taskNames, "Allie");

%% Dana's data
dData = readtable("data-Validation.xlsx", 'Sheet','Matlab_Data');
ptptIDs = unique(string(dData.PPcode));
data.Dana = strings(length(ptptIDs), length(dataVars));

country = "";
continent = "";
hemisphere = "";
rlmD = "yellow";

for ptpt = 1:length(ptptIDs)
    doneHigherPriorityStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl, studyPriorityOrder);
    idx = strcmp(string(dData.PPcode), ptptIDs(ptpt))...
          & table2array(sum(dData(strcmp(dData.PPcode,ptptIDs(ptpt)), "HRR_Pass")));
    ptptData = dData(idx,:);
    if ~isempty(ptptData)
        ptptID = string(table2array(ptptData(1,"PPcode")));
        ptptData.PPcode = [];
        sex = string(table2array(ptptData(1,"Sex")));
        ptptData.Sex = [];
        study = ptptData.Study(1);
        month = ptptData.Month(1);
        year = ptptData.Year(1);
        studyMonth = ptptData.RLM_Date2(1); if isnan(studyMonth), studyMonth = ptptData.HFP_Date2(1); end
        studyYear = ptptData.RLM_Date1(1); if isnan(studyMonth), studyMonth = ptptData.HFP_Date1(1); end
        if studyMonth == 0 || studyYear == 0
            if study == 1.1, studyMonth = 1; elseif study == 1.2, studyMonth = 3; end
            studyYear = 2023; 
        end
        age = studyYear - year; if month > studyMonth, age = age - 1; end
        ethnicity = ptptData.Ethnicity(1);
        geneRow = find(strcmpi(geneTbl.ptptID, ptptID));
        if ~isempty(geneRow), geneOpsin = geneTbl.OPN1LW180Prediction(geneRow); else, geneOpsin = ""; end
        switch study
            case 1.1
                rlmMT = "best";
                hfpMT = "best";
                idx = ptptData.Match_Type == 1;
            case 1.2
                rlmMT = "n/a";
                hfpMT = "midpoint";
                idx = ptptData.Match_Type == 2 | ptptData.Match_Type == 3;
        end
        ptptData = ptptData(idx,:);
        row = height(ptptData)/5 + 1;
        ptptData = mean(ptptData(row:end,:),'omitmissing');

        rg1 = ptptData.RLM_Red_1 / ptptData.RLM_Green_1;
        rg2 = ptptData.HFP_Leo_Red_1 ./ ptptData.HFP_Leo_Green_1;
        rg3 = ptptData.RLM_MixLight_1;
        rg4 = ptptData.HFP_Uno_Red_1 ./ 1024;
        rlmR = ptptData.RLM_Red_1 ./ 255;
        rlmG = ptptData.RLM_Green_1 ./ 255;
        rlmY = ptptData.RLM_Yellow_1 ./ 255;
        rlmRG = ptptData.RLM_Lambda_1;
        hfpR = ptptData.HFP_Leo_Red_1 ./ 255;
        hfpG = ptptData.HFP_Leo_Green_1 ./ 255;
        if isnan(hfpR) || isnan(hfpG)
            hfpR = rg4;
            hfpG = 1;
            hfpD = "uno"; 
        else
            hfpD = "yellow";
        end

        dtVars = ["HFP_Date" + string(1:3), "HFP_Time" + string(1:3)];
        hfpDate = datetime(table2array(ptptData(1,dtVars)));
        hfpDay = day(hfpDate,"dayofyear") / yeardays(ptptData.HFP_Date1(1));
        if hfpDay == 0, hfpDay = NaN; end
        hfpMinute = hour(hfpDate) * 60 + minute(hfpDate);
        if hfpMinute == 0, hfpMinute = NaN; else, hfpMinute = hfpMinute / (60*24); end

        data.Dana(ptpt,:) = [study, ptptID, doneHigherPriorityStudy,... 
            sex, age, month, year, ethnicity, country, continent, hemisphere, geneOpsin,... 
            rg1, rg2, rg3, rg4, rlmR, rlmG, rlmY, rlmRG, rlmMT, rlmD, hfpR, hfpG, hfpMT, hfpD, hfpDay, hfpMinute];
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

study = 2;
rg3 = NaN;
rg4 = NaN;
rlmMT = "midpoint";
hfpMT = "best";
rlmD = "yellow";
hfpD = "yellow";

for ptpt = 1:length(ptptIDs)
    doneHigherPriorityStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl, studyPriorityOrder);
    idx = strcmp(jData.Code, ptptIDs(ptpt))...
        & ~isnan(jData.PP);
    ptptDemoData = jData(idx,:);
    idx = strcmp(jData.Code, ptptIDs(ptpt))...
        & jData.Trial > 1 ...
        & strcmpi(jData.("Match Type"),"Best");
    ptptData = jData(idx,:);

    if ~isempty(ptptDemoData) & ~isempty(ptptData)
        idx = strcmp(table2array(ptptDemoData(1, "Plates")), "P");
        if idx
            ptptID = string(table2array(ptptDemoData(1,"Code")));
            sex = string(table2array(ptptDemoData(1,"Sex")));
            month = ptptDemoData.("Birth Month")(1);
            year = ptptDemoData.("Birth Year")(1);
            studyMonth = ptptDemoData.HFP_DateTime_2(1);
            studyYear = ptptDemoData.HFP_DateTime_1(1);
            if studyMonth == 0 || studyYear == 0, studyMonth = 3; studyYear = 2023; end
            age = studyYear - year; if month > studyMonth, age = age - 1; end
            ethnicity = ptptDemoData.Ethnicity(1);
            country = string(ptptDemoData.("Country of Birth")(1));
            continent = FindContinentFromCountry(country);
            hemisphere = FindHemisphereFromCountry(country);
            switch hemisphere
                case "nothern"
                case "southern"
                    month = month + 6;
                    if month > 12, month = month - 12; end
                case "equitorial"
                    month = NaN;
            end
            geneRow = find(strcmpi(geneTbl.ptptID, ptptID));
            if ~isempty(geneRow), geneOpsin = geneTbl.OPN1LW180Prediction(geneRow); else, geneOpsin = ""; end
            vars = ["RLM_Red", "RLM_Green", "RLM_Yellow", "RLM_Lambda", "HFP_RedValue", "HFP_GreenValue"];
            ptptValueData = mean(ptptData(:,vars),'omitmissing');
            rg1 = ptptValueData.RLM_Red ./ ptptValueData.RLM_Green;
            rg2 = ptptValueData.HFP_RedValue ./ ptptValueData.HFP_GreenValue;
            rlmR = ptptValueData.RLM_Red ./ 255;
            rlmG = ptptValueData.RLM_Green ./ 255;
            rlmY = ptptValueData.RLM_Yellow ./ 255;
            rlmRG = ptptValueData.RLM_Lambda;
            hfpR = ptptValueData.HFP_RedValue ./ 255;
            hfpG = ptptValueData.HFP_GreenValue ./ 255;
            if isnan(hfpR) || isnan(hfpG), hfpR = rg4; hfpG = 1; end

            dtVars = "HFP_DateTime_" + string(1:6);
            hfpDate = datetime(table2array(ptptData(1,dtVars)));
            try
                hfpDay = day(hfpDate,"dayofyear") / yeardays(ptptData.HFP_DateTime_1(1));
                if hfpDay == 0, hfpDay = NaN; end
            catch
                hfpDay = NaN;
            end
            hfpMinute = hour(hfpDate) * 60 + minute(hfpDate);
            if hfpMinute == 0, hfpMinute = NaN; else, hfpMinute = hfpMinute / (60*24); end

            data.Josh(ptpt,:) = [study, ptptID, doneHigherPriorityStudy,... 
            sex, age, month, year, ethnicity, country, continent, hemisphere, geneOpsin,... 
            rg1, rg2, rg3, rg4, rlmR, rlmG, rlmY, rlmRG, rlmMT, rlmD, hfpR, hfpG, hfpMT, hfpD, hfpDay, hfpMinute];
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
mDataRLM = load("Rayleigh-Mitch.mat","ParticipantMatchesRLM");
mDataRLM = mDataRLM.ParticipantMatchesRLM;
mDataRLM = mDataRLM(~contains(string(mDataRLM.ParticipantCode), "TEST"),:);

mDataDemo = readtable("dataDemographic-Mitch.xlsx");

ptptIDs = unique(string(mDataDemo.ParticipantCode));
ptptIDs = ptptIDs(strlength(ptptIDs) == 3);

% Mitch's HFP data
mDataHFP_files=dir(fullfile('data\Mitch-Large-N\dataHFP-Mitch','*.mat'));
for file = 1:length(mDataHFP_files)
    fileName = mDataHFP_files(file).name;
    currentFile = load(strcat(pwd, '\data\Mitch-Large-N\dataHFP-Mitch\', fileName));
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

study = 3;
rg2 = NaN;
rg3 = NaN;
rlmMT = "midpoint";
hfpMT = "staircase";
rlmD = "green";
hfpD = "uno";

for ptpt = 1:length(ptptIDs)
    ptptID = ptptIDs(ptpt);
    doneHigherPriorityStudy = CheckPreviousParticipation(ptptIDs(ptpt), ptptIdTbl, studyPriorityOrder);
    hrrPass = strcmpi(string(table2array(mDataDemo(strcmp(string(mDataDemo.ParticipantCode), ptptID),"CVD"))), "No");
    if hrrPass == 1
        ptptDataDemo = mDataDemo(strcmp(string(mDataDemo.ParticipantCode), ptptID),:);
        if ~isempty(ptptDataDemo)
            sex = string(ptptDataDemo.Sex);
            month = ptptDataDemo.BirthMonth;
            year = ptptDataDemo.BirthYear;
            ethnicity = ptptDataDemo.Ethnicity;
            country = string(ptptDataDemo.CountryOfBirth);
            continent = FindContinentFromCountry(country);
            hemisphere = FindHemisphereFromCountry(country);
            switch hemisphere
                case "nothern"
                case "southern"
                    month = month + 6;
                    if month > 12, month = month - 12; end
                case "equitorial"
                    month = NaN;
            end
        end
        geneRow = find(strcmpi(geneTbl.ptptID, ptptID));
        if ~isempty(geneRow), geneOpsin = geneTbl.OPN1LW180Prediction(geneRow); else, geneOpsin = ""; end

        idx = strcmp(string(mDataRLM.ParticipantCode),ptptID)...
              & ismember(string(mDataRLM.MatchType), ["MinLambda","MaxLambda"])...
              & mDataRLM.Trial > 1;
        ptptDataRLM = mean(mDataRLM(idx,["Red","Green","Yellow","Lambda"]),'omitmissing');
        rg1 = ptptDataRLM.Red ./ ptptDataRLM.Green;

        studyDate = table2array(mDataRLM(idx,"DateTime"));
        if isempty(studyDate) | studyDate == 0 
            studyMonth = 2; studyYear = 2024;
        else
            studyMonth = studyDate(1,2); studyYear = studyDate(1,1);
        end
        age = studyYear - year; if month > studyMonth, age = age - 1; end

        idx = strcmp(string(mDataHFP.trialID),ptptID)...
              & mDataHFP.trialNum > 1;
        ptptDataHFP = table2array(mean(mDataHFP(idx,"meanTestAmpSetting"),'omitmissing'));
        rg4 = ptptDataHFP ./ 1024;
        rlmR = ptptDataRLM.Red ./ 255;
        rlmG = ptptDataRLM.Green ./ 255;
        rlmY = ptptDataRLM.Yellow ./ 255;
        rlmRG = ptptDataRLM.Lambda;
        hfpR = rg4; hfpG = 1;

        dateData = mDataRLM.DateTime(idx,:);
        if ~isempty(dateData)
            dateData = dateData(1,:);
            hfpDate = datetime(dateData);
            try
                hfpDay = day(hfpDate,"dayofyear") / yeardays(dateData(1));
                if hfpDay == 0, hfpDay = NaN; end
            catch
                hfpDay = NaN;
            end
            hfpMinute = hour(hfpDate) * 60 + minute(hfpDate);
            if hfpMinute == 0, hfpMinute = NaN; else, hfpMinute = hfpMinute / (60*24); end
        else
            hfpDay = NaN;
            hfpMinute = NaN;
        end

        data.Mitch(ptpt,:) = [study, ptptID, doneHigherPriorityStudy,... 
            sex, age, month, year, ethnicity, country, continent, hemisphere, geneOpsin,... 
            rg1, rg2, rg3, rg4, rlmR, rlmG, rlmY, rlmRG, rlmMT, rlmD, hfpR, hfpG, hfpMT, hfpD, hfpDay, hfpMinute];
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

    [data.(resNames(res)).hfpDaySin, data.(resNames(res)).hfpDayCos] = SinCos1(data.(resNames(res)).hfpDay);
    [data.(resNames(res)).hfpMinuteSin, data.(resNames(res)).hfpMinuteCos] = SinCos1(data.(resNames(res)).hfpMinute);
end

dataVars = [dataVars, newCats(:,1)', "monthSin", "monthCos", "seasonSin", "seasonCos",...
    "hfpDaySin", "hfpDayCos", "hfpMinuteSin", "hfpMinuteCos"];
numVars = [numVars, "monthSin", "monthCos", "seasonSin", "seasonCos",...
    "hfpDaySin", "hfpDayCos", "hfpMinuteSin", "hfpMinuteCos"];
strVars = [strVars, newCats(:,1)'];


%% all data combine
data.all = table.empty(0,length(dataVars));
data.all.Properties.VariableNames = dataVars;
for i = 1:length(resNames)
    data.all = [data.all; data.(resNames(i))];
end
data.all = data.all(~data.all.doneHigherPriorityStudy,:);

% uk terms
ukTerms = ["United Kingdom", "UK", "England"];
idx = ismember(data.all.country, ukTerms);
data.all.country(idx) = "UK";

CalculateWeatherData;

dataNums = array2table((1:height(data.all))','VariableNames',"ptptNum");
data.all = [dataNums data.all];

warning('on','MATLAB:table:ModifiedAndSavedVarnames');

end