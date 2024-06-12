 %% clear up
clc; clear; close all;
cd(strcat('C:\Users\', getenv('USERNAME'), '\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Analysis\Season-of-Birth'));
addpath('scripts\'); addpath('scripts\functions\');
addpath('data\'); addpath('data\dataHFP-MT');

%% load data
% studyPriorityOrder = ["Allie", "Dana", "Josh", "Mitch"];
studyPriorityOrder = ["Josh", "Mitch", "Dana", "Allie"];
monthTimeFrame = 8;
LoadData; 

%% models
clc;
modelVars = struct;
validcats = struct;

% modelVars.control = ["combHFP",... 
%                    "study", "sex", "ethnicGroup", "RLM_Leo_RG"];
% modelVars.month = ["combHFP",... 
%                "study", "sex", "ethnicGroup", "RLM_Leo_RG", "monthSin", "monthCos"];
% modelVars.seasonCat = ["combHFP",... 
%                "study", "sex", "ethnicGroup", "RLM_Leo_RG", "season"];
% modelVars.season = ["combHFP",... 
%               "study", "sex", "ethnicGroup", "RLM_Leo_RG", "seasonSin", "seasonCos"];
% modelVars.day = ["combHFP",... 
%                "study", "sex", "ethnicGroup", "RLM_Leo_RG", "daylightHours"];
% sunshine hours available for UK only!
% modelVars.sun = ["combHFP",... 
%                "study", "sex", "ethnicGroup", "RLM_Leo_RG", "sunshineHours"];
% modelVars.irr_pop = ["combHFP",... 
%                  "study", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance_pop"];
% modelVars.irr_area = ["combHFP",... 
%                  "study", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance_area"];

validcats.ethnicGroup = ["asian", "white", "mixed-wa"];
validcats.country = "UK";
%validcats.country = ["UK", "China"];
%validcats.year = [1980 2023];
%validcats.season = ["summer", "autumn", "winter", "spring"];
%validcats.devCombHFP = ["uno", "leo_y"];
validcats.sex = ["M","F"];

LMEs;


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