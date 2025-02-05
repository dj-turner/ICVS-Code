%function plot Stockman Sharpe cone fundamentals for comparison

function plotSSEnergyLinearConeFundamentals(ssWav,ssEL,ssEM,ssES)

plot(ssWav,ssEL,'r--');
plot(ssWav,ssEM,'g--');
plot(ssWav,ssES,'b--');

end
