%function plot Stockman Sharpe cone fundamentals for comparison

function plotSSConeFundamentals(ssWav,ssL,ssM,ssS)

plot(ssWav,ssL,'r--');
plot(ssWav,ssM,'g--');
plot(ssWav,ssS,'b--');

end
