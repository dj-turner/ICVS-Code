close all; clear all; clc;

% laod data
load('all_data.mat');

% read in cone fundamentals
%coneFundamentals = csvread('linss2_10e_fine.csv');

% read in individual diff cone fundamentals
load('multipleObservers.mat');

% calibration measurements
% write these number down somewhere smart!!!
gLumMax = 594.3295;%3;%4.9;%7.6;%1.2525e-06;%2.3681e-04;%%1.7713;%100;
rLumMax =  962.7570;%16;%26.3;%16.8;%366.3%4.0736e-06;%0.0017;%%3.1136;%500;function ExtractConeRatioFromHFP_indDiffs

% think L and M estimates here are wrong way around
% Q FOR ALLIE: why 1000 here?
a=zeros(15,50); % was 1000

%%

% Q FOR ALLIE: what do these values represent?
lms = usable_ptpt(:,3);
%lms=sort(lms,'descend');

%%
for i=1:50 %was 1000
    for j=1:15
        lambda = 390:5:780;
        % Q FOR ALLIE: why are there 50 sets of cone fundamentals? how were
        % these calculated?
        l = LMS_All(:,1,i);
        m = LMS_All(:,2,i);
        % add age changes and HFP errors to these too!
        % Q FOR ALLIE: Are these values supposed to represent lm ratio?
        % there are a lot of high values (3+) and not many in the 2 range,
        % these values seem strange
        a(j,i) = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, lms{j});
    end
end

%%
histogram(mean(a,2),100)

%%
% for i=1:15
%     errorbar(mean(a(i,:),2),1,std(a(i,:),[],2),'horizontal','x');
%     usable_ptpt{i,6} = mean(a(i,:),2);
%     usable_ptpt{i,7} = std(a(i,:),[],2); 
%     hold on;
%     xlim([0,5]);
% end

save(['all_data.mat'], 'usable_ptpt', 'big_df');

% % predict settings as a function of a
% a = 0:0.2:16; %1.980647; %1:0.2:8;
% for i = 1:length(a)
%     rSetting(i) = FindRSetting(gLumMax, rLumMax, lambda, l, m, a(i));
% end
% rMinSetting = FindRSetting(gLumMax, rLumMax, lambda, l, m, 1000)
% %
% %figure; hold on;
% %plot(a, rSetting, 'rx');
% 
% % estimate a from settings
% %rSetting = 0:0.05:1;
% %rSetting=0.3125;
% for i = 1:length(rSetting)
%     aCalc(i) = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, rSetting(i));
% end

%SSa = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, 0.6175)
% a = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, 0.6175)
% 
% save('lmFromHFP','aCalc', 'rSetting');
% figure()
% plot(rSetting, aCalc,'ko');
% xlim([0,1]);
% ylim([0,20]);
% 
% %plot([-16 16], [rMinSetting rMinSetting], 'r-.');
% %plot([-16 16], [1 1], 'k-.');
% xlim([0,20]);
% axis tight
% box on
% %---------------------------------
% SS = FindRSetting(gLumMax, rLumMax, lambda, l, m, 1.980647)
%---------------------------------
% FIND R SETTING RIGHT, FIND A SETTING NOT RIGHT YET

function rSetting = FindRSetting(gLumMax, rLumMax, lambda, l, m, a)
% specify wavelength and max "luminance" of G and R primaries
% fix g setting and find r setting

VFe = (a .* l + m);
VFss = (1.980647 .* l + m);

gLambda = 545;
rLambda = 630;
sensToG = VFe(lambda == gLambda)./VFss(lambda == gLambda);
sensToR = VFe(lambda == rLambda)./VFss(lambda == rLambda);

gSetting = 1;

gLumEffective = gSetting .* sensToG .* gLumMax;
% rLumEffective = rSetting .* sensToR .* rLumMax;
rSetting = gLumEffective ./ (sensToR .* rLumMax);

%---------------------------------
end

%---------------------------------
function a = FindaFromSetting(gLumMax, rLumMax, lambda, l, m, rSetting)
% specify rSetting
% derive a that would have produced a luminance match

% % VFe = (a .* l + m) ./ 2.87090767;

glambda = 545;
rlambda = 630;
VFss = (1.980647 .* l + m);

sensToRFromM = rSetting.*m(lambda == rlambda).*rLumMax.*VFss(lambda == glambda);
sensToGFromM = m(lambda==glambda).*gLumMax.*VFss(lambda==rlambda);
sensToGFromL = l(lambda==glambda).*gLumMax.*VFss(lambda==rlambda);
sensToRFromL = rSetting.*l(lambda==rlambda).*rLumMax.*VFss(lambda == glambda);

a = (sensToRFromM-sensToGFromM)./(sensToGFromL-sensToRFromL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACH comment out 03/12/19
% a = 1;

%this doesn't work because it should be integrated - not just peak
% sensToGFromL = a .* l(lambda == gLambda);
% sensToGFromM = m(lambda == gLambda);
% sensToRFromL = a .* l(lambda == rLambda);
% sensToRFromM = m(lambda == rLambda);

%gSetting = 1;

% gLumEffective = gSetting .* (sensToGFromL + sensToGFromM) .* gLumMax;
% rLumEffective = rSetting .* (sensToRFromL + sensToRFromM) .* rLumMax;

%a = ((gSetting .* gLumMax .* sensToGFromM)-(rSetting .* rLumMax .* sensToRFromM)) ./ ((rSetting .* rLumMax .* sensToRFromL)-(gSetting .* gLumMax .* sensToGFromL) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------

%---------------------------------

% % % construct vLambda
% % VFe = 0.68990272 .* l  + 0.34832189 .* m;
% a = 1.980647;
% VFe = (a .* l + m) ./ 2.87090767;

% % % test by checking vLambda
% vLambda = csvread('linCIE2008v2e_fine.csv');
% vL = vLambda(:, 2);
% sum(vL - VFe)

end