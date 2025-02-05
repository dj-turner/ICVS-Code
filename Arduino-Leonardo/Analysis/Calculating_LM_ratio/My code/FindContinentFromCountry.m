function continent = FindContinentFromCountry(country)

filePath = "data\Continents.mat";
%% Continent list
if exist(filePath,"file")
    load(filePath); %#ok<*LOAD>
else
   countryContinents = table.empty(0,2);
   countryContinents.Properties.VariableNames = ["Country", "Continent"];
end

%% Continents numbered
continentList = ["Europe", "N. America", "Asia", "Africa", "S. America", "Oceania", "Antarctica"];

idx = strcmpi(countryContinents.Country,country);

if sum(idx) == 1
    continent = countryContinents.Continent(idx);
else
    disp("Country " + country + " not added yet! Enter continent: ")
    for i = 1:length(continentList)
        disp(i + "): " + continentList(i));
    end
    cNum = input("");

    continent = continentList(cNum);

    tblRow = array2table([country, continent],"VariableNames", countryContinents.Properties.VariableNames);
    countryContinents = [countryContinents; tblRow];
    save(filePath,"countryContinents");
end

end