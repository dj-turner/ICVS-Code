function WriteLEDs(a, LEDvals)

% Locations of red, green, and yellow LED
dNum = ["D6", "D5", "D9"];      % Blue = "D3"

for i = 1:length(dNum)
    colVal = (255 - LEDvals(i)) / 255;
    writePWMDutyCycle(a, dNum(i), colVal);
end

end
