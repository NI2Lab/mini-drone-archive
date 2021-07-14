% Color Detect
clear()
% HSV Threshold Green
thdown_green = [0.25, 40/240, 80/240];
thup_green = [0.40, 240/240, 240/240];
% HSV Threshold Blue
thdown_blue = [0.5, 0.35, 0.25];
thup_blue = [0.75, 1, 1];

% RGB RED & PurPle
red_hsv = rgb2hsv([255/255, 0, 0]);
purple_hsv = rgb2hsv([112/255, 48/255, 160/255]);

thdown_red1 = [0, 0.37, 0.37];
thup_red1 = [0.125, 1, 1];
thdown_red2 = [0.875, 0.37, 0.37];
thup_red2 = [1, 1, 1];
thdown_purple = [purple_hsv(1) - 0.125, 0.25, 0.25];
thup_purple = [purple_hsv(1) + 0.125, 1, 1];

thdown_red1 = [0, 0.25, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.25, 0.25];
thup_red2 = [1, 1, 1];
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
% frame = imread('dot2.jpg');
while 1
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
    bw_red = (((thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)))) ...% 빨간색1 검출
        + (((thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3))));      % 빨간색2 검출
    bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));   % 보라색 검출
    subplot(2, 2, 1), imshow(frame);
    subplot(2, 2, 3), imshow(bw_red);
    subplot(2, 2, 4), imshow(bw_purple);
    
end