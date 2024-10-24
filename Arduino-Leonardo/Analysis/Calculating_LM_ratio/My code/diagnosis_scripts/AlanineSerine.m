clc; clear; close all;

addpath(genpath(GoBackFolders(1)));

shift.S180 = 2.4; shift.A180 = -1.76;
peak.S180 = 563; peak.A180 = 559;
[coneFuns,~] = ConeFundamentals(fieldSize = 2, normalisation = "area");
wvls = 400:.1:700;
lCone.Std = pchip(coneFuns.wavelengths,coneFuns.lCones,wvls);
peak.Std = wvls(lCone.Std==max(lCone.Std));

lCone.A180 = pchip(wvls+(peak.A180-peak.Std),lCone.Std,wvls);
lCone.S180 = pchip(wvls+(peak.S180-peak.Std),lCone.Std,wvls);

f = NewFigWindow; 
hold on
plot(coneFuns.wavelengths,coneFuns.lCones,'Marker','none','LineWidth',3,'Color','r');
plot(coneFuns.wavelengths,coneFuns.mCones,'Marker','none','LineWidth',3,'Color','g');
plot(coneFuns.wavelengths,coneFuns.sCones,'Marker','none','LineWidth',3,'Color','b');
plot(wvls,lCone.S180,'Marker','none','LineWidth',3,'Color','r','LineStyle','--');
plot(wvls,lCone.A180,'Marker','none','LineWidth',3,'Color','r','LineStyle',':');
hold off
xlim([400 700]);
xlabel("Wavelength (nm)");
ylabel("Spd");
l = legend("L-Cones", "M-Cones", "S-cones", "L-Cones S180", "L-Cones A180");
NiceGraphs(f,l);

%%
data = LoadData; 
data = data.all;
idx = ~strcmp(data.geneOpsin,"");
data = data(idx,:);
idx = data.rlmRG > .4;
data = data(idx,:);
%%
genes = unique(data.geneOpsin);
ns = nan(3,1);
cols = ['m','y','c'];
linestyles = ["--","-.",":"];
f = NewFigWindow;
hold on
for g = 1:length(genes)
    idx = strcmp(data.geneOpsin,genes(g));
    x = data.rlmRG(idx);
    y = data.rlmYellow(idx);
    ns(g) = numel(y);
    scatter(x,y,100,...
        'Marker','o','MarkerEdgeColor','w','MarkerFaceColor',cols(g));
    plot(repmat(mean(x,"omitmissing"),[1 2]),0:1,...
        'Marker','none',...
        'LineStyle',char(linestyles(g)),'LineWidth',2,'Color',cols(g));
    plot(0:1,repmat(mean(y,"omitmissing"),[1 2]),...
        'Marker','none',...
        'LineStyle',char(linestyles(g)),'LineWidth',2,'Color',cols(g));
    disp("Lambda mean " + genes(g) + " = " + string(mean(x,"omitmissing")));
    disp("Yellow mean " + genes(g) + " = " + string(mean(y,"omitmissing")));
end
hold off
xlim([0 1]);
ylim([0 1]);
xticks(0:.1:1);
yticks(0:.1:1);
xlabel("Lambda");
ylabel("Yellow");
title("Participants' RM Plotted by Gene Opsin")
l = legend([genes + " (n=" + string(ns) + ")", genes + " Mean Line", repmat("",[height(genes),1])]');
NiceGraphs(f,l);
grid on

%%
vars = ["wvls", "L", "M", "S"];
cvrl = readtable("linss2_10e_5.csv");
cvrl.Properties.VariableNames = vars;

[dana,dSettings] = ConeFundamentals(normalisation = "height", fieldSize = 2);

f = NewFigWindow;
hold on
plot(cvrl.wvls,cvrl.L,'Marker','none','LineWidth',3,'Color',[1 0 0 1],'LineStyle',':');
plot(cvrl.wvls,cvrl.M,'Marker','none','LineWidth',3,'Color',[0 1 0 1],'LineStyle',':');
plot(cvrl.wvls,cvrl.S,'Marker','none','LineWidth',3,'Color',[0 0 1 1],'LineStyle',':');

plot(dana.wavelengths,dana.lCones,'Marker','none','LineWidth',10,'Color',[1 0 0 .5],'LineStyle','-')
plot(dana.wavelengths,dana.mCones,'Marker','none','LineWidth',10,'Color',[0 1 0 .5],'LineStyle','-')
plot(dana.wavelengths,dana.sCones,'Marker','none','LineWidth',10,'Color',[0 0 1 .5],'LineStyle','-')
hold off
xlabel("Wavelength (nm)");
xlim([400 700]);
NiceGraphs(f);

%%
[coneFun.Std,~] = ConeFundamentals(normalisation="height",geneOpsin="");
[coneFun.A180,~] = ConeFundamentals(normalisation="height",geneOpsin="A180");
[coneFun.S180,~] = ConeFundamentals(normalisation="height",geneOpsin="S180");
[coneFun.Both,~] = ConeFundamentals(normalisation="height",geneOpsin="Both");

types = string(fieldnames(coneFun));

f = NewFigWindow;
hold on
styles = ["-","--",":","-."];
x = coneFun.Std.wavelengths;
for i = 1:length(types)
    y = coneFun.(types(i)).lCones;
    plot(x,y,...
        Marker='none',...
        LineStyle=char(styles(i)),LineWidth=3,Color='r');
end
hold off
l = legend(["Standard Observer", "S180 Shift", "A180 Shift", "Shift for Both copies"]);
NiceGraphs(f,l);

