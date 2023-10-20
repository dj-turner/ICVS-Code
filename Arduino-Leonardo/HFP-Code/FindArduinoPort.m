function [serialObj, connection] = FindArduinoPort
% Sets default port number to try first
defaultPortCode = 'COM11';

% First attempts to open arduino using the default port number
try
    % Tells the user what is happening
    disp(strcat("Attempting to open arduino using port '", defaultPortCode, "' from default..."))

    % Opens port
    serialObj=serialport(defaultPortCode, 9600);

    % Informs the user that the default value is correct
    disp("Port opened successfully using default value!")
    disp(" ");

    % Set connection type to 1
    connection = 1;

% If this fails, asks experimenter to manually enter the port number to try again
catch
    try
        % Asks user for port number input
        enteredPortNumber = input("Unable to open port! Please enter the correct port number here to try again: ");

        % Creates port code using inputted number
        enteredPortCode = strcat('COM', char(string(enteredPortNumber)));

        % Tells the user what is happening
        disp(strcat("Attempting to open arduino using port '", enteredPortCode, "' instead..."))

        % Opens port
        serialObj=serialport(enteredPortCode, 9600);

        % Informs the user that the entered value is correct
        disp("Port opened successfully using value entered!")
        disp(" ");

        % Set connection type to 2
        connection = 2;

    % If this also fails, displays an error message and marks connection as unsuccessful
    catch
        % informs the user that the connection was unsuccessful
        disp("Port not opened successfully. Please troubleshoot the issue and try again.")
        disp(" ");

        % Set connection type to 0
        connection = 0;

        % Sets serialObj to NaN
        serialObj = NaN;
    end
end

end
