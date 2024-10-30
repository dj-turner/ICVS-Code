data = LoadData;

tbl = readtable("data\Ptpt_ID_Links.xlsx");

tbl = convertvars(tbl,tbl.Properties.VariableNames,'string');

idxValidation = ~strcmp(tbl.PtptIDDana,"");
idxLargeN = ~strcmp(tbl.PtptIDJosh,"");

validTbl = tbl(idxValidation & idxLargeN,:);

valueArray = zeros(height(validTbl),2*2);
grads = zeros(height(validTbl),1);

for ptpt = 1:height(validTbl)
    validationID = validTbl.PtptIDDana(ptpt);
    largeNID1 = validTbl.PtptIDJosh(ptpt);

    hfpValidation = data.Dana.HFP_Leo_logRG(strcmp(data.Dana.ptptID,validationID));
    dateValidation = data.Dana.hfpDay(strcmp(data.Dana.ptptID,validationID));

    if ~strcmp(largeNID1,"")
        hfpLargeN1 = data.Josh.HFP_Leo_logRG(strcmp(data.Josh.ptptID,largeNID1));
        dateLargeN1 = data.Josh.hfpDay(strcmp(data.Josh.ptptID,largeNID1));
    else
        hfpLargeN1 = NaN;
        dateLargeN1 = NaN;
    end

    valueArray(ptpt,:) = [dateValidation, hfpValidation, dateLargeN1, hfpLargeN1];

    grads(ptpt) = (hfpLargeN1 - hfpValidation) / (dateLargeN1 - dateValidation);

end

f = NewFigWindow;
hold on
for ptpt = 1:height(valueArray)
    x = [valueArray(ptpt,1), valueArray(ptpt,3)];
    y = [valueArray(ptpt,2), valueArray(ptpt,4)];
    plot(x,y,...
        'LineWidth',1,'Color','w',...
        'Marker','o','MarkerSize',10,...
        'MarkerEdgeColor','w','MarkerFaceColor','m');
    plot(x(end),y(end),...
        'LineStyle','none',...
        'Marker','o','MarkerSize',10,...
        'MarkerEdgeColor','w','MarkerFaceColor','c');
end
text(valueArray(:,3),valueArray(:,4),string(1:height(validTbl)),'Color','r','FontWeight','bold','FontSize',20);

lgdStr = [(string(1:height(validTbl))' + " = " + validTbl.Name)'; repmat("", [1, height(validTbl)])];
ldgStr = reshape(lgdStr, [numel(ldgStr) 1]);
l = legend(lgdStr);

xlim([0 .4]);
NiceGraphs(f,l);
%%
idx = abs(grads) < 10;
validGrads = grads(idx);

[h,p,ci,stats] = ttest(valueArray(:,2),valueArray(:,4))

[h,p,ci,stats] = ttest(validGrads,0)