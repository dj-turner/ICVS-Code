data = readtable("Data-Pt1.2.xlsx", 'Sheet','Matlab_Data');

vars = ["RLM_Lambda", "RLM_MixLight", "HFP_Leo_RG", "HFP_Uno_Red"];

dataMeans = nan(max(data.PPno),(1+12));
dataAllMeans = nan(max(data.PPno), 4);
dataSEs = dataMeans;
dataAllSEs = dataAllMeans;

for ptpt = 1:max(data.PPno)
    ptptData = data(data.PPno == ptpt & data.HRR_Pass == 1 & data.Match_Type == 1,:);
    if ~isempty(ptptData)
    dataMeans(ptpt,1) = ptpt;
    col = 1;
    for var = 1:length(vars)
        for session = 1:3
            if ptpt == 8 && var >= 3 && session == 2, continue; end
            col = col + 1;
            currentVar = strcat(vars(var), "_", string(session));
            dataMeans(ptpt,col) = mean(ptptData.(currentVar),'omitmissing');
            dataSEs(ptpt,col) = std(ptptData.(currentVar),'omitmissing') ./ height(ptptData.(currentVar)(~isnan(ptptData.(currentVar)),:));
        end
        currentVars = startsWith(string(ptptData.Properties.VariableNames), vars(var));
        dataAllMeans(ptpt,var) = table2array(mean(ptptData(:,currentVars),'all','omitmissing'));
        seData = reshape(table2array(ptptData(:,currentVars)), numel(ptptData(:,currentVars)), 1);
        dataAllSEs(ptpt,var) = std(seData,'omitmissing') ./ height(seData(~isnan(seData),:));
    end
    end
end

dataMeans = [dataMeans dataAllMeans];

rlmData = dataMeans(:,[2,3,4,14,15]);
hfpData = dataMeans(:,[8,9,10,16,17]);

% RLM
hfpData(8,:) = [];
dataAllSEs(8,:) = [];
[r,p] = corr(hfpData(:,4), hfpData(:,5), 'Rows','pairwise')

% hold on
% %plot(0:.01:1, 0:.01:1, 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')
% errorbar(rlmData(:,4), rlmData(:,5), dataAllSEs(:,2), dataAllSEs(:,2), dataAllSEs(:,1), dataAllSEs(:,1),... 
%     'Marker','none','LineStyle','none', 'LineWidth', 3, 'Color','r')
% plot(rlmData(:,4), rlmData(:,5), 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm',...
%     'MarkerSize', 10, 'LineStyle', 'none')
% xlim([.54, .64]);
% ylim([44, 54]);
% set(gca,'FontSize',40,'XTick', [.54:.02:.64], 'YTick', [44:2:54])
% xlabel("uPPD")
% ylabel("Oculus HMC Anomaloscope")
% l = lsline;
% l.LineWidth = 3;
% l.Color = 'k';
