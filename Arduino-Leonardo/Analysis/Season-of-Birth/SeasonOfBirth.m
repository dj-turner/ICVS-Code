 %% clear up
clc; clear; close all;

addpath('scripts\'); addpath('scripts\functions\');
addpath('data\'); addpath('data\dataHFP-MT');

%% load data
monthTimeFrame = 8;

d = load(strcat('C:\Users\', getenv('USERNAME'), '\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Analysis\Calculating_LM_ratio\My code\LMratioData.mat'));
data = d.data;
dataTbl = data.analysis;
dataTbl.season = categorical(dataTbl.season);

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

modelVars.day = ["foveaDensityL",... 
               "sex", "ethnicGroup", "daylightHours"];
modelVars.sun = ["foveaDensityL",... 
               "sex", "ethnicGroup", "sunshineHours"]; % sunshine hours available for UK only!
modelVars.irr_pop = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "irradiance_pop"];
modelVars.irr_area = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "irradiance_area"];

validCats.sex = ["M", "F"];
validCats.ethnicGroup = ["white", "asian", "mixed-wa"];
%validCats.country = ["UK", "China"];

[lmeModels, mdlData] = LMEs(dataTbl, modelVars, validCats);

disp(lmeModels.month)
disp(lmeModels.seasonCat)