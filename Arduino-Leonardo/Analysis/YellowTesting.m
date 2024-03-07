%load rlm data
rlm_data = load("ParticipantMatchesRLM_15feb24.mat");
rlm_data = rlm_data.ParticipantMatchesRLM;

% load calibration data
cal_data = load(strcat("C:/Users/", getenv('USERNAME'), "/Documents/GitHub/ICVS-Code/Arduino-Leonardo/Calibration/CalibrationResults.mat"));
cal_data = cal_data.calibrationTable;

% filter relevant data from calibration file
s = struct;
colours = ["red", "green", "yellow"];

for colour = 1:length(colours)
    s.(colours(colour)).data = cal_data(cal_data.InputValue == 255 & strcmp(cal_data.LED, colours(colour)) & strcmp(cal_data.Device, "Green Band"),:);
    s.(colours(colour)).dates = [s.(colours(colour)).data.DateTime.Day, s.(colours(colour)).data.DateTime.Month, s.(colours(colour)).data.DateTime.Year];
    
    idx = zeros(height(s.(colours(colour)).dates), 1);
    for i = 1:height(s.(colours(colour)).dates)
        if i ~= height(s.(colours(colour)).dates) && sum(s.(colours(colour)).dates(i,:) == s.(colours(colour)).dates(i+1,:)) == 3
            idx(i+1) = 1;
        end
    end
    
    s.(colours(colour)).data(idx==1,:) = [];
    s.(colours(colour)).dates = [s.(colours(colour)).data.DateTime.Day, s.(colours(colour)).data.DateTime.Month, s.(colours(colour)).data.DateTime.Year];
end

%%
rlm_dates = fliplr(rlm_data.DateTime(:,1:3));
idx = zeros(height(rlm_dates), 1);
for i = 1:height(rlm_dates)
    if any(rlm_dates(i,:) == s.(colours(colour)).dates)
        idx(i) = 1;
    end
end

%%

rlm_data = rlm_data(logical(idx),:);
rlm_data = rlm_data(strcmp(rlm_data.MatchType, "Best") & rlm_data.Trial ~=1, :);

ptpts = unique(rlm_data.ParticipantCode);

ptptYellowData = zeros(height(ptpts), 6);
for i = 1:length(ptpts)
    ptpt = string(ptpts(i));
    ptptData = rlm_data(strcmp(string(rlm_data.ParticipantCode), ptpt), :);
    ptptRed = mean(ptptData.Red);
    ptptGreen = mean(ptptData.Green);
    ptptYellow = mean(ptptData.Yellow);
    ptptRatio = (ptptRed + ptptGreen) / ptptYellow;
    ptptDate = fliplr(ptptData.DateTime(1,1:3));
    ptptCalRed = table2array(s.red.data(sum(s.red.dates == ptptDate, 2) == 3,"Luminance"));
    ptptCalGreen = table2array(s.green.data(sum(s.green.dates == ptptDate, 2) == 3,"Luminance"));
    ptptCalYellow = table2array(s.yellow.data(sum(s.yellow.dates == ptptDate, 2) == 3,"Luminance"));
    ptptCalRatio = (ptptCalRed + ptptCalGreen) / ptptCalYellow;
    ptptYellowData(i,:) = [i, ptptDate, ptptRatio, ptptCalRatio];
end

ptptYellowData = array2table(ptptYellowData, "VariableNames", ["ptptNum", "Day", "Month", "Year", "ParticipantRatio", "CalibrationRatio"]);

x = ptptYellowData.CalibrationRatio;
y = ptptYellowData.ParticipantRatio;

scatter(x,y, "Marker", 'x', "MarkerEdgeColor", 'k', "LineWidth", 3);
xlabel("(R+G)/Y Calibration Luminance Value");
ylabel("Participant Average R+G)/Y Value for RLM Matching");
[r,p] = corr(x, y, 'tail', 'left')

