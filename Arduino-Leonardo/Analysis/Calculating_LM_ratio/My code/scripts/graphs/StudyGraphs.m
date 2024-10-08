cols = FindColours(studies);
textX = max(studyStats.mean + studyStats.se);

hold on
for i = 1:length(studies)

    yVal = length(studies)+1-i;
    errorbar(studyStats.mean(i), yVal,...
        0, 0, studyStats.se(i), studyStats.se(i),...
        'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', cols(i,:), 'LineWidth', 5, 'Color', cols(i,:))
    textStr = strcat(studies(i), " (n = ", num2str(studyStats.n(i)), ")");
    text(-0.4, yVal, textStr,'FontSize', 26,'Color', cols(i,:), 'FontWeight', 'bold')
end
hold off

ylim([0,length(studies)+1])
set(gca,'FontSize',26, 'FontName', 'Courier', 'FontWeight', 'bold')

input("Press ENTER to continue");
close all
hold off