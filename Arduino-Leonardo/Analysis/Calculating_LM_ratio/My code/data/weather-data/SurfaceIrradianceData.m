analysisDir = pwd;
dataDir = 'C:\Users\dturner\Documents\IrradianceData';

cd(dataDir); 
files = dir('irradiance-*.csv');
fileNames = strings(1, numel(files));
for i = 1:numel(files), fileNames(i) = files(i).name; end
countryStrings = split(fileNames, "-");

dataTypes = unique(countryStrings(:,:,2));
countries = unique(extractBefore(countryStrings(:,:,3), ".csv"));

%%

for dataType = 1:length(dataTypes)
    cd(dataDir);
    for country = 1:length(countries)
        idx = contains(fileNames, dataTypes(dataType)) & contains(fileNames, countries(country));
        cData = readtable(fileNames(idx));
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
    matName = strcat("IrradianceDataProcessed_", dataTypes(dataType), ".mat");
    save(matName, "irradianceData")
end
