analysisDir = pwd;
cd('C:\Users\dturner\Documents\IrradianceData'); 

files = dir('irradiance-*.csv');
fileNames = strings(1, numel(files));
for i = 1:numel(files), fileNames(i) = files(i).name; end
countries = extractBetween(fileNames, "irradiance-", ".csv");

for country = 1:length(countries)
    cData = readtable(fileNames(country));
    cData = table2timetable(cData(:,1:2));
    cData = retime(cData, 'monthly', 'mean');
    if country == 1
        irradianceData = timetable2table(cData);
    else
        irradianceData = join(irradianceData, timetable2table(cData));
    end
end

irradianceData.time.Format = 'MM-yyyy';
irradianceData.Properties.VariableNames = ["date", countries];
[irradianceData.year, irradianceData.month, ~] = ymd(irradianceData.date);

cd(analysisDir);
save("IrradianceDataProcessed.mat", "irradianceData")
