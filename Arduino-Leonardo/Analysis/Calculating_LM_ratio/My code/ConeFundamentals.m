function [cone_fundamentals_tbl, wavelengths] = ConeFundamentals(age, field_size, pupil_size, graphs)

cones = ['r', 'g', 'b'];
addpath("tables\");

if ~exist("field_size", 'var'), field_size = 2; end

% Importing density tables
spectral_absorbance = table2array(readtable("ssabance_5.csv"));
wavelengths = spectral_absorbance(:,1);
spectral_absorbance = spectral_absorbance(:,2:end);
spectral_absorbance = 10 .^ spectral_absorbance; 
for cone = 1:length(cones)
    spectral_absorbance(:,cone) = spectral_absorbance(:,cone) ./ max(spectral_absorbance(:,cone));
end

macular_density = table2array(readtable("macPigRelative_5.csv")); % ask Allie
macular_density = macular_density(:,2:end);

lens_density = table2array(readtable("lens2components.csv")); % ask Allie
lens_density = lens_density(:,2:end); 

% Wavelengths
idx = wavelengths >= 400 & wavelengths <= 700;
wavelengths = wavelengths(idx,:);
spectral_absorbance = spectral_absorbance(idx,:);

% Lens density and pupil size
if exist("pupil_size", 'var')
    if strcmpi(pupil_size, "large") || strcmpi(pupil_size, "l")
        lens_density = lens_density .* .86207;
    elseif ~strcmpi(pupil_size, "small") && ~strcmpi(pupil_size, "s") && ~strcmpi(pupil_size, "default")
        disp("Please set variable pupil_size to a valid string!");
        disp("Valid string values: ""default"", ""small"", ""s"", ""large"", ""l""");
        return;
    end
end

% 5.3 - Peak optical density & Field Size
if field_size >= 1 && field_size <= 10
    Dt_max_macula = 0.485 .* exp(-field_size / 6.132);
else
    disp("Field size must be set between 1 and 10!");
    return
end

% 5.6 - Spectral optical density & Age
Dt_ocul = zeros(height(wavelengths),1);

if age >= 20 && age <=60
    for wavelength = 1:height(wavelengths)
        Dt_ocul(wavelength) = (lens_density(wavelength,1) * (1 + (0.02 * (age - 32)))) + lens_density(wavelength,2);
    end

elseif age > 60 && age <= 80
    for wavelength = 1:height(wavelengths)
        Dt_ocul(wavelength) = (lens_density(wavelength,1) * (1.56 + (0.0667 * (age - 60)))) + lens_density(wavelength,2);
    end

else
    disp("Age must be set between 20 and 80!");
    return
end

% 5.7 - Visual Pigments & Field Size
Dt_max = zeros(1,length(cones));
D_max_constants = [0.38, 0.54;... 
                    0.38, 0.54;... 
                    0.30, 0.45];

for cone = 1:length(cones)
    Dt_max(cone) = D_max_constants(cone,1) + D_max_constants(cone,2) * exp(-field_size / 1.333);
end

% 5.9 - Cone Fundamentals
ai_tbl = zeros(height(wavelengths), length(cones));
for wavelength = 1:height(wavelengths)
    for cone = 1:length(cones)
        ai_tbl(wavelength,cone) = 1 - (10 ^ (-Dt_max(cone) * spectral_absorbance(wavelength,cone)));
    end
end

cone_fundamentals_tbl = zeros(height(wavelengths), length(cones));
for wavelength = 1:height(wavelengths)
    for cone = 1:length(cones)
        cone_fundamentals_tbl(wavelength,cone) = ai_tbl(wavelength,cone) * (10 ^ (-Dt_max_macula * macular_density(wavelength) - Dt_ocul(wavelength)));
    end
end

for cone = 1:length(cones)
    cone_fundamentals_tbl(:,cone) = cone_fundamentals_tbl(:,cone) .* wavelengths;
    cone_fundamentals_tbl(:,cone) = cone_fundamentals_tbl(:,cone) ./ max(cone_fundamentals_tbl(:,cone));
end

cone_fundamentals_tbl(isnan(cone_fundamentals_tbl)) = 0;

% Draw graph
if exist("graphs", 'var')
    if strcmpi(graphs, "yes") || strcmpi(graphs, "y")
        for cone = 1:length(cones)
            x = wavelengths;
            y = cone_fundamentals_tbl(:,cone);
            plot(x, y, "LineWidth", 2, "Color", cones(cone))
            hold on
        end
        ylim([0, 1]);
        xlim([min(x), max(x)]);
        xlabel("Wavelength (nm)");
        ylabel("Cone Fundamentals");
        title("Chapter 5");
        text(610, .9, strjoin(["Age = ", age, "," newline, "Field Size = ", field_size, "°"],''));
        hold off
    end
end

end
