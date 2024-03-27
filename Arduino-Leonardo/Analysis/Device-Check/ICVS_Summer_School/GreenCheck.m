colours = ["red", "green", "yellow"];

for LED = 1:length(colours)
    figure(LED)
    t = tiledlayout(2,4);
    spectrum = NaN(81, 8);

    for group = 1:8
        fileName = char(strcat("calibration_data_", colours(LED), "_group", num2str(group), ".mat"));
        load(fileName);
    
        if group == 1
            wavelengths = wls';
        end
    
        spectrum(:, group) = spd;
    end

    spectrumMax = max(spectrum, [], 'all');
    
    for group = 1:8
        nexttile
        plot(wavelengths, spectrum(:,group), 'Marker', 'x', 'MarkerEdgeColor', 'k', 'Color', colours(LED));
        xlim([min(wavelengths), max(wavelengths)]);
        ylim([0, spectrumMax]);
        title(strcat("Group ", num2str(group)))
    end

end