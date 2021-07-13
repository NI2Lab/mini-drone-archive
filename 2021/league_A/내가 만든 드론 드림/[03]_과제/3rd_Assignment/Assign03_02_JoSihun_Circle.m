% 중심좌표탐색
% 방법1: 내부사각형 좌표값 평균을 이용한 중심좌표 탐색
% 방법2: 대각선 크로스 교차점을 이용한 중심좌표 탐색 (현재적용중인코드)
% 원리: 내외부 사각형을 반전(ROI사용)시킨 뒤, Canny Edge 적용 후 코너값 탐색

% Image Read
src = imread('./datasets/Circle_005.png');
imshow(src);

% HSV Convert
src_hsv = rgb2hsv(src);

% HSV Threshold Green
thdown_green = [0.25, 40/240, 80/240];
thup_green = [0.40, 240/240, 240/240];

% ImageProcessing1
dst_hsv1 = double(zeros(size(src_hsv)));
dst_hsv2 = double(zeros(size(src_hsv)));
[rows, cols, channels] = size(src_hsv);
for row = 1:rows
    for col = 1:cols
        if thdown_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_green(1) ...
        && thdown_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_green(2) ...
        && thdown_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_green(3)
%             dst_hsv(row, col, :) = src_hsv(row, col, :);
%             dst_hsv(row, col, :) = (thdown_green + thup_green) / 2;
            dst_hsv1(row, col, :) = [0, 0, 1];   % White
            dst_hsv2(row, col, :) = [0, 0, 0];   % Black
        else
            dst_hsv1(row, col, :) = [0, 0, 0];   % Black
            dst_hsv2(row, col, :) = [0, 0, 1];   % White
        end
    end
end

% Image Processing2
thres_dst1 = hsv2rgb(dst_hsv1);                 % 붙여넣야하는 그림 / 초록색이 White
thres_dst2 = hsv2rgb(dst_hsv2);                 % 잘라내야하는 그림 / 초록색이 Black

gray_thres_dst1 = rgb2gray(thres_dst1);
corners1 = pgonCorners(gray_thres_dst1, 4);

% ROI
roix = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];    % ROI 범위 소량 확장
roiy = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];    % ROI 범위 소량 확장
roi = roipoly(thres_dst1, roix, roiy);
thres_dst = thres_dst2 .* roi;
gray_thres_dst = rgb2gray(thres_dst);

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

subplot(2, 3, 1); imshow(src);
subplot(2, 3, 2); imshow(thres_dst1);
subplot(2, 3, 3); imshow(thres_dst2);
subplot(2, 3, 4); imshow(gray_thres_dst);
subplot(2, 3, 5); imshow(gray_thres_dst); hold on;
plot(center_col, center_row, 'r*'); hold off;
subplot(2, 3, 6); imshow(src); hold on;
plot(center_col, center_row, 'r*'); hold off;
