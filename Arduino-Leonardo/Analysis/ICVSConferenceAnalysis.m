clc; clearvars -except data; close all;

%data = LoadData;

dataTbl = data.all;

[c, p] = corr(dataTbl.RLM_Leo_logRG,dataTbl.RLM_Anom_logRG, "Rows","pairwise");
scatter(dataTbl.RLM_Leo_logRG,dataTbl.RLM_Anom_logRG);
[c, p] = corr(dataTbl.HFP_Leo_logRG,dataTbl.HFP_Uno_logRG, "Rows","pairwise");
scatter(dataTbl.HFP_Leo_logRG,dataTbl.HFP_Uno_logRG);