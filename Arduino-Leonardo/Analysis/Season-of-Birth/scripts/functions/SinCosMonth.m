function [sinMonths,cosMonths] = SinCosMonth(inputMonths)

sinMonths = sin(2*pi*((inputMonths)/12));
cosMonths = cos(2*pi*((inputMonths)/12));

end