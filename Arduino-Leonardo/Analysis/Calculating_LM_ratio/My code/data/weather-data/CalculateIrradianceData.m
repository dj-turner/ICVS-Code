addpath("rawIrradianceData\");

load("countryCodes.mat");
timeTbl = struct;

types = ["land", "pop"];
typeNames = ["area", "pop"];

for t = 1:length(types)
    type = types(t);
    for c = 1:height(countryCodes)
        code = countryCodes(c,2);
        country = countryCodes(c,1);
        fileName = "renewables_ninja_country_" + code + "_irradiance-surface_merra-2_" + type + "-wtd.csv";
        try
            tbl = readtable(fileName, "VariableNamingRule","preserve","Range","A:B");
        catch
            error("Unable to find table for country " + country + " using code " + code + ".");
        end

        timeTbl = table2timetable(tbl);
        monthlyTimeTbl = retime(timeTbl, 'monthly', 'mean');

        monthlyTimeTbl.time.Format = 'MM-yyyy';

        if c == 1
            irradianceData = monthlyTimeTbl;
            irradianceData = [irradianceData, array2table(NaN(height(irradianceData),height(countryCodes)-1))];
        else
            irradianceData(:,c) = monthlyTimeTbl;
        end   
    end
    irradianceData = timetable2table(irradianceData);
    irradianceData.Properties.VariableNames = ["date"; countryCodes(:,1)];
    [irradianceData.year, irradianceData.month, ~] = ymd(irradianceData.date);
   
    savePath = pwd + "\IrradianceDataProcessed_" + typeNames(t) + ".mat";
    save(savePath,"irradianceData");

end