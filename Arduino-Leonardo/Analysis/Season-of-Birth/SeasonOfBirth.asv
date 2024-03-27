% clear up
clc; clear; close all;

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

%%
monthMeansDJ = NaN(2, 12);
monthNsDJ = NaN(2,12);
for month = 1:12
    monthDataDJ = djData(djData.("Birth Month") == month, endsWith(djData.Properties.VariableNames, "RG"));
    monthNsDJ(1,month) = height(monthDataDJ(~isnan(table2array(monthDataDJ(:,1))),:));
    monthNsDJ(2,month) = height(monthDataDJ(~isnan(table2array(monthDataDJ(:,2))),:));
    monthMeansDJ(:, month) = table2array(mean(monthDataDJ, "omitmissing"))';
end

%%

% average rows
rlmVars = ["Red", "Green", "Yellow"];

% mitch's rlm data
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
mitchDataResultsRLM.RG = mitchDataResultsRLM.Red ./ mitchDataResultsRLM.Green;

monthMeansMT = NaN(1,12);
monthNsMT = NaN(1, 12);
for month = 1:12
    monthDataMT = mitchDataResultsRLM(mitchDataResultsRLM.Month == month, "RG");
    monthDataMT = monthDataMT(~isnan(table2array(monthDataMT)),:);
    monthNsMT(month) = height(monthDataMT);
    monthMeansMT(month) = table2array(mean(monthDataMT));
end


monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

monthTbl = array2table([monthMeansDJ; monthMeansMT], "RowNames", ["RLM-DJ", "HFP-DJ", "RLM-MT"], "VariableNames", monthVars);

monthLabsRLM = strings(1,12);
monthLabsHFP = strings(1,12);
for month = 1:12
    monthLabsRLM(month) = strcat(monthVars(month), " (nJosh = ", num2str(monthNsDJ(1,month)), ", nMitch = ", num2str(monthNsMT(month)), ")");
    monthLabsHFP(month) = strcat(monthVars(month), " (nJosh = ", num2str(monthNsDJ(2,month)), ")");
end

figure(1)
idx = contains(monthTbl.Properties.RowNames, "RLM");
s = spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabsRLM), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', [1 0 0; 0 1 0], 'FillOption', 'on', 'FillTransparency', .3);
    title("RLM");

figure(2)
idx = contains(monthTbl.Properties.RowNames, "HFP");
s = spider_plot(table2array(monthTbl(idx,:)), 'AxesLabels', cellstr(monthLabsHFP), 'AxesLimits',...
    [repmat(table2array(min(monthTbl(idx,:), [], "all")), [1 12]); repmat(table2array(max(monthTbl(idx,:), [], "all")), [1 12])],...
    'Color', [1 0 0], 'FillOption', 'on', 'FillTransparency', .3);
    title("HFP");

% % mitches hfp data
% mitchDataHFP_files=dir(fullfile('dataHFP-MT','*.mat'));
% for file = 1:length(mitchDataHFP_files)
%     fileName = mitchDataHFP_files(file).name;
%     currentFile = load(strcat(pwd, '\dataHFP-MT\', fileName));
%     currentFile = currentFile.hfpData;
%     currentFile = convertvars(currentFile, "trialID", 'string');
%     currentFile.trialID = extractBefore(currentFile.trialID, "_");
%     if file == 1, mitchDataHFP = currentFile;
%     else, mitchDataHFP = [mitchDataHFP; currentFile]; %#ok<AGROW>
%     end
% end
% 
% mitchDataHFP.trialID(6:10) = "MAB";

