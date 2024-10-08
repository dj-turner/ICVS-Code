% violin plots
f = NewFigWindow;
violinData = struct;
seasonVars = ["spring", "summer", "autumn", "winter"];
monthNum = 7;

seasonColours = [0 1 0; 1 1 0; 1 0 0; 0 0 1];

violinData = cell(1,4);
for season = 1:length(seasonVars)
    idx = strcmpi(data.analysis.season, seasonVars(season));
    seasonData = data.analysis.foveaDensityL(idx);
    violinData(season) = {seasonData(~isnan(seasonData))};
end
violin(violinData, 'xlabel', seasonVars, 'facecolor', seasonColours);
title("L-cone Density in Fovea",'Interpreter','none')
NiceGraphs(f);
set(gca,'FontSize',26, 'FontName', 'Courier', 'FontWeight', 'bold')
