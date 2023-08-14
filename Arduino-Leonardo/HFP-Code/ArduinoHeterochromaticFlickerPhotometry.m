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
sessionNumber = input('Session Number: ');
disp(" ");
%Turns on character capture
ListenChar(2);

% SET ARDUINO INPUTS
increaseInputs={'q', 'w', 'e'};     % Key codes for increasing the red light that the arduino can read
decreaseInputs={'r', 't', 'y'};     % Key codes for decreasing the red light that the arduino can read
% i = reset trial
% o = display results
% m = change green value
% n = change initial values to current values
% g = saves current red value as best match
% h = reinstates best match to current red value

rDeltas = [20, 5, 1];               % Red light step sizes
deltaIndex = 1;                     % Red light delta
redDelta = rDeltas(deltaIndex);

% Accepted confidence ratings
acceptedConfidenceRatings = 1:4;

% Set trial counter
trialNumber = 0;

% EXECUTION LOOP
% Loops until all trials are completed
while trialNumber < taskNumber
    
    % Open the arduino device
    fopen(a);

    % Add 1 to trial number counter
    trialNumber = trialNumber + 1;

    % Resets match type
    matchType = 0;

    % Display the current trial
    disp(strjoin(["TRIAL", num2str(trialNumber), "STARTING..."],' '));
    
    % Loops until all 3 matches are completed
    while matchType < 3

        % pauses between trials
        pause(.5);

        % Tells Arduino to set current values as initial values
        fprintf(a,'n');
        % Reads the initial green value from the device
        gValinit=read(a, 6, "char");       
        % Store the value as the correct number
        gValinit = str2num(gValinit) - 100; 

        % Adds 1 to the match type counter
        matchType = matchType + 1;

        % Sets up trial according to match type
        switch matchType
            % 1 = Best match
            case 1
                % Send character "i" to the device, which randomises the red light
                fprintf(a, 'i'); 

                % Reads initial red value and converts it
                rValinit = read(a,6,"char");
                rValinit = str2num(rValinit) - 100; 

                % Resets the delta value
                deltaIndex = 1;
                redDelta = rDeltas(deltaIndex);

                % Resets staircase variables
                currentDir = 0;
                lastDir = 0;   

                % Print the initial red and green values
                disp(" ");
                fprintf("Initial Red Value = %d, Initial Green Value = %d, Red Delta Value = %d \n", rValinit, gValinit, redDelta);
                disp(" ");
                disp("Make your best match!");

            % 2 = Most red match
            case 2
                % Sets delta to smallest value
                deltaIndex = length(rDeltas);
                redDelta = rDeltas(deltaIndex);
                % Tells arduino to save the current red value as the best match value
                fprintf(a, 'g');
                disp("Now add red until the lights no longer match!");

            % 3 = most green match
            case 3
                % Tells arduino to reinstate the best match value as the current red value
                fprintf(a, 'h');
                disp("Now add green until the lights no longer match!");
        end

        % Sets subTrialCompleted as 0. The next trial will only start when this changes to a 1.
        subTrialCompleted = 0;

        % Trial loop: will loop until next trial starts
        while subTrialCompleted == 0

            pause(.1);

            % Waits for a key press
            keyName = FindKeypress;
        
            % Responds according to key pressed
            switch keyName
                % If the "=" key is pressed, completes the trial count, match count, and match completed so that the program saves and exits
                case '=+'
                    trialNumber = taskNumber;
                    matchType = 3;
                    subTrialCompleted = 1;
        
                % If the "a" key is pressed, increases the red value based on the current delta
                case 'a'
                    arduinoInput = increaseInputs{deltaIndex};
                    % Sends increase in red value to device
                    fprintf(a, arduinoInput);
                    % Records increase in RG for staircase
                    if matchType == 1
                        lastDir = currentDir;
                        currentDir = 1;
                    end
        
                % If the "d" key is pressed, decreases the red value based on the current delta
                case 'd'
                    arduinoInput = decreaseInputs{deltaIndex};
                    % Sends decrease in red delta to the device
                    fprintf(a, arduinoInput);
                    % Records decrease in RG for staircase
                    if matchType == 1
                        lastDir = currentDir;
                        currentDir = 2;
                    end
                    
                % % If the "k" button is pressed, decreases red delta (the amount of
                % % change in red that occurs with each key press, i.e. the step size)
                % case 'k'
                %     % Will only change step size if match type = 1
                %     if matchType == 1
                %         deltaIndex = deltaIndex + 1;
                %         % If already at the smallest step size, does not change
                %         if deltaIndex > length(rDeltas)
                %             deltaIndex = length(rDeltas);
                %         end
                %         redDelta = rDeltas(deltaIndex);
                %     end
        
                % If the "o" key is pressed, sends an 'o' character to the device.
                % This tells the device to send all the current values to MATLAB.
                case 'o'
                    % Sends the 'o' character to the device
                    fprintf(a, 'o');
        
                    % Reads the current red and green values from the device
                    rVal=read(a, 6, "char");
                    gVal=read(a, 6, "char");
        
                    % Stores these values as the correct numbers
                    rVal = str2num(rVal) - 100;
                    gVal = str2num(gVal) - 100;
        
                    % Prints the current red, green, & delta values in the console
                    fprintf("Current Red Value = %d, Current Green Value = %d, Red Delta Value = %d \n", rVal, gVal, redDelta);
        
                % If the "i" key is pressed, resets the trial. This randomises the
                % red light and resets the step size back to the maximum value.
                case 'i'
                    if matchType == 1
                        % Send character "i" to the device, which randomises the red light
                        fprintf(a, 'i');
                    
                        % Red the initial red and green values from the device
                        rValinit=read(a, 6, "char");
                    
                        % Store the initial values as the correct numbers
                        rValinit = str2num(rValinit) - 100;

                        % Resets the delta value
                        deltaIndex = 1;
                        redDelta = rDeltas(deltaIndex);
    
                        % Resets staircase variables
                        currentDir = 0;
                        lastDir = 0;
                    
                        % Print the initial red and green values
                        fprintf("Initial Red Value = %d, Initial Green Value = %d, Current Green Value = %d, Red Delta Value = %d \n", rValinit, gValinit, gVal, redDelta);
                    else
                        disp(" ");
                        disp("Can only randomise a best match trial!");
                        disp(" ");
                    end

                % if the 'm' key is pressed, allows for experimener to
                % change the green value to 64, 128, 192, or 256
                case 'm'
                    % Checks that it is a best match
                    if matchType == 1 && currentDir == 0
                        % Allows key input
                        ListenChar(0);
                        % Asks experimenter for key value of new gren value
                        % until a valid response is entered
                        gValInput = NaN;
                        disp(" ");
                        while ~ismember(gValInput, 1:4)
                            gValInput = input("Input a new green value! 1 = 64, 2 = 128, 3 = 192, 4 = 256: ");
                        end
                        % Closes console response
                        ListenChar(2);
                        disp(" ");
                        % Sends new green value to the arduino
                        fprintf(a, gValInput);
                        % Reads current green value from the arduino
                        gVal=read(a, 6, "char");
                        gVal = str2num(gVal) - 100;

                    elseif matchType ~= 1
                        disp(" ");
                        disp("Can only be changed at the start of a best match trial! Please wait until the next best match trial.");
                        disp(" ");

                    else
                        disp(" ");
                        disp("Can only be changed at the start of a best match trial! Press ""i"" to reset this trial first.");
                        disp(" ");          
                    end

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
         
                    % Reads the initial and final red and green values from the device
                    rVal=read(a, 6, "char");
                    gVal=read(a, 6, "char");
        
                    % Stores these values as the correct numbers
                    rVal = str2num(rVal) - 100;
                    gVal = str2num(gVal) - 100;
        
                    % Prints the final values in the console
                    disp(" ");
                    fprintf("Initial Red Value = %d, Initial Green Value = %d \n", rValinit, gValinit);
                    fprintf("Final Red Value = %d, Final Green Value = %d, Red Delta Value = %d \n", rVal, gVal, redDelta);
                    disp(" ");
                    
                    % Confidence rating
                    % Opens responses in console
                    ListenChar(0);
                    % Loops until a valid value in entered for the confidence rating
                    confidenceRating = NaN;
                    while ~ismember(confidenceRating, acceptedConfidenceRatings)
                            confidenceRating = input("Rate your confidence 1-4: ");
                    end
                    disp(" ");
                    % Closes responses in console
                    ListenChar(2);
        
                    % Saves the resulte to "ParticipantMatchesHFP.mat"
                    SaveHFPResults(ptptID, sessionNumber, trialNumber, matchType, rVal, gVal, rValinit, gValinit, redDelta, confidenceRating);              
        
                    % Tells MATLAB to go to the next trial
                    subTrialCompleted = 1;
            end

            % STAIRCASING (for best matches only)
            % If direction was switched between last change to RG and
            % current change (1 = increase, 2 = decrease)...
            if (matchType == 1) && (deltaIndex < length(rDeltas)) && (currentDir + lastDir == 3)
                % Resets lastDir
                lastDir = 0;   
                % If already at the smallest step size, does not change
                % Decreases RG step size
                deltaIndex = deltaIndex+1;
                redDelta = rDeltas(deltaIndex);
            end


        end
    end
end

% Clear devices
delete(instrfindall);

% Turn off character capture.
ListenChar(0)

end
