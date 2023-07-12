function [whatcolor, coordinate] = findrgv(img)
rimg = img(:,:,1);
gimg = img(:,:,2);
bimg = img(:,:,3);

hsvimg = rgb2hsv(img);
h = hsvimg(:,:,1);

hr = h>0.95 | h<0.05;
hg = h>0.25 & h<0.45;
hv = h>0.6 & h<0.85;

findr = rimg >80 & gimg < 80 & bimg < 80 & hr;
findg = rimg <130 & gimg > 65 & bimg < 130 & hg;
findv = rimg >70 & rimg < 170 & gimg >20 & gimg <100 & bimg >110 & bimg <210 & hv;

shape = strel('disk', 10);
findrnoisecut = imopen(findr,shape);
findgnoisecut = imopen(findg,shape);
findvnoisecut = imopen(findv,shape);

r = rimg >70 & rimg < 170;
g = gimg >20 & gimg <100;
b = bimg >110 & bimg <210;

oimg = r & g & b & hv;
noisecut = imopen(oimg,shape);

subplot(2,2,1);
imshow(findrnoisecut)
%imshow(findr);

subplot(2,2,2);
imshow(findr)
%imshow(findg);

subplot(2,2,3);
imshow(r)
%imshow(findv);

subplot(2,2,4);
imshow(b)

red = find(findrnoisecut==1,1);
green = find(findgnoisecut==1,1);
violet = find(findvnoisecut==1,1);

row = length(rimg);
column = length(rimg(:,1));
disp(green)

if ~isempty(red)
    whatcolor = 1;
    coordinate = [(red/column)+1 mod(red,row)];
elseif ~isempty(green)
    whatcolor = 2;
    coordinate = [(green/column)+1 mod(green,row)];
elseif ~isempty(violet)
    whatcolor = 3;
    coordinate = [(violet/column)+1 mod(violet,row)];
else
    whatcolor = 4;
    coordinate = [0 0];
end


end