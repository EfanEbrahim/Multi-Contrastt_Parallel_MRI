% This code will reproduce the results of the paper
% "A multi-channel framework for joint reconstruction
% of multi-contrast parallel MRI".
% Submitted for peer review.
% Code by Erfan Ebrahim Esfahani.
% Feel free to ask any questions or report bugs via
% email: erfan.ebrahim@outlook.com
%% Reproducing the results of NRITV in Fig. S5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all, close all
addpath(genpath('./Utils'));
%% Setting parameters


maxit = 200;              
param.mu = 0.7;           %no need to change
param.delta = 0.99;       %no need to change
param.theta = 1;          %no need to change
param.tau = sqrt(16/(3*(8+4+1)));  %no need to change
param.beta = 4e-5;       %might need to change
param.lambda_inv = 7e-5; %Should change according to noise

%% Loading data

load Radial_data_n80
[m,n,N] = size(x0);
Kudata = repmat(mask,1,1,size(ss,3),N).*b;


%% Sensitivity estimation
CalS = getCalibSize(mask);
KS = [3,3];
eigThresh_1 = 0.004;
sss = ESPIRiT_Erfan2(Kudata(:,:,:,1),CalS,KS,eigThresh_1);
coil_err = 100*norm(ss(:)-sss(:))/norm(ss(:));
fprintf('Coil Sensitivity Estimation Error = %2f percent\n\n',coil_err);

%% Sloution by NRITV

out = solver_MC_P_NRITV2 (maxit,mask,sss,x0,param,Kudata);

out.Runtime
u = out.sol;
SNR_proposed = out.SNR;
SSIM_proposed = out.SSIM;


u = abs(u);

for ii = 1:N
figure,imshow(u(:,:,ii));title('Proposed');
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
set(gca,'FontSize',14);
h=xlabel('Iterations');
set(h,'FontSize',14);
h=ylabel('SNR');
set(h,'FontSize',14);
legend({'27 ms','94 ms'}); 
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
set(gca,'FontSize',14);
h=xlabel('Iterations');
set(h,'FontSize',14);
h=ylabel('SSIM');
set(h,'FontSize',14);
legend({'27 ms','94 ms'}); 
grid on
