% problem row was 599

data = load("CalibrationResults.mat");
data = data.calibrationTable;

devices = ["Yellow Band", "Green Band", "Test red band device"];

rgLums = double.empty(0,length(devices));
dateTimes = datetime.empty(0,length(devices));

for device = 1:length(devices)
    idx = strcmp(data.Device, devices(device))...
        & (strcmp(data.LED, "red") | strcmp(data.LED, "green"))...
        & data.InputValue == 255;
    
    vars = ["DateTime", "LED", "Luminance"];
    
    deviceData = data(idx, vars);

    row = 0;
    for i = 1:2:height(deviceData)
        row=row+1;
        dateTimes(row,device) = deviceData.DateTime(i);
        rgLums(row,device) = deviceData.Luminance(i) / deviceData.Luminance(i+1);
    end
end
rgLums(rgLums == 0) = NaN;


t = tiledlayout(1,2);
nexttile

hold on
colours = ['b', 'g', 'r'];
for device = 1:width(rgLums)
    scatter(dateTimes(:,device), rgLums(:,device), 'MarkerEdgeColor', colours(device), 'Marker', 'x')
end
hold off

nexttile
b = boxplot(rgLums, 'Labels', devices);

