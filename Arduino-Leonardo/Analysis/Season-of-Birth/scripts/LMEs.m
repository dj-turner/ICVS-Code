lmes = struct;
modelFields = string(fieldnames(modelVars));
for model = 1:numel(modelFields)
    currentVars = modelVars.(modelFields(model));
    modelStrVars = currentVars(ismember(currentVars, strVars));
    modelNumVars = currentVars(ismember(currentVars, numVars));
    idxStr = strcmp(table2array(data.all(:,modelStrVars)), "");
    idxNum = isnan(table2array(data.all(:,modelNumVars)));

    catNames = string(fieldnames(validcats));
    catNum = length(catNames);
    idxCat = NaN(height(data.all), catNum);
    for cat = 1:catNum
        if isstring(validcats.(catNames(cat)))
            idxCat(:,cat) = ismember(data.all.(catNames(cat)), validcats.(catNames(cat)));
        else
            idxCat(:,cat) = data.all.(catNames(cat)) >= validcats.(catNames(cat))(1)... 
                & data.all.(catNames(cat)) <= validcats.(catNames(cat))(2);
        end
    end
    idxCat = sum(idxCat,2) == width(idxCat);

    idx = sum([idxStr,idxNum],2) == 0 & idxCat;
    modelData = data.all(idx,currentVars);
    
    modelStr = char(strjoin(currentVars, " + "));
    modelStr(regexp(modelStr, '+', 'once')) = "~"; 
    
    for var = 1:length(modelStrVars)
        modelData.(modelStrVars(var)) = categorical(modelData.(modelStrVars(var)));
        if ismember(modelStrVars(var), catNames)
            currentValidCats = string(unique(modelData.(modelStrVars(var))));
            idx = ismember(validcats.(modelStrVars(var)), currentValidCats);
            modelData.(modelStrVars(var)) = reordercats(modelData.(modelStrVars(var)), validcats.(modelStrVars(var))(idx));
        end
    end


   % modelData.ethnicGroup = string(modelData.ethnicGroup);
   % idx = strcmp(modelData.ethnicGroup, "mixed-o");
   % modelData.ethnicGroup(idx) = categorical("white");
   % modelData.ethnicGroup = categorical(modelData.ethnicGroup);
    
    % try
        lmes.(modelFields(model)) = fitlme(modelData,modelStr);
        disp(lmes.(modelFields(model)))
    % catch
    %     disp("Failed to run lme!")
    %     lmes.(modelFields(model)) = "error";
    % end

    % seasons = unique(modelData.season);
    % for season = 1:numel(seasons)
    %     idx = strcmp(string(modelData.season), string(seasons(season))) & ~isnan(modelData.foveaDensityL);
    %     disp(string(seasons(season)));
    %     disp(height(modelData(idx,:)));
    %     disp(" ");
    % end

    ethnicities = unique(modelData.ethnicGroup);
    for eth = 1:numel(ethnicities)
        idx = strcmp(string(modelData.ethnicGroup), string(ethnicities(eth))) & ~isnan(modelData.foveaDensityL);
        disp(string(ethnicities(eth)));
        disp(height(modelData(idx,:)));
        disp(" ");
    end


    
end