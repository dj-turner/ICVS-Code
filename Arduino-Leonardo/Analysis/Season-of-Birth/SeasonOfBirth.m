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
% modelVars.seasonCat = ["combHFP",... 
%                  "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "season"];
% modelVars.month = ["combHFP",... 
%                    "study", "sex", "ethnicGroup", "RLM_Leo_RG", "monthSin", "monthCos"];
% modelVars.season = ["combHFP",... 
%                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "seasonSin", "seasonCos"];
% modelVars.day = ["combHFP",... 
%              "study", "sex", "ethnicGroup", "RLM_Leo_RG", "daylightHours"];
% sunshine hours available for UK only!
% modelVars.sun = ["combHFP",... 
%                "study", "sex", "ethnicGroup", "RLM_Leo_RG", "sunshineHours"];
modelVars.irr = ["combHFP",... 
                 "study", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance"];

validcats.ethnicGroup = ["white", "asian", "mixed-wa"];
validcats.country = irrCountries;
validcats.year = [1980 2005];
validcats.season = ["winter", "autumn", "summer", "spring"];
%validcats.devCombHFP = ["uno", "leo_y", "leo_g"];
validcats.sex = ["M", "F"];

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
c = convertvars(c, "N", 'double')

eths = unique(data.all.ethnicGroup);
ethCount = NaN(length(eths), 1);
for eth = 1:length(eths)
    ethCount(eth) = sum(strcmp(data.all.ethnicGroup, eths(eth)));
end

e =array2table([eths ethCount], 'VariableNames', ["Ethnic Group", "N"]);
e = convertvars(e, "N", 'double')
