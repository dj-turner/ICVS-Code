% clear up
clc; clear; close all;

%%
% josh's data
joshData = readtable("data-DJ.xlsx", "VariableNamingRule","preserve");

demoVars = ["PP", "Code", "Birth Month", "Country of Birth", "Ethnicity", "Plates"];
joshDataDemo = joshData(~isnan(joshData.PP), demoVars);
joshDataDemo = convertvars(joshDataDemo, ["Code", "Country of Birth", "Plates"], 'string');

rlmVars = ["RLM_Red", "RLM_Green", "RLM_Yellow"];
hfpVars = ["HFP_RedValue", "HFP_GreenValue"];
resultsVars = [rlmVars, hfpVars];

ptptIDs = unique(joshDataDemo.Code);

resultsData = NaN(length(ptptIDs), length(resultsVars));
for ptpt = 1:length(ptptIDs)
    idx = strcmp(joshData.Code, ptptIDs(ptpt))... 
        & strcmp(joshData.("Match Type"), "Best")... 
        & joshData.Trial ~= 1;
    ptptData = joshData(idx,:);

    rlmData = table2array(mean(ptptData(ptptData.RLM_ConfidenceRating > 1, rlmVars), 'omitmissing'));
    hfpData = table2array(mean(ptptData(ptptData.HFP_ConfidenceRating > 1, hfpVars), 'omitmissing'));
    resultsData(ptpt,:) = [rlmData hfpData];
end

joshDataResults = array2table(resultsData, 'VariableNames', resultsVars);

djData = [joshDataDemo joshDataResults];

djData.RLM_RG = djData.RLM_Red ./ djData.RLM_Green;
djData.HFP_RG = djData.HFP_RedValue ./ djData.HFP_GreenValue;

monthMeansDJ = NaN(2, 12);
monthNsDJ = NaN(2,12);
for month = 1:12
    monthDataDJ = djData(djData.("Birth Month") == month, endsWith(djData.Properties.VariableNames, "RG"));
    monthNsDJ(1,month) = height(monthDataDJ(~isnan(table2array(monthDataDJ(:,1))),:));
    monthNsDJ(2,month) = height(monthDataDJ(~isnan(table2array(monthDataDJ(:,2))),:));
    monthMeansDJ(:, month) = table2array(mean(monthDataDJ, "omitmissing"))';
end

%%
% mitch's rlm data
rlmVars = ["Red", "Green", "Yellow"];

mitchDataRLM = load("dataRLM-MT.mat","ParticipantMatchesRLM");
mitchDataRLM = mitchDataRLM.ParticipantMatchesRLM;
mitchDataRLM = mitchDataRLM(~contains(string(mitchDataRLM.ParticipantCode), "TEST"),:);

mitchDataDemo = readtable("dataDemo-MT.xlsx");

ptptIDs = unique(string(mitchDataRLM.ParticipantCode));
ptptIDs = ptptIDs(strlength(ptptIDs) == 3);

mitchDataResultsRLM = NaN(length(ptptIDs), 4);
for ptpt = 1:length(ptptIDs)
    idx = strcmp(string(mitchDataRLM.ParticipantCode), ptptIDs(ptpt))...
          & strcmp(mitchDataRLM.MatchType, "Best") & mitchDataRLM.Trial ~= 1 & mitchDataRLM.ConfidenceRating > 1;
    ptptData = mitchDataRLM(idx,:);
    if unique(ptptData.Session) > 1
        ptptData = ptptData(ptptData.Session == ptptData.Session(1),:);
    end
    if height(ptptData) > 4
        ptptData = ptptData(1:4,:);
    end
    mitchDataResultsRLM(ptpt,2:4) = table2array(mean(ptptData(:,rlmVars)));

    mitchDataResultsRLM(ptpt,1) = table2array(mitchDataDemo(strcmp(mitchDataDemo.ParticipantCode, ptptIDs(ptpt)),"BirthMonth"));
end

mitchDataResultsRLM = array2table(mitchDataResultsRLM, "VariableNames", ["Month", rlmVars]);
mitchDataResultsRLM.RLM_RG = mitchDataResultsRLM.Red ./ mitchDataResultsRLM.Green;

