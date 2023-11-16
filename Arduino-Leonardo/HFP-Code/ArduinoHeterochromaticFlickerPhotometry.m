function ptptID = ArduinoHeterochromaticFlickerPhotometry(trialNumber)

% Clear everything before starting program
delete(instrfindall)

% Clear all extra variables from the workspace
clearvars -except trialNumber;

% Call arduino object
[arduino, connection] = FindArduinoPort;

% If the connection failed, exit the program
if connection == 0
    return
end

% Turn off character capture
ListenChar(0);
% Asks for participant code
ptptID = input('Participant Code: ', 's');
% makes all letters in ptpt id upper case
ptptID = upper(ptptID);
% Asks for session number
sessionNumber = input('Session Number: ');
% Displays blank line in console
disp(" ");
%Turns on character capture
ListenChar(2);

% Set reversal number
reversalNumber = 9;

% Arduino inputs depending on reversal and direction
changeInputs = ['q', 'q', 'w', 'w', 'e', 'e', 'e', 'e', 'e';...
                'r', 'r', 't', 't', 'y', 'y', 'y', 'y', 'y'];
% Green level inputs
greenInputs = ['z', 'x', 'c', 'v'];
greenInputsNum = 1:length(greenInputs);

% Opens arduino
fopen(arduino);
% prints starting green value (255)
fprintf(arduino, 'v');

% Set trial counter
trialCount = 0;

% EXECUTION LOOP
% Loops until all trials are completed
while trialCount < trialNumber

    % Add 1 to trial number counter
    trialCount = trialCount + 1;
    % Resets match type
    reversalCount = 0;
    % set change direction to NaN for the first reversal
    changeDir = NaN;
    % reset trialResults array to an empty array
    trialResultsRed = NaN(1, reversalNumber);
    % Reset arduino light to random red
    fprintf(arduino, 'i'); 

    % Display the current trial
    disp(strjoin(["TRIAL", num2str(trialCount), "STARTING..."],' '));
    % pulls initial values from arduino
    [rValInit, gVal] = ExtractResults(arduino);

    while reversalCount < reversalNumber

        % pauses between trials
        pause(.5);
        % Adds 1 to the reversal counter
        reversalCount = reversalCount + 1;

        % Switch direction of reversal
            % 0 = adding red reversal
            % 1 = adding green reversal
            % NaN = adding either reversal (1st)
        switch changeDir
            case 0
                changeDir = 1;
                addColour = "green";
            case 1
                changeDir = 0;
                addColour = "red";
            otherwise
                addColour = "either colour";
        end

        % Determine user arduino inputs
        redInputIncrease = changeInputs(1, reversalCount);
        redInputDecrease = changeInputs(2, reversalCount);

        % Display
        disp(strjoin(["Reversal ", num2str(reversalCount), "/", num2str(reversalNumber), ", adding ", addColour, "..."],''));

        % Sets subTrialCompleted as 0. The next trial will only start when this changes to a 1.
        reversalCompleted = 0;

        % Trial loop: will loop until next trial starts
        while reversalCompleted == 0

            pause(.1);

            % Waits for a key press
            keyName = FindKeypress;
        
            if ischar(keyName)
                % Responds according to key pressed
                switch keyName
                    % If the "=" key is pressed, completes the trial count, match count, and match completed so that the program saves and exits
                    case '=+'
                        % runs prepare to exit function
                        PrepareToExit(arduino);
                        % exits
                        return
             
                    % If the "a" key is pressed, increases the red value based on the current delta
                    case {'a', '1'}
                        % Sends red value increase to device (unless green trial)
                        if changeDir ~= 1
                            fprintf(arduino, redInputIncrease);
                        end
                        % If first reversal, updates latest change dir
                        if reversalCount == 1
                            changeDir = 0;
                        end
    
                    case {'d', '3'}
                        % Sends red value decrease to device (unless red trial)
                        if changeDir ~= 0
                            fprintf(arduino, redInputDecrease);
                        end
                        % If first reversal, updates latest change dir
                        if reversalCount == 1
                            changeDir = 1;
                        end
    
                    % allows change of reference green
                    case 'm'
                        % only if this is the first reversal
                        if reversalCount == 1
                            % set green value to NaN as a filler
                            greenValue = NaN;
                            % Opens character capture
                            ListenChar(0);
                            % Keeps asking for an answer until a valid one is received
                            while ~any(greenValue==greenInputsNum)
                                greenValue = input("Please select a new green value ('1' = 64, '2' = 128, '3' = 192, '4' = 255 (default)): ");
                            end
                            % Closes character capture
                            ListenChar(2);
                            % Sends new green value to the arduino
                            fprintf(arduino, greenInputs(greenValue));
                            % Re-randomises the red light for the new trial
                            fprintf(arduino, 'i');
                            % Prints new starting values
                            [rValInit, gVal] = ExtractResults(arduino);
                        % displays error message if this is not the first reversal
                        else
                            disp("Not the first reversal! Please wait until the next trial to change the green value.");
                        end
            
                    % If the "o" key is pressed, sends an 'o' character to the device.
                    % This tells the device to send all the current values to MATLAB.
                    case 'o'
                        [~, ~] = ExtractResults(arduino);
            
                    % If the "return" or "p" key is pressed, ends the trial
                    case {'return', 'p'}
                        [rVal, ~] = ExtractResults(arduino);
                        % Stores these values as the correct numbers
                        trialResultsRed(reversalCount) = rVal;       
                        % Tells MATLAB to go to the next trial
                        reversalCompleted = 1;
                end
            end
        end
    end

    % Saves the results to "ParticipantMatchesHFP.mat"
    SaveHFPResults(ptptID, sessionNumber, trialCount, rValInit, trialResultsRed, gVal); 
    disp(" ");
end

PrepareToExit(arduino);

end

%--------------------------------------------------------------------------

function [r,g] = ExtractResults(a)
% asks arduino for values
fprintf(a, 'o');
% Reads the current red and green values from the device
rRaw = read(a, 6, "char");
gRaw = read(a, 6, "char");
% Stores these values as the correct numbers
r = str2double(rRaw) - 100;
g = str2double(gRaw) - 100;
% displays values
disp(" ");
fprintf("Red Value = %d, Green Value = %d", r, g);
disp(" ");
end

%--------------------------------------------------------------------------

function PrepareToExit(a)
% turns off LEDs
fprintf(a, 'j');
% Clear devices
delete(instrfindall);
% Turn on character capture.
ListenChar(0)
end
