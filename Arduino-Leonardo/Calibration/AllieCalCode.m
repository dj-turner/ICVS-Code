function ArduinoCalibration(testLight, luminanceLevels, alignmentLight)

if (~exist('arduinosetup.m','file'))
    if (~strcmp(computer,'MACI64'))
        error('You need to modify code for Windows/Linux to get the Arduino AddOn Toolbox onto your path and to get the arduino call to find the device');
    end
    a = ver;
    rel = a(1).Release(2:end-1);
    sysInfo = GetComputerInfo;
    user = sysInfo.userShortName;
    addpath(genpath(fullfile('/Users',user,'Documents','MATLAB','SupportPackages',rel)));
end

clearvars -except testLight luminanceLevels alignmentLight;
clear a;
devRootStr = 'COM4';
arduinoType = 'leonardo';
possiblePorts = dir([devRootStr '*']);
openedOK = false;
if (isempty(possiblePorts))
    try 
        a = arduino;
        openedOK = true;
        fprintf('Opened arduino using arduino function''s autodetect of port and type\n');
    catch e
        fprintf('Could not detect the arduino port or otherwise open it.\n');
        fprintf('Rethrowing the underlying error message.\n');
        rethrow(e);
    end
else
    for pp = 1:length(possiblePorts)
        thePort = fullfile(possiblePorts.folder,possiblePorts.name);
        try
            a = arduino(thePort,arduinoType);
            openedOK = true;
        catch e
        end
    end
    if (~openedOK)
        fprintf('Despite our best cleverness, unable to open arduino. Exiting with an error\n');
        error('');
    else
        fprintf('Opened arduino on detected port %s\n',thePort);
    end
end

%
if strcmp(luminanceLevels, 'standard')
     lightLevelNumber = 6;
     lightLevels = zeros(1, lightLevelNumber);
     for i = 1:(lightLevelNumber - 1)
         lightLevels(1, i+1) = i * (256/(lightLevelNumber-1)) - 1;
     end
%lightLevels = [127,255];

elseif strcmp(luminanceLevels, 'greenPresets')
    lightLevelNumber = 5;
    lightLevels = zeros(1, lightLevelNumber);
    for i = 1:(lightLevelNumber - 1)
        lightLevels(1, i+1) = (256*i/(lightLevelNumber-1));
        if lightLevels(1, i+1) > 255
            lightLevels(1, i+1) = 255;
        end
    end
    

elseif isnumeric(luminanceLevels)
    lightLevels = luminanceLevels;

else
    disp("luminanceLevels input error! Use 'standard', 'greenPresets', or a double object");
    return;
end

if strcmp(alignmentLight, 'yes')
    lightLevels = [255 lightLevels];
elseif strcmp(alignmentLight, 'yes') == 0 && strcmp(alignmentLight, 'no') == 0
    disp("Please enter 'yes' or 'no' for whether you'd like to start with an alignment light!");
    return;
end

allLights = {'red' 'green' 'yellow'}
allLights{1}
if strcmp(testLight, 'all')
    runNumber = length(allLights);
else
    runNumber = 1;
end

for j = 1:runNumber
    if strcmp(testLight, 'all')
        currentTestLight = allLights(j);
    else
        currentTestLight = testLight;
    end
    disp(string(join(['Testing light colour: ', currentTestLight])));
    input('Press RETURN when the PR670 is focused on the right light',"s");

    for i = 1:length(lightLevels)
        lightValue = lightLevels(i);
        if strcmp(currentTestLight, 'red')
            red = lightValue;
            green = 0;
            yellow = 0;
        elseif strcmp(currentTestLight, 'green')
            red = 0;
            green = lightValue;
            yellow = 0;
        elseif strcmp(currentTestLight, 'yellow')
            red = 0;
            green = 0;
            yellow = lightValue;
        end
        
        writeRGB(a,red,green,0);
        writeYellow(a,yellow);
        disp(string(join(['Current ' currentTestLight ' value: ' num2str(lightValue)])));
        PR670init('COM11');
        if i==length(lightLevels)
            spd = PR670measspd([380 5 81]);
            xyz = PR670measxyz;
            output_lum(i) = xyz(2);
            requested_value(i) = lightValue/255;
        else
            xyz = PR670measxyz;
            output_lum(i) = xyz(2);
            requested_value(i) = lightValue/255;
            input('Press RETURN for the next trial',"s");
        end
    end

    
    figure()
    wls = 380:5:780';
    plot(380:5:780,spd, 'k', 'LineWidth',2);
    xlabel('Wavelength (nm)')
    ylabel('Radiance (W/sr/m2)')
    %axis sqaure;
    %grid on;
    title(['Spectrum for the ' allLights(j) 'LED on max'])
    figure()
    plot(requested_value,output_lum./max(output_lum),'kx','MarkerSize',4,'LineWidth',2)
    %axis square;
    %grid on;
    xlabel('Requested Value')
    ylabel('Output intensity')
    title(['Gamma curve for the ' allLights(j) 'LED'])
    save(['calibration_data_' allLights{j} '_group8.mat'], 'spd','wls', 'output_lum', 'requested_value')
end

disp('End of testing!');

end