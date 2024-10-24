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
% - rlmRGY: Rayleigh match RGY values in device units. must be a 1x3 double
% vector. Default = NaN
% - rlmDevice: Device used to conduct Rayleigh match. Options include
% "yellow" and "green". Default = "N/A"
% - geneOpsin: Genetically tested gene opsin for spectral absorbance shift.
% Will only be used if rlmAdjustment isa not used. values = "A180", "S180",
% or "Both".
%   NOTE: If either rlmRGY or rlmDevice are not defined, this function will
%   skip Rayleigh match adjustment of the L-cone spectral sensitivity.
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
% normalisation = "area", pupilSize = "large", rlmRGY = [28 175 170], 
% rlmDevice = "yellow", graphs = "yes");

function [coneFunStruct, parameterStruct] = ConeFundamentals(varargin)
%% INITIATION
% Add data tables to path
addpath("tables\");

% Sets default parameters
parameterStruct = struct('age', 32,... 
                       'fieldSize', 2,... 
                       'pupilSize', "small",... 
                       'normalisation', "none",...
                       'graphs', false,...
                       'rlmRGY', [NaN NaN NaN],...
                       'geneOpsin', "",...
                       'rlmDevice', "N/A");

% Extract defined parameters from varargin and add to parameter structure
fns = string(fieldnames(parameterStruct));
for i = 1:2:length(varargin)-1
    var = string(varargin(i));
    if ~ismember(var,fns)
        error('Parameter variable "' + var + '" is not valid!'... 
        + newline + 'Valid parameter variables include: '...
        + newline + join('"' + fns + '"', ", ") + '.'...
        + newline + 'Note: Parameter variables are case-sensitive!'); 
    end
    val = varargin(i+1);
    type = class(parameterStruct.(var));
    switch type
        case {'string','char'}
            val = lower(string(val)); 
            val = extract(val,lettersPattern);
            % if isempty(val)
            %     ClassErrorMessage(var,type)
            % end
        case 'double'
            try 
                val = cell2mat(val);
            catch 
                ClassErrorMessage(var,type); 
            end
        case 'logical'
            try 
                val = logical(cell2mat(val)); 
            catch 
                ClassErrorMessage(var,type); 
            end
    end
    parameterStruct.(var) = val;
end

% Set default wavelength range
measuredWavelengths = (400:5:700)';

%% Importing density tables
% Spectral absorbance
% load table
spectralAbsorbance = table2array(readtable("spectAbsCie2006.xlsx",Sheet="Corrected"));
% Only include defined wavelengths
idx = ismember(spectralAbsorbance(:,1), measuredWavelengths);
spectralAbsorbance = spectralAbsorbance(idx,2:end);
% Raise to the 10th power
spectralAbsorbance = 10 .^ spectralAbsorbance; 

% Macular density
macularDensity = table2array(readtable("macPigRelative_5.csv"));
macularDensity = macularDensity(:,2:end);

% Lens density
lensDensity = table2array(readtable("lens2components.csv"));
lensDensity = lensDensity(:,2:end); 

%% Adjusting L-cone Spectral Absorbance using RLM Data
rlmAdj = sum(isnan(parameterStruct.rlmRGY)) == 0 & ~strcmpi(parameterStruct.rlmDevice,"N/A");

if rlmAdj
    [optLConeSA, optLConePSS] = EstimatingOptimalLConeSpectAbsShift(spectralAbsorbance, parameterStruct.rlmRGY,... 
        parameterStruct.rlmDevice, parameterStruct.graphs);
    spectralAbsorbance(:,4) = spectralAbsorbance(:,1);
    spectralAbsorbance(:,1) = optLConeSA;
else
    spectralAbsorbance(:,1) = GeneOpsinConeFunShift(spectralAbsorbance(:,1),parameterStruct.geneOpsin);
end

%% Lens density and pupil size
switch lower(parameterStruct.pupilSize)
    case {"l","large"}
        lensDensity = lensDensity .* .86207;
    case {"s","small"}
    otherwise
        error("Pupil size must be set as ""small"" or ""large""!");
end

%% 5.3 - Peak optical density & Field Size
validFieldSize = parameterStruct.fieldSize >= 1 && parameterStruct.fieldSize <= 10;
if validFieldSize
    dtMaxMacula = 0.485 .* exp(-parameterStruct.fieldSize / 6.132);
else
    error("Field size must be set between 1 and 10!");
end

%% 5.6 - Spectral optical density & Age
ageGroup = discretize(parameterStruct.age, [20 60 80]);

switch ageGroup
    case 1
        dtOculConstants = [1 .02 32];
    case 2
        dtOculConstants = [1.56 .0667 60];
    otherwise
        error("Age must be set between 20 and 80!");
end

dtOcul = (lensDensity(:,1) * (dtOculConstants(1) + (dtOculConstants(2) *... 
    (parameterStruct.age - dtOculConstants(3))))) + lensDensity(:,2);

%% 5.7 - Visual Pigments & Field Size
dtMaxConstants = [0.38, 0.54; 0.38, 0.54; 0.30, 0.45];

dtMax = dtMaxConstants(:,1) + dtMaxConstants(:,2) *... 
    exp(-parameterStruct.fieldSize / 1.333);

if rlmAdj, dtMax = [dtMax; dtMax(1)]; end

%% 5.9 - Cone Fundamentals
aiTbl = 1 - (10 .^ (-dtMax' .* spectralAbsorbance));

coneFunTbl = aiTbl .* (10 .^ (-dtMaxMacula .* macularDensity - dtOcul));
coneFunTbl = coneFunTbl .* measuredWavelengths;

coneFunTbl(isnan(coneFunTbl)) = 0;

%% Normalise curves
coneFunTbl = CurveNormalisation(coneFunTbl, parameterStruct.normalisation);

%% Draw graph
if parameterStruct.graphs
    cones = ['r','g','b','m'];
    NewFigWindow;
    hold on
    for cone = 1:width(coneFunTbl)
        plot(measuredWavelengths, coneFunTbl(:,cone),... 
            "LineWidth", 2, "Color", cones(cone),...
            'Marker', 'o', 'MarkerEdgeColor', 'w', 'MarkerSize', .5)
    end
    xlim([min(measuredWavelengths), max(measuredWavelengths)]);
    ylim([0,max(coneFunTbl,[],"all")]);
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
    lgdLabs = ["L-cone", "M-cone", "S-cone", "Unadj. L-Cone"];
    legend(lgdLabs(1:width(coneFunTbl)),'Location','northeastoutside','TextColor','w','FontSize',30);
end

%% Store data in structure
coneFunStruct = struct("wavelengths", measuredWavelengths,... 
    "lCones", coneFunTbl(:,1),...
    "mCones", coneFunTbl(:,2),...
    "sCones", coneFunTbl(:,3));

if rlmAdj
    coneFunStruct.unadjLCones = coneFunTbl(:,4);
    coneFunStruct.spectAbsShift = optLConePSS;

    pssUnadj = measuredWavelengths(coneFunTbl(:,4)==max(coneFunTbl(:,4)));
    pssAdj = measuredWavelengths(coneFunTbl(:,1)==max(coneFunTbl(:,1)));
    coneFunStruct.peakSpectSensShift = pssAdj - pssUnadj;
else
    coneFunStruct.spectAbsShift = 0;
    coneFunStruct.peakSpectSensShift = 0;
end

%% FUNCTIONS
function ClassErrorMessage(var,type)

switch type
    case {"string","char"}
        typeStr = '"string" or "char"';
    case "logical"
        typeStr = '"logical" or "double" (0/1)';
    otherwise
        typeStr = '"' + type + '"';  
end

error('Parameter value for variable "' + var + '" is invalid!'...
    + newline + 'Input should be class ' + typeStr + '.');
end

end


