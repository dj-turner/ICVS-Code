% function to plot linear energy cone fundamentals

function plotEnergyConeFundamentals(wavelengths,eL,eM,eS)

plot(wavelengths,eL,'r');
hold on;
plot(wavelengths,eM,'g');
plot(wavelengths,eS,'b');
xlabel('Wavelengths (lambda)');
ylabel('Cone Fundamentals Energy (lin absorptance)');

end