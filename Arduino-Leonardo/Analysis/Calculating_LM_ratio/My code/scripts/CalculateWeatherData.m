%% weather data
weatherData = WeatherInputData;

weathers = ["daylightHours", "sunshineHours", "irradiance_pop", "irradiance_area"];

dayCountries = string(fieldnames(weatherData.daylightHours));
sunCountries = string(fieldnames(weatherData.sunshineHours));

headers = string(weatherData.irradiance.pop.Properties.VariableNames);
idxCell = isstrprop(headers,'upper');
idx = NaN(1, numel(idxCell));
for i = 1:numel(idxCell)
    if sum(cell2mat(idxCell(i))) == 0
        idx(i) = 0;
    else
        idx(i) = 1;
    end
end
idx = logical(idx);
irrCountries = headers(idx);


data.all.daylightHours = NaN(height(data.all),1);
data.all.sunshineHours = NaN(height(data.all),1);
data.all.irradiance_pop = NaN(height(data.all),1);
data.all.irradiance_area = NaN(height(data.all),1);


%% sunshineData
monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

daylightDataList = weatherData.daylightHours;
for country = 1:length(dayCountries)
    daylightDataList.(dayCountries(country)) = repmat(daylightDataList.(dayCountries(country)), [1,2]);
end

irrDataTypes = string(fieldnames(weatherData.irradiance));

%%

for ptpt = 1:height(data.all)
    year = data.all.year(ptpt);
    month = data.all.month(ptpt);
    relevantMonths = month:month+monthTimeFrame;
    country = data.all.country(ptpt);

    if ismember(country,dayCountries) && ~isnan(month)
        daylightData = daylightDataList.(country);
        daylightData = daylightData(relevantMonths);
        daylightData([1,end]) = 0.5*daylightData([1,end]);
        data.all.daylightHours(ptpt) = sum(daylightData) / (length(daylightData)-1);
    end

    if ismember(country,sunCountries) && ~isnan(month) && ~isnan(year)
        idx_x = find(weatherData.sunshineHours.(country).year == year);
        idx_y = ismember(string(weatherData.sunshineHours.(country).Properties.VariableNames), lower(monthVars));
        sunshineData = table2array(weatherData.sunshineHours.(country)([idx_x idx_x+1], idx_y));
        sunshineData = [sunshineData(1,:), sunshineData(2,:)];
        sunshineData = sunshineData(relevantMonths);
        sunshineData([1,end]) = 0.5*sunshineData([1,end]);
        data.all.sunshineHours(ptpt) = sum(sunshineData) / (length(sunshineData)-1);
    end

    if ismember(country,irrCountries) && ~isnan(month) && ~isnan(year) 
        for dataType = 1:length(irrDataTypes)
            idxCell = find(weatherData.irradiance.(irrDataTypes(dataType)).month == month...
                  & weatherData.irradiance.(irrDataTypes(dataType)).year == year);
            if ~isempty(idxCell)
                irradianceData = weatherData.irradiance.(irrDataTypes(dataType))(idxCell:idxCell+monthTimeFrame,country);
                irradianceData = table2array(irradianceData)';
                irradianceData([1,end]) = 0.5*irradianceData([1,end]);
                data.all.(strcat("irradiance_", irrDataTypes(dataType)))(ptpt) = sum(irradianceData) / (length(irradianceData)-1);
            end
        end
    end
end

%%
dataVars = [dataVars, weathers];
numVars = [numVars, weathers];