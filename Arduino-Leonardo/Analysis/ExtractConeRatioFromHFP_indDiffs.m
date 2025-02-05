close; clear; clc;

% load data
load('all_data.mat');

% read in individual diff cone fundamentals
load('multipleObservers.mat');
%%

% calibration measurements
% write these number down somewhere smart!!!
gLumMax = 594.3295;
rLumMax = 962.7570;

% think L and M estimates here are wrong way around       
a=zeros(15,1000);

lms = usable_ptpt(:,3);
%lms=sort(lms,'descend');

for i=1:50
    for j=1:15
        lambda = 390:5:780;
        l = LMS_All(:,1,i);
        m = LMS_All(:,2,i);
        % add age changes and HFP errors to these too!
        a(j,i) = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, lms{j});
    end
end

% for i=1:15
%     errorbar(mean(a(i,:),2),1,std(a(i,:),[],2),'horizontal','x');
%     usable_ptpt{i,6} = mean(a(i,:),2);
%     usable_ptpt{i,7} = std(a(i,:),[],2); 
%     hold on;
%     xlim([0,5]);
% end

save('all_data.mat', 'usable_ptpt', 'big_df');



%----------------------------------------------------------------------%
function a = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, rSetting)
% specify rSetting
% derive a that would have produced a luminance match

glambda = 545;
rlambda = 630;
VFss = (1.980647 .* l + m);

% Vlambda
sensToRFromM = rSetting.*m(lambda == rlambda).*rLumMax.*VFss(lambda == glambda);
sensToGFromM = m(lambda==glambda).*gLumMax.*VFss(lambda==rlambda);
sensToGFromL = l(lambda==glambda).*gLumMax.*VFss(lambda==rlambda);
sensToRFromL = rSetting.*l(lambda==rlambda).*rLumMax.*VFss(lambda == glambda);

a = (sensToRFromM-sensToGFromM)./(sensToGFromL-sensToRFromL);

end