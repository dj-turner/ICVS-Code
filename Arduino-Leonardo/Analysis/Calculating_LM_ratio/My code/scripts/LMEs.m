function [lmes,data] = LMEs(data,modelVars,validCats)

%% Initialise variables
lmes = struct;
models = string(fieldnames(modelVars));
categories = string(fieldnames(validCats));

%% Filter data based on valid categories
for category = 1:length(categories), catName = categories(category);
    idx = ismember(data.(catName), validCats.(catName));
    data = data(idx,:);

    % Filter out blanks
    dataClass = class(data.(catName));
    switch dataClass
        case 'double'
            idx = ~isnan(data.(catName));
        case 'string'
            idx = ~strcmp(data.(catName),"");
            data.(catName) = categorical(data.(catName));
    end
    data = data(idx,:);
end

%% Generate models
for model = 1:length(models), modelName = models(model);

    modelString = char(strjoin(modelVars.(modelName), " + "));
    idx = strfind(modelString,'+');
    modelString(idx(1)) = "~";

    lmes.(modelName) = fitlme(data,modelString);
end

end