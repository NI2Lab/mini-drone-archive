clear()
% HSV Threshold Green
thdown_green = [0.25, 40/240, 80/240];
thup_green = [0.40, 240/240, 240/240];
% HSV Threshold Blue
thdown_blue = [0.5, 0.35, 0.25];
thup_blue = [0.75, 1, 1];

% droneObj = ryze()
% cameraObj = camera(droneObj)
% takeoff(droneObj);

v = VideoReader('test_video.mp4');
while 1
    % HSV Convert
    % frame = imread('./datasets/test03.jpg');
    frame = readFrame(v);
%     frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    disp('HSV Converting');

    % ImageProcessing1: Detecting Blue
    disp('Image Processing 1: Detecting Blue');
    dst_hsv1 = double(zeros(size(src_hsv)));
    dst_hsv2 = double(zeros(size(src_hsv)));
    [rows, cols, channels] = size(src_hsv);
    for row = 1:rows
        for col = 1:cols
            if thdown_blue(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_blue(1) ...
            && thdown_blue(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_blue(2) ...
            && thdown_blue(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_blue(3)
                dst_hsv1(row, col, :) = [0, 0, 1];   % White
                dst_hsv2(row, col, :) = [0, 0, 0];   % Black
            else
                dst_hsv1(row, col, :) = [0, 0, 0];   % Black
                dst_hsv2(row, col, :) = [0, 0, 1];   % White
            end
        end
    end

    try
        % Image Processing2: Detect Circle
        disp('Image Processing 2: Detect Circle');
        thres_dst1 = hsv2rgb(dst_hsv1);                 % 붙여넣야하는 그림 / 초록색이 White
        thres_dst2 = hsv2rgb(dst_hsv2);                 % 잘라내야하는 그림 / 초록색이 Black

        gray_thres_dst1 = rgb2gray(thres_dst1);
        corners1 = pgonCorners(gray_thres_dst1, 4);
        
        % ROI
        disp('ROI Image Processing');
        roix = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];    % ROI 범위 소량 확장
        roiy = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];    % ROI 범위 소량 확장
        roi = roipoly(thres_dst1, roix, roiy);
        thres_dst = thres_dst2 .* roi;
        gray_thres_dst = rgb2gray(thres_dst);

        % Detecting Center
        disp('Image Processing 2: Detect Center');
        count_pixel = 0;
        center_row = 0;
        center_col = 0;
        for row = 1:rows
            for col = 1:cols
                if gray_thres_dst(row, col) == 1
                    count_pixel = count_pixel + 1;
                    center_row = center_row + row;
                    center_col = center_col + col;    
                end        
            end
        end
        center_row = center_row / count_pixel;
        center_col = center_col / count_pixel;
        camera_mid_row = rows / 2;
        camera_mid_col = cols / 2;
        
        disp('Move to Center Caculating');
        moveRow = center_row - camera_mid_row
        moveCol = center_col - camera_mid_col
        if not(-40< moveRow && moveRow < 40) || not(-40< moveCol && moveCol < 40)
            if moveRow < -40
                disp('MoveLeft');
                moveleft(droneObj, 'Distance', 0.2)
            end
            if moveRow > 40
                disp('MoveRight');
                moveright(droneObj, 'Distance', 0.2)
            end
            if moveCol < -40
                disp('MoveUp');
                moveup(droneObj, 'Distance', 0.2)
            end
            if moveCol > 40
                disp('MoveDown');
                movedown(droneObj, 'Distance', 0.2)
            end
        else
            break
        end
            subplot(2, 2, 1), imshow(frame); hold on;
            plot(center_col, center_row, 'r*'); hold off;
            subplot(2, 2, 2), imshow(gray_thres_dst); hold on;
            plot(center_col, center_row, 'r*'); hold off;
            subplot(2, 2, 3), imshow(dst_hsv1);
            subplot(2, 2, 4), imshow(dst_hsv2);
            clear corners1;
    catch exception
        disp('ROI Error');
    end
end
moveforward(droneObj, 'Distance', 1)
land(droneObj);