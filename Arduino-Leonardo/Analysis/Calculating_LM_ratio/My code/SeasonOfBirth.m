 %% clear up
clc; clear; close all;
addpath(genpath(pwd)); 

%% load data
dataTbl = LMratio([.4,13]);
dataTbl = dataTbl(dataTbl.validRatio,:);

seasons = ["spring","summer","autumn","winter"];
seasonCols = ['g','y','r','b'];
dataTbl.season = categorical(dataTbl.season,seasons,Ordinal=true);

%%
for shift = 0:11
    dataTbl.("monthShift_" + shift) = dataTbl.month + shift;
    idx = dataTbl.("monthShift_" + shift) > 12;
    dataTbl.("monthShift_" + shift)(idx) = dataTbl.("monthShift_" + shift)(idx) - 12;
    [dataTbl.("monthSin_" + shift), dataTbl.("monthCos_" + shift)] = SinCosMonth(dataTbl.("monthShift_" + shift));
end

%% models 
clc;
modelVars = struct;
validCats = struct;

modelVars.control = ["foveaDensityL",... 
                 "sex", "ethnicGroup"];
% 
for shift = 0:11
    modelVars.("month_" + shift) = ["foveaDensityL",... 
                   "sex", "ethnicGroup", "monthSin_"+shift, "monthCos_"+shift];
end

modelVars.seasonCat = ["foveaDensityL",... 
               "sex", "ethnicGroup", "season"];
% 
weatherVars = ["daylightHours","sunshineHours","irradiancePop","irradianceArea"];
% 
for weather = 1:length(weatherVars)
    for month = 1:12
        var = weatherVars(weather) + "_" + month;
        modelVars.(var) = ["foveaDensityL", "sex", "ethnicGroup", var];
    end
end

% modelVars.daylight8 = ["foveaDensityL",... 
%                         "sex", "ethnicGroup", "daylightHours_8"];

modelVars.time = ["foveaDensityL",... 
               "sex", "ethnicGroup",... 
               "hfpDaySin", "hfpDayCos", "hfpMinuteSin", "hfpMinuteCos"];

validCats.sex = ["M", "F"];
validCats.ethnicGroup = ["white", "asian", "mixed-wa"];
%validCats.country = ["UK", "China"];

[lmeModels, mdlData] = LMEs(dataTbl, modelVars, validCats);

% disp(lmeModels.month)
% disp(lmeModels.seasonCat)

cats = string(fieldnames(lmeModels));

for i = 1:length(cats), cat = cats(i);
    disp((lmeModels.(cat)));
end


%% pvals
pVals = NaN(12,length(weatherVars));
ns = NaN(1,length(weatherVars));

for weather = 1:length(weatherVars)
    for month = 1:12
        var = weatherVars(weather) + "_" + month;
        mdl = lmeModels.(var);
        idx = find(strcmp(string(mdl.Coefficients.Name),var));
        pVals(month,weather) = mdl.Coefficients.pValue(idx);
    end
    ns(weather) = lmeModels.(var).NumObservations;
end

pVals = array2table(pVals,"VariableNames",weatherVars,"RowNames",string(1:12));

%% graphs
cols = ['c','y','m','g','r'];
f1 = NewFigWindow;
hold on
for var = 1:width(pVals)
    plot(pVals.(weatherVars(var)),'MarkerSize',8,'Marker','x','MarkerEdgeColor','w','LineWidth',3,'Color',cols(var));
    % optimal p vals
    optPVal = min(pVals.(weatherVars(var)));
    optMonth = find(optPVal==pVals.(weatherVars(var)));
    plot(optMonth,optPVal,...
        'MarkerSize',10,'Marker','o',...
        'MarkerEdgeColor','w','MarkerFaceColor',cols(end),...
        'LineWidth',3,'LineStyle','none')
    % significant p vals
    % sigPVals = pVals.(weatherVars(var))(pVals.(weatherVars(var)) < .05);
    % sigPVals = sigPVals(sigPVals ~= optPVal);
    % sigMonths = find(ismember(pVals.(weatherVars(var)),sigPVals));
    % if ~isempty(sigMonths)
    %     plot(sigMonths,sigPVals,'MarkerSize',8,'Marker','x','MarkerEdgeColor',cols(end), 'LineWidth',3, 'LineStyle','none')  
    % end
