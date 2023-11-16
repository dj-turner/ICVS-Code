function [lum, spect, peak] = MeasurePR670(port)

% Set constants
minLambda = 380;    % minimum lambda value
lambdaStep = 5;     % steps between each lamda value
stepNum = 81;       % number of steps

% Calculate constants
maxLambda = minLambda + lambdaStep * (stepNum - 1); % maximum lambda value
lambdas = (minLambda : lambdaStep : maxLambda)';    % lambda list

% Opens PR670
PR670init(port);

% Measures spectrum
[spd, ~] = PR670measspd([minLambda lambdaStep stepNum], 'off');

% Measures xyz output (customised Psychtoolbox function to disable sync mode)
[xyz, ~] = PR670measxyz_syncMode('off');

% Extracts luminance from xyz values
lum = xyz(2);

% Finds lambda value corresponding to the highest spectral value
peak = lambdas(spd == max(spd));

% Saves lambda and spectral values as an array
spect = [lambdas, spd]'; 

end
