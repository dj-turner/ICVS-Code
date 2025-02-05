% simulate CIE 2006 observers for 25 different observers with field sizes
% of 1,2,4,7,and 10 degrees, and ages of 20, 32, 40,60, and 80

% simulate standard observer

% created by ACH 11/08/2020

ages = 32;
fss = 10;

c=1; % just count through the 25 observers
for age=1:length(ages)
    for fs = 1:length(fss)
        coneFun = reconstructingConeFundamentals(ages(age),fss(fs),0);
        LMS_nstd(:,:,c) = [coneFun.eL, coneFun.eM, coneFun.eS];
    end
end

