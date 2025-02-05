% function to plot cone fundamentals

function plotConeFundamentals(wavelengths,l,m,s);

plot(wavelengths,log10(l),'r');
hold on;
plot(wavelengths,log10(m),'g');
plot(wavelengths,log10(s),'b');
xlabel('Wavelengths (lambda)');
ylabel('Cone Fundamentals Quanta (log abosptrance)');

end