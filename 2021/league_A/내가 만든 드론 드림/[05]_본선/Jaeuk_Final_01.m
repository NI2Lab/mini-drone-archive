% HSV Threshold Green
thdown_blue = [0.5, 120/240, 60/240];
thup_blue = [0.75, 240/240, 240/240];

% 파란색 임계값 범위 설정
detected_blue = (0.5<dst_h)&(dst_h<0.75);

% 드론 객체 선언
droneObj = ryze();
cam = camera(droneObj);

% 드론 이륙 및 1단계 높이 맞추기
takeoff(droneObj);
moveup(droneObj, 'Distance', 0.5);

% 실시간 영상 받기
preview(cam);

% 드론과 링 거리 일정 범위 이내까지 전진
while 1
    % 현재 이미지 받아오기
    img = snapshot(cam);
    % HSV Convert
    img_hsv = rgb2hsv(img);
    dst_h = img_hsv(:,:,1);
    detected_green = (0.25<dst_h)&(dst_h<0.40);
    
    if sum(detect_green, 'all') >= 150000
        break;
    else
        moveforward(droneObj, 'Distance', 0.5);
    end
end

% 현재 위치의 이미지를 가지고 중점 탐색
[rows, cols, channels] = size(img_hsv);
dst_hsv1 = double(zeros(size(img_hsv)));
dst_hsv2 = double(zeros(size(img_hsv)));

cnt_rows=0; cnt_cols=0;
sum_rows=0; sum_cols=0;

for row = 1:rows
    for col = 1:cols
        if thdown_green(1) < img_hsv(row, col, 1) && img_hsv(row, col, 1) < thup_green(1) ...
                && thdown_green(2) < img_hsv(row, col, 2) && img_hsv(row, col, 2) < thup_green(2) ...
                && thdown_green(3) < img_hsv(row, col, 3) && img_hsv(row, col, 3) < thup_green(3)
            dst_hsv1(row, col, :) = [0, 0, 1];
            dst_hsv2(row, col, :) = [0, 0, 0];
        else
            dst_hsv1(row, col, :) = [0, 0, 0];
            dst_hsv2(row, col, :) = [0, 0, 1];
        end
    end
end

dst_rgb1 = hsv2rgb(dst_hsv1);
dst_rgb2 = hsv2rgb(dst_hsv2);

% corners 함수로 링 외부 사각형 4개 꼭지점 찾기
dst_gray1 = rgb2gray(dst_rgb1);
corners1 = pgonCorners(dst_gray1, 4);

% ROI 함수로 사각형 도려내기
roi_x = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];
roi_y = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];
roi = roipoly(dst_gray1, roi_x, roi_y);

% 점곱으로 2차배열이미지 곱해서 합쳐주기
dst_img = dst_rgb2 .* roi;        

% 내부 픽셀 수 count하여 중간 픽셀 위치 찾기
count_pixel = 0;
center_row = 0;
center_col = 0;
for row = 1:rows
    for col = 1:cols
        if dst_img(row, col) == 1
            count_pixel = count_pixel + 1;
            center_row = center_row + row;
            center_col = center_col + col;    
        end        
    end
end
center_row = center_row / count_pixel;
center_col = center_col / count_pixel;

ring_mid = [center_col, center_row];
img_mid = [img_size(1)/2, img_size(2)/2];

% 링의 중점과 이미지의 중점좌표를 일치화 후 전진
while 1
    if img_mid(2) - ring_mid(2) > 50
        moveleft(droneObj, 'Distance', 0.2);
    elseif img_mid(2) - ring_mid(2) < -50
        moveright(droneObj, 'Distance', 0.2);
    elseif img_mid(1) - ring_mid(1) > 50
        moveup(droneObj, 'Distance', 0.2);
    elseif img_mid(1) - ring_mid(1) < -50
        movedown(droneObj, 'Distance', 0.2);
    else
        moveforward(droneObj, 'Distance', 1.0);
        break;
    end
end

% 표식 속 빨간색 픽셀 개수가 일정한 범위에 도달할때까지 전진 후 방향제어
while 1
    img = snapshot(cam);
    img_hsv = rgb2hsv(img);
    dst_h = img_hsv(:,:,1);
    detected_red = (dst_h>1)+(dst_h<0.05);
    
    if sum(detect_red, 'all') >= 150000
        turn(droneObj, deg2rad(-90));
        break;
    else
        moveforward(droneObj, 'Distance', 0.3);
    end
end

% 문제 : 어느정도 거리까지 전진해야 원하는 거리의 픽셀값 개수가 될까?
% 링의 중점을 찾는 코드를 함수로 구현하여 코드 간략화할 필요성 O

% while 1
%     
%     
%     if sum(detect_green, [0 0 480 720], 'all') - sum(detect_green, [480 0 960 720], 'all') >5000
%         
%     
%         
%     
%     
% end


% subplot(2, 3, 1); imshow(img);
% subplot(2, 3, 2); imshow(dst_rgb1);
% subplot(2, 3, 3); imshow(dst_rgb2);
% subplot(2, 3, 4); imshow(dst_img);
% subplot(2, 3, 5); imshow(dst_img); hold on;
% plot(center_col, center_row, 'r*'); hold off;
% subplot(2, 3, 6); imshow(img); hold on;
% plot(center_col, center_row, 'r*'); hold off


