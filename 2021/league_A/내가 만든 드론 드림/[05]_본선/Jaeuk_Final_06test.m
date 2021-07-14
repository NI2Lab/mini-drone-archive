red_hsv = rgb2hsv([255,0,0]);
purple_hsv = rgb2hsv([112/255, 48/255, 160/255]);

img = imread('dot1.jpg');

img_hsv = rgb2hsv(img);
img_h = img_hsv(:,:,1);
img_s = img_hsv(:,:,2);
img_v = img_hsv(:,:,3);
[rows, cols, channel] = size(img_hsv);

thdown_red1 = [0, 0.35, 0.25];
thup_red1 = [0.125, 1, 1];
thdown_red2 = [0.875, 0.35, 0.25];
thup_red2 = [1, 1, 1];
thdown_purple = [purple_hsv(1) - 0.15, 0.25, 0.25];
thup_purple = [purple_hsv(1) + 0.15, 0.25, 0.25];

img_bw1 = double(zeros(size(img_hsv)));

for row = 1: rows
    for col = 1: cols
        if img_hsv(row, col, 1) == detected_red
            img_bw1(row, col, :) = [0, 0, 1];
        end
    end
end


subplot (1,3,1), imshow(img);
subplot (1,3,2), imshow(img_hsv);
subplot (1,3,3), imshow(img_bw1);


