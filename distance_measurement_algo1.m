% This script is the algorithm for measuring the distance between the
% tissue and the iOCT tip with OCT signal as feedback.
% Detailed information please refer to the paper "An Optical Coherence Tomography Equipped Continuum Robot with
% Shape Sensing Capability and Laser Ablation Function for In Situ
% Diseases Theranostic: A proof of concep".
% Please indicate Copyright from Brandon Chen. Only non-commercial usage is allowed.

%% Read image and generate its profile at vertical direction
load("pos.mat")
load("Bmodedata.mat")
I=imread('boundary_polarfps_2022-08-12_0273.tiff');

pks_sig=[]
lks_sig=[]
Distance = Inf(1,6238,'single')
% Initialize the parameters
delta_d = 0.2;
theta_zero = 0.92;
r_zero = 0.9

%% Generate plot and find peaks with raw A-line signal data
x_pos = pos;
y_signal = I_amp_comp;
step = 90;
for i = 1:step:size(y_signal, 2)
    [pks_sig{i}, lks_sig{i}] = findpeaks(y_signal(:,i), x_pos, "MinPeakHeight", 2000, "MinPeakDistance", 70)
    if size(lks_sig{1},1) >= 3
       
    end
    

end

figure
plot(x_pos, y_signal(:,1), lks_sig{1}, pks_sig{1},'o')
title('From A-line signal')
legend
%%
disp(lks_sig{1}(2))
%% Generate plot with peaks and image
% profiles in horizontal direction
x1 = [0 size(I,2)];
y1 = [size(I,1)/2 size(I,1)/2];
profile1 = improfile(I,x1,y1); % Define the intensity profile range
profile1_nor = normalize(squeeze(profile1),'range');

imagesc(flipud(I))
set(gca,'YDir','normal')
axis on;
hold on;
plot(x1,y1,'b')
a = linspace(0,size(I,2),size(I,2))
b = size(I,1) - profile1_nor(2:end,1)*y1(1)
% find minimal peak method
[pks_img, lks_img] = findpeaks(b, a, "MinPeakHeight", 0.39*size(I,1)/2+size(I,1)/2, "MinPeakDistance", 20)
plot(a,b,lks_img,pks_img,'o')
title('Original')
hold off;





