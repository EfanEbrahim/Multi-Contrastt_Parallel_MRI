% This code will reproduce the results of the paper
% "A multi-channel framework for joint reconstruction
% of multi-contrast parallel MRI".
% Submitted for peer review.
% Code by Erfan Ebrahim Esfahani.
% Feel free to ask any questions or report bugs via
% email: erfan.ebrahim@outlook.com

%% Reproducing the results of NRITV in Fig. 8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all
 addpath(genpath('./Utils'));
%% Setting parameters

maxit = 150;              
param.mu = 0.7;           %no need to change
param.delta = 0.99;       %no need to change
param.theta = 1;          %no need to change
param.tau = sqrt(16/(3*(8+4+1)));  %no need to change
param.beta = 4e-5;       %no need to change
param.lambda_inv = 0.005; % needs change according to noise

%% Loading data

load Knee_data_fig8
%b: Fully sampled k-space
%x0: Ref magnitude for SNR,SSIM calculation
%ss: Ref sensitivy maps for RLNE calculation
%mask: Sampling pattern

%Get the sizes
[n,m,N] = size(x0);

%Undersampled k-space
Kudata = repmat(mask,1,1,size(ss,3),N).*b;

%Estimated sensitivity maps to be used by the algorithm
CalS = getCalibSize(mask);
KS = [7,7];
eigThresh_1 = 0.02;
sss = ESPIRiT_Erfan2(Kudata(:,:,:,1),CalS,KS,eigThresh_1);
coil_err = 100*norm(ss(:)-sss(:))/norm(ss(:));
fprintf('\nCoil Sensitivity Estimation Error = %2f percent\n\n',coil_err);

%% Sloution by NRITV
out = solver_MC_P_NRITV2 (maxit,mask,sss,x0,param,Kudata);

Time = out.Runtime
u = out.sol;
SNR_proposed = out.SNR;
SSIM_proposed = out.SSIM;


u = abs(u);

%% Dispaly results
%zoom
x11 = 95;
x22 = 145;
y11 = 55;
y22 = 105;


uRR = u;
for t = 1:2
uRRxy(:,:,t) = uRR(x11:x22,y11:y22,t);
end
for ii = 1:2
 zz = insertText([u(:,:,ii),imresize(uRRxy(:,:,ii),[n,m])] ,[1,1], ...
  ['SNR:' num2str(SNR_proposed(ii,end),'%0.1f')...
  ', SSIM:' num2str(SSIM_proposed(ii,end),'%0.2f')],...
  'FontSize',12,'BoxColor','white');
qq(:,:,ii) = rgb2gray(zz);
figure,imshow(qq(:,:,ii));title('Proposed');
end


x11 = 85;
x22 = 145;
y11 = 40;
y22 = 100;
clear uRRxy
for t = 3
uRRxy(:,:,t) = uRR(x11:x22,y11:y22,t);
end
for ii = 3
 zz = insertText([u(:,:,ii),imresize(uRRxy(:,:,ii),[n,m])] ,[1,1], ...
  ['SNR:' num2str(SNR_proposed(ii,end),'%0.1f')...
  ', SSIM:' num2str(SSIM_proposed(ii,end),'%0.2f')],...
  'FontSize',12,'BoxColor','white');
qq(:,:,ii) = rgb2gray(zz);
figure,imshow(qq(:,:,ii));title('Proposed');
end
%% Graph of SNR
mm = maxit;
figure;
h=plot(1:1:mm,SNR_proposed(1,:),'k'); 
set(h,'LineWidth',2);
hold on;
h=plot(1:1:mm,SNR_proposed(2,:),'r');  
set(h,'LineWidth',2);
hold on;
h=plot(1:1:mm,SNR_proposed(3,:),'b'); 
set(h,'LineWidth',2);
set(gca,'FontSize',14);
h=xlabel('Iterations');
set(h,'FontSize',14);
h=ylabel('SNR');
set(h,'FontSize',14);
legend({'T_1','T_2', 'PD'}); 
grid on

%% Graph of SSIM
mm = maxit;
figure;
h=plot(1:1:mm,SSIM_proposed(1,:),'k'); 
set(h,'LineWidth',2);
hold on;
h=plot(1:1:mm,SSIM_proposed(2,:),'r');  
set(h,'LineWidth',2);
hold on;
h=plot(1:1:mm,SSIM_proposed(3,:),'b'); 
set(h,'LineWidth',2);
set(gca,'FontSize',14);
h=xlabel('Iterations');
set(h,'FontSize',14);
h=ylabel('SSIM');
set(h,'FontSize',14);
legend({'T_1','T_2', 'PD'}); 
grid on
