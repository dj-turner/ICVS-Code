%% weather data
weatherData = WeatherInputData;

weathers = string(fieldnames(weatherData));

dayCountries = string(fieldnames(weatherData.daylightHours));
sunCountries = string(fieldnames(weatherData.sunshineHours));

headers = string(weatherData.irradiance.Properties.VariableNames);
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

for weather = 1:length(weathers)
    data.all.(weathers(weather)) = NaN(height(data.all),1);
end

%% sunshineData
monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

daylightDataList = weatherData.daylightHours;
for country = 1:length(dayCountries)
    daylightDataList.(dayCountries(country)) = repmat(daylightDataList.(dayCountries(country)), [1,2]);
end
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
        data.all.sunshineHours(ptpt) = sum(sunshineData)  / (length(sunshineData)-1);
    end

    if ismember(country,irrCountries) && ~isnan(month) && ~isnan(year)
        idxCell = find(weatherData.irradiance.month == month...
              & weatherData.irradiance.year == year);
        if ~isempty(idxCell)
            irradianceData = weatherData.irradiance(idxCell:idxCell+monthTimeFrame,country);
            irradianceData = table2array(irradianceData)';
            irradianceData([1,end]) = 0.5*irradianceData([1,end]);
            data.all.irradiance(ptpt) = sum(irradianceData) / (length(irradianceData)-1);
        end
    end
end

%%
dataVars = [dataVars, weathers'];
numVars = [numVars, weathers'];