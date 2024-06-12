% function to get Stockman Sharpe cone fundamentals for comparison

function [ssWav,ssEL,ssEM,ssES] = getSSEnergyLinearConeFundamentals

ssE = csvread('linss2_10e_5.csv');
ssEL = ssE(3:63,2);
ssEM = ssE(3:63,3);
ssES = ssE(3:63,4);
ssWav = ssE(3:63,1);

end