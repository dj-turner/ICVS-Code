clc; clear; close all;

AddAllToPath;

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
    idx = data.PPno==ptpt & data.Match_Type == 1;
    ptptData = data(idx,:);

    if ~ptptData.HRR_Pass(1), continue; end
    if height(ptptData) ~= 5, disp("Error for ptpt "+ptpt); continue; end

    ptptData = mean(ptptData(2:end,vars));

    sessionData(ptpt,:) = ptptData;

end

idx = str2double(string(sessionData.Properties.RowNames)) == 8;
hfpLeoVars = startsWith(string(sessionData.Properties.VariableNames),"HFP_Leo_RG");
sessionData(idx,hfpLeoVars) = array2table(NaN(sum(idx),sum(hfpLeoVars)));


%% Session correlations
corrs = struct;

sessionFig = NewFigWindow;
chart = tiledlayout(3, length(tasks));

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

            % graph
            if s1 < s2
                nexttile
                hold on
                scatter(sessionData.(var1), sessionData.(var2));
                text(sessionData.(var1)(nIdx),sessionData.(var2)(nIdx),string(sessionData.Properties.RowNames(nIdx)))
                lsline;
                hold off
                xlabel(var1,Interpreter='none');
                ylabel(var2,Interpreter='none');
                title(task + ": sessions " + s1 + "&" + s2,Interpreter='none');
                subtitle("R = " + round(r,2) + ", P = " + round(p,3) + ", N = " + n);
            end
        end
    end
end

%% Device correlations
meanData = NaN(ptptNum,length(tasks));
meanData = array2table(meanData,"VariableNames",tasks,"RowNames",string(1:ptptNum));

for t = 1:length(tasks), task = tasks(t);
    idx = startsWith(vars,task);
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
    n = sum(nIdx);

    nexttile
    hold on
    scatter(meanData.(var1), meanData.(var2));
    text(meanData.(var1)(nIdx),meanData.(var2)(nIdx),string(meanData.Properties.RowNames(nIdx)))
    lsline;
    hold off
    xlabel(var1,Interpreter='none');
    ylabel(var2,Interpreter='none');
    title(var1 + " & " + var2,Interpreter='none');
    subtitle("N = " + n + ", R = " + r + ", P = " + p);
end
