clc; clear; close all;

warning('off','MATLAB:table:ModifiedAndSavedVarnames');

data = readtable("data\data-DJ.xlsx");

data.RLM_Yellow = data.RLM_Yellow ./ 255;

startRows = find(~isnan(data.PP));
endRows = [startRows(2:end)-1; height(data)];

ptptNum = length(startRows);

lambdas = nan(ptptNum,1);
yellows = nan(ptptNum,1);
scoresLambda = nan(ptptNum,1);
scoresYellow = nan(ptptNum,1);
experimenter = repmat("",[ptptNum 1]);

for ptpt = 1:ptptNum
    %selecting rows
    ptptData = data(startRows(ptpt):endRows(ptpt),:);

    %experimenter
    ptptID = char(ptptData.Code(1));
    experimenter(ptpt) = ptptID(1);

    %check setup
    trialRows = find(strcmp(string(ptptData.MatchType),"Best"));
    trialNum = numel(trialRows);
    ptptScoresLambda = nan(1,trialNum);
    ptptScoresYellow = nan(1,trialNum);

    for trial = 1:trialNum
        %lambda check
        row = trialRows(trial);

        dirs = nan(1,2);
        dirs(1) = sign(ptptData.RLM_Lambda(row) - ptptData.RLM_Lambda(row+1));
        dirs(2) = sign(ptptData.RLM_Lambda(row) - ptptData.RLM_Lambda(row+2));
        idx = min(dirs) == -1 && max(dirs) == 1;
        ptptScoresLambda(trial) = idx;

        %yellow check
        idx = ptptData.RLM_Yellow(row) == ptptData.RLM_Yellow(row+1) && ptptData.RLM_Yellow(row) == ptptData.RLM_Yellow(row+2);
        ptptScoresYellow(trial) = idx;
    end

    scoresLambda(ptpt) = (sum(ptptScoresLambda) / trialNum) * 100;
    scoresYellow(ptpt) = (sum(ptptScoresYellow) / trialNum) * 100;

    % lambda and yellow mean
    lambdas(ptpt) = mean(ptptData.RLM_Lambda(trialRows),"omitmissing");
    yellows(ptpt) = mean(ptptData.RLM_Yellow(trialRows),"omitmissing");
end

idxDana = strcmp(experimenter,"D");
danaScoresLambda = scoresLambda(idxDana);
danaScoresLambda = danaScoresLambda(~isnan(danaScoresLambda));
danaScoresYellow = scoresYellow(idxDana);
danaScoresYellow = danaScoresYellow(~isnan(danaScoresYellow));

idxJosh = strcmp(experimenter,"J");
joshScoresLambda = scoresLambda(idxJosh);
joshScoresLambda = joshScoresLambda(~isnan(joshScoresLambda));
joshScoresYellow = scoresYellow(idxJosh);
joshScoresYellow = joshScoresYellow(~isnan(joshScoresYellow));

[hLambda,pLambda,ciLambda,statsLambda] = ttest2(danaScoresLambda,joshScoresLambda);
[hYellow,pYellow,ciYellow,statsYellow] = ttest2(danaScoresYellow,joshScoresYellow);

%%
disp("Comparing Dana and Josh's participants for Correct Lambda Settings..."...
    + newline + "Means: Dana = " + round(mean(danaScoresLambda)) + "%, Josh = " + round(mean(joshScoresLambda)) + "%"...
    + newline + "T-test: T = " + round(statsLambda.tstat,2) + ", P = " + round(pLambda,3) + ", Sig. Diff = " + logical(hLambda)...
    + newline...
    + newline + "Comparing Dana and Josh's participants for Correct Yellow Settings..."...
    + newline + "Means: Dana = " + round(mean(danaScoresYellow)) + "%, Josh = " + round(mean(joshScoresYellow)) + "%"...
    + newline + "T-test: T = " + round(statsYellow.tstat,2) + ", P = " + round(pYellow,3) + ", Sig. Diff = " + logical(hYellow)...
    + newline);


%%
[hL,pL,ciL,statsL] = ttest2(lambdas(idxDana),lambdas(idxJosh));
idxOutlier = lambdas < .4;
[hL2,pL2,ciL2,statsL2] = ttest2(lambdas(idxDana & ~idxOutlier),lambdas(idxJosh & ~idxOutlier));
[hY,pY,ciY,statsY] = ttest2(yellows(idxDana),yellows(idxJosh));

disp("Comparing Dana and Josh's participants for Mean Lambda Settings..."...
    + newline + "Means: Dana = " + round(mean(lambdas(idxDana),"omitmissing"),2) + ", Josh = " + round(mean(lambdas(idxJosh),"omitmissing"),2)...
    + newline + "T-test: T = " + round(statsL.tstat,2) + ", P = " + round(pL,3) + ", Sig. Diff = " + logical(hL)...
    + newline...
    + newline + "Excluding the outlier..."...
    + newline + "Means: Dana = " + round(mean(lambdas(idxDana & ~idxOutlier),"omitmissing"),2) + ", Josh = " + round(mean(lambdas(idxJosh & ~idxOutlier),"omitmissing"),2)...
    + newline + "T-test: T = " + round(statsL2.tstat,2) + ", P = " + round(pL2,3) + ", Sig. Diff = " + logical(hL2)...
    + newline...
    + newline + "Comparing Dana and Josh's participants for Mean Yellow Settings..."...
    + newline + "Means: Dana = " + round(mean(yellows(idxDana),"omitmissing"),2) + ", Josh = " + round(mean(yellows(idxJosh),"omitmissing"),2)...
    + newline + "T-test: T = " + round(statsY.tstat,2) + ", P = " + round(pY,3) + ", Sig. Diff = " + logical(hY));

