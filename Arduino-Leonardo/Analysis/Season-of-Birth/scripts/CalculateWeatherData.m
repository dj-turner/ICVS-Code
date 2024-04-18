%% weather data
weatherData = WeatherInputData;

weathers = string(fieldnames(weatherData));
countries = string(fieldnames(weatherData.(weathers(1))));

for weather = 1:length(weathers)
    data.all.(weathers(weather)) = NaN(height(data.all),1);
end

%% sunshineData
monthVars = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

daylightDataList = weatherData.daylightHours;
for country = 1:length(countries)
    daylightDataList.(countries(country)) = repmat(daylightDataList.(countries(country)), [1,2]);
end
%%

for ptpt = 1:height(data.all)
    year = data.all.year(ptpt);
    month = data.all.month(ptpt);
    relevantMonths = month:month+monthTimeFrame;
    country = data.all.country(ptpt);

    if ismember(country,countries) && ~isnan(month)
        daylightData = daylightDataList.(country);
        daylightData = daylightData(relevantMonths);
        daylightData([1,end]) = 0.5*daylightData([1,end]);
        data.all.daylightHours(ptpt) = sum(daylightData);

        if ~isnan(year)
            idx = find(weatherData.irradiance.(country).month == month...
                  & weatherData.irradiance.(country).year == year);
            if ~isempty(idx)
                irradianceData = weatherData.irradiance.(country);
                irradianceData = irradianceData(idx:idx+monthTimeFrame,country);
                irradianceData = table2array(irradianceData)';
                irradianceData([1,end]) = 0.5*irradianceData([1,end]);
                data.all.irradiance(ptpt) = sum(irradianceData);
            end

            if strcmp(country,"UK")
                idx_x = find(weatherData.sunshineHours.(country).year == year);
                idx_y = ismember(string(weatherData.sunshineHours.(country).Properties.VariableNames), lower(monthVars));
                sunshineData = table2array(weatherData.sunshineHours.(country)([idx_x idx_x+1], idx_y));
                sunshineData = [sunshineData(1,:), sunshineData(2,:)];
                sunshineData = sunshineData(relevantMonths);
                sunshineData([1,end]) = 0.5*sunshineData([1,end]);
                data.all.sunshineHours(ptpt) = sum(sunshineData);
            end
        end
    end
end

%%
dataVars = [dataVars, weathers'];
numVars = [numVars, weathers'];