clc; clear; close all;

%AddAllToPath;
addpath(genpath(pwd));

data = readtable("data\data-B.xlsx",Sheet='Matlab_Data');

tasks = ["RLM_Lambda", "RLM_MixLight", "HFP_Leo_RG", "HFP_Uno_Red", "RLM_Yellow", "RLM_RefLight"];

ptptNum = max(data.PPno);

%%
vars = contains(data.Properties.VariableNames,tasks) & ~contains(data.Properties.VariableNames,"Mean");
vars = string(data.Properties.VariableNames(vars));

unoVars = contains(data.Properties.VariableNames,"HFP_Uno_Red");
data(:,unoVars) = data(:,unoVars) ./ 1024;

yellowVars = contains(data.Properties.VariableNames,"RLM_Yellow");
data(:,yellowVars) = data(:,yellowVars) ./ 255;

sessionData = NaN(ptptNum,length(vars));
sessionData = array2table(sessionData,"VariableNames",vars,"RowNames",string(1:ptptNum));

for ptpt = 1:ptptNum
    idx = data.PPno == ptpt & data.Match_Type == 1;
    ptptData = data(idx,:);

    if ~ptptData.HRR_Pass(1), continue; end
    if height(ptptData) ~= 5, disp("Error for ptpt "+ptpt); continue; end

    sessionData(ptpt,:) = mean(ptptData(2:end,vars));
end

idx = str2double(string(sessionData.Properties.RowNames)) == 8;
hfpLeoVars = startsWith(string(sessionData.Properties.VariableNames),"HFP_Leo_RG");
sessionData(idx,hfpLeoVars) = array2table(NaN(sum(idx),sum(hfpLeoVars)));

%% Session correlations
corrs = struct;
anovas = struct;

sessionFig = NewFigWindow;
chart = tiledlayout(3, length(tasks));

barChart = NewFigWindow;
bChart = tiledlayout(2,3);
warning('off','stats:boxplot:BadObjectType');

for t = 1:length(tasks), task = tasks(t);
    corrs.(task) = NaN(3,3,3);
    for s1 = 1:3
        for s2 = 1:3
            var1 = task + "_" + s1;
            var2 = task + "_" + s2;

            [r,p] = corr(sessionData.(var1), sessionData.(var2),"Rows","pairwise");

            nIdx = ~isnan(sessionData.(var1)) & ~isnan(sessionData.(var2));
            n = sum(nIdx);

            corrs.(task)(s1,s2,1) = n;
            corrs.(task)(s1,s2,2) = r;
            corrs.(task)(s1,s2,3) = p;

            if s1 < s2
                % graph
                figure(sessionFig)
                nexttile
                hold on
                x = sessionData.(var1);
                y = sessionData.(var2);
                scatter(x,y);
                plot(0:100, 0:100, 'Color', 'r', 'LineStyle', '-', 'LineWidth', .5, 'Marker', 'none');
                text(x(nIdx), y(nIdx), string(sessionData.Properties.RowNames(nIdx)))
                lsline;
                hold off
                xlim([min([x;y],[],'omitmissing'),max([x;y],[],'omitmissing')])
                ylim([min([x;y],[],'omitmissing'),max([x;y],[],'omitmissing')])
                xlabel(var1,Interpreter='none');
                ylabel(var2,Interpreter='none');
                title(task + ": sessions " + s1 + "&" + s2,Interpreter='none');
                subtitle("N = " + n + ", R = " + round(r,2) + ", P = " + round(p,3) + SigSymbol(p));
                grid on

                if rem(t,2) == 0
                    r1 = corrs.(tasks(t-1))(s1,s2,2);
                    r2 = corrs.(tasks(t))(s1,s2,2);
                    n1 = corrs.(tasks(t-1))(s1,s2,1);
                    n2 = corrs.(tasks(t))(s1,s2,1);
                    pVal = compare_correlation_coefficients(r1,r2,n1,n2);
                    disp("Tasks " + tasks(t-1) + " & " + tasks(t)...
                        + newline + "Sessions " + s1 + " & " + s2...
                        + newline + "P = " + pVal + SigSymbol(pVal)...
                        + newline);
                end
            end
        end
    end
    % bar chart
    figure(barChart)
    nexttile
    tVars = startsWith(sessionData.Properties.VariableNames, task);
    sessionTbl = table2array(sessionData(:,tVars));
    boxplot(sessionTbl);
    title(task, Interpreter = 'none');


    anovas.(task) = anova(sessionTbl);
end
warning('on','stats:boxplot:BadObjectType');

%% Device correlations
meanData = NaN(ptptNum,length(tasks));
meanData = array2table(meanData,"VariableNames",tasks,"RowNames",string(1:ptptNum));

for t = 1:length(tasks), task = tasks(t);
    idx = startsWith(vars,task); %& ~contains(vars, "2");
    taskData = sessionData(:,idx);
    meanData(:,t) = mean(taskData,2,'omitmissing');
end

deviceFig = NewFigWindow;
tiledlayout(1,width(meanData)/2);

for t1 = 1:2:length(tasks), t2 = t1+1;
    var1 = string(meanData.Properties.VariableNames(t1));
    var2 = string(meanData.Properties.VariableNames(t2));
    [r,p] = corr(meanData.(var1),meanData.(var2),'Rows','pairwise');

    nIdx = ~isnan(meanData.(var1)) & ~isnan(meanData.(var2));

    nexttile
    hold on
    scatter(meanData.(var1), meanData.(var2));
    text(meanData.(var1)(nIdx),meanData.(var2)(nIdx),string(meanData.Properties.RowNames(nIdx)))
    lsline;
    hold off
    xlabel(var1,Interpreter='none');
    ylabel(var2,Interpreter='none');
    title(var1 + " & " + var2,Interpreter='none');

    subtitle("N = " + sum(nIdx) + ", R = " + r + ", P = " + p + SigSymbol(p));
end

%%
vars = startsWith(data.Properties.VariableNames, "RLM_Yellow");
mus = nan(ptptNum,sum(vars)); 
sigmas = mus;
ranges = mus;
for ptpt = 1:ptptNum
    sData = table2array(data(data.PPno == ptpt,vars));
    mus(ptpt,:) = mean(sData,"omitmissing");
    sigmas(ptpt,:) = std(sData,"omitmissing");
    ranges(ptpt,:) = max(sData,[],"omitmissing") - min(sData,[],"omitmissing");
end

anova(sigmas)
anova(ranges)
    



