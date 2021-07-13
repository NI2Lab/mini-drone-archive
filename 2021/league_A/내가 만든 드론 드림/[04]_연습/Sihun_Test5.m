% droneObj = ryze()
% cameraObj = camera(droneObj)
% 
% takeoff(droneObj)
% moveup(droneObj, 'Distance', 0.8)
% moveforward(droneObj, 'Distance', 2)

% HSV: 인간의 시각적 지각요소를 기반으로, 원통형 좌표계에서 색상을 표시하는 모델
% Hue(색조): Red, Yellow, Green, Cyan, Blue, Magenta를 주요색조로하는 인접한 색조간의 선형조합(=연속적인 색조)
% Saturation(채도): 해당 색조의 강도(짙고 옅음)
% Value(명도): 빛의 에너지 강도에 따라 감각적으로 느끼는 "밝기"
FILENAME = "test4.png";
src_rgb = imread(FILENAME);         % src_gray = rgb2gray(src_rgb);
src_hsv = rgb2hsv(src_rgb);         % HSV 3차원 배열
src_h = src_hsv(:, :, 1);           % Hue 채널
src_s = src_hsv(:, :, 2);           % Saturation 채널
src_v = src_hsv(:, :, 3);           % Value 채널

% red 0~0.05
% green 0.275 ~ 0.325
% blue 0.575 ~ 0.625
lower_red = [0, 0, 0];                      % 빨간색 범위값 정규화
upper_red = [0.05, 1, 1];                   % 빨간색 범위값 정규화
lower_green = [0.25, 40/240, 80/240];       % 초록색 범위값 정규화
upper_green = [0.4, 240/240, 240/240];      % 초록색 범위값 정규화
lower_blue = [0.575, 0, 0];                 % 파란색 범위값 정규화
upper_blue = [0.625, 1, 1];                 % 파란색 범위값 정규화

[rows, cols, channels] = size(src_hsv);
dst_hsv = double(zeros(size(src_hsv)));
dst_h = dst_hsv(:, :, 1);
dst_s = dst_hsv(:, :, 2);
dst_v = dst_hsv(:, :, 3);

% Hue% Saturation % Value
cnt_rows=0; cnt_cols=0;
sum_rows=0; sum_cols=0;
for row = 1:rows
    for col = 1:cols
        if lower_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < upper_green(1) ...
                && lower_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < upper_green(2) ...
                && lower_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < upper_green(3)
            dst_hsv(row, col, :) = src_hsv(row, col, :);
            dst_hsv(row, col, :) = (lower_green + upper_green) / 2;
            
            sum_rows = sum_rows + row;
            sum_cols = sum_cols + col;
            cnt_rows = cnt_rows + 1;
            cnt_cols = cnt_cols + 1;
        end
    end
end
mid_row = sum_rows / cnt_rows;
mid_col = sum_cols / cnt_cols;


dst_rgb = hsv2rgb(dst_hsv);
dst_bw = im2bw(dst_rgb);
dst_bw = imfill(dst_bw, 'holes');

corners = pgonCorners(dst_bw, 4);
imshow(dst_rgb); hold on;
plot(corners(:, 2), corners(:, 1), 'yo', 'MarkerFaceColor', 'r', 'MarkerSize', 12, 'LineWidth', 2);
p1 = corners(4, :);
p2 = corners(3, :);
p3 = corners(1, :);
p4 = corners(2, :);
plot([p1(2), p4(2)], [p1(1), p4(1)], 'LineWidth', 2);
plot([p2(2), p3(2)], [p2(1), p3(1)], 'LineWidth', 2);

% y1 = m1 * (x1 - p1(1)) + p1(2);
% y2 = m2 * (x2 - p2(1)) + p2(2);
m1 = (p1(2) - p4(2)) / (p1(1) - p4(1));
m2 = (p2(2) - p3(2)) / (p2(1) - p3(1));
cx = (m1 * p1(1) - m2 * p2(1) + p2(2) - p1(2)) / (m1 - m2);
cy = m1 * (cx - p1(1)) + p1(2);
plot(cy, cx, 'ro');
% plot(mid_col, mid_row, 'ro')


