function equ = FindLedEquations(calTbl,devices,graphs)

if ~exist("devices",'var'), devices = ["yellow","green"]; end
if ~exist("graphs",'var'), graphs = false; end
lights = ["red","green","yellow"];
s = struct;
equ = struct;

if graphs, NewFigWindow; tiledlayout(length(devices),length(lights)-1); end
for device = 1:length(devices), d = devices(device);
    for light = 1:length(lights), l = lights(light);
    
        idx = strcmp(calTbl.Device, proper(d+ " band"))...
            & strcmp(calTbl.LED, l)...
            & calTbl.InputValue == 255;

        s.(d).(l) = calTbl(idx,"Luminance");
        s.(d).(l).Properties.VariableNames = l;
    end

    l1 = lights(1);
    for light = 2:length(lights), l = lights(light);
        col = char(l); col = col(1);
        tbl = [s.(d).(l1), s.(d).(l)];
        tbl = sortrows(tbl,l1,"ascend");
        fitvars = polyfit(tbl.(l1),tbl.(l),1);
        equ.(d).(col).m = fitvars(1);
        equ.(d).(col).c = fitvars(2);
        x = tbl.(l1);
        y = equ.(d).(col).m .* x + equ.(d).(col).c;
        if graphs
            nexttile
            hold on
            plot(x,tbl.(l),'Color',col,'LineWidth',3);
            plot(x,y,'Color',col,'LineStyle','--');
            title("Device = " + d);
            xlabel(l1); ylabel(l);
            xlim([min(x),max(x)]); ylim([min(tbl.(l)),max(tbl.(l))]);
            hold off
            NiceGraphs
        end
    end
end

end
