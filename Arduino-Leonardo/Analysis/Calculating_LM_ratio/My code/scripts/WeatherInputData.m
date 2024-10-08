function weatherData = WeatherInputData

%% daylight hours
% worlddata.info for respective capital cities
weatherData.daylightHours = readtable("DaylightHours.xlsx");
weatherData.daylightHours = convertvars(weatherData.daylightHours,"Country",'string');

%% sunshine hours
% https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/Sunshine/date/UK.txt
weatherData.sunshineHours.UK = readtable("SunshineHours.xlsx", 'Sheet', 'UK');

% irradiance data
% https://www.renewables.ninja/news/raw-weather-data
irrDataPop = load("IrradianceDataProcessed_pop.mat"); 
weatherData.irradiance.pop = irrDataPop.irradianceData;
irrDataArea = load("IrradianceDataProcessed_area.mat"); 
weatherData.irradiance.area = irrDataArea.irradianceData;

end