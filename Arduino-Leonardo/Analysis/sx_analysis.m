% load data
data = readtable("Data-Pt1.2.xlsx",Sheet="Matlab_Data");

data = data(data.Month~=0,:);

idx1 = startsWith(string(data.Properties.VariableNames),["RLM_Lambda","RLM_MixLight"]);
idx2 = data.("Match_Type")==1;

lambdaData = data(idx2,idx1);

ptptMean = zeros(height(lambdaData)/5,2);
ptptStd = ptptMean;

for ptpt = 1:height(lambdaData)/5
    row1idx = (ptpt-1)*5 + 1;
    r2 = row1idx+5-1;
    for device = 1:2
        c = 1:2:width(lambdaData);
        c = c + device - 1;
        ptptData = table2array(lambdaData(row1idx:r2,c));
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

%% participant info
% row 1 index
ppno = max(data.PPno);
row1idx = nan(1,ppno);
for i = 1:ppno
    idx = find(data.PPno == i);
    row1idx(i) = min(idx);
end

% ages
data2 = data(row1idx,:);

rlmIdx = ~isnan(data2.RLM_Lambda_1);
data2 = data2(rlmIdx,:);

disp("Sessions 1&2");
N(data2); Age(data2); Sex(data2);
disp(" ");

rlm3Idx = ~isnan(data2.RLM_Lambda_3);
data3 = data2(rlm3Idx,:);

disp("Session 3");
N(data3); Age(data3); Sex(data3);
disp(" ");

%
function n = N(d)
    n = height(d);
    disp("N = " + n);
end

% age
function ages = Age(d)
    dob = datetime(d.Year,d.Month,15);
    rlmDate = datetime(d.RLM_Date1,d.RLM_Date2,d.RLM_Date3);
    ages = calyears(between(dob,rlmDate));
    disp("Mean Age = " + mean(ages) + ", SD Age = " + std(ages));
end

% gender
function sexStr = Sex(d) 
    sex = d.Sex;
    sexKey = 'FMX';
    sex = sexKey(sex);
    sexStr = "";
    sexCount = nan(1,numel(sexKey));
    for i = 1:numel(sexKey)
        sexCount(i) = sum(sex==sexKey(i));
        sexStr = sexStr + sexKey(i) + "=" + sexCount(i) + " ";
    end
    disp(sexStr);
end

