clc; clear; close all;

fig = 0;

user = getenv('USERNAME');

d = dir('*.xlsx');

tbl = readtable(d.name, "Sheet", "Matlab_Data");
%%
indexTbl = ["RLM_Lambda", "RLM_MixLight";...
    "RLM_Yellow", "RLM_RefLight";...
    "HFP_Leo_RG", "HFP_Uno_Red"];

s = struct;
r = NaN(height(indexTbl),1);
p = r;

for pair = 1:height(indexTbl)
    for device = 1:width(indexTbl)
        s.(indexTbl(pair,device)).mean = NaN(max(tbl.PPno),1);
        s.(indexTbl(pair,device)).sMean = NaN(max(tbl.PPno),3);
        s.(indexTbl(pair,device)).sd = NaN(max(tbl.PPno),1);
        s.(indexTbl(pair,device)).sSd = NaN(max(tbl.PPno),3);
        for ptpt = 1:max(tbl.PPno)
            ptptTbl = tbl(tbl.PPno == ptpt & tbl.Match_Type == 1, :);
            if ptptTbl.HRR_Pass(1) == 1 %&& (ptpt ~= 8 || pair ~= 3)
                s.(indexTbl(pair,device)).mean(ptpt) = table2array(mean(ptptTbl(2:end,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device))), "all", "omitmissing"));
                s.(indexTbl(pair,device)).sMean(ptpt,:) = table2array(mean(ptptTbl(2:end,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device))), 1, "omitmissing"));
                s.(indexTbl(pair,device)).sd(ptpt) = std(table2array(ptptTbl(2:end,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device)))), 0, "all", "omitmissing");
                s.(indexTbl(pair,device)).sSd(ptpt,:) = std(table2array(ptptTbl(2:end,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device)))), 0, 1, "omitmissing");

            end
        end
        sessionNum = width(s.(indexTbl(pair,device)).sMean);
        fig = fig + 1;
        figure(fig);

        t = tiledlayout(1,sessionNum-1);
        title(t, strcat(indexTbl(pair,device)), 'Interpreter','none');

        for ySession = 2:sessionNum
            x = s.(indexTbl(pair,device)).sMean(:,1);
            y = s.(indexTbl(pair,device)).sMean(:,ySession);
            l = 1:height(x);

            [xRank, yRank, lRank] = ContinuousToRanked(x,y,l);

            nexttile
            DrawGraph(xRank,yRank,strcat("Sessions 1 & ", num2str(ySession)),"Session 1", strcat("Session ", num2str(ySession)),lRank);
        end
    end

    fig = fig + 1;
    figure(fig);

    t = tiledlayout(1, sessionNum);
    for session = 1:sessionNum
        x = s.(indexTbl(pair,1)).sMean(:,session);
        y = s.(indexTbl(pair,2)).sMean(:,session);
        l = 1:height(x);

        [xRank, yRank, lRank] = ContinuousToRanked(x,y,l);

        gTit = strcat(extractAfter(indexTbl(pair,1),"_"), " & ", extractAfter(indexTbl(pair,2),"_"), ", session ", num2str(session));
        nexttile
        DrawGraph(xRank,yRank,gTit,"Leonardo Device","Lab-Based Device",lRank);
    end
end

function DrawGraph(xVar,yVar,gTitle,xLab,yLab,scatterLabels)

% if isequal(sort(xVar)', 1:length(xVar)) || isequal(sort(yVar)', 1:length(yVar))
%     corrType = 'Spearman';
%     repType = "Rho";
% else
%     corrType = 'Pearson';
%     repType = "R";
% end

corrType = 'Pearson';
repType = "R";

[c, p] = corr(xVar, yVar, 'rows', 'pairwise', 'type', corrType);
scatter(xVar, yVar, 'Marker', 'x', 'MarkerEdgeColor', 'b', 'LineWidth', 1)

% hold on
% errorbar(x, y, ySD, ySD, xSD, xSD, '.', 'Color', 'k');
% hold off

line = lsline;
line.Color = 'r';
line.LineWidth = 1;

xlabel(xLab);
ylabel(yLab);
text(max(xVar), max(yVar), strjoin([corrType, "'s ", repType, " = ", num2str(round(c,2)), ",", newline, "P = ", num2str(round(p,3))],''));
text(xVar+.005*max(xVar), yVar+.005*max(yVar), scatterLabels);
title(gTitle, 'Interpreter','none');

end

function [xRanked,yRanked,lRanked] = ContinuousToRanked(xCont,yCont,lCont)

idx = ~isnan(xCont) & ~isnan(yCont);
xCont = xCont(idx); yCont = yCont(idx); lRanked = lCont(idx);

lRanked = string(lRanked');

[~,pX] = sort(xCont,'descend');
xRanked = 1:length(xCont);
xRanked(pX) = xRanked;
xRanked = xRanked';

[~,pY] = sort(yCont,'descend');
yRanked = 1:length(yCont);
yRanked(pY) = yRanked;
yRanked = yRanked';

end


