FILENAME = "test2.png";
src_rgb = imread(FILENAME);         % src_gray = rgb2gray(src_rgb);
src_hsv = rgb2hsv(src_rgb);         % HSV 3차원 배열

lower_red = [0, 0, 0];                      % 빨간색 범위값 정규화
upper_red = [0.05, 1, 1];                   % 빨간색 범위값 정규화
lower_green = [0.25, 40/240, 80/240];       % 초록색 범위값 정규화
upper_green = [0.4, 240/240, 240/240];      % 초록색 범위값 정규화
lower_blue = [0.575, 0, 0];                 % 파란색 범위값 정규화
upper_blue = [0.625, 1, 1];                 % 파란색 범위값 정규화

[rows, cols, channels] = size(src_hsv);
dst_hsv1 = double(zeros(size(src_hsv)));
dst_hsv2 = double(zeros(size(src_hsv)));

for row = 1:rows
    for col = 1:cols
        if lower_green(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < upper_green(1) ...
                && lower_green(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < upper_green(2) ...
                && lower_green(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < upper_green(3)
            dst_hsv1(row, col, :) = [0 0 1];    % 초록색이 흰색
            dst_hsv2(row, col, :) = [0 0 0];    % 초록색이 검은색
        else
            dst_hsv1(row, col, :) = [0 0 0];            
            dst_hsv2(row, col, :) = [0 0 1];            
        end
    end
end

dst_rgb1 = hsv2rgb(dst_hsv1);
dst_rgb2 = hsv2rgb(dst_hsv2);
imshow(dst_rgb1);
imshow(dst_rgb2);

dst_gray1 = rgb2gray(dst_rgb1);
corners1 = pgonCorners(dst_gray1, 4);

% ROI
roix = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];
roiy = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];
roi = roipoly(dst_gray1, roix, roiy);

dst = dst_rgb2 .* roi;
dst_gray = rgb2gray(dst);
dst_edge = edge(dst_gray, 'Canny');

imshow(dst_edge);
corners = pgonCorners(dst_edge, 4);
hold on;
p1 = corners(4, :);       % 좌상단
p2 = corners(3, :);       % 우상단
p3 = corners(1, :);       % 좌하단
p4 = corners(2, :);       % 우하단

plot([p1(2), p4(2)], [p1(1), p4(1)],'r', 'LineWidth', 2);
plot([p2(2), p3(2)], [p2(1), p3(1)],'r', 'LineWidth', 2);

m1 = (p1(2) - p4(2)) / (p1(1) - p4(1));
m2 = (p2(2) - p3(2)) / (p2(1) - p3(1));
cx = (m1 * p1(1) - m2 * p2(1) + p2(2) - p1(2)) / (m1 - m2);
cy = m1 * (cx - p1(1)) + p1(2);
plot(cy, cx, 'ro');


% vidObj = VideoReader('test.mp4');
% while hasFrame(vidObj)
%     vidFrame = readFrame(vidObj);
%     imshow(vidFrame)
%     pause(1/vidObj.FrameRate);
% end


% v = VideoReader('test.mp4');
% 
% for i = 1 : v.FrameRate * v.Duration; 
%     video = readFrame(v);
%     imwrite(video,strcat('0000',int2str(i),'.bmp'),'bmp');
%     image_data{i}=video;
% end

