% This code will reproduce the results of the paper
% "A multi-channel framework for joint reconstruction
% of multi-contrast parallel MRI".
% Submitted for peer review.
% Code by Erfan Ebrahim Esfahani.
% Feel free to ask any questions or report bugs via
% email: erfan.ebrahim@outlook.com
%% Reproducing the results of NRITV in Fig. 9
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
param.beta = 4e-5;        %no need to change
param.lambda_inv = 7e-5;  %Should change according to noise

%% Loading data

load Breast_data_fig9
[n,m,N] = size(x0);


%Undersampled k-space data
Kudata = repmat(mask,1,1,size(ss,3),N).*b;

sss = ss;
%% Sloution by NRITV

out = solver_MC_P_NRITV2 (maxit,mask,sss,x0,param,Kudata);

out.Runtime
u = out.sol;
SNR_proposed = out.SNR;
SSIM_proposed = out.SSIM;



%% Display results
%zoom
x11 = 50;
x22 = 110;
y11 = 10;
y22 = 70;


u = abs(u);
uRR = u;
for t = 1:N
uRRxy(:,:,t) = uRR(x11:x22,y11:y22);
end
for ii = 1:N
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
hold on;
h=plot(1:1:mm,SNR_proposed(4,:),'g'); 
set(h,'LineWidth',2);
set(gca,'FontSize',14);
h=xlabel('Iterations');
set(h,'FontSize',14);
h=ylabel('SNR');
set(h,'FontSize',14);
legend({'Contrast 1','Contrast 2', 'Contrast 3', 'Contrast 4'}); 
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
hold on;
h=plot(1:1:mm,SSIM_proposed(4,:),'g');
set(h,'LineWidth',2);
set(gca,'FontSize',14);
h=xlabel('Iterations');
set(h,'FontSize',14);
h=ylabel('SSIM');
set(h,'FontSize',14);
legend({'Contrast 1','Contrast 2', 'Contrast 3', 'Contrast 4'}); 
grid on
