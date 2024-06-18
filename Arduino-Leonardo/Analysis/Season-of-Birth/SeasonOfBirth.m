 %% clear up
clc; clear; close all;

cd(strcat('C:\Users\', getenv('USERNAME'), '\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Analysis\Season-of-Birth'));
addpath('scripts\'); addpath('scripts\functions\');
addpath('data\'); addpath('data\dataHFP-MT');

%% load data
% studyPriorityOrder = ["Allie", "Dana", "Josh", "Mitch"];
studyPriorityOrder = ["Josh", "Mitch", "Dana", "Allie"];
monthTimeFrame = 6;
LoadData_old; 

load(strcat('C:\Users\', getenv('USERNAME'), '\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Analysis\Calculating_LM_ratio\My code\LMratioData.mat'));
data.all = dataTbl;
data.all.combHFP = log(data.all.combHFP);

%% models
clc;
modelVars = struct;
validcats = struct;

% modelVars.control = ["foveaDensityL",... 
%                  "sex", "ethnicGroup", "RLM_Leo_logRG"];
% modelVars.month = ["foveaDensityL",... 
%                "sex", "ethnicGroup", "RLM_Leo_logRG", "monthSin", "monthCos"];
% modelVars.seasonCat = ["foveaDensityL",... 
%                "sex", "ethnicGroup", "RLM_Leo_logRG", "season"];
% modelVars.season = ["foveaDensityL",... 
%               "sex", "ethnicGroup", "RLM_Leo_logRG", "seasonSin", "seasonCos"];
modelVars.day = ["foveaDensityL",... 
               "sex", "ethnicGroup", "RLM_Leo_logRG", "daylightHours"];
% sunshine hours available for UK only!
% modelVars.sun = ["foveaDensityL",... 
%                "sex", "ethnicGroup", "RLM_Leo_RG", "sunshineHours"];
% modelVars.irr_pop = ["foveaDensityL",... 
%                  "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance_pop"];
% modelVars.irr_area = ["foveaDensityL",... 
%                  "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance_area"];

validcats.ethnicGroup = ["asian", "mixed-wa", "white", "mixed-o"]; %, 
%validcats.devCombRLM = ["leo_y", "leo_g"];
%validcats.country = "UK";
validcats.country = ["UK", "China"];
%validcats.year = [1980 2023];
%validcats.season = ["summer", "autumn", "winter", "spring"];
%validcats.devCombHFP = ["uno", "leo_y"];
validcats.sex = ["M","F"];

LMEs;

%%
for group = 1:length(validcats.ethnicGroup)
    disp(validcats.ethnicGroup(group));
    disp(sum(strcmp(string(modelData.ethnicGroup),validcats.ethnicGroup(group)) & ~isnan(modelData.foveaDensityL)));
end

%%
clear modelvars
clear validcats

%% graphs
RadarGraphs;
ViolinGraphs;
StudyGraphs;
%%
% ideal month number
FindMonthNum;

%%
countries = unique(data.all.country);
countryCount = NaN(length(countries), 1);
for country = 1:length(countries)
    countryCount(country) = sum(strcmp(data.all.country, countries(country)));
end

c =array2table([countries countryCount], 'VariableNames', ["Country", "N"]);
c = convertvars(c, "N", 'double');

eths = unique(data.all.ethnicGroup);
ethCount = NaN(length(eths), 1);
for eth = 1:length(eths)
    ethCount(eth) = sum(strcmp(data.all.ethnicGroup, eths(eth)));
end

e =array2table([eths ethCount], 'VariableNames', ["Ethnic Group", "N"]);
e = convertvars(e, "N", 'double');

%%
s = struct;
[s.Sine, s.Cosine] = SinCosMonth(1:12);
cols = ['r', 'b'];
vars = string(fieldnames(s));
t = tiledlayout(1,length(vars));
for var = 1:length(vars)
    nexttile
    plot(1:12, s.(vars(var)), 'LineWidth', 5, 'Color', cols(var), 'Marker', 'x', 'MarkerEdgeColor', 'k')
    xlim([1 12])
    ylim([-1 1])
    set(gca, 'XTick',(1:12), 'XTickLabel', monthVars)
    title(strcat("Month ", vars(var), " Conversion"))
    set(gca,'FontSize',26, 'FontName', 'Courier', 'FontWeight', 'bold')
end

%%
s = struct;
[s.Sine, s.Cosine] = SinCosSeason(["spring"; "summer"; "autumn"; "winter"]);
cols = ['r', 'b'];
vars = string(fieldnames(s));
t = tiledlayout(1,length(vars));
for var = 1:length(vars)
    nexttile
    plot(1:4, s.(vars(var)), 'LineWidth', 3, 'Color', cols(var))
    xlim([1 4])
    ylim([-1 1])
    set(gca, 'XTick',(1:4), 'XTickLabel', ["spring", "summer", "autumn", "winter"])
    title(strcat("Season ", vars(var), " Conversion"))
    set(gca,'FontSize',26, 'FontName', 'Courier', 'FontWeight', 'bold')
end

%%
WorldHeatMap(c, "testVarName", "N", "countryVarName", "Country", "undefinedVarName", "", "scalingType", "count")

%%
ethnicities = unique(data.all.ethnicGroup);
ethnicities(strcmp(ethnicities,"")) = [];
means = NaN(height(ethnicities),1);
ns = means;
stds = means;
stes = means;
for i = 1:height(ethnicities)
    idx = strcmp(data.all.ethnicGroup, ethnicities(i));
    means(i) = mean(data.all.foveaDensityL(idx),'omitmissing');
    stds(i) = std(data.all.foveaDensityL(idx),'omitmissing');
    ns(i) = height(data.all.foveaDensityL(idx));
    stes(i) = stds(i) / ns(i);
end

idx = ns >= 5;

hold on
bar(ethnicities(idx), means(idx))
errorbar(1:height(ethnicities(idx)), means(idx), stds(idx), stds(idx), 'LineStyle', 'none')