h = NewFigWindow;
tiledlayout(1,2)
nexttile
hold on
histogram(lambdas(idxDana & ~idxOutlier),'BinWidth',.01,'FaceColor','m','EdgeColor','w','FaceAlpha',.5);
histogram(lambdas(idxJosh & ~idxOutlier),'BinWidth',.01,'FaceColor','c','EdgeColor','w','FaceAlpha',.3);
hold off
title("Lambdas");
NiceGraphs(h);
nexttile
hold on
histogram(yellows(idxDana),'BinWidth',.01,'FaceColor','m','EdgeColor','w','FaceAlpha',.5);
histogram(yellows(idxJosh),'BinWidth',.01,'FaceColor','c','EdgeColor','w','FaceAlpha',.3);
hold off
title("Yellows");
l = legend("Dana's Data", "Josh's Data");
NiceGraphs(h,l);
l.Location = "northeast";

%
cols1 = repmat('m',[ptptNum 1]);
cols1(idxJosh) = 'c';

cols2 = repmat('r',[ptptNum 1]);
cols2(idxJosh) = 'b';


%%
alpha = .3;

lambdaData = nan(ptptNum,5);
f = NewFigWindow;
tiledlayout(1,2);
nexttile
hold on 
for ptpt = 1:ptptNum
    ptptData = data(startRows(ptpt):endRows(ptpt),:);
    idx = find(strcmp(string(ptptData.MatchType),"Best"));
    
    x = 1:numel(idx);
    yLambda = ptptData.RLM_Lambda(idx);
    p = plot(x,yLambda,'Marker','x','MarkerEdgeColor',cols2(ptpt),'LineWidth',3,'MarkerSize',5,'Color',cols1(ptpt));
    if ~isempty(p)
        p.Color = [p.Color, alpha];
    end
    if ~isempty(yLambda), lambdaData(ptpt,:) = yLambda'; end
end
stdLambda = std(lambdaData,1,"omitmissing");
nLambda = sum(~isnan(lambdaData),1);
steLambda = stdLambda ./ sqrt(nLambda);
errorbar(x,mean(lambdaData,1,"omitmissing"),...
    steLambda,steLambda,...
    'Color','g','Marker','x','MarkeredgeColor','w','LineWidth',5,'MarkerSize',10);
hold off
xlim([1 5]);
ylim([0 1]);
xlabel("Trial");
ylabel("Lambda Value");
title("Lambdas");

NiceGraphs
grid on

yellowData = nan(ptptNum,5);
validPtptIdx = true([ptptNum,1]);
nexttile
hold on
for ptpt = 1:ptptNum
    ptptData = data(startRows(ptpt):endRows(ptpt),:);
    idx = find(strcmp(string(ptptData.MatchType),"Best"));
    
    x = 1:numel(idx);
    yYellow = ptptData.RLM_Yellow(idx);
    p = plot(x,yYellow,'Color',cols1(ptpt),'Marker','x','MarkerEdgeColor',cols2(ptpt),'LineWidth',3,'MarkerSize',5);
    if ~isempty(p)
        p.Color = [p.Color, alpha];
    end
    if isempty(yYellow)
        validPtptIdx(ptpt) = false;
    else
        yellowData(ptpt,:) = yYellow'; 
    end
end
stdYellow = std(yellowData,1,"omitmissing");
nYellow = sum(~isnan(yellowData),1);
steYellow = stdYellow ./ sqrt(nYellow);
errorbar(x,mean(yellowData,1,"omitmissing"),...
    steYellow,steYellow,...
    'Color','g','Marker','x','MarkeredgeColor','w','LineWidth',5,'MarkerSize',10);
hold off
xlim([1 5]);
ylim([0 1]);
xlabel("Trial");
ylabel("Yellow Value");
title("Yellows");

%legend
plottedYellowData = yellowData(validPtptIdx,:);
plottedExperimenter = experimenter(validPtptIdx,:);

danaPtpt1 = find(strcmp(plottedExperimenter,"D")); danaPtpt1 = danaPtpt1(1);
joshPtpt1 = find(strcmp(plottedExperimenter,"J")); joshPtpt1 = joshPtpt1(1);

lgdLabs = repmat("",[1 height(plottedYellowData)+1]);
lgdLabs(danaPtpt1) = "Dana's participants";
lgdLabs(joshPtpt1) = "Josh's participants";
lgdLabs(end) = "Trial Means (error bar = 1 std. err.)";
lambdaDataR = legend(lgdLabs);

NiceGraphs(f,lambdaDataR);
lambdaDataR.Location = 'northoutside';
grid on

%% anova
t = repmat(1:width(lambdaData), [height(lambdaData) 1]);
t = reshape(t, [numel(t) 1]);
lambdaDataR = reshape(lambdaData, [numel(lambdaData) 1]);
yellowDataR = reshape(yellowData, [numel(yellowData) 1]);

[pLambda,tLambda,statsLambda] = anova1(lambdaDataR,t);
[cLambda,mLambda,hLambda,gLambda] = multcompare(statsLambda);
lambdaTbl = array2table(mLambda,"RowNames",gLambda, ...
    "VariableNames",["Mean","Standard Error"]);
disp(lambdaTbl);

[pYellow,tYellow,statsYellow] = anova1(yellowDataR,t);
[cYellow,mYellow,hYellow,gYellow] = multcompare(statsYellow);
yellowTbl = array2table(mYellow,"RowNames",gYellow, ...
    "VariableNames",["Mean","Standard Error"]);
disp(yellowTbl);




