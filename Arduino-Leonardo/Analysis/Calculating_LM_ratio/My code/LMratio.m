clc; clear; close;

% Define variables
hfpVar = "HFP_Uno_Red_Mean";
graphDim = [4,4];

% Load data
wavelengths = (400:5:700)';
data = struct; 

dataTbl = readtable("Data-Pt1.2.xlsx", "Sheet", "MATLAB_Data", "VariableNamingRule", "preserve");

% lumFunc = readtable("tables\linCIE2008v2e_5.csv");
% lumFunc.Properties.VariableNames = ["Wavelength", "Vlambda"];
% lumFunc = lumFunc(lumFunc.Wavelength >= min(wavelengths) & lumFunc.Wavelength <= max(wavelengths), :);

PPno = max(table2array(dataTbl(:,"PPno")));
PPcodes = [(1:PPno)', unique(string(table2array(dataTbl(:,"PPcode"))), 'stable')];

dataTbl.PPcode = [];

% Calculate best match means for each participant
meanTbl = zeros(PPno, width(dataTbl));

for ptpt = 1:PPno
    idx = dataTbl.PPno == ptpt & dataTbl.Match_Type == 1;
    meanTbl(ptpt,:) = mean(table2array(dataTbl(idx,:)), 1);
end

meanTbl = array2table(meanTbl, "VariableNames", dataTbl.Properties.VariableNames);

% Remove ptpts that didnt do Uno HFP
idx = ~isnan(meanTbl.(hfpVar));
meanTbl = meanTbl(idx,:);
PPcodes = PPcodes(idx,:);
PPno = height(meanTbl);

% Calculate cone fundamentals for each participant
for ptpt = 1:PPno
    age = table2array(meanTbl(ptpt, "Age_HFP"));
    if age < 20
        age = 20;
    elseif age > 80
        age = 80;
    end
    coneFunArray = ConeFundamentals(age, 2, "default", "no");
    data.(PPcodes(ptpt,2)).coneFun = array2table([wavelengths, coneFunArray], "VariableNames", ["Wavelength", "L", "M", "S"]);
end

% Constants from Allie's thesis
redMinTrolansPower = 10 ^ 2.39;
redMaxTrolansPower = 10 ^ 2.99;
redPeakWavelength = 630;
redFWHM = 10;

greenMaxTrolansPower = 10 ^ 2.77; 
greenPeakWavelength = 545;
greenFWHM = 10;

% Full width half maximum to SD conversion
fwhm2sigma = 1 / 2.35482004503;

% Generating normalised LED gaussian curves
redGaussian = normpdf(wavelengths, redPeakWavelength, (redFWHM * fwhm2sigma));
redGaussian = (redGaussian - min(redGaussian)) ./ max(redGaussian);
greenGaussian = normpdf(wavelengths, greenPeakWavelength, (greenFWHM * fwhm2sigma));
greenGaussian = (greenGaussian - min(greenGaussian)) ./ max(greenGaussian);

% Convert raw HFP Uno data to trolans
fig = 0;

for ptpt = 1:PPno
    rawValue = table2array(meanTbl(ptpt, hfpVar)) / 1024;
    data.(PPcodes(ptpt,2)).redSetting = rawValue;

    redTrolans = redPeakWavelength * redMaxTrolansPower;
    greenTrolans = greenPeakWavelength * greenMaxTrolansPower;

    data.(PPcodes(ptpt,2)).trolans.red = redTrolans;
    data.(PPcodes(ptpt,2)).trolans.green = greenTrolans;
    data.(PPcodes(ptpt,2)).trolans.rg_ratio = redTrolans / greenTrolans;
    
    % Scale red LED gaussian curve using ptpt's mean settings
    redGaussianPtpt = redGaussian;
    greenGaussianPtpt = greenGaussian;
    
    % Store variables
    l = table2array(data.(PPcodes(ptpt,2)).coneFun(:,"L"))';
    m = table2array(data.(PPcodes(ptpt,2)).coneFun(:,"M"))';
    R = redGaussianPtpt';
    G = greenGaussianPtpt';

    vLambda = (1.980647 .* l + m);

    % Use trapezium method to find area under both curves
    lR = trapz(wavelengths, min([l; R])) * redMaxTrolansPower * vLambda(wavelengths == greenPeakWavelength) * data.(PPcodes(ptpt, 2)).redSetting;
    lG = trapz(wavelengths, min([l; G])) * greenMaxTrolansPower * vLambda(wavelengths == redPeakWavelength);
    mR = trapz(wavelengths, min([m; R])) * redMaxTrolansPower * vLambda(wavelengths == greenPeakWavelength) * data.(PPcodes(ptpt, 2)).redSetting;
    mG = trapz(wavelengths, min([m; G])) * greenMaxTrolansPower * vLambda(wavelengths == greenPeakWavelength);
    
    data.(PPcodes(ptpt, 2)).sens.lR = lR;
    data.(PPcodes(ptpt, 2)).sens.lG = lG;
    data.(PPcodes(ptpt, 2)).sens.mR = mR;
    data.(PPcodes(ptpt, 2)).sens.mG = mG;

    % Calculate L:M ratio
    LM_ratio = (mG - mR) / (lR - lG);
    data.(PPcodes(ptpt,2)).LM_ratio = LM_ratio;

    disp(strjoin(["(", PPcodes(ptpt,1), ") " PPcodes(ptpt,2), " = ", sprintfc('%0.2f', LM_ratio), ":1"],''));

    %Graph
    if rem(ptpt,prod(graphDim)) == 1
        fig = fig + 1;
        figure(fig);
        tiledlayout(graphDim(1), graphDim(2));
    end
    nexttile
    hold on
    plot(wavelengths, R, "Color", 'r');
    plot(wavelengths, G, "Color", 'g');
    plot(wavelengths, l, "Color", 'r');
    plot(wavelengths, m, "Color", 'g');

    plot(wavelengths, min([l;R]), "LineStyle", "--", "Color", "k");
    plot(wavelengths, min([l;G]), "LineStyle", "--", "Color", "k");
    plot(wavelengths, min([m;R]), "LineStyle", "--", "Color", "k");
    plot(wavelengths, min([m;G]), "LineStyle", "--", "Color", "k");
    
    xlabel("Wavelength")
    ylabel("Relative Values")
    title(strjoin(["(", PPcodes(ptpt,1), ") ", PPcodes(ptpt,2)],''))
    text(650, max([R; G], [], "all"), strjoin([sprintfc('%0.2f', LM_ratio), ":1"],''));
    hold off    
end
