clear()
% HSV Threshold Blue
thdown_blue = [0.5, 0.35, 0.25];        % 파란색의 임계값 범위
thup_blue = [0.75, 1, 1];             
red = rgb2hsv([255/255, 0, 0]);                 % [0, 1, 1]
purple = rgb2hsv([112/255, 48/255, 160/255]);   % [0.76, 0.7, 0.6]
% thdown_red1 = [0, 0.37, 0.37];
% thup_red1 = [0.125, 1, 1];
% thdown_red2 = [0.875, 0.37, 0.37];
% thup_red2 = [1, 1, 1];
% thdown_purple = [purple(1) - 0.125, 0.25, 0.25];
% thup_purple = [purple(1) + 0.125, 1, 1];
thdown_red1 = [0, 0.5, 0.5];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.5, 0.5];
thup_red2 = [1, 1, 1];
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

% droneObj = ryze();
% cameraObj = camera(droneObj);
% takeoff(droneObj);
frame = imread('dot1.jpg');

% moveforward(droneObj, 'distacne', 1.75);
% moveup(droneObj, 'distance', 0.3);
while(1)
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);
    
    bw_red = (thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)) ...
        | (thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3)); 
    bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));
    
    subplot(1, 3, 1), imshow(frame);
    subplot(1, 3, 2), imshow(bw_red);
    subplot(1, 3, 3), imshow(bw_purple);

    if(sum(bw_red, 'all') > 8000)
        turn(droneObj, deg2rad(-90));
%         moveforward(droneObj, 'distance', 0.7);
        land(droneObj);
%         disp('왼쪽으로 회전!');
        break;
    elseif(sum(bw_purple, 'all') > 8000)
        land(droneObj);
        return;
    else
        moveforward(droneObj, 'distance', 0.5);
    end
end
