% This code will reproduce the results of the paper
% "A multi-channel framework for joint reconstruction
% of multi-contrast parallel MRI".
% Submitted for peer review.
% Code by Erfan Ebrahim Esfahani.
% Feel free to ask any questions or report bugs via
% email: erfan.ebrahim@outlook.com

%% Reproducing the results of NRITV in Fig. 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uncomment the sampling pattern whose 
% results you'd like to reproduce.
% This code takes about 3 hours 
% to run on an average laptop with 8 GB RAM, please be patient!
% The output will be mean +/- standard deviation
% of SNR and SSIM, as seen in Fig. 2.
clear all
addpath(genpath('./Utils'));
%% Statistical report
% Default values
sigma = 0;
rng('default')
maxit = 300;
param.mu = 0.7;           %no need to change
param.delta = 0.99;       %no need to change
param.theta = 1;          %no need to change
param.tau = sqrt(16/(3*(8+4+1))); %no need to change
param.beta = 4e-5;        %no need to change
param.lambda_inv = 7e-5;

% Loading data
load Phantom_data
%mask = mask_R7;  %Uncomment to see R=7 results from figure 2!
mask = mask_R5;
n = size(mask,1);
mask0 = mask;
C = size(X,4);

for i = 1:size(X,3) %Image sets 1:20
xx = squeeze(X(:,:,i,:));
x0 = imresize(xx,[n n]);

% Undersampled k-space
Kudata = repmat(mask,1,1,size(ss,3),C).*b(:,:,:,:,i);

% Sensitivity estimation
CalS = getCalibSize(mask);
KS = [3,3];
eigThresh_1 = 1e-4;
sss = ESPIRiT_Erfan2(Kudata(:,:,:,1),CalS,KS,eigThresh_1);
sss = abs(sss);
coil_err(i) = 100*norm(ss(:)-sss(:))/norm(ss(:));
fprintf('Coil Sensitivity Estimation Error = %2f percent\n\n',coil_err(i));

% Solution
tic;
u = solver_MC_P_NRITV2 (maxit,mask,sss,x0,param,Kudata);
time = toc;
out = abs(u.sol);

  
SNR(i,:) = (u.SNR(:,end));
SSIM(i,:) = (u.SSIM(:,end));
end


%% Performance Metrics
for c = 1: C
   Mean_SNR5(c) = mean(SNR(:,c));
   Std_SNR5(c) = std(SNR(:,c));
   
   Mean_SSIM5(c) = mean(SSIM(:,c));
   Std_SSIM5(c) = std(SSIM(:,c));
   
   Mean_coil_err = mean(coil_err);
end   

Average_SNR = Mean_SNR5
STD_SNR = Std_SNR5
Average_SSIM = Mean_SSIM5
STD_SSIM = Std_SSIM5
Average_Sensitivity_estimation_error =  Mean_coil_err

