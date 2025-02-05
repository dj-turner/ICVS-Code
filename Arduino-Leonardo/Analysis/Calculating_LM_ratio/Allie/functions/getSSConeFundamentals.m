% function to get Stockman Sharpe cone fundamentals for comparison

function [ssWav,ssL,ssM,ssS] = getSSConeFundamentals

ss = csvread('ss2_10q_1.csv');
ssL = ss(11:5:311,2);
ssM = ss(11:5:311,3);
ssS = ss(11:5:311,4);
ssWav = ss(11:5:311,1);

end