data = readtable("data\data-B.xlsx",Sheet="Matlab_Data");

data.RLM_Yellow_1 = data.RLM_Yellow_1 ./ 255;
data.RLM_RefLight_1 = data.RLM_RefLight_1 ./ 45;

vars = ["RLM_Yellow_1","RLM_RefLight_1"];
yData = NaN(max(data.PPno),length(vars));
yDataStd = NaN(max(data.PPno),length(vars));
yDataSte = NaN(max(data.PPno),length(vars));

for ptpt = 1:max(data.PPno)
    %yellow
    idx = data.PPno == ptpt;
    d = data(idx,vars);
    d = table2array(d(2:end,:));
    yDataStd(ptpt,:) = std(d,1,"omitmissing");
    yDataSte(ptpt,:) = yDataStd(ptpt,:) ./ sqrt(height(d));
    yData(ptpt,:) = mean(d,1,"omitmissing");
end

yData = array2table(yData,VariableNames=vars);
yDataStd = array2table(yDataStd,VariableNames=vars);
yDataSte = array2table(yDataSte,VariableNames=vars);

f = NewFigWindow; 
hold on
alpha = .5;

errX = errorbar(yData.RLM_Yellow_1, yData.RLM_RefLight_1,... 
    yDataSte.RLM_Yellow_1, "horizontal",... 
    "LineStyle","none","Color",'r',"LineWidth",2);

set([errX.Bar, errX.Line], 'ColorType', 'truecoloralpha', 'ColorData', [errX.Line.ColorData(1:3); 255*alpha]);

errY = errorbar(yData.RLM_Yellow_1, yData.RLM_RefLight_1,... 
    yDataSte.RLM_RefLight_1, "vertical",... 
    "LineStyle","none","Color",'c',"LineWidth",2);

set([errY.Bar, errY.Line], 'ColorType', 'truecoloralpha', 'ColorData', [errY.Line.ColorData(1:3); 255*alpha]);

points = scatter(yData.RLM_Yellow_1, yData.RLM_RefLight_1,... 
    Marker='o',MarkerEdgeColor='w',MarkerFaceColor='m',...
    MarkerEdgeAlpha=1,MarkerFaceAlpha=1);

idx = ~isnan(yData.RLM_Yellow_1) & ~isnan(yData.RLM_RefLight_1);
yDataNoNaN = yData(idx,:);
mc = polyfit(yDataNoNaN.RLM_Yellow_1, yDataNoNaN.RLM_RefLight_1, 1);
x = 0:.1:1;
y = mc(1) .* x + mc(2);

fitLine = plot(x,y,'Marker','none','Color','y','LineStyle','--','LineWidth',2);

xlim([0 1]);
xticks(0:.1:1);
ylim([0 1]);
yticks(0:.1:1);
xlabel("Yellow Setting: Arduino Device");
ylabel("Reference Light Setting: Anomaloskop")

hold off
l = legend([points,errX,errY,fitLine],["Mean Setting", "Arduino Error (1 Ste)", "Anomaloskop Error (1 Ste)", "Regression Line"]);
NiceGraphs(f,l)
l.Location = 'northeast';
grid on

%%
[rCorr,pCorr] = corrcoef(yData.RLM_Yellow_1, yData.RLM_RefLight_1,'rows','pairwise');
rSquared = rCorr(1,2) * rCorr(1,2);

%%
[h,p,ci,stats] = ttest2(yDataSte.RLM_Yellow_1,yDataSte.RLM_RefLight_1);

%%
data = convertvars(data, "PPcode", 'string');

lmeString = 'RLM_RefLight_1 ~ RLM_Yellow_1 + (1|PPcode)';
lme = fitlme(data,lmeString);