% violin plots
violinData = struct;
vars = dataVars(endsWith(dataVars, "_RG"));
seasonVars = ["spring", "summer", "autumn", "winter"];

seasonColours = [0 1 0; 1 1 0; 1 0 0; 0 0 1];

t = tiledlayout(2,2);
for var = 1:length(vars)
    violinData.(vars(var)) = cell(1,4);
    for season = 1:length(seasonVars)
        idx = strcmpi(data.all.season, seasonVars(season));
        seasonData = data.all.(vars(var))(idx);
        violinData.(vars(var))(season) = {seasonData(~isnan(seasonData))};
    end
    nexttile
    violin(violinData.(vars(var)), 'xlabel', strcat(seasonVars), 'facecolor', seasonColours);
    title(vars(var),'Interpreter','none')
end
set(gca,'FontSize',26, 'FontName', 'Courier', 'FontWeight', 'bold')

input("Press ENTER to continue");
close all