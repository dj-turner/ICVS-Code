clc; clear; close all;

filePath = "C:\Users\" + getenv('USERNAME') +... 
    "\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Saved-Data\RLM\RLM_JAA2.xlsx";
data.Dana = readtable(filePath);
filePath = "C:\Users\" + getenv('USERNAME') +... 
    "\Documents\GitHub\Arduino-Colour-Vision-Genetics\Saved-Data\RLM\RLM_tab_1.xlsx";
data.Hannah = readtable(filePath);
filePath = strrep(filePath,"tab","tac");
data.Takuma = readtable(filePath);

ptpts = string(fieldnames(data));
%%
for ptpt = 1:length(ptpts), fn = ptpts(ptpt);
data.(fn).Yellow = data.(fn).Yellow ./ 255;

idxBest = find(strcmp(string(data.(fn).MatchType),"Best"));

vars = ["Lambda","Yellow"];
f = NewFigWindow;
t = tiledlayout(1,2);

x = 1:numel(idxBest);
nexttile
hold on
y = data.(fn).Lambda(idxBest);
yMin = data.(fn).Lambda(idxBest+1);
yMax = data.(fn).Lambda(idxBest+2);
errorbar(x, y, y - yMin, yMax - y,...
    "Marker",'x',"MarkerSize",20,"MarkerEdgeColor",'w',...
    "LineWidth",3,"Color",'r');
plot(x, repmat(mean(y), [1 numel(idxBest)]),...
    "Marker",'none',...
    "LineStyle",'--',"LineWidth",1,"Color",'g');
plot(x, repmat(mean(yMin), [1 numel(idxBest)]),...
    "Marker",'none',...
    "LineStyle",'--',"LineWidth",1,"Color",'c');
plot(x, repmat(mean(yMax), [1 numel(idxBest)]),...
    "Marker",'none',...
    "LineStyle",'--',"LineWidth",1,"Color",'c');
hold off
xlim([1 numel(idxBest)]);
ylim([0 1]);
xlabel("Trial Number");
ylabel("Lambda");
xticks(1:numel(idxBest));
yticks(0:.1:1);
l = legend(["Lambda Settings (Error Bars = Min/Max Settings)",...
    "Best Match Mean", "Min/Max Match Means", ""]);
NiceGraphs(f,l);
l.Location = 'northeast';
l.FontSize = 12;

nexttile
y = data.(fn).Yellow(idxBest);
hold on
plot(x, y,...
    "Marker",'x',"MarkerSize",20,"MarkerEdgeColor",'w',...
    "LineWidth",3,"Color",'y');
plot(x, repmat(mean(y), [1 numel(idxBest)]),...
    "Marker",'none',...
    "LineStyle",'--',"LineWidth",1,"Color",'b');
plot(x, repmat(min(y), [1 numel(idxBest)]),...
    "Marker",'none',...
    "LineStyle",'--',"LineWidth",1,"Color",'m');
plot(x, repmat(max(y), [1 numel(idxBest)]),...
    "Marker",'none',...
    "LineStyle",'--',"LineWidth",1,"Color",'m');
hold off
xlim([1 numel(idxBest)]);
ylim([0 1]);
xlabel("Trial Number");
ylabel("Yellow");
xticks(1:numel(idxBest));
yticks(0:.1:1);
title(fn);
l = legend(["Yellow Settings",...
    "Best Match Mean", "Min/Max Yellow Setting", ""]);
NiceGraphs(f,l);
l.Location = 'northeast';
l.FontSize = 12;

[r,p] = corr(data.(fn).Lambda(idxBest),data.(fn).Yellow(idxBest));

x = 0:.0001:1;
yLambda = CurveNormalisation(normpdf(x,mean(data.(fn).Lambda(idxBest)),std(data.(fn).Lambda(idxBest))),"height");
yYellow = CurveNormalisation(normpdf(x,mean(data.(fn).Yellow(idxBest)),std(data.(fn).Yellow(idxBest))),"height");

f2 = NewFigWindow;
hold on
plot(x,yLambda,...
    'Marker','none','MarkerSize',.1,'MarkerEdgeColor','w','MarkerFaceColor','k',...
    'Color','r','LineWidth',3);
plot(x,yYellow,...
    'Marker','none','MarkerSize',.1,'MarkerEdgeColor','w','MarkerFaceColor','k',...
    'Color','y','LineWidth',3);
hold off
xlim([0 1]);
xticks(0:.1:1);
xlabel("Input Value");
ylim([0 1]);
yticks(0:1);
ylabel("Relative Probability Density");
title("Normal Distributions of " + fn + "'s Lambda & Yellow Settings");
l2 = legend(vars);
NiceGraphs(f2,l2);
grid on

end

