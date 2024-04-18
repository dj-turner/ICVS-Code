%% model parameters
modelVars = struct;
validcats = struct;

modelVars.day = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "daylightHours"];
modelVars.sun = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "sunshineHours"];
modelVars.irr = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance"];

validcats.ethnicGroup = ["white", "asian"];
validcats.country = ["UK", "China"];
validcats.devCombHFP = ["uno", "leo_y", "leo_g"];
validcats.sex = ["M", "F"];

%% load data
% studyPriorityOrder = ["Allie", "Dana", "Josh", "Mitch"];
daylightPs = NaN(1,12);
sunshinePs = NaN(1,12);
irradiancePs = NaN(1,12);
for monthTimeFrame = 1:12
    CalculateWeatherData;
    data.all.daylightHours(~isnan(data.all.daylightHours));
    LMEs

    daylightPs(monthTimeFrame) = lmes.day.Coefficients.pValue(end);
    sunshinePs(monthTimeFrame) = lmes.sun.Coefficients.pValue(end);
    irradiancePs(monthTimeFrame) = lmes.irr.Coefficients.pValue(end);

    clear('weatherData');
end

%%
hold on
plot(1:12, daylightPs, 'Marker', 'x', 'Color', 'b', 'LineWidth', 3, 'MarkerSize', 10);
plot(1:12, sunshinePs, 'Marker', 'x', 'Color', 'r', 'LineWidth', 3, 'MarkerSize', 10);
plot(1:12, irradiancePs, 'Marker', 'x', 'Color', 'g', 'LineWidth', 3, 'MarkerSize', 10);
plot(1:12, repmat(.05, [1 12]), 'Marker', 'none', 'LineStyle', '--', 'Color', 'k');
xlim([1 12]); ylim([0 1]);
xlabel("Number of months after birth considered");
ylabel("P-value of variable in lme");
title("Significance of weather variables")
legend(["Daylight Data", "Sunshine Data", "Irradiance Data", ""]);
hold off


