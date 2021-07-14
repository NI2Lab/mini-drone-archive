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

thdown_red1 = [0, 0.25, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.25, 0.25];
thup_red2 = [1, 1, 1];
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
% takeoff(droneObj);
% moveup(droneObj, 'distance', 0.5);
% frame = imread('dot2.jpg');
while 1
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
%     bw_red = (((thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)))) ...% 빨간색1 검출
%         + (((thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3))));      % 빨간색2 검출
%     bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));   % 보라색 검출
    bw_red = ((thdown_red1(1) < src_h) & (src_h < thup_red1(1))) + ((thdown_red2(1) < src_h) & (src_h < thup_red2(1)));     % 빨간색2 검출
    bw_purple = (thdown_purple(1) < src_h) & (src_h < thup_purple(1));   % 보라색 검출

    % Image Preprocessing
    bw1 = (0.5 < src_h) & (src_h < 0.75); % 파란색 검출 
    if sum(bw1, 'all') == 0
        bw1 = double(zeros(size(src_hsv)));
    end
    
    bw2 = imfill(bw1,'holes');      % 파란색 배경 안 원을 채움(내부가 채워진 사각형)
    % 구멍을 채우기 전후를 비교, 원이 아닌부분 0(검은색), 원 부분 1(흰색)
    for row = 1:rows
        for col = 1:cols
            if bw1(row, col) == bw2(row, col)
                bw2(row, col) = 0;
            end
        end
    end
    

    % Detecting Center
    disp('Image Processing 2: Detecting Center');
    count_pixel = 0;
    center_row = 0;
    center_col = 0;
    for row = 1:rows
        for col = 1:cols
            if bw2(row, col) == 1
                count_pixel = count_pixel + 1;
                center_row = center_row + row;
                center_col = center_col + col;    
            end        
        end
    end
    center_row = center_row / count_pixel;
    center_col = center_col / count_pixel; 

    try
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        clear center_col;
        clear center_row;
   catch exception
        disp('There is no Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame);
        subplot(2, 2, 3), imshow(bw1);
%         subplot(2, 2, 4), imshow(bw2);
    end
    sum(bw2, 'all')
end