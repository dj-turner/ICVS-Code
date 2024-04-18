countries = ["UK", "China"];

chinaData = readtable("SurfaceIrradiance.xlsx", 'Sheet', 'China');
ukData = readtable("SurfaceIrradiance.xlsx", 'Sheet', 'China');

chinaData = table2timetable(chinaData(:,1:2));
ukData = table2timetable(ukData(:,1:2));

chinaData = retime(chinaData, 'monthly', 'mean');
ukData = retime(ukData, 'monthly', 'mean');

%%
irradianceData = timetable2table(join(ukData, chinaData));
irradianceData.time.Format = 'MM-yyyy';
irradianceData.Properties.VariableNames = ["date", "UK", "China"];
[irradianceData.year, irradianceData.month, ~] = ymd(irradianceData.date);

%%
save("IrrandianceDataProcessed.mat", "irradianceData")


%%
