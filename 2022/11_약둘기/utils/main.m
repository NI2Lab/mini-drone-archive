file_name = "문제5.png";
img = imread(file_name);

th_min_line = 0.299; %0.311
th_max_line = 0.500; %0.458

hsv = rgb2hsv(img);
h = hsv(:,:,1);
s = hsv(:,:,2);

filter = s>0.1;

binary_res = (h > th_min_line).*(h < th_max_line);
binary_res = binary_res .* filter;

se = strel('disk',9);
binary_res = imopen(binary_res,se);
binary_res = imclose(binary_res,se);

subplot(2,2,1);
imshow(binary_res);


bw = imcomplement(binary_res); 
bw = bwareaopen(bw,3);
[B,L] = bwboundaries(bw,'noholes');

subplot(2,2,2);
imshow(bw);

subplot(2,2,3);
imshow(label2rgb(L,@jet,[.5 .5 .5]))
hold on
for k = 1:length(B)
  boundary = B{k};
  plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
end

stats = regionprops(L,'Area','Centroid');

threshold = 0.7;
nMax_metric = 0.0;
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;    
  perimeter = sum(sqrt(sum(delta_sq,2)));
  
  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;
  
  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;
  
  % display the results
  metric_string = sprintf('%2.2f',metric);


  if metric > threshold
      if metric > nMax_metric 
            real_centroid = stats(k).Centroid;
            nMax_metric = metric;
            aBestCircle = boundary;
      end
  end
  
end

title(['Metrics Closer to 1 Indicate that ',...
       'the Object is Approximately Round'])

[nX_size , nY_size] = size(aBestCircle);

nBestCenter_X = real_centroid(1)
nBestCenter_Y = real_centroid(2)

plot(nBestCenter_X,nBestCenter_Y,'ro');


