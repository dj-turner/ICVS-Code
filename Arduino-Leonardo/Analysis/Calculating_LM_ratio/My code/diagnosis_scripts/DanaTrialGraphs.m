filePath = "C:\Users\" + getenv('USERNAME') +... 
    "\Documents\GitHub\ICVS-Code\Arduino-Leonardo\Saved-Data\RLM\RLM_JAA2.xlsx";
data = readtable(filePath);
data.Yellow = data.Yellow ./ 255;

idxBest = find(strcmp(string(data.MatchType),"Best"));

vars = ["Lambda","Yellow"];
f = NewFigWindow;
t = tiledlayout(1,2);

x = 1:numel(idxBest);
nexttile
hold on
y = data.Lambda(idxBest);
yMin = data.Lambda(idxBest+1);
yMax = data.Lambda(idxBest+2);
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
y = data.Yellow(idxBest);
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
l = legend(["Yellow Settings",...
    "Best Match Mean", "Min/Max Yellow Setting", ""]);
NiceGraphs(f,l);
l.Location = 'northeast';
l.FontSize = 12;

