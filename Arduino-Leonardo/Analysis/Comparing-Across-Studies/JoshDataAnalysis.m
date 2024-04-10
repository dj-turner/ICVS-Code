tbl = readtable("data-DJ.xlsx", 'Sheet', 'Sheet1');

ptptNum = max(tbl.PP);
rowsPerPtpt = height(tbl) / ptptNum;

vars = ["Num", "Sex", "Year", "Month", "Ethnicity", "Plates", "Lambda", "RGratio"];

meanTbl = table.empty(0,8);
meanTbl.Properties.VariableNames = vars;

for ptpt = 1:ptptNum
    rowStart = (ptpt - 1) * rowsPerPtpt + 1;
    rowEnd = rowStart + rowsPerPtpt - 1;

    ptptTbl = tbl(rowStart:rowEnd,:);
    bestTbl = ptptTbl(strcmp(ptptTbl.MatchType, "Best"),:);
    if isempty(bestTbl), continue; end

    meanValueRLM = mean(bestTbl.RLM_Lambda, 'all');
    meanValueHFP = mean(bestTbl.HFP_RedValue ./ bestTbl.HFP_GreenValue, 'all');

    ptptRow = table(ptpt, table2array(bestTbl(1,"Sex")),... 
        table2array(bestTbl(1,"BirthYear")), table2array(bestTbl(1,"BirthMonth")),... 
        table2array(bestTbl(1,"Ethnicity")), table2array(bestTbl(1,"Plates")),...
        meanValueRLM, meanValueHFP);
    ptptRow.Properties.VariableNames = vars;

    meanTbl = [meanTbl; ptptRow];
end

meanTbl = convertvars(meanTbl, ["Sex", "Plates"], 'string');

meanTbl.Season = repmat("",[height(meanTbl) 1]);
meanTbl.EthnicGroup = repmat("",[height(meanTbl) 1]);

seasons = ["Winter", "Winter", "Spring", "Spring", "Spring", "Summer",...
    "Summer", "Summer", "Autumn", "Autumn", "Autumn", "Winter"];
ethnicities = ["White", "White", "White", "White",...
    "Mixed", "Mixed", "Mixed", "Mixed",...
    "Asian", "Asian", "Asian", "Asian", "Asian",...
    "Black", "Black", "Black",...
    "Arab", "Other", "PNTS"];

for ptpt = 1:height(meanTbl)
    meanTbl(ptpt,"Season") = array2table(seasons(table2array(meanTbl(ptpt,"Month"))));
    meanTbl(ptpt,"EthnicGroup") = array2table(ethnicities(table2array(meanTbl(ptpt,"Ethnicity"))));
end

%%
idx = strcmp(meanTbl.EthnicGroup, "White") | strcmp(meanTbl.EthnicGroup, "Asian");
anova1(meanTbl.Lambda(idx), meanTbl.EthnicGroup(idx));
anova1(meanTbl.RGratio(idx), meanTbl.EthnicGroup(idx));
%%
anova1(meanTbl.Lambda, meanTbl.Season);
anova1(meanTbl.RGratio, meanTbl.Season);
%%
idx = strcmp(meanTbl.Sex, "M") | strcmp(meanTbl.Sex, "F");
anova1(meanTbl.Lambda(idx), meanTbl.Sex(idx));
anova1(meanTbl.RGratio(idx), meanTbl.Sex(idx));
%%
[r,p] = corr(meanTbl.Year, meanTbl.Lambda, "rows","pairwise")
[r,p] = corr(meanTbl.Year, meanTbl.RGratio, "rows","pairwise")
%%
meanTbl.SexCat = categorical(meanTbl.Sex);
meanTbl.SeasonCat = categorical(meanTbl.Season);
meanTbl.EthnicityCat = categorical(meanTbl.EthnicGroup);

modelStrRLM = 'Lambda ~ SexCat + Year + SeasonCat + EthnicityCat';
mdlRLM = fitlm(meanTbl, modelStrRLM)
modelStrHFP = 'RGratio ~ SexCat + Year + SeasonCat + EthnicityCat';
mdlHFP = fitlm(meanTbl, modelStrHFP)

