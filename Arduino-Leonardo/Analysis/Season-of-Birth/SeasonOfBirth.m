%% clear up
clc; clear; close all;
cd(strcat('C:\Users\', getenv('USERNAME'), '\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Analysis\Season-of-Birth'));
addpath('scripts\'); addpath('scripts\functions\');
addpath('data\'); addpath('data\dataHFP-MT');

%% load data
% studyPriorityOrder = ["Allie", "Dana", "Josh", "Mitch"];
studyPriorityOrder = ["Josh", "Mitch", "Dana", "Allie"];
monthTimeFrame = 7;
LoadData;

%% models
modelVars = struct;
validcats = struct;

modelVars.control = ["combHFP",... 
                   "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG"];
modelVars.seasonCat = ["combHFP",... 
                   "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "monthSin", "season"];
modelVars.month = ["combHFP",... 
                   "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "monthSin", "monthCos"];
modelVars.season = ["combHFP",... 
                   "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "seasonSin", "seasonCos"];
modelVars.day = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "daylightHours"];
% sunshine hours available for UK only!
modelVars.sun = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "sunshineHours"];
modelVars.irr = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance"];

validcats.ethnicGroup = ["white", "asian", "mixed-wa", "mixed-wb"];
validcats.country = ["UK", "China"];
validcats.year = [1980 2005];
validcats.devCombHFP = ["uno", "leo_y", "leo_g"];
validcats.sex = ["M", "F"];

LMEs;

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


