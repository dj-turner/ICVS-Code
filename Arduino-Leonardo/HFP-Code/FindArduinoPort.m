function serialObj = FindArduinoPort

availablePorts = serialportlist;

arduinoPort = char(availablePorts(end));
serialObj = serialport(arduinoPort, 9600);

end