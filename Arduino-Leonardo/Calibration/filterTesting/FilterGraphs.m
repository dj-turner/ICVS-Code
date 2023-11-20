clc; clear; close all;

load('filter.mat')
filterSpect = filterValues.filter.spect;
noFilterSpect = filterValues.nofilter.spect;

t = tiledlayout(1, 2);
nexttile

    plot(filterSpect(1,:), filterSpect(2,:), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', 'r')
    xlim([min(filterSpect(1,:)), max(filterSpect(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(filterSpect(2,:))]);
    ylabel("Spectral Sensitivity");
    title("Spectrum: With Filter");

    nexttile

    plot(noFilterSpect(1,:), noFilterSpect(2,:), 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', 'b')
    xlim([min(noFilterSpect(1,:)), max(noFilterSpect(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(noFilterSpect(2,:))]);
    ylabel("Spectral Sensitivity");
    title("Spectrum: Without Filter");

    %%
    redNoFilterOverFilter = tbl.LambdaSpectrum(1,:) ./ tbl.LambdaSpectrum(3,:);
    greenNoFilterOverFilter = tbl.LambdaSpectrum(2,:) ./ tbl.LambdaSpectrum(4,:);

    t = tiledlayout(1, 2);
nexttile

    plot(filterSpect(1,:), redNoFilterOverFilter, 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', 'r')
    xlim([min(filterSpect(1,:)), max(filterSpect(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(redNoFilterOverFilter)]);
    ylabel("Spectral Sensitivity");
    title("Red LED: No filter / filter");

    nexttile

    plot(noFilterSpect(1,:), greenNoFilterOverFilter, 'Color', 'k', 'Marker', 'x', 'MarkerEdgeColor', 'g')
    xlim([min(noFilterSpect(1,:)), max(noFilterSpect(1,:))]);
    xlabel("Lambda (nm)");
    ylim([0, max(greenNoFilterOverFilter)]);
    ylabel("Spectral Sensitivity");
    title("Green LED: No filter / filter");

    s.red = redNoFilterOverFilter;
    s.green = greenNoFilterOverFilter;

    save("no-filter-over-filter", "s");

    %%
  load('filter.mat')  

 wavelengths = filterValues.filter.spect(1,:);
 filterSpect = filterValues.filter.spect(2,:);
 noFilterSpect = filterValues.nofilter.spect(2,:);

 noFilterOverFilter = noFilterSpect ./ filterSpect;

plot(wavelengths, noFilterOverFilter, 'Marker', 'x', 'MarkerEdgeColor', 'r', 'Color', 'k')