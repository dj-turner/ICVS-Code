clear; close all; clc;
%%
% RLM
tbl = readtable("DanaCheck.xlsx", 'Sheet', 'RLMData');

bestTbl = tbl(strcmp(tbl.MatchType, "Best"), ~strcmp(tbl.Properties.VariableNames, "MatchType"));

sessionNum = max(bestTbl.Session);

summaryArray = NaN(sessionNum, width(bestTbl));

for session = 1:sessionNum
    sessionTbl = bestTbl(bestTbl.Session == session, :);
    meanSessionTbl = mean(table2array(sessionTbl), 1);
    summaryArray(session,:) = meanSessionTbl;
end

summaryTbl = array2table(summaryArray, "VariableNames", bestTbl.Properties.VariableNames);

clearvars("dates");
% date
for session = 1:sessionNum
    date = datetime(strcat(string(summaryTbl.Day(session)), "/",... 
        string(summaryTbl.Month(session)), "/",... 
        string(summaryTbl.Year(session))),... 
        'InputFormat', 'dd/MM/uuuu', 'Format', 'dd/MM/uuuu');
    dates(session,1) = date;
end


f = figure(1);
% graphs
t = tiledlayout(2, 2);

nexttile
plot(summaryTbl.Session, summaryTbl.Lambda, 'Marker', 'x', 'Color', 'r', 'MarkerEdgeColor', 'k');
title("Lambda by Session");
nexttile
plot(summaryTbl.Session, summaryTbl.Yellow, 'Marker', 'x', 'Color', 'b', 'MarkerEdgeColor', 'k');
title("Yellow by Session");

nexttile
plot(dates, summaryTbl.Lambda, 'Marker', 'x', 'Color', 'r', 'MarkerEdgeColor', 'k');
title("Lambda by Date");
nexttile
plot(dates, summaryTbl.Yellow, 'Marker', 'x', 'Color', 'b', 'MarkerEdgeColor', 'k');
title("Yellow by Date");

f.WindowState = 'maximized';
exportgraphics(t, strcat(pwd, '\DanaOverTime_RLM.jpg'));

%%
% HFP
tbl = readtable("DanaCheck.xlsx", 'Sheet', 'HFPData');

bestTbl = tbl(strcmp(tbl.MatchType, "Best"), ~strcmp(tbl.Properties.VariableNames, "MatchType"));

sessionNum = max(bestTbl.Session);

summaryArray = NaN(sessionNum, width(bestTbl));

for session = 1:sessionNum
    sessionTbl = bestTbl(bestTbl.Session == session, :);
    meanSessionTbl = mean(table2array(sessionTbl), 1);
    summaryArray(session,:) = meanSessionTbl;
end

summaryTbl = array2table(summaryArray, "VariableNames", bestTbl.Properties.VariableNames);

clearvars("dates");
% date
for session = 1:sessionNum
    date = datetime(strcat(string(summaryTbl.Day(session)), "/",... 
        string(summaryTbl.Month(session)), "/",... 
        string(summaryTbl.Year(session))),... 
        'InputFormat', 'dd/MM/uuuu', 'Format', 'dd/MM/uuuu');
    dates(session,1) = date;
end

f = figure(2);
% graphs
t = tiledlayout(1, 2);

nexttile
plot(summaryTbl.Session, summaryTbl.RatioRG, 'Marker', 'x', 'Color', 'r', 'MarkerEdgeColor', 'k');
title("RG Ratio by Session");

nexttile
plot(dates, summaryTbl.RatioRG, 'Marker', 'x', 'Color', 'r', 'MarkerEdgeColor', 'k');
title("RG Ratio by Date");

f.WindowState = 'maximized';
exportgraphics(t, strcat(pwd, '\DanaOverTime_HFP.jpg'));