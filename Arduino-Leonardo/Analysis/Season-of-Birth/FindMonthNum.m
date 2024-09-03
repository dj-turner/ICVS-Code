%% model parameters
modelVars = struct;
validcats = struct;

modelVars.day = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "daylightHours"];
modelVars.sun = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "sunshineHours"];
modelVars.irr_pop = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "irradiance_pop"];
modelVars.irr_area = ["foveaDensityL",... 
                 "sex", "ethnicGroup", "irradiance_area"];

validcats.ethnicGroup = ["asian", "white"];
%validcats.country = ["UK", "China"];
%validcats.year = [1980 2023];
%validcats.devCombHFP = ["uno", "leo_y", "leo_g"];
validcats.sex = ["M", "F"];


%% load data
% studyPriorityOrder = ["Allie", "Dana", "Josh", "Mitch"];
pVals = struct;
modelNames = string(fieldnames(modelVars));
%%
for var = 1:length(modelNames)
    pVals.(modelNames(var)) = NaN(1,12);
end
for monthTimeFrame = 1:12
    CalculateWeatherData;
    LMEs;    
    for var = 1:length(modelNames)
        pVals.(modelNames(var))(monthTimeFrame) = lmes.(modelNames(var)).Coefficients.pValue(end);
    end
end


%%
cols = [0 0 1; 1 0 0; 1 0 1; .6 .2 .9];
legendLabs = strings(1, numel(fieldnames(modelVars)));
for i = 1:length(legendLabs)
    legendLabs(i) = modelVars.(modelNames(i))(end);
end
%%
hold on
for var = 1:length(modelNames)
    plot(1:12, pVals.(modelNames(var)), 'Marker', 'x', 'Color', cols(var,:), 'LineWidth', 5, 'MarkerSize', 10);
end
plot(1:12, repmat(.05, [1 12]), 'Marker', 'none', 'LineStyle', '--', 'Color', 'k', 'LineWidth', 5, 'Color', 'k');
xlim([1 12]); ylim([0 1]);
xlabel("Number of months after birth considered");
ylabel("P-value of variable in lme");
set(gca,'FontSize',26, 'FontName', 'Courier','FontWeight','bold')
title("Significance of weather variables")
legend(legendLabs, "Interpreter","none","Location","north");
hold off

for var = 1:length(modelNames)
    lowestP = find(pVals.(modelNames(var)) == min(pVals.(modelNames(var))));
    disp(strcat("Optimal month number for variable ", legendLabs(var), " = ", num2str(lowestP)));
end
