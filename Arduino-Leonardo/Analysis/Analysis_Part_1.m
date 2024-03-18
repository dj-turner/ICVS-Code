clc; clear; close all;

fig = 0;

user = getenv('USERNAME');

d = dir('*.xlsx');

tbl = readtable(d.name, "Sheet", "Matlab_Data");

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
                s.(indexTbl(pair,device)).mean(ptpt) = table2array(mean(ptptTbl(:,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device))), "all", "omitmissing"));
                s.(indexTbl(pair,device)).sMean(ptpt,:) = table2array(mean(ptptTbl(:,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device))), 1, "omitmissing"));
                s.(indexTbl(pair,device)).sd(ptpt) = std(table2array(ptptTbl(:,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device)))), 0, "all", "omitmissing");
                s.(indexTbl(pair,device)).sSd(ptpt,:) = std(table2array(ptptTbl(:,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device)))), 0, 1, "omitmissing");

            end
        end
        sessionNum = width(s.(indexTbl(pair,device)).sMean);
        fig = fig + 1;
        figure(fig);

        t = tiledlayout(1,sessionNum-1);
        title(t, strcat(indexTbl(pair,device)), 'Interpreter','none');
        x = s.(indexTbl(pair,device)).sMean(:,1);
        for ySession = 2:sessionNum
            y = s.(indexTbl(pair,device)).sMean(:,ySession);
            nexttile
            DrawGraph(x,y,strcat("Sessions 1 & ", num2str(ySession)),"Session 1", strcat("Session ", num2str(ySession)));
        end
    end

    fig = fig + 1;
    figure(fig);

    t = tiledlayout(1, sessionNum);
    for session = 1:sessionNum
        x = s.(indexTbl(pair,1)).sMean(:,session);
        y = s.(indexTbl(pair,2)).sMean(:,session);   
        
        gTit = strcat(extractAfter(indexTbl(pair,1),"_"), " & ", extractAfter(indexTbl(pair,2),"_"), ", session ", num2str(session));
        nexttile
        DrawGraph(x,y,gTit,"Leonardo Device","Lab-Based Device");
    end
end

function DrawGraph(xVar,yVar,gTitle,xLab,yLab)

    [r, p] = corr(xVar, yVar, 'rows', 'pairwise');
    scatter(xVar, yVar, 'Marker', 'x', 'MarkerEdgeColor', 'b', 'LineWidth', 1)
    
    % hold on
    % errorbar(x, y, ySD, ySD, xSD, xSD, '.', 'Color', 'k');
    % hold off

    line = lsline;
    line.Color = 'r';
    line.LineWidth = 1;

    xlabel(xLab);
    ylabel(yLab);
    text(max(xVar), max(yVar), strjoin(["R = ", num2str(r), ",", newline, "P = ", num2str(p)],''));
    text(xVar+.001*max(xVar), yVar+.001*max(yVar), string(1:length(xVar)));
    title(gTitle, 'Interpreter','none');

end
