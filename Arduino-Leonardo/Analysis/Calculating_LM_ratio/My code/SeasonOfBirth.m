 %% clear up
clc; clear; close all;
addpath(genpath(pwd)); 

%% load data
dataTbl = LMratio;

seasons = ["spring","summer","autumn","winter"];
seasonCols = ['g','y','r','b'];
dataTbl.season = categorical(dataTbl.season,seasons,Ordinal=true);

%% models 
clc;
modelVars = struct;
validCats = struct;

modelVars.control = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "RLM_Leo_RG"];

modelVars.month = ["foveaDensityL",... 
               "sex", "ethnicGroup", "monthSin", "monthCos"];

modelVars.seasonCat = ["foveaDensityL",... 
               "sex", "ethnicGroup", "season"];

weatherVars = ["daylightHours","sunshineHours","irradiancePop","irradianceArea"];

for weather = 1:length(weatherVars)
    for month = 1:12
        var = weatherVars(weather) + "_" + month;
        modelVars.(var) = ["foveaDensityL",... 
                       "sex", "ethnicGroup", var];
    end
end

validCats.sex = ["M", "F"];
validCats.ethnicGroup = ["white", "asian", "mixed-wa"];
validCats.country = ["UK", "China"];

[lmeModels, mdlData] = LMEs(dataTbl, modelVars, validCats);

disp(lmeModels.month)
disp(lmeModels.seasonCat)


%% pvals
pVals = NaN(12,length(weatherVars));

for weather = 1:length(weatherVars)
    for month = 1:12
        var = weatherVars(weather) + "_" + month;
        mdl = lmeModels.(var);
        idx = find(strcmp(string(mdl.Coefficients.Name),var));
        pVals(month,weather) = mdl.Coefficients.pValue(idx);
    end
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
    sigPVals = pVals.(weatherVars(var))(pVals.(weatherVars(var)) < .05);
    sigPVals = sigPVals(sigPVals ~= optPVal);
    sigMonths = find(ismember(pVals.(weatherVars(var)),sigPVals));
    if ~isempty(sigMonths)
        plot(sigMonths,sigPVals,'MarkerSize',8,'Marker','x','MarkerEdgeColor',cols(end), 'LineWidth',3, 'LineStyle','none')  
    end
end
plot(repmat(.05,[height(pVals) 1]),'LineStyle','--','LineWidth',3,'Color',cols(end));
xticks(1:12); yticks(0:.1:1);
xlim([1 12]); ylim([0 1]);
xlabel("Number of months after birth considered");
ylabel("P-value of weather variable in LME Model");
hold off

lgdLabs = repmat("", [1 3*numel(weatherVars)+1]); 
lgdLabs(1:3:end-2) = weatherVars;
lgdLabs(end-2) = "Optimal Month Marker";
lgdLabs(end-1) = "Significant Month Marker";
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
l = legend(seasons);
NiceGraphs(f2,l);