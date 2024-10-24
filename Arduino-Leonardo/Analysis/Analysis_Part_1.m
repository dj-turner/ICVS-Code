clc; clear; close all;

user = getenv('USERNAME');

d = dir('*.xlsx');

tbl = readtable(d.name, "Sheet", "Matlab_Data");

indexTbl = ["RLM_Lambda", "RLM_MixLight";... 
            "RLM_Yellow", "RLM_RefLight"]; %;... 
            %"HFP_Leo_RG", "HFP_Uno_Red"];

s = struct;
r = NaN(height(indexTbl),1);
p = r;

for pair = 1:height(indexTbl)
    for device = 1:width(indexTbl)
        s.(indexTbl(pair,device)).mean = NaN(max(tbl.PPno),1);
        s.(indexTbl(pair,device)).sd = NaN(max(tbl.PPno),1);
        for ptpt = 1:max(tbl.PPno)
            ptptTbl = tbl(tbl.PPno == ptpt & tbl.Match_Type == 1, :);
            if ptptTbl.HRR_Pass(1) == 1
                s.(indexTbl(pair,device)).mean(ptpt) = table2array(mean(ptptTbl(:,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device))), "all", "omitmissing"));
                s.(indexTbl(pair,device)).sd(ptpt) = std(table2array(ptptTbl(:,startsWith(ptptTbl.Properties.VariableNames, indexTbl(pair,device)))), 0, "all", "omitmissing");
            end
        end
    end

    x = s.(indexTbl(pair,1)).mean;
    y = s.(indexTbl(pair,2)).mean;
    xSD = s.(indexTbl(pair,1)).sd;
    ySD = s.(indexTbl(pair,2)).sd;

    [r(pair), p(pair)] = corr(x, y, 'rows', 'pairwise');
    
    figure(pair);
    scatter(x, y, 'Marker', 'x', 'MarkerEdgeColor', 'b', 'LineWidth', 1)
    
    % hold on
    % errorbar(x, y, ySD, ySD, xSD, xSD, '.', 'Color', 'k');
    % hold off

    line = lsline;
    line.Color = 'r';
    line.LineWidth = 1;

    xlabel("Raw Arduino Leonardo Value");
    ylabel("Raw Anomaloscope Value");
    text(max(x), max(y), strjoin(["R = ", num2str(r(pair)), ",", newline, "P = ", num2str(p(pair))],''));
    text(x+.001*max(x), y+.001*max(y), string(1:max(tbl.PPno)));
    title(extractAfter(indexTbl(pair,1),"_"));

end

