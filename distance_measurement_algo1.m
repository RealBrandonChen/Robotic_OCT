% This script is the algorithm for measuring the distance between the
% tissue and the iOCT tip with OCT signal as feedback.
% Detailed information please refer to the paper "Design and Evaluation of a Flexible Sensorized Robotic OCT".
% Any copies/variants, please indicate copyright from Brandon Chen. Only non-commercial usage is allowed.

%% Read image and generate its profile at vertical direction
% load the data read from the spectrometer
load("pos.mat");
% save from I_amp_comp variance
load("Bmodedata_160fps_00.mat");
load('hlf_tot_pix.mat');
load('cat_pix.mat');

% Initialize the parameters
pks_sig=[];
lks_sig=[];
delta_d = 0.2; % physics wall thickness of the catheter
theta_zero = 54 * 2/360 * pi * 2; % reflection angle of the micro-reflector
r_zero = 0.7; % inner radius of the catheter
d_min_index = inf; % location between the inner surface of the catheter and the boundary represented with index
d_index = 0; 
cat_index = 0;
d_min_lks = 0; % location of the minimal distance in one A-line

%% Find peaks with raw A-line signal data and return the minimal distance
x_pos = pos;
y_signal = I_amp_comp;
step = 10; % sampling
for i = 1:step:size(y_signal, 2)
    [pks_sig{i}, lks_sig{i}] = findpeaks(y_signal(:,i), x_pos, "MinPeakHeight", 1000, "MinPeakDistance", 200); % find local maxima
    if size(lks_sig{i},1) >= 3
       d_index = lks_sig{i}(3) - lks_sig{i}(1);
       if d_index <= d_min_index
          d_min_index = d_index;
          d_min_lks = i
       end
    end
end
% figure
% plot(x_pos,y_signal(:,1), lks_sig{1}, pks_sig{1},'o')
% plot(x_pos,y_signal(:,d_min_lks), lks_sig{d_min_lks}, pks_sig{d_min_lks},'o')
%%
cat_index = lks_sig{1}(2) - lks_sig{1}(1);

% Calculate the minimal distance
gamma = delta_d/(cat_index * sin(theta_zero)); % adjusting factor to transfer the index intervals to the physical distance 
d_min = gamma * d_min_index + r_zero;
%% Visualize the imgae and corresponding A-line with minimal distance
I=imread('5fps_00_160.tiff');
figure('Position', [10 10 900 900])

imagesc(flipud(I))
set(gca,'YDir','normal')
axis off;
axis equal;
hold on;

%% set first A-line signal
% set x and y on the image
cat_inner_lks = cath_pix/hlf_tot_pix * size(I,1)/2 + size(I,2)/2;
A_x1 = linspace(cat_inner_lks,size(I,1),4096);
A_y1 = y_signal(:, 1);
A_y1_norm = (A_y1/pks_sig{1}(2) * 750) * 0.9 + 750; % Normalized signal by over the maximum peak value, can be adjust here.
H_x = [size(I,2)/2, size(I,2)];
H_y = [size(I,2)/2, size(I,2)/2];
plot(A_x1, A_y1_norm, 'Color',[0.6350 0.0780 0.1840])
plot(H_x, H_y,'Color',[0.6350 0.0780 0.1840],'LineStyle','--')

%%
% Set A-line signal of the minial distance and rotate it to proper place
A_x_min= linspace(cat_inner_lks,size(I,1),4096);
A_y_min = y_signal(:, d_min_lks);
A_y_min_norm = (A_y_min/pks_sig{d_min_lks}(1) * 750) * 0.9 + 750;

x_center = size(I,2)/2;
y_center = size(I,1)/2;
signal_rotation_angle = d_min_lks/6238 * pi * 2;

[x_rotated, y_rotated] = rotate_curve(A_x_min, A_y_min_norm, x_center, y_center, signal_rotation_angle);
[Hx_rotated, Hy_rotated] = rotate_curve(H_x, H_y, x_center, y_center, signal_rotation_angle);
plot(x_rotated,y_rotated,  'Color', [0 0.4470 0.7410], 'LineStyle','-')
plot(Hx_rotated, Hy_rotated, 'Color', [0 0.4470 0.7410], 'LineStyle','--')

% title('A-line for Distance Measurement')
% legend('A-line of no objects detected', '','A-line of minimal distance','')
hold off;


%% Read profiles of the image for verification. 
% profiles in horizontal direction
% x1 = [0 size(I,2)];
% y1 = [size(I,1)/2 size(I,1)/2];
% profile1 = improfile(I,x1,y1); % Define the intensity profile range
% profile1_nor = normalize(squeeze(profile1),'range');
% 
% imagesc(flipud(I))
% set(gca,'YDir','normal')
% axis on;
% hold on;
% plot(x1,y1,'b')
% A_x1 = linspace(0,size(I,2),size(I,2))
% A_y_min_norm = size(I,1) - profile1_nor(2:end,1)*y1(1)
% % find minimal peak method
% [pks_img, lks_img] = findpeaks(A_y_min_norm, A_x1, "MinPeakHeight", 0.39*size(I,1)/2+size(I,1)/2, "MinPeakDistance", 20)
% plot(A_x1,A_y_min_norm,lks_img,pks_img,'o')
% title('Original')
% hold off;




