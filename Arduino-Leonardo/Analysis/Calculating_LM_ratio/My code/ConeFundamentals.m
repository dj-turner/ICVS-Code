function [coneFunStruct, inputStruct] = ConeFundamentals(varargin)
%% INITIATION
% Add data tables tp path
addpath("tables\");

% Sets default parameters for undefined variables
defaultStruct = struct('age', 32,... 
                       'fieldSize', 2,... 
                       'normalisation', "none",...
                       'pupilSize', "small",... 
                       'graphs', "yes");

% Extract defined parameters from varargin
inputStruct = struct;
for i = 1:2:length(varargin)-1
    var = string(varargin(i+1));
    if ~isnan(str2double(var)), try var = str2double(var); catch; end; end
    inputStruct.(string(varargin(i))) = var;
end

% List fields in both structs
allFields = fieldnames(defaultStruct); 
% List fields missing in inputStruct
idx = find(~ismember(allFields,fieldnames(inputStruct)));
% Assign missing fields to inputStruct
for i = 1:length(idx), inputStruct.(allFields{idx(i)}) = defaultStruct.(allFields{idx(i)}); end

% Set default wavelength range
measuredWavelengths = (400:5:700)';

%% Importing density tables
% Spectral absorbance
% load table
spectralAbsorbance = table2array(readtable("ssabance_5.csv"));
% Separate wavelengths
saWavelengths = spectralAbsorbance(:,1);
% Only include defined wavelengths
spectralAbsorbance = spectralAbsorbance(ismember(saWavelengths, measuredWavelengths),2:end);
% Raise to the 10th power
spectralAbsorbance = 10 .^ spectralAbsorbance; 
% Scale so that max value = 1
spectralAbsorbance = spectralAbsorbance ./ max(spectralAbsorbance);

% Macular density
macularDensity = table2array(readtable("macPigRelative_5.csv"));
macularDensity = macularDensity(:,2:end);

% Lens density
lensDensity = table2array(readtable("lens2components.csv"));
lensDensity = lensDensity(:,2:end); 

% Lens density and pupil size
if strcmpi(inputStruct.pupilSize, "large")
    lensDensity = lensDensity .* .86207;
elseif ~strcmpi(inputStruct.pupilSize, "small")
    error("Pupil size must be set as ""small"" or ""large""!");
end

% 5.3 - Peak optical density & Field Size
if inputStruct.fieldSize >= 1 && inputStruct.fieldSize <= 10
    dtMaxMacula = 0.485 .* exp(-inputStruct.fieldSize / 6.132);
else
    error("Field size must be set between 1 and 10!");
end

% 5.6 - Spectral optical density & Age
if inputStruct.age >= 20 && inputStruct.age <=60
    dtOculConstants = [1 .02 32];
elseif inputStruct.age > 60 && inputStruct.age <= 80
    dtOculConstants = [1.56 .0667 60];
else
    error("Age must be set between 20 and 80!");
end

dtOcul = (lensDensity(:,1) * (dtOculConstants(1) + (dtOculConstants(2) * (inputStruct.age - dtOculConstants(3))))) + lensDensity(:,2);

% 5.7 - Visual Pigments & Field Size
dtMaxConstants = [0.38, 0.54; 0.38, 0.54; 0.30, 0.45];

dtMax = dtMaxConstants(:,1) + dtMaxConstants(:,2) * exp(-inputStruct.fieldSize / 1.333);

% 5.9 - Cone Fundamentals
aiTbl = 1 - (10 .^ (-dtMax' .* spectralAbsorbance));
coneFunTbl = aiTbl .* (10 .^ (-dtMaxMacula .* macularDensity - dtOcul));
coneFunTbl = coneFunTbl .* measuredWavelengths;

coneFunTbl(isnan(coneFunTbl)) = 0;

% Lambda max adjustment using RLM data

% normalise so that all cones have the same area under curve / same height
switch inputStruct.normalisation
    case "area"
        areas = trapz(measuredWavelengths, coneFunTbl);
        coneFunTbl = coneFunTbl ./ areas; 
    case "height"
        coneFunTbl = coneFunTbl ./ max(coneFunTbl);
end

% Draw graph
if strcmpi(inputStruct.graphs,"yes")
    cones = ['r', 'g', 'b'];
    hold on
    for cone = 1:length(cones)
        plot(measuredWavelengths, coneFunTbl(:,cone), "LineWidth", 2, "Color", cones(cone),...
            'Marker', 'o', 'MarkerEdgeColor', 'w', 'MarkerSize', .5)
    end
    xlim([min(measuredWavelengths), max(measuredWavelengths)]);
    xlabel("Wavelength (nm)");
    ylabel("Reltive Spectral Sensitivities");
    title("Cone Fundamentals");
    text(.9*max(measuredWavelengths), .9*max(coneFunTbl,[],"all"), strjoin([...
                 "Age = ", inputStruct.age, ","... 
        newline, "Field Size = ", inputStruct.fieldSize, "°,",...
        newline, "Pupil Size = ", inputStruct.pupilSize, ",",...
        newline, "Normalisation = ", inputStruct.normalisation
        ],''));
    hold off
elseif ~strcmpi(inputStruct.graphs,"no")
    disp("Graphs must be set as ""yes"" or ""no""!");
    disp("For this run, I'll assume you don't want graphs.");
end

% store data in structure
coneFunStruct = struct("wavelengths", measuredWavelengths,... 
    "lCones", coneFunTbl(:,1),...
    "mCones", coneFunTbl(:,2),...
    "sCones", coneFunTbl(:,3));

end