end
plot(repmat(.05,[height(pVals) 1]),'LineStyle','--','LineWidth',3,'Color',cols(end));
xticks(1:12); yticks(0:.1:1);
xlim([1 12]); ylim([0 1]);
xlabel("Number of months after birth considered");
ylabel("P-value of weather variable in LME Model");
hold off

lgdLabs = repmat("", [1 2*numel(weatherVars)+1]); 
lgdLabs(1:2:end-2) = weatherVars + " (n = " + string(ns) + ")";
lgdLabs(end-1) = "Optimal Month Marker";
%lgdLabs(end-1) = "Significant Month Marker";
lgdLabs(end) = "Significance Line"; 
l = legend(lgdLabs);
NiceGraphs(f1,l);
grid on

%% correlations
corrVals = NaN(length(weatherVars),length(weatherVars),12,2);

for month = 1:12
    for i = 1:length(weatherVars)
        for j = (i+1):length(weatherVars)
            x = dataTbl.(weatherVars(i) + "_" + month);
            y = dataTbl.(weatherVars(j) + "_" + month);
            [r,p] = corr(x,y,'Rows','pairwise');
            corrVals(i,j,month,1) = r;
            corrVals(i,j,month,2) = p;
        end
    end
end

%%
f2 = NewFigWindow;
hold on
for i = 1:length(seasons)
    idx = strcmp(string(dataTbl.season),seasons(i));
    y = dataTbl.foveaDensityL(idx);
    x = repmat(i, [height(y) 1]);
    scatter(x,y,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor',seasonCols(i));
end
xlim([0,length(seasons)+1]);
ylim([min(dataTbl.foveaDensityL),max(dataTbl.foveaDensityL)]);
l2 = legend(seasons);
NiceGraphs(f2,l2);

%%
f3 = NewFigWindow;
colMap = colorcet('C7');
monthMeans = NaN(1,12);
monthStes = NaN(1,12);
hold on
for month = 1:12
    idx = dataTbl.month == month;
    x = dataTbl.month(idx);
    y = dataTbl.foveaDensityL(idx);
    monthMeans(month) = mean(y);
    monthStes(month) = std(y) / sqrt(numel(y));
    %colourmap
    num = round((month+5) / 12 * height(colMap),0);
    if num > 256, num = num - 256; end
    col = colMap(num,:);
    scatter(x,y,...
        Marker='o',MarkerEdgeColor='w',MarkerFaceColor=col);
end
errorbar(1:12,monthMeans,monthStes,monthStes,...
    Marker='x',MarkerEdgeColor='w',MarkerSize=20,...
    LineStyle='-',LineWidth=3,Color='w');

xticks(1:12);
xticklabels(["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]);
NiceGraphs(f3);
hold off

%%
f4 = NewFigWindow;
y = dataTbl.foveaDensityL;
hold on
scatter(dataTbl.hfpDaySin, y,...
    'Marker', 'o','MarkerEdgeColor', 'w', 'MarkerFaceColor', 'm');
scatter(dataTbl.hfpDayCos, y,...
    'Marker', 'o','MarkerEdgeColor', 'w', 'MarkerFaceColor', 'c');
l4 = legend(["Sin","Cos"]);
NiceGraphs(f4,l4);
xlim([-1 1]);
hold off

%%
f5 = NewFigWindow;
hold on
scatter(dataTbl.month, -dataTbl.monthSin_5, 'LineWidth', 2, 'Marker', 'x');
scatter(dataTbl.month, -dataTbl.monthCos_0, 'LineWidth', 2, 'Marker', '+');
hold off
l5 = legend(["Results", "Sunlight"]);
NiceGraphs(f5,l5);

%%
for shift = 0:11
    idx = startsWith(lmeModels.("month_"+shift).Coefficients.Name,"monthSin");
    pSin(shift+1) = lmeModels.("month_"+shift).Coefficients.pValue(idx);
    idx = startsWith(lmeModels.("month_"+shift).Coefficients.Name,"monthCos");
    pCos(shift+1) = lmeModels.("month_"+shift).Coefficients.pValue(idx);
end

f6 = NewFigWindow;
hold on
plot(0:11,pSin,Color='r',LineWidth=3);
plot(0:11,pCos,Color='b',LineWidth=3);
hold off
xlim([0 11]); ylim([0 1]);
xlabel("Month Shift"); ylabel("P-Value");
l6 = legend(["Sin","Cos"]);
NiceGraphs(f6,l6);
