% [coneFunStruct, parameterStruct] = ConeFundamentals(varargin)
% A function that estimates the cone fundamentals of an individual.
%
% INPUT VALUES (Case-sensitive, will use default values listed if not defined):
% - age: Age, in years, of the participant. Must be between 20 and 80
% inclusive. Default = 32
% - fieldSize: Field size of stimulus used. Must be between 1 and 10
% degrees inclusive. Default = 2
% - pupilSize: Size of the participant's pupil. Options include "small" or
% "large". Default = "small"
% - normalisation: Normalisation of the cone fundamentals - sets the 
% requested parameter to 1 for all cone types. Options include "none", 
% "height", or "area". Default = "none"
% - graphs: Whether a graph displaying the outputted cone fundamentals is
% generated and displayed. Options include "yes" or "no". Default = "no"
%
% OUTPUT VALUES:
% - coneFunStruct: Structure including the wavelengths (nm) and spectral
% sensitivies of the l-, m-, and s-cones scaled according to the
% "normalisation" input parameter.
% - parameterStruct: Structure containing all the parameters used and their
% values. Includes the default parameter values, custom-set values, and
% additional parameters set on input.
%
% EXAMPLE USAGE:
% [coneFuns, parametersUsed] = ConeFundamentals(age = 21, fieldSize = 10,
% normalisation = "area", pupilSize = "large", graphs = "yes");

function [coneFunStruct, parameterStruct] = ConeFundamentals(varargin)
%% INITIATION
% Add data tables tp path
addpath("tables\");

% Sets default parameters
parameterStruct = struct('age', 32,... 
                       'fieldSize', 2,... 
                       'pupilSize', "small",... 
                       'normalisation', "none",...
                       'graphs', "no");

% Extract defined parameters from varargin and add to parameter structure
for i = 1:2:length(varargin)-1
    val = lower(string(varargin(i+1)));
    if ~isnan(str2double(val)), val = str2double(val); end
    parameterStruct.(string(varargin(i))) = val;
end

% Set default wavelength range
measuredWavelengths = (400:5:700)';

%% Importing density tables
% Spectral absorbance
% load table
spectralAbsorbance = table2array(readtable("ssabance_5.csv"));
% Only include defined wavelengths
spectralAbsorbance = spectralAbsorbance(ismember(spectralAbsorbance(:,1), measuredWavelengths),2:end);
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
if strcmp(parameterStruct.pupilSize, "large")
    lensDensity = lensDensity .* .86207;
elseif ~strcmp(parameterStruct.pupilSize, "small")
    error("Pupil size must be set as ""small"" or ""large""!");
end

% 5.3 - Peak optical density & Field Size
if parameterStruct.fieldSize >= 1 && parameterStruct.fieldSize <= 10
    dtMaxMacula = 0.485 .* exp(-parameterStruct.fieldSize / 6.132);
else
    error("Field size must be set between 1 and 10!");
end

% 5.6 - Spectral optical density & Age
if parameterStruct.age >= 20 && parameterStruct.age <=60
    dtOculConstants = [1 .02 32];
elseif parameterStruct.age > 60 && parameterStruct.age <= 80
    dtOculConstants = [1.56 .0667 60];
else
    error("Age must be set between 20 and 80!");
end

dtOcul = (lensDensity(:,1) * (dtOculConstants(1) + (dtOculConstants(2) *... 
    (parameterStruct.age - dtOculConstants(3))))) + lensDensity(:,2);

% 5.7 - Visual Pigments & Field Size
dtMaxConstants = [0.38, 0.54; 0.38, 0.54; 0.30, 0.45];

dtMax = dtMaxConstants(:,1) + dtMaxConstants(:,2) *... 
    exp(-parameterStruct.fieldSize / 1.333);

% 5.9 - Cone Fundamentals
aiTbl = 1 - (10 .^ (-dtMax' .* spectralAbsorbance));
coneFunTbl = aiTbl .* (10 .^ (-dtMaxMacula .* macularDensity - dtOcul));
coneFunTbl = coneFunTbl .* measuredWavelengths;

coneFunTbl(isnan(coneFunTbl)) = 0;

% Lambda max adjustment using RLM data


% Normalise curves
switch parameterStruct.normalisation
    case "none"
    case "height"
        coneFunTbl = coneFunTbl ./ max(coneFunTbl);
    case "area"
        coneFunTbl = coneFunTbl ./ trapz(measuredWavelengths, coneFunTbl); 
    otherwise
        error("""normalisation"" parameter must be set to ""none"", ""height"", or ""area""!");
end

% Draw graph
if strcmp(parameterStruct.graphs,"yes")
    cones = ['r', 'g', 'b'];
    hold on
    for cone = 1:length(cones)
        plot(measuredWavelengths, coneFunTbl(:,cone),... 
            "LineWidth", 2, "Color", cones(cone),...
            'Marker', 'o', 'MarkerEdgeColor', 'w', 'MarkerSize', .5)
    end
    xlim([min(measuredWavelengths), max(measuredWavelengths)]);
    xlabel("Wavelength (nm)");
    ylabel("Relative Spectral Sensitivities");
    title("Cone Fundamentals");
    text(.9*max(measuredWavelengths), .9*max(coneFunTbl,[],"all"), strjoin([...
                 "Age = ", parameterStruct.age, ","... 
        newline, "Field Size = ", parameterStruct.fieldSize, "°,",...
        newline, "Pupil Size = ", parameterStruct.pupilSize, ",",...
        newline, "Normalisation = ", parameterStruct.normalisation
        ],''));
    hold off
    NiceGraphs
elseif ~strcmp(parameterStruct.graphs,"no")
    disp("Graphs must be set as ""yes"" or ""no""!");
    disp("For this run, I'll assume you don't want graphs.");
end

% store data in structure
coneFunStruct = struct("wavelengths", measuredWavelengths,... 
    "lCones", coneFunTbl(:,1),...
    "mCones", coneFunTbl(:,2),...
    "sCones", coneFunTbl(:,3));

end
