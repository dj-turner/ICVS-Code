function weatherData = WeatherInputData

%% daylight hours
% worlddata.info for respective capital cities
% weatherData.daylightHours.UK = [8+(24/60), 10+(3/60), 11+(56/60),... 
%                    13+(58/60), 15+(43/60), 16+(41/60),... 
%                    16+(14/60), 14+(39/60), 12+(42/60),... 
%                    10+(45/60), 8+(55/60), 7+(56/60)];
% 
% weatherData.daylightHours.China = [9+(41/40), 10+(44/60), 11+(58/60),...
%                       13+(19/60), 14+(26/60), 15+(3/60),...
%                       14+(47/60), 13+(48/60), 12+(31/60),...
%                       11+(13/60), 10+(2/60), 9+(25/60)];

weatherData.daylightHours = readtable("DaylightHours.xlsx");

% sunshine hours (https://en.wikipedia.org/wiki/List_of_cities_by_sunshine_duration)
% weatherData.sunshineHours.UK = [62, 78, 115, 169, 199, 204,... 
%                                 212, 205, 149, 117, 73, 52];

% weatherData.sunshineHours.China = [194.1, 197.4, 231.8, 251.9,...
%                                    283.4, 261.4, 212.4, 220.9,...
%                                    232.1, 222.1, 185.3, 180.7];

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