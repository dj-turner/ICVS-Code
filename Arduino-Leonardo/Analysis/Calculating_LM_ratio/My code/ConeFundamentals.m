function cone_fundamentals_struct = ConeFundamentals(age, field_size, pupil_size, graphs)
%% INITIATION
% Add data tables tp path
addpath("tables\");

% Sets default parameterts for undefined variables
if ~exist("age", 'var'), age = 32; disp("Age default used (32)"); end
if ~exist("field_size", 'var'), field_size = 2; disp("Field size default used (2)"); end
if ~exist("pupil_size", 'var'), pupil_size = "small"; disp("Pupil size default used (small)");end
if ~exist("graphs", 'var'), graphs = "no"; disp("Graph default used (no)"); end

% Set default wavelength range
wavelengths = 400:5:700;

%% Importing density tables
% Spectral absorbance
% load table
spectral_absorbance = table2array(readtable("ssabance_5.csv"));
% Separate wavelengths
wavelengths_sa = spectral_absorbance(:,1);
% Only include defined wavelengths
spectral_absorbance = spectral_absorbance(ismember(wavelengths_sa, wavelengths),2:end);
% Raise to the 10th power
spectral_absorbance = 10 .^ spectral_absorbance; 
% Scale so that max value = 1
spectral_absorbance = spectral_absorbance ./ max(spectral_absorbance);

% Macular density
macular_density = table2array(readtable("macPigRelative_5.csv"));
macular_density = macular_density(:,2:end);

% Lens density
lens_density = table2array(readtable("lens2components.csv"));
lens_density = lens_density(:,2:end); 

% Lens density and pupil size
if sum(strcmpi(pupil_size, ["large","l"]))
    lens_density = lens_density .* .86207;
elseif ~sum(strcmpi(pupil_size, ["small","s"]))
    error("Pupil size must be set as ""small"" (""s"") or ""large"" (""l"")!");
end

% 5.3 - Peak optical density & Field Size
if field_size >= 1 && field_size <= 10
    Dt_max_macula = 0.485 .* exp(-field_size / 6.132);
else
    error("Field size must be set between 1 and 10!");
end

% 5.6 - Spectral optical density & Age
if age >= 20 && age <=60
    Dt_ocul_constants = [1 .02 32];
elseif age > 60 && age <= 80
    Dt_ocul_constants = [1.56 .0667 60];
else
    error("Age must be set between 20 and 80!");
end

Dt_ocul = (lens_density(:,1) * (Dt_ocul_constants(1) + (Dt_ocul_constants(2) * (age - Dt_ocul_constants(3))))) + lens_density(:,2);

% 5.7 - Visual Pigments & Field Size
Dt_max_constants = [0.38, 0.54; 0.38, 0.54; 0.30, 0.45];

Dt_max = Dt_max_constants(:,1) + Dt_max_constants(:,2) * exp(-field_size / 1.333);

% 5.9 - Cone Fundamentals
ai_tbl = 1 - (10 .^ (-Dt_max' .* spectral_absorbance));
cone_fundamentals_tbl = ai_tbl .* (10 .^ (-Dt_max_macula .* macular_density - Dt_ocul));
cone_fundamentals_tbl = cone_fundamentals_tbl .* wavelengths';

cone_fundamentals_tbl(isnan(cone_fundamentals_tbl)) = 0;

% normalise so that all cones have the same area under curve
areas = trapz(wavelengths, cone_fundamentals_tbl);
cone_fundamentals_tbl = cone_fundamentals_tbl ./ areas; 

% Draw graph
if sum(strcmpi(graphs, ["yes","y"]))
    cones = ['r', 'g', 'b'];
    hold on
    for cone = 1:length(cones)
        plot(wavelengths, cone_fundamentals_tbl(:,cone), "LineWidth", 2, "Color", cones(cone))
    end
    xlim([min(wavelengths), max(wavelengths)]);
    xlabel("Wavelength (nm)");
    ylabel("Cone Fundamentals");
    title("Chapter 5");
    text(610, .9, strjoin(["Age = ", age, ","... 
        newline, "Field Size = ", field_size, "°,",...
        newline, "Pupil Size = ", pupil_size],''));
    hold off
elseif ~sum(strcmpi(graphs, ["no","n"]))
    disp("Graphs must be set as ""yes"" (""y"") or ""no"" (""n"")!");
    disp("For this run, I'll assume you don't want graphs.");
end

% store data in structure
cone_fundamentals_struct = struct("wavelengths", wavelengths,... 
    "lCones", cone_fundamentals_tbl(:,1),...
    "mCones", cone_fundamentals_tbl(:,2),...
    "sCones", cone_fundamentals_tbl(:,3));
end
