function [lum, spect, peak] = MeasurePR670(port,outputs)

% Default outputs
lum = NaN;
spect = NaN;
peak = NaN;

% Set constants
minLambda = 380;    % minimum lambda value
lambdaStep = 5;     % steps between each lamda value
stepNum = 81;       % number of steps

% which measurements to take
if ~exist("outputs",'var')
    outputs = ["spd","lum"];
else
    outputs = lower(outputs); 
end

% Calculate constants
maxLambda = minLambda + lambdaStep * (stepNum - 1); % maximum lambda value
lambdas = (minLambda : lambdaStep : maxLambda)';    % lambda list

% Opens PR670
PR670init(port);

if ismember("spd",outputs)
    % Measures spectrum
    [spd, ~] = PR670measspd([minLambda lambdaStep stepNum], 'off');
    % Finds lambda value corresponding to the highest spectral value
    peak = lambdas(spd == max(spd));
    % Saves lambda and spectral values as an array
    spect = [lambdas, spd]'; 
end

if ismember("lum",outputs)
    % Measures xyz output (customised Psychtoolbox function to disable sync mode)
    [xyz, ~] = PR670measxyz_syncMode('off');
    % Extracts luminance from xyz values
    lum = xyz(2);
end

end
