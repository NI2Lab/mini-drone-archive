drone = ryze("Tello")
cam = camera(drone);

takeoff(drone);
pause(3);

frame = snapshot(cam);
pause(2);

hsv = rgb2hsv(frame);
h = hsv(:,:,1);
s = hsv(:,:,2);

green = ((0.285 <= h) & (h <= 0.409)) & (s >=0.3);

temp1 = bwareaopen(green, 1000);

temp2 = imfill(temp1, 'holes');

temp2 = temp2 - temp1;

temp2 = bwareaopen(temp2, 1000);
imshow(temp2)

[rows, cols] = find(temp2);

size_row = size(rows);
size_row = size_row(1);
size_col = size(cols);
size_col = size_col(1);

mid_row = sum(rows)/size_row;
mid_col = sum(cols)/size_col;

ans = [round(mid_col), round(mid_row)];
disp(ans);