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
FILENAME = "test2.png";
src_rgb = imread(FILENAME);         % src_gray = rgb2gray(src_rgb);
src_hsv = rgb2hsv(src_rgb);         % HSV 3차원 배열
src_h = src_hsv(:, :, 1);           % Hue 채널
src_s = src_hsv(:, :, 2);           % Saturation 채널
src_v = src_hsv(:, :, 3);           % Value 채널

% red 0~0.05
% green 0.275 ~ 0.325
% blue 0.575 ~ 0.625
lower_red = [0, 0, 0];                   % 빨간색 범위값 정규화
upper_red = [0.05, 1, 1];                % 빨간색 범위값 정규화
% lower_green = [0.275, 50/240, 50/240]             % 초록색 범위값 정규화
% upper_green = [0.325, 150/240, 150/240]             % 초록색 범위값 정규화
lower_green = [0.25, 40/240, 80/240];             % 초록색 범위값 정규화
upper_green = [0.4, 240/240, 240/240];             % 초록색 범위값 정규화
lower_blue = [0.575, 0, 0];              % 파란색 범위값 정규화
upper_blue = [0.625, 1, 1];              % 파란색 범위값 정규화

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
%             row_array = [row_array, row];       % 최적화 필요, 실행속도가 너무 느림
%             col_array = [col_array, col];       % 최적화 필요, 실행속도가 너무 느림
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
% min_row = min(row_array);
% max_row = max(row_array);
% min_col = min(col_array);
% max_col = max(col_array);

dst_rgb = hsv2rgb(dst_hsv);
dst_rgb(min_row: min_row+10, min_col:min_col+10, :) = 255;
dst_rgb(max_row: max_row+10, max_col:max_col+10, :) = 255;

%imshow(dst_rgb)
%%%%%%%%%%%%%%%%%

for col = 1:cols
    for row = 1:rows
        if lower_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < upper_green(1) ...
                && lower_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < upper_green(2) ...
                && lower_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < upper_green(3)
            max_row2 = row;
            max_col2 = col;
            break
        end
    end
end

if max_col2 == max_col
    dst_rgb(max_row2: max_row2+10, max_col2:max_col2+10, :) = 255;

    mid_row = (min_row + max_row2) / 2;
    mid_col = (min_col + max_col2) / 2;
    % dst_rgb(mid_row: mid_row+10, mid_col:mid_col+10, :) = 255;

    % X2 = 1:0.1:max_col2;
    X1 = [min_col, max_col2];
    Y1 = [min_row, max_row2];
    X2 = [max_col, min_col];
    Y2 = [min_row, max_row];    % 두 개 직선 긋기

    m1 = (min_row-max_row)/(max_col-min_col);
    m2 = (min_row-max_row2)/(min_col-max_col);
    cx = (min_col*m1 - max_row - max_col*m2 + max_row2) / (m1-m2);
    cy = m1 * (cx - min_col) + max_row;     % 두 직선의 교점 찾기
else
    X1 = [min_col, max_col];
    Y1 = [min_row, max_row];
    X2 = [max_col, min_col];
    Y2 = [min_row, max_row];    % 두 개 직선 긋기

    m1 = (min_row-max_row)/(max_col-min_col);
    m2 = (min_row-max_row)/(min_col-max_col);
    cx = (min_col*m1 - max_row - max_col*m2 + max_row) / (m1-m2);
    cy = m1 * (cx - min_col) + max_row;     % 두 직선의 교점 찾기
end

    
figure,
imshow(dst_rgb); hold on;
% Y2 = ((min_row-max_row)/(max_col-min_col))*(X-min_col)+max_row;
plot(X1,Y1,'LineWidth', 2)
plot(X2,Y2,'LineWidth', 2)
plot(cx, cy, 'ro')
cx; cy;
hold off


% 
% figure(1);
% subplot(2, 5, 1), imshow(src_rgb), title('src\_rgb');
% subplot(2, 5, 2), imshow(src_hsv), title('src\_hsv');
% subplot(2, 5, 3), imshow(src_hsv(:, :, 1)), title('src\_h');
% subplot(2, 5, 4), imshow(src_hsv(:, :, 2)), title('src\_s');
% subplot(2, 5, 5), imshow(src_hsv(:, :, 3)), title('src\_v');
% 
% subplot(2, 5, 6), imshow(dst_rgb), title('dst\_rgb');
% subplot(2, 5, 7), imshow(dst_hsv), title('dst\_hsv');
% subplot(2, 5, 8), imshow(dst_hsv(:, :, 1)), title('dst\_h');
% subplot(2, 5, 9), imshow(dst_hsv(:, :, 2)), title('dst\_s');
% subplot(2, 5, 10), imshow(dst_hsv(:, :, 3)), title('dst\_v');
