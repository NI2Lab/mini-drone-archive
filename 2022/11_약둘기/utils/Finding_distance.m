clear drone;
disp("Clear!")
%%
drone = ryze();
cam = camera(drone);

 cMin_blue_th=0.630;
 cMax_blue_th=0.670;

while 1
    x= input("enter to snap: ",'s');
    [aRaw_frame, void] = snapshot(cam);
    aHSV_frame = rgb2hsv(aRaw_frame);

    aConverted_HSV = aHSV_frame(:,:,1);
    filter = aHSV_frame(:,:,2) > 0.2;

    aFiltered_blue = ( aConverted_HSV > cMin_blue_th) & (aConverted_HSV < cMax_blue_th);
    aFiltered_blue = aFiltered_blue .* filter;

    se = strel('disk',7);

    aFiltered_blue = imgaussfilt(aFiltered_blue,2);
    
    aFiltered_blue = imdilate (aFiltered_blue,se);
 

    nDetected_pixel = nnz(aFiltered_blue);
    aFiltered_blue = round(aFiltered_blue);

    binary_res = aFiltered_blue;
    
    subplot(2,2,1);
    imshow(binary_res);
    
    bw = imcomplement(binary_res); %반전 안시키면 바깥이 검은색이라서 구멍으로 인식 불가능함.
    bw = bwareaopen(bw,10);
    
   se = strel('disk',5);
    bw = imerode(bw,se);
%     bw = imclose(bw,se);

    [B,L] = bwboundaries(bw,'noholes');
 
    subplot(2,2,2);
    imshow(aRaw_frame);
    hold on
    for k = 1:length(B)
      boundary = B{k};
      plot(boundary(:,2),boundary(:,1),'w','LineWidth',2)
    end
    
    stats = regionprops(L,'Area','Centroid','Eccentricity','MajorAxisLength','MinorAxisLength');
    
    threshold = 0.4; %0.4 
    nMax_metric = 0.0;
    nMaxsizeB=0;
    for k = 1:length(B)
    
      % obtain (X,Y) boundary coordinates corresponding to label 'k'
      boundary = B{k};
      [sizeB,sizeX] = size(boundary);
      % compute a simple estimate of the object's perimeter
      delta_sq = diff(boundary).^2;    
      perimeter = sum(sqrt(sum(delta_sq,2)));
      
      % obtain the area calculation corresponding to label 'k'
      area = stats(k).Area;
      
      % compute the roundness metric
      metric = 4*pi*area/perimeter^2;
      
      % display the results
      metric_string = sprintf('%2.2f',metric);
    
      % mark objects above the threshold with a black circle
      if metric > threshold
    %       centroid = stats(k).Centroid;
    %       plot(centroid(1),centroid(2),'ko');
          
          if(sizeB<3000 && sizeB>nMaxsizeB)
            real_centroid = stats(k).Centroid;
            nCircle_r = mean([stats(k).MajorAxisLength stats(k).MinorAxisLength],2);
            nMax_metric = metric;
            aBestCircle = boundary;
            nMaxsizeB = sizeB;
          end
          
      end
      
    end

    title(['Metrics Closer to 1 Indicate that ',...
           'the Object is Approximately Round'])
    
   
    [nX_size , nY_size] = size(aBestCircle);
    
    size(aBestCircle);

    nBestCenter_X = fix(real_centroid(1));
    nBestCenter_Y = fix(real_centroid(2));
    
    plot(nBestCenter_X,nBestCenter_Y,'ro');



% 위에서부터 최초로 1이 나타나는 y값 찾고
% 찾으면 break 건후에
% 아래서부터 최초로 1이 나타나는 y값 찾고
% 서로뺌 => 지름 

  
    nMax_Y = max(aBestCircle(:,2));
    nMin_Y = min(aBestCircle(:,2));

    
    nCircle_r
     if nMax_metric < 0.1 
        disp("No Circle");
    end
    
    subplot(2,2,3);
    imshow(bw);

    subplot(2,2,4);
    imshow(aRaw_frame);

    
end