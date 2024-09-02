function equ = FindRedGreenLedEquation(calTbl, devices)

if ~exist("devices",'var'), devices = ["yellow","green"]; end
lights = ["red","green"];
s = struct;
equ = struct;

% NewFigWindow;
% hold on
for device = 1:length(devices), d = devices(device);
    for light = 1:length(lights), l = lights(light);
    
        idx = strcmp(calTbl.Device, proper(d+ " band"))...
            & strcmp(calTbl.LED, l)...
            & calTbl.InputValue == 255;

        s.(d).(l) = calTbl(idx,"Luminance");
        s.(d).(l).Properties.VariableNames = l;
    end

    tbl = [s.(d).red,s.(d).green];
    tbl = sortrows(tbl,"red","ascend");
    % col = char(d); col = col(1);
    % plot(tbl.red,tbl.green,'Color',col,'LineWidth',3);
    fitvars = polyfit(tbl.red,tbl.green,1);
    equ.(d).m = fitvars(1);
    equ.(d).c = fitvars(2);
    % x = tbl.red;
    % y = equ.(d).m .* x + equ.(d).c;
    % plot(x,y,'Color',col,'LineStyle','--');  
end
% hold off
% NiceGraphs

end
