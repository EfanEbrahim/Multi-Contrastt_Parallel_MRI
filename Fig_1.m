clear all
addpath(genpath('./Utils'));

D = @(x) cat(3,[diff(x,1,1);zeros(1,size(x,2))],[diff(x,1,2) zeros(size(x,1),1)]);

load MC_phantom
N = size(x,3);
%% Unique lesion for C1
x(140:150, 120:130,1) = 1;

%% Gradient for all contrasts
for c = 1: N
    v(:,:,:,c) = D(x(:,:,c));
end
%% Gradient vector at lesion corner for all contrasts
 V = reshape(v(140,130,:,:),[2,N])

 z = [x(:,:,1) x(:,:,2) x(:,:,3) x(:,:,4)];


%% Display results
%zoom
x11 = 100;
x22 = 170;
y11 = 90;
y22 = 160;


uRR =x;
for t = 1:N
uRRxy(:,:,t) = uRR(x11:x22,y11:y22,t);
zz(:,:,t) = imresize(uRRxy(:,:,t),[200 200]);
end


zz = [z;zz(:,:,1) zz(:,:,2) zz(:,:,3) zz(:,:,4)];

figure,imshow(zz)
% imwrite(zz,'MC_phantom.png')