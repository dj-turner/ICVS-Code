% if the code doesn't work, check that the arduino port (written in
% ConstantsHFP) is the right one (for windows, check Device Manager->ports)

function ptptID = ArduinoHeterochromaticFlickerPhotometry(taskNumber)

% Clear everything before starting program
delete(instrfindall)

% Clear all extra variables from the workspace
clearvars -except taskNumber;

% Call arduino object
% Tries using the value in ConstantsHFP
[a, connection] = FindArduinoPort;

% If the connection failed, exit the program
if connection == 0
    return
end

% Turn off character capture
ListenChar(0);
% Asks for participant code
ptptID = input('Participant Code: ', 's');
ptptID = upper(ptptID);
sessionNumber = input('Session Number: ');
disp(" ");
%Turns on character capture
ListenChar(2);

% Set reversal number
reversalNumber = 9;

changeInputs = ['q', 'q', 'w', 'w', 'e', 'e', 'e', 'e', 'e';...
                'r', 'r', 't', 't', 'y', 'y', 'y', 'y', 'y'];

greenInputs = ['z', 'x', 'c', 'v'];
greenInputsNum = 1:length(greenInputs);

% Set trial counter
trialCount = 0;

% EXECUTION LOOP
% Loops until all trials are completed
while trialCount < taskNumber
    
    % Open the arduino device
    fopen(a);

    % Add 1 to trial number counter
    trialCount = trialCount + 1;

    % Resets match type
    reversalCount = 0;

    % Reset arduino light to max red
    fprintf(a, 'i'); 

    % reset trialResults array to an empty array
    trialResultsRed = NaN(1, reversalNumber);

    % Display the current trial
    disp(strjoin(["TRIAL", num2str(trialCount), "STARTING..."],' '));
    
    % Loops until all 3 matches are completed
    while reversalCount < reversalNumber

        % pauses between trials
        pause(.5);

        % Adds 1 to the reversal counter
        reversalCount = reversalCount + 1;

        % Determine direction of reversal
        if rem(reversalCount,2) == 0
            direction = 1; 
            addColour = "red";
        else 
            direction = 2; 
            addColour = "green";
        end

        % Determine user arduino input
        userArduinoInput = changeInputs(direction, reversalCount);

        % Display
        disp(strjoin(["Reversal ", num2str(reversalCount), "/", num2str(reversalNumber), ", adding ", addColour, "..."],''));

        % Sets subTrialCompleted as 0. The next trial will only start when this changes to a 1.
        reversalCompleted = 0;

        % Trial loop: will loop until next trial starts
        while reversalCompleted == 0

            pause(.1);

            % Waits for a key press
            keyName = FindKeypress;
        
            % Responds according to key pressed
            switch keyName
                % If the "=" key is pressed, completes the trial count, match count, and match completed so that the program saves and exits
                case '=+'
                    delete(instrfindall);
                    ListenChar(0)
                    return
         
                % If the "a" key is pressed, increases the red value based on the current delta
                case 's'
                    % Sends red value change to device
                    fprintf(a, userArduinoInput);

                case 'm'
                    if reversalCount == 1
                        greenValue = NaN;
                        ListenChar(0);
                        while ~any(greenValue==greenInputsNum)
                            greenValue = input("Please select a new green value ('1' = 64, '2' = 128 (default), '3' = 192, '4' = 255): ");
                        end
                        ListenChar(2);
                        fprintf(a, greenInputs(greenValue));
                        fprintf(a, 'i');
                    else
                        disp("Not the first reversal! Please wait until the next trial to change the green value.");
                    end
        
                % If the "o" key is pressed, sends an 'o' character to the device.
                % This tells the device to send all the current values to MATLAB.
                case 'o'
                    % Sends the 'o' character to the device
                    fprintf(a, 'o');
        
                    % Reads the current red and green values from the device
                    rVal=read(a, 6, "char");
                    gVal=read(a, 6, "char");
        
                    % Stores these values as the correct numbers
                    rVal = str2double(rVal) - 100;
                    gVal = str2double(gVal) - 100;
        
                    % Prints the current red, green, & delta values in the console
                    fprintf("Current Red Value = %d, Current Green Value = %d", rVal, gVal);
                    disp(" ");

                    % Pauses the program for .5 seconds
                    pause(.5);
        
                % If the "return" or "p" key is pressed, ends the trial
                case {'return', 'p'}
                    
                    % Tells the user that the results are being processed
                    disp("Printing final results... please wait");
        
                    % Sends a 'u' character to the device, which tells it to send
                    % all the values to MATLAB and re-randomise the red value for
                    % the next trial
                    fprintf(a, 'o');
         
                    % Reads the current red and green values from the device
                    rVal=read(a, 6, "char");
                    gVal=read(a, 6, "char");
        
                    % Stores these values as the correct numbers
                    rVal = str2double(rVal) - 100;
                    gVal = str2double(gVal) - 100;
        
                    % Stores these values as the correct numbers
                    trialResultsRed(reversalCount) = rVal;
        
                    % Prints the final values in the console
                    disp(" ");
                    fprintf("Final Red Value = %d, Final Green Value = %d", rVal, gVal);
                    disp(" ");            
        
                    % Tells MATLAB to go to the next trial
                    reversalCompleted = 1;
            end
        end
    end

    % Saves the resulte to "ParticipantMatchesHFP.mat"
    SaveHFPResults(ptptID, sessionNumber, trialCount, trialResultsRed, gVal); 
    disp(" ");
end

% Clear devices
delete(instrfindall);

% Turn on character capture.
ListenChar(0)

end
