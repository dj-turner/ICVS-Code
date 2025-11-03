% load data
data = readtable("Data-Pt1.2.xlsx",Sheet="Matlab_Data");

idx1 = startsWith(string(data.Properties.VariableNames),["RLM_Lambda","RLM_MixLight"]);
idx2 = data.("Match_Type")==1;

lambdaData = data(idx2,idx1);

ptptMean = zeros(height(lambdaData)/5,2);
ptptSte = ptptMean;

for ptpt = 1:height(lambdaData)/5
    r1 = (ptpt-1)*5 + 1;
    r2 = r1+5-1;
    for device = 1:2
        c = 1:2:width(lambdaData);
        c = c + device - 1;
        ptptData = table2array(lambdaData(r1:r2,c));
        ptptData = reshape(ptptData,[numel(ptptData) 1]);
        ptptData(isnan(ptptData)) = [];
        ptptMean(ptpt,device) = mean(ptptData);
        ptptStd(ptpt,device) = std(ptptData) ./ sqrt(numel(ptptData));
    end
end

ptptMean(ptptMean < .5) = NaN;

[r,p] = corr(ptptMean(:,1),ptptMean(:,2),"Rows","pairwise");

hold on
errorbar(ptptMean(:,1),ptptMean(:,2),ptptStd(:,2),ptptStd(:,2),ptptStd(:,1),ptptStd(:,1),...
    'LineStyle','none');

fit = polyfit(ptptMean(:,1),ptptMean(:,2),1);

plot(0:.1:1,polyval(fit,0:.1:1),'Marker','none','LineStyle','-')

hold off