% function to plot lens density as a function of age

function plotLensDensity(wavelengths,ages,lens1st,lens2nd)

plot(wavelengths,(lens1st.*(1+0.02*(ages(1)-32)))+lens2nd);
hold on;
plot(wavelengths,(lens1st.*(1+0.02*(ages(2)-32)))+lens2nd);
plot(wavelengths,(lens1st.*(1+0.02*(ages(3)-32)))+lens2nd);
xlabel('Wavelengths (lambda)');
ylabel('Lens Density');
title('D,r,ocul');
leg = legend('20yrs','40yrs','60yrs');

end