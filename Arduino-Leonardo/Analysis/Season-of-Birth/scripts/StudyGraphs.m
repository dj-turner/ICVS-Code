cols = FindColours(studies);
textX = max(studyStats.mean + studyStats.se);

hold on
for i = 1:length(studies)

    yVal = length(studies)+1-i;
    errorbar(studyStats.mean(i), yVal,...
        0, 0, studyStats.se(i), studyStats.se(i),...
        'Marker', 'o', 'MarkerSize', 8, 'MarkerFaceColor', cols(i,:), 'LineWidth', 2.5, 'Color', cols(i,:))
    textStr = strcat(studies(i), " (n = ", num2str(studyStats.n(i)), ")");
    text(textX, yVal, textStr,'FontSize', 20,'Color', cols(i,:))
end
hold off

ylim([0,length(studies)+1])

input("Press ENTER to continue");
close all