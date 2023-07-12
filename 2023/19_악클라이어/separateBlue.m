function bimg = separateBlue(img)
rimg = img(:,:,1);
gimg = img(:,:,2);
bimg = img(:,:,3);
wimg = bimg > 120 & rimg >120 & gimg> 120; %white image

hsv = rgb2hsv(img);
h = hsv(:,:,1);

threshold_1 = 0.5 <h;
threshold_2 = h < 0.7;

bimg = threshold_1 & threshold_2 & ~wimg; %detect only blue
imshow(bimg)
% 
% subplot(2,2,1);
% imshow(bimg);
% % subplot(2,2,3);
% % imshow(nnoiseimg);
end