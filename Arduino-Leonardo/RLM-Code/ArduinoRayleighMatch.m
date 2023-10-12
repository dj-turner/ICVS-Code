function ptptID = ArduinoRayleighMatch(taskNumber)

% Clear everything before starting program
delete(instrfindall)

% Clear all extra variables from the workspace
clearvars -except taskNumber;

% Loading and setting up the arduino device - Do not touch this code!
a = OpenArduinoPort;
disp(" ");

% Reset all lights to off (in case the arduino previously crashed)
WriteLEDs(a,[0,0,0]);

% Allows console responses
ListenChar(0);
% Asks for participant ID and session number
ptptID = input('Participant Code: ', 's');
sessionNumber = input('Session Number: ');
disp(" ");
% Disables console responses
ListenChar(2);
% Flushes events
FlushEvents;

% SETTING CONSTANTS
% Red/green mixture parameters.  These get traded off in the
% mixture by a parameter lambda.
redAnchor = 50;                                 % Red value for lambda = 1
greenAnchor = 350;                              % Green value for lambda = 0
lambdaDeltas = [0.05 0.02 0.01 0.005 0.001];    % Set of lambda deltas
% Yellow LED parameters
yellowDeltas = [25 15 10 5 1];                  % Set of yellow deltas

% Accepted confidence ratings
acceptedConfidenceRatings = 1:4;

% Sets counter of number of completed trials
trialNumber = 0;

% EXECUTION LOOP
while trialNumber < taskNumber

    % Adds 1 to trial number
    trialNumber = trialNumber + 1;

    % Resets match type counter for new trial
    matchType = 0;

    % Displays current trial number
    disp(strjoin(["TRIAL", num2str(trialNumber), "STARTING..."],' '));

    % Loops until all 3 matches have been completed
    while matchType < 3

        % Pauses the system. useful for between trials
        pause(.5);

        % Adds 1 to the match type counter
        matchType = matchType + 1;

        % Sets values according to the current match type
        switch matchType
            % 1 = Best match
            case 1
                lambda = rand();                                % Lambda value
                lambdaDeltaIndex = 1;                           % Lambda step size
                lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta
                yellow = round(255 .* rand());                  % Yellow value
                yellowDeltaIndex = 1;                           % Yellow step size
                yellowDelta = yellowDeltas(yellowDeltaIndex);   % Yellow delta
<<<<<<< Updated upstream
                [red, green] = SetReaaaaaaaadAndGreen(lambda, redAnchor, greenAnchor);
=======
                [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
>>>>>>> Stashed changes

                %Resets staircase variables
                currentDirRG = 0;
                lastDirRG = 0;
                currentDirY = 0;
                lastDirY = 0;

                % Displays starting values
                disp(" ");
                fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
                fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta);
                disp(" ");
                disp("Make your best match!");
            
            % 2 = Most red match
            case 2
                bestLambda = lambda;                            % Saves best match lambda value to re-use in matchType 3
                lambdaDeltaIndex = length(lambdaDeltas);        % Makes the lambda delta the smallest available value
                lambdaDelta = lambdaDeltas(lambdaDeltaIndex);
                disp("Now add red until the lights no longer match!");
            
            % 3 = Most green match
            case 3
                lambda = bestLambda;                            % Reinstates the lambda value of the best match
                disp("Now add green until the lights no longer match!");
        end

        % Sets variable to keep track of when the current match is completed
        matchCompleted = 0;

        while matchCompleted == 0

            % Sets red and green values based on current lambda
            [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
            % Writes LED values to device
            WriteLEDs(a, [red, green, yellow]);
        
            % Waits for a key press
            keyName = FindKeypress;
        
            % Responds accoring to the key pressed
            switch keyName
                % If the "=" key is pressed, completes the trial count, match count, and match completion so that the program saves and exits
                case '=+'
                    trialNumber = taskNumber;
                    matchType = 3;
                    matchCompleted = 1;
                
                % If the "a" key is pressed, increases lambda (the proportion of red in the red/green light)
                case 'a'
                    lambda = lambda + lambdaDelta;
                    % Stops lambda going over 1
                    if (lambda > 1)
                        lambda = 1;
                    end
                    % Records increase in RG for staircase
                    if matchType == 1
                        lastDirRG = currentDirRG;
                        currentDirRG = 1;
                    end
                
                % If the "d" key is pressed, decreases lambda (the proportion of red in the red/green light)
                case 'd'
                    lambda = lambda - lambdaDelta;
                    % Stops lambda going below 0
                    if (lambda < 0)
                        lambda = 0;
                    end
                    % Records decrease in RG for staircase
                    if matchType == 1
                        lastDirRG = currentDirRG;
                        currentDirRG = 2;
                    end
                  
                % If the "w" key is pressed, increases the brightness of the yellow light
                case 'w'
                    if matchType == 1
                        yellow = round(yellow+yellowDelta);
                        % Stops yellow going over 255
                        if (yellow > 255)
                            yellow = 255;
                        end
                        % Records increase in Y for staircase
                        lastDirY = currentDirY;
                        currentDirY = 1;
                    end
            
                % If the "s" key is pressed, decreases the brightness of the yellow light
                case 's'
                    if matchType == 1
                        yellow = round(yellow-yellowDelta);
                        % Stops yellow going below 0
                        if (yellow < 0)
                            yellow = 0;
                        end
                        % Records decrease in Y for staircase
                        lastDirY = currentDirY;
                        currentDirY = 2;
                    end
            
                % % If the "k" button is pressed, decreases lambda delta (the amount of
                % % change in lambda that occurs with each key press, i.e. the step size)
                % case 'k'
                %     lambdaDeltaIndex = lambdaDeltaIndex+1;
                %     % If already at the smallest step size, does not change
                %     if (lambdaDeltaIndex > length(lambdaDeltas))
                %         lambdaDeltaIndex = length(lambdaDeltas);
                %     else
                %         lambdaDelta = lambdaDeltas(lambdaDeltaIndex);
                %     end
                % 
                % % If the "l" button is pressed, decreases yellow delta (the amount of
                % % change in yellow that occurs with each key press, i.e. the step size)
                % case 'l'
                %     if matchType == 1
                %         yellowDeltaIndex = yellowDeltaIndex+1;
                %         % If already at the smallest step size, does not change
                %         if (yellowDeltaIndex > length(yellowDeltas))
                %             yellowDeltaIndex = length(lambdaDeltas);
                %         else        
                %             yellowDelta = yellowDeltas(yellowDeltaIndex);
                %         end
                %     end
            
                % If the "o" key is pressed, prints  the current light values in the
                % console without ending the trial
                case 'o'
                    fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
                    fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 
            
                % If the "i" key is pressed, resets the trial. This randomises the
                % lights and resets the step sizes back to the maximum value.
                case 'i'
                    if matchType == 1
                        lambda = rand();                                % Lambda value
                        lambdaDeltaIndex = 1;                           % Lambda step size
                        lambdaDelta = lambdaDeltas(lambdaDeltaIndex);   % Lambda delta
                        yellow = round(255 .* rand());                  % Yellow value
                        yellowDeltaIndex = 1;                           % Yellow step size
                        yellowDelta = yellowDeltas(yellowDeltaIndex);   % Yellow delta
                        [red, green] = SetRedAndGreen(lambda, redAnchor, greenAnchor);
                        
                        %Resets staircase variables
                        currentDirRG = 0;
                        lastDirRG = 0;
                        currentDirY = 0;
                        lastDirY = 0;

                        % Prints the new light values
                        fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n',lambda, red, green, yellow); 
                        fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta); 
                    else
                        disp(" ");
                        disp("Can only randomise a best match trial!");
                        disp(" ");
                    end
                   
                % If the "return" or "p" key is pressed, ends the trial
                case {'return', 'p'}
            
                    % Prints final values of the trial in the console
                    fprintf('Lambda = %0.3f, Red = %d, Green = %d, Yellow = %d\n', lambda, red, green, yellow); 
                    fprintf('\tLambda delta %0.3f; Yellow delta %d\n', lambdaDelta, yellowDelta);

                    % CONFIDENCE RATING
                    % Opens responses in console
                    ListenChar(0);
                    % Loops until a valid value in entered for the confidence rating
                    confidenceRating = NaN;
                    while ~ismember(confidenceRating, acceptedConfidenceRatings)
                            confidenceRating = input("Rate your confidence 1-4: ");
                    end
                    % Closes responses in console
                    ListenChar(2);
                    
                    % Informs the experimenter that the results will be saved
                    disp("Saving results...");
                    disp(" ");
            
                    % Adds the results to "ParticipantMatchesRLM.mat"
                    SaveRLMResults(ptptID, sessionNumber, trialNumber, matchType, red, green, yellow, lambda, lambdaDelta, yellowDelta, confidenceRating);
    
                    % Sets subTrialCompleted to 1 to move on to the next trial
                    matchCompleted = 1;
            end

            % STAIRCASING (for best matches only)
            if matchType == 1
                % If direction was switched between last change to RG and
                % current change (1 = increase, 2 = decrease)...
                if  (lambdaDeltaIndex < length(lambdaDeltas)) && (currentDirRG + lastDirRG == 3)
                    % Resets lastDirRG
                    lastDirRG = 0;   
                    % Decreases RG step size
                    lambdaDeltaIndex = lambdaDeltaIndex+1;
                    lambdaDelta = lambdaDeltas(lambdaDeltaIndex);
                % If direction was switched between last change to Y and
                % current change (1 = increase, 2 = decrease)...
                elseif (yellowDeltaIndex < length(yellowDeltas)) && (currentDirY + lastDirY == 3)
                    % Reset lastDirY
                    lastDirY = 0;
                    % Decrease Y step size 
                    yellowDeltaIndex = yellowDeltaIndex+1;
                    yellowDelta = yellowDeltas(yellowDeltaIndex);
                end
            end

        end
    end
end

% Turn off character capture.
ListenChar(0);

% Close arduino
clear a;

end
