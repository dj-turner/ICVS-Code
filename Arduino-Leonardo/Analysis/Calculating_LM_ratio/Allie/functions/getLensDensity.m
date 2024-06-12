% function to calculate optical density of lens as a function of age, D,r,ocul(lambda)

function [Docul,lens1st,lens2nd] = getLensDensity(age)

lens2components = csvread('lens2components.csv');
lens1st = lens2components(:,2); %extract 1st component of 2 component model
lens2nd = lens2components(:,3); %extract 2nd component of 2 component model
Docul = (lens1st.*(1+0.02*(age-32)))+lens2nd;

end
