fullTbl = readtable("DataPt1.xlsx", "Sheet","Matlab_Data");

ptptNum = max(fullTbl.PPno);
allieArray = double.empty(0, 8);

for ptpt = 1:ptptNum

    ptptTbl = fullTbl(fullTbl.PPno == ptpt & fullTbl.Match_Type == 1, :);

    if ptptTbl.RLM(1) == 0
        continue
    end

    lambdaArray = table2array(ptptTbl(:, contains(ptptTbl.Properties.VariableNames, "Lambda")));
    lambdaArray = reshape(lambdaArray, [numel(lambdaArray), 1]);
    lambdaArray(isnan(lambdaArray)) = [];

    yellowArray = table2array(ptptTbl(:, contains(ptptTbl.Properties.VariableNames, "Yellow")));
    yellowArray = reshape(yellowArray, [numel(yellowArray), 1]);
    yellowArray(isnan(yellowArray)) = [];
    yellowArray = yellowArray ./ 255;

    if length(lambdaArray) == length(yellowArray)
        trialNum = length(lambdaArray);
    else
        disp(strcat("Error in values for ptpt ", num2str(ptpt)));
        continue
    end

    lambdaMean = mean(lambdaArray);
    lambdaStd = std(lambdaArray);
    lambdaSte = lambdaStd / sqrt(trialNum);

    yellowMean = mean(yellowArray);
    yellowStd = std(yellowArray);
    yellowSte = yellowStd / sqrt(trialNum);

    dataRow = [ptpt, trialNum, lambdaMean, lambdaStd, lambdaSte, yellowMean, yellowStd, yellowSte];
    allieArray = [allieArray; dataRow];

end

allieTbl = array2table(allieArray, "VariableNames",...
    ["Participant", "NumberOfTrials",...
    "LambdaMean", "LambdaStd", "LambdaSte",...
    "YellowMean", "YellowStd", "YellowSte"]);

save("allieTbl.mat", "allieTbl");

allieTbl_15 = allieTbl(allieTbl.NumberOfTrials == 15, :);
save("allieTbl_15.mat", "allieTbl_15");