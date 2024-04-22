%% model parameters
modelVars = struct;
validcats = struct;

modelVars.day = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "daylightHours"];
modelVars.sun = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "sunshineHours"];
modelVars.irr_pop = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance_pop"];
modelVars.irr_area = ["combHFP",... 
                 "devCombHFP", "sex", "ethnicGroup", "RLM_Leo_RG", "irradiance_area"];

validcats.ethnicGroup = ["white", "asian", "mixed-wa"];
validcats.country = ["UK", "China"];
validcats.year = [1980 2023];
validcats.devCombHFP = ["uno", "leo_y", "leo_g"];
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
    plot(1:12, pVals.(modelNames(var)), 'Marker', 'x', 'Color', cols(var,:), 'LineWidth', 3, 'MarkerSize', 10);
end
plot(1:12, repmat(.05, [1 12]), 'Marker', 'none', 'LineStyle', '--', 'Color', 'k');
xlim([1 12]); ylim([0 1]);
xlabel("Number of months after birth considered");
ylabel("P-value of variable in lme");
title("Significance of weather variables")
legend(legendLabs, "Interpreter","none");
hold off

for var = 1:length(modelNames)
    lowestP = find(pVals.(modelNames(var)) == min(pVals.(modelNames(var))));
    disp(strcat("Optimal month number for variable ", legendLabs(var), " = ", num2str(lowestP)));
end