% mitches hfp data
mitchDataHFP_files=dir(fullfile('dataHFP-MT','*.mat'));
mitchDataResultsHFP = NaN(height(ptptIDs),1);
for file = 1:length(mitchDataHFP_files)
    fileName = mitchDataHFP_files(file).name;
    currentFile = load(strcat(pwd, '\dataHFP-MT\', fileName));
    currentFile = currentFile.hfpData;
    currentFile = convertvars(currentFile, "trialID", 'string');
    currentID = extractBefore(extractAfter(fileName, 'HFP_'), '_');
    currentFile.trialID = repmat(currentID, [height(currentFile) 1]);
    if file == 1, mitchDataHFP = currentFile;
    else, mitchDataHFP = [mitchDataHFP; currentFile]; %#ok<AGROW>
    end
    
    mitchDataResultsHFP(strcmp(currentID, ptptIDs)) = table2array(mean(currentFile(currentFile.trialNum > 1, "meanTestAmpSetting")));
end
mitchDataResultsHFP = array2table(mitchDataResultsHFP, "VariableNames", "HFP_RG");
mitchDataResults = [mitchDataResultsRLM mitchDataResultsHFP];

monthMeansMT = NaN(2,12);
monthNsMT = NaN(2,12);
for month = 1:12
    monthDataMT = mitchDataResults(mitchDataResults.Month == month, endsWith(mitchDataResults.Properties.VariableNames, "RG"));
    monthNsMT(1,month) = height(monthDataMT(~isnan(table2array(monthDataMT(:,1))),:));
    monthNsMT(2,month) = height(monthDataMT(~isnan(table2array(monthDataMT(:,2))),:));
    monthMeansMT(:, month) = table2array(mean(monthDataMT, "omitmissing"))';
end

%%
% Allie's data
aData = load("data-A.mat");
aData = aData.hfpTable;
allieDataDemo = readtable("dataDemo-A.xlsx");

ptptIDs = unique(string(aData.ptptID));

allieResultsData = NaN(height(ptptIDs), 2);
for ptpt = 1:height(aData)
    idx = contains(string(allieDataDemo.LM100ID), ptptIDs(ptpt));
    if sum(idx) == 1
        dob = char(table2array(allieDataDemo(idx, "DOB")));
        if ~isempty(dob), month = str2num(dob(4:5)); else, month = NaN; end
        logRG = table2array(aData(ptpt, "meanTestAmp"));
        allieResultsData(ptpt,:) = [month logRG];
    end
end

idx = sum(isnan(allieResultsData),2) == width(allieResultsData);
allieResultsData = allieResultsData(~idx,:);
allieResultsData = array2table(allieResultsData, "VariableNames", ["Month", "amp"]);

monthMeansA = NaN(1,12);
monthNsA = NaN(1,12);
for month = 1:12
    monthDataA = allieResultsData(allieResultsData.Month == month, strcmp(allieResultsData.Properties.VariableNames, "amp"));
    monthNsA(1,month) = height(monthDataA(~isnan(table2array(monthDataA(:,1))),:));
    monthMeansA(:, month) = table2array(mean(monthDataA, "omitmissing"))';
end

%%
% Dana's data
vars = ["Month", "RLM_Red_1", "RLM_Green_1", "RLM_MixLight_1", "HFP_Leo_Red_1", "HFP_Leo_Green_1", "HFP_Uno_Red_1"];
dataB = readtable("data-B.xlsx", 'Sheet','Matlab_Data');
ptptIDs = unique(string(dataB.PPcode));
danaData = array2table(NaN(length(ptptIDs), length(vars)), 'VariableNames', vars);
for ptpt = 1:length(ptptIDs)
    idx = strcmp(string(dataB.PPcode), ptptIDs(ptpt))...
          & dataB.Study == 1.1;
    currentData = dataB(idx,vars);
    if ~isempty(currentData)
        danaData(ptpt,:) = mean(currentData(2:end, :), 'omitmissing');
    end
end

danaData.RLM_RG = danaData.RLM_Red_1 ./ danaData.RLM_Green_1;
danaData.HFP_RG = danaData.HFP_Leo_Red_1 ./ danaData.HFP_Leo_Green_1;

monthMeansB = NaN(4,12);
monthNsB = NaN(4,12);
for month = 1:12
    monthDataB = danaData(danaData.Month == month, ["RLM_RG", "RLM_MixLight_1", "HFP_RG", "HFP_Uno_Red_1"]);
    for i = 1:width(monthDataB)
        monthNsB(i,month) = height(monthDataB(~isnan(table2array(monthDataB(:,i))),:));
    end
    monthMeansB(:, month) = table2array(mean(monthDataB, "omitmissing"))';
end

%%
% radar graphs
monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

monthTbl = array2table([monthMeansDJ; monthMeansMT; monthMeansA; monthMeansB],... 
    "RowNames", ["RLM-Leo-DJ", "HFP-Leo-DJ", "RLM-Leo-MT", "HFP-Uno-MT", "HFP-Uno-A", "RLM-Leo-B", "RLM-Anom-B", "HFP-Leo-B", "HFP-Uno-B"], "VariableNames", monthVars);

monthLabs = strings(4,12);
for month = 1:12
    monthLabs(1,month) = strcat(monthVars(month), " (nJosh = ", num2str(monthNsDJ(1,month)), ", nMitch = ", num2str(monthNsMT(1,month)), ", nDana = ", num2str(monthNsB(1,month)), ")");
    monthLabs(2,month) = strcat(monthVars(month), " (nDana = ", num2str(monthNsB(2,month)), ")");
    monthLabs(3,month) = strcat(monthVars(month), " (nJosh = ", num2str(monthNsDJ(2,month)), ", nDana = ", num2str(monthNsB(3,month)), ")");
    monthLabs(4,month) = strcat(monthVars(month), " (nMitch = ", num2str(monthNsMT(2,month)), ", nAllie = ", num2str(monthNsA(month)), ", nDana = ", num2str(monthNsB(4,month)), ")");
end

figure(1)
idx = contains(monthTbl.Properties.RowNames, "RLM-Leo");
s = spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabs(1,:)), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', [1 0 0; 0 1 0; 1 0 1], 'FillOption', 'on', 'FillTransparency', .3);
    title("RLM Leonardo");

figure(2)
idx = contains(monthTbl.Properties.RowNames, "RLM-Anom");
s = spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabs(2,:)), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', [1 0 1], 'FillOption', 'on', 'FillTransparency', .3);
    title("RLM Anomaloscope");

figure(3)
idx = contains(monthTbl.Properties.RowNames, "HFP-Leo");
s = spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabs(3,:)), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', [1 0 0; 1 0 1], 'FillOption', 'on', 'FillTransparency', .3);
    title("HFP Leonardo");

figure(4)
idx = contains(monthTbl.Properties.RowNames, "HFP-Uno");
s = spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabs(4,:)), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', [0 1 0; 0 0 1; 1 0 1], 'FillOption', 'on', 'FillTransparency', .3);
    title("HFP Uno");
