% clear console
clc;

% LOAD DATA
% allie's hfp data
allieDataHFP = load("data-A.mat");
allieDataHFP = allieDataHFP.hfpTable;

% dana's data
danaData = readtable("data-B.xlsx", "Sheet", "Matlab_Data");

% josh's data
joshData = readtable("data-DJ.xlsx", "VariableNamingRule","preserve");

% mitch's rlm data
mitchDataRLM = load("dataRLM-MT.mat","ParticipantMatchesRLM");
mitchDataRLM = mitchDataRLM.ParticipantMatchesRLM;

% mitches hfp data
mitchDataHFP_files=dir(fullfile('dataHFP-MT','*.mat'));
for file = 1:length(mitchDataHFP_files)
    fileName = mitchDataHFP_files(file).name;
    currentFile = load(strcat(pwd, '\dataHFP-MT\', fileName));
    currentFile = currentFile.hfpData;
    currentFile = convertvars(currentFile, "trialID", 'string');
    currentFile.trialID = extractBefore(currentFile.trialID, "_");
    if file == 1, mitchDataHFP = currentFile;
    else, mitchDataHFP = [mitchDataHFP; currentFile]; %#ok<AGROW>
    end
end

% participant id linkage data
ptptIDData = readtable("Ptpt_ID_Links.xlsx", 'Sheet', "Merged");

%%
% create empty array to store ptpt IDs of relevant ptpts
compTbl = string.empty(0,4);

% for each row of ptpts in the linkage data...
for r = 1:height(ptptIDData)
    % allie's ptpt ID
    aID = string(ptptIDData.PtptIDAllie(r));
    % dana's ptpt ID
    dID = string(ptptIDData.PtptIDDana(r));
    % josh's ptpt ID
    jID = string(ptptIDData.PtptIDJosh(r));
    % mitch's ptpt ID
    mID = string(ptptIDData.PtptIDMitch(r));

    % if the ptpt has a mitch id and at least 1 other id...
    if ~strcmp(mID, "") && (~strcmp(aID, "") || ~strcmp(dID, "") || ~strcmp(jID, ""))
       % add id data to comparison data 
       compTbl = [compTbl; [dID jID mID aID]]; %#ok<AGROW>
    end
end

%%
rlmTbl = NaN(height(compTbl), (15+5+5));
for ptpt = 1:height(compTbl)
    try
        rlmTbl(ptpt, 1:15) = reshape(table2array(danaData(strcmp(string(danaData.PPcode), compTbl(ptpt,1)),...
            startsWith(danaData.Properties.VariableNames, "RLM_Lambda"))), [1 15]);
    catch
    end
    try
        rlmTbl(ptpt, 16:20) = table2array(joshData(strcmp(string(joshData.Code), compTbl(ptpt,2)) & ~strcmp(string(joshData.Code), "") & strcmp(joshData.("Match Type"), "Best"),...
            "RLM_Lambda"));
    catch
    end
    rlmTbl(ptpt, 21:25) = table2array(mitchDataRLM(strcmp(string(mitchDataRLM.ParticipantCode), compTbl(ptpt,3)) & strcmp(mitchDataRLM.MatchType, "Best"),... 
        "Lambda"));
end

keepRows = nan(height(rlmTbl), 1);
for ptpt = 1:height(rlmTbl)
    if isnan(rlmTbl(ptpt, 1)) && isnan(rlmTbl(ptpt, 16))
        keepRows(ptpt) = 0;
    else
        keepRows(ptpt) = 1;
    end
end
keepRows = logical(keepRows);

compTblRLM = compTbl(keepRows,:);
rlmTbl = rlmTbl(keepRows,:);

%%
yAxis = [min(rlmTbl, [], "all"), max(rlmTbl, [], "all")];

sessionColours = ['k', 'r', 'm', 'g', 'b'];

meanList = nan(ptpt, 5);
seList = NaN(ptpt, 5);

figure(1);
t = tiledlayout(2, height(rlmTbl));
title(t, "RLM");
for ptpt = 1:height(rlmTbl)
    for dataSet = 1:(width(rlmTbl)/5)
        c1 = (dataSet-1) * 5 + 1;
        yData = rlmTbl(ptpt, c1:c1+4);
        meanList(ptpt,dataSet) = mean(yData);
        seList(ptpt,dataSet) = std(yData) ./ sqrt(5);

        % nexttile(1+height(fullTbl), [1 height(fullTbl)]);
        % hold on
        % plot(1:5, fullTbl(ptpt, c1:c1+4), "Color", ptptColours(ptpt));
        % ylim(yAxis)
        % hold off

        nexttile(ptpt+height(rlmTbl));
        hold on
        plot(1:5, repmat(meanList(ptpt,dataSet),[1 5]),...
            "Color", sessionColours(dataSet), "LineWidth", 3, "LineStyle","-");
        plot(1:5, repmat(meanList(ptpt,dataSet),[1 5]) - repmat(seList(ptpt,dataSet),[1 5]),...
            "Color", sessionColours(dataSet), "LineWidth", .5, "LineStyle","-.");
        plot(1:5, repmat(meanList(ptpt,dataSet),[1 5]) + repmat(seList(ptpt,dataSet),[1 5]),...
            "Color", sessionColours(dataSet), "LineWidth", .5, "LineStyle","--");
        xlim([1,5])
        ylim(yAxis)
        hold off

        nexttile(ptpt);
        hold on
        plot(1:5, yData, "Color", sessionColours(dataSet), "LineWidth", 2, "Marker", 'o');
        xlim([1,5])
        ylim(yAxis)
        title(strcat(compTblRLM(ptpt,:)));
        hold off
    end
end

lgd = legend('Dana_1', 'Dana_2', 'Dana_3', 'Josh', 'Mitch');
lgd.Location = 'eastoutside';

%%
compTblHFP = compTbl(:,[1,3,4]);

hfpTbl = nan(height(compTblHFP),21);

for ptpt = 1:height(compTblHFP)
    try
    hfpTbl(ptpt, 1:15) = reshape(table2array(danaData(strcmp(string(danaData.PPcode), compTblHFP(ptpt,1)),... 
        startsWith(danaData.Properties.VariableNames, "HFP_Uno_Red") & ~endsWith(danaData.Properties.VariableNames, "Mean"))), [1 15]);
    catch
    end
    hfpTbl(ptpt, 16:20) = table2array(mitchDataHFP(strcmp(mitchDataHFP.trialID, compTblHFP(ptpt,2)),... 
        "meanTestAmpSetting"))';
    try
    hfpTbl(ptpt, 21) = table2array(allieDataHFP(strcmp(string(allieDataHFP.ptptID), compTblHFP(ptpt,3)),...
        "meanTestAmp"));
    catch
    end
end

%%
yAxis = [min(hfpTbl, [], "all"), max(hfpTbl, [], "all")];

sessionColours = ['k', 'r', 'm', 'b'];

meanList = NaN(ptpt, 4);
seList = NaN(ptpt, 4);

figure(2);
t = tiledlayout(2, height(hfpTbl));
title(t, "HFP");
for ptpt = 1:height(hfpTbl)
    for dataSet = 1:(width(hfpTbl)/5)
        c1 = (dataSet-1) * 5 + 1;
        yData = hfpTbl(ptpt, c1:c1+4);
        meanList(ptpt,dataSet) = mean(yData);
        seList(ptpt,dataSet) = std(yData) ./ sqrt(5);

        nexttile(ptpt+height(hfpTbl));
        hold on
        plot(1:5, repmat(meanList(ptpt,dataSet),[1 5]),...
            "Color", sessionColours(dataSet), "LineWidth", 3, "LineStyle","-");
        plot(1:5, repmat(meanList(ptpt,dataSet),[1 5]) - repmat(seList(ptpt,dataSet),[1 5]),...
            "Color", sessionColours(dataSet), "LineWidth", .5, "LineStyle","-.");
        plot(1:5, repmat(meanList(ptpt,dataSet),[1 5]) + repmat(seList(ptpt,dataSet),[1 5]),...
            "Color", sessionColours(dataSet), "LineWidth", .5, "LineStyle","--");
        xlim([1,5])
        ylim(yAxis)
        hold off
        
        nexttile(ptpt);
        hold on
        plot(1:5, yData, "Color", sessionColours(dataSet), "LineWidth", 2, "Marker", 'o');
        xlim([1,5])
        ylim(yAxis)
        title(strcat(compTblHFP(ptpt,:)));
        hold off
    end
end

lgd = legend('Dana_1', 'Dana_2', 'Dana_3', 'Mitch');
lgd.Location = 'eastoutside';

