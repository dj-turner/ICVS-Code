function [sinMonths,cosMonths] = SinCosMonth(inputMonths)

sinMonths = sin(2*pi*((inputMonths-1)/12));
cosMonths = cos(2*pi*((inputMonths-1)/12));

end