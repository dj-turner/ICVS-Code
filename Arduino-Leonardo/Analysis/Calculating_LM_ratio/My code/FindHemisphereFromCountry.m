function hemisphere = FindHemisphereFromCountry(country)

filePath = "data\Hemispheres.mat";
%% Hemisphere list
if exist(filePath,"file")
    load(filePath); %#ok<*LOAD>
else
   countryHemispheres = table.empty(0,2);
   countryHemispheres.Properties.VariableNames = ["Country", "Hemisphere"];
end

%% Hemisphere numbered
hemisphereList = ["Northern", "Southern", "Equitorial"];

idx = strcmpi(countryHemispheres.Country,country);

if sum(idx) == 1
    hemisphere = countryHemispheres.Hemisphere(idx);
else
    disp("Country " + country + " not added yet! Enter hemisphere: ")
    for i = 1:length(hemisphereList)
        disp(i + "): " + hemisphereList(i));
    end
    cNum = input("");

    hemisphere = hemisphereList(cNum);

    tblRow = array2table([country, hemisphere],"VariableNames", countryHemispheres.Properties.VariableNames);
    countryHemispheres = [countryHemispheres; tblRow];
    save(filePath,"countryHemispheres");
end

end