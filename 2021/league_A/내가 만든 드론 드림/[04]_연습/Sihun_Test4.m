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
FILENAME = "test7.png";
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
row_array = [];
col_array = [];

min_row = rows;
min_col = cols;
max_row = 1;
max_col = 1;
for row = 1:rows
    for col = 1:cols
        if lower_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < upper_green(1) ...
                && lower_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < upper_green(2) ...
                && lower_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < upper_green(3)
            dst_hsv(row, col, :) = src_hsv(row, col, :);
            dst_hsv(row, col, :) = (lower_green + upper_green) / 2;
            if row < min_row
                min_row = row;
            end
            if col < min_col
                min_col = col;
            end
            if row > max_row
                max_row = row;
            end
            if col > max_col
                max_col = col;
            end
        end
    end
end

p1 = [];
p2 = [];
p3 = [];
p4 = [];
dst_rgb = hsv2rgb(dst_hsv);
dst_bw = im2bw(dst_rgb);
stats = [regionprops(dst_bw); regionprops(not(dst_bw))];
imshow(dst_bw); hold on;
for i = 1:numel(stats)
    rectangle('Position', stats(i).BoundingBox, 'Linewidth', 3, 'EdgeColor', 'r', 'LineStyle', '--');
end
hold off;

% 좌표 P1 (x, min_col), 위 -> 아래 방향으로 row 탐색
for row = 1:1:rows
    if lower_green(1) < src_hsv(row, min_col, 1) && src_hsv(row, min_col, 1) < upper_green(1) ...
        && lower_green(2) < src_hsv(row, min_col, 2) && src_hsv(row, min_col, 2) < upper_green(2) ...
        && lower_green(3) < src_hsv(row, min_col, 3) && src_hsv(row, min_col, 3) < upper_green(3)
        dst_rgb(row:row+10, min_col:min_col+10, :) = 255;
        p1 = [row, min_col];
        break
    end
end
% 좌표 P2 (min_row, y), 오른 -> 왼 방향으로 탐색
for col = cols:-1:1
    if lower_green(1) < src_hsv(min_row, col, 1) && src_hsv(min_row, col, 1) < upper_green(1) ...
        && lower_green(2) < src_hsv(min_row, col, 2) && src_hsv(min_row, col, 2) < upper_green(2) ...
        && lower_green(3) < src_hsv(min_row, col, 3) && src_hsv(min_row, col, 3) < upper_green(3)
        dst_rgb(min_row:min_row+10, col:col+10, :) = 255;
        p2 = [min_row, col];
        break
    end
end
% 좌표 P3 (max_row, y), 왼 -> 오른 방향으로 탐색
for col = 1:1:cols
    if lower_green(1) < src_hsv(max_row, col, 1) && src_hsv(max_row, col, 1) < upper_green(1) ...
        && lower_green(2) < src_hsv(max_row, col, 2) && src_hsv(max_row, col, 2) < upper_green(2) ...
        && lower_green(3) < src_hsv(max_row, col, 3) && src_hsv(max_row, col, 3) < upper_green(3)
        dst_rgb(max_row:max_row+10, col:col+10, :) = 255;
        p3 = [max_row, col];
        break
    end
end
% 좌표 P4 (x, max_col), 아래 -> 위 방향으로 탐색
for row = rows:-1:1
    if lower_green(1) < src_hsv(row, max_col, 1) && src_hsv(row, max_col, 1) < upper_green(1) ...
        && lower_green(2) < src_hsv(row, max_col, 2) && src_hsv(row, max_col, 2) < upper_green(2) ...
        && lower_green(3) < src_hsv(row, max_col, 3) && src_hsv(row, max_col, 3) < upper_green(3)
        dst_rgb(row:row+10, max_col:max_col+10, :) = 255;
        p4 = [row, max_col];
        break
    end
end

% dst_rgb(min_row: min_row+10, min_col:min_col+10, :) = 255;      % 왼쪽 위
% dst_rgb(max_row: max_row+10, min_col:min_col+10, :) = 255;      % 왼쪽 아래
% dst_rgb(min_row: min_row+10, max_col:max_col+10, :) = 255;      % 오른쪽 위
% dst_rgb(max_row: max_row+10, max_col:max_col+10, :) = 255;      % 오른쪽 아래
imshow(dst_rgb); hold on;
plot(p1(2), p1(1), 'ro')
plot(p2(2), p2(1), 'ro')
plot(p3(2), p3(1), 'ro')
plot(p4(2), p4(1), 'ro')
plot([p1(2), p4(2)], [p1(1), p4(1)],'LineWidth', 2)
plot([p2(2), p3(2)], [p2(1), p3(1)],'LineWidth', 2)
hold off