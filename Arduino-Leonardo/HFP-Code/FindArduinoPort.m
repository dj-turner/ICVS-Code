function serialObj = FindArduinoPort
portCode = 'COM6';

try
    disp(strcat("Attempting to open arduino using port '", portCode, "' from default..."))
    serialObj=serialport(portCode, 9600);
    disp("Port opened successfully using default value!")
    disp(" ");
% If this fails, asks experimenter to manually enter the port number to try again
catch
    try
        portNumber = input("Unable to open port! Please enter the correct port number here to try again: ", 's');
        portCode = strcat('COM', portNumber);
        disp(strcat("Attempting to open arduino using port '", portCode, "' instead..."))
        serialObj=serialport(portCode, 9600);
        disp("Port opened successfully using value entered!")
        disp(" ");
    % If this fails, displays an error message and exits the program
    catch
        disp("Port not opened successfully. Please troubleshoot the issue and try again.")
        disp(" ");
        return;
    end
end

end
