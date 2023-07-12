### ATOM_drone


# 대회 진행 전략
> 1단계 : 크로마키 천을 검출하여 중심을 찾으며 1~2m 이동하며 빨강색 표식을 인식 후 90도 회전
>  > 2단계 : 크로마키 천을 검출하여 중심을 찾으며 1~2m 이동하며 빨강색 표식을 인식 후 90도 회전
>  >  > 3단계 : 크로마키 천을 검출하여 중심을 찾으며 1~2m 이동하며 초록색 표식을 인식 후 30-60도 회전
>  >  >  > 4단계 : 크로마키 천을 검출하여 각도를 조정하고 1~2m 이동하며 보라색 표식을 2m 뒤에서 인식 후 착지


### 1단계 ~ 3딘계 알고리즘

1. 크로마키 천의 내부 원이 전체가 확실히 보이기 위해서 후진을 한다.
2. 크로마키 천을 Detecting하여 중심 좌표를 맞추면 두가지 상황이 존재한다.
   2.1 크로마키 천의 전체가 보이는 상황
   2.2 크로마키 천의 전체가 보이지 않는 상황
3. 2.1인 경우 크로마키 천의 내부 원을 검출하여 원의 중심 좌표로 드론을 이동시킨다.
   2.2인 경우 크로마키 천의 중심 좌표로 드론을 이동시킨다.
4. 후진한 거리와 크로마키 천의 거리를 감안하여 드론을 이동 시킨 후 HSV를 통해 표식의 50cm 전까지 이동시킨다.
5. 표식을 인식 후 정해진 임무를 수행한다.
   
# 크로마키 천 탐지 알고리즘

1. 파란색을 인식 후 가장 큰 영역의 경계 박스를 만들어서 내부를 채운다.
```matlab
    image_only_B = image1B - image1R/2 - image1G/2;
    bw2 = image_only_B > 63;
    
    % Apply Gaussian filter for noise reduction
    filterSize = 10;
    gaussianFilter = fspecial('gaussian', filterSize);
    smoothedImage = imfilter(bw2, gaussianFilter);
 

    disp("noninvert");

    % Find connected components
    cc = bwconncomp(smoothedImage);
    graindata = regionprops(cc, 'basic');
    
    % Find the largest connected component
    maxArea = 0;
    idxMax = 0;
    for idx = 1:length(graindata)
        if graindata(idx).Area > maxArea
            maxArea = graindata(idx).Area;
            idxMax = idx;
        end
    end
    
    % Get the bounding box
    boundingBox = round(graindata(idxMax).BoundingBox);
    
    % Fill the bounding box area with 1
    smoothedImage(boundingBox(2):(boundingBox(2)+boundingBox(4)), boundingBox(1):(boundingBox(1)+boundingBox(3))) = 1;
```

2. 중심 좌표를 탐색 후 이미지의 중심과 차이만큼 이동한다.

   ```matlab
       centerBoundingBox = [boundingBox(1)+boundingBox(3)/2, boundingBox(2)+boundingBox(4)/2];
       centerBoundingBox = round(centerBoundingBox);
       centroidDifference = centerBoundingBox - imageCenter;
      disp(['Centroid difference: ', num2str(centroidDifference)]);
  
      if centroidDifference(1) < -tolerance
          if centroidDifference(2)+50 < -tolerance
              %left and up
              disp("left and up");
              move(droneobj, [0 -0.2 -0.2]);
          elseif centroidDifference(2)+50 > tolerance
              %left and down
              disp("left and down");
              move(droneobj, [0 -0.2 0.2]);
          else %left
              disp("left");
              moveleft(droneobj, 'Distance', 0.2,"Speed",1);
          end
      elseif centroidDifference(1) > tolerance
          if centroidDifference(2)+50 < -tolerance
              %right and up
               disp("right and up");
              move(droneobj, [0 0.2 -0.2]);
          elseif centroidDifference(2)+50 > tolerance
              %right and down
               disp("right and down");
              move(droneobj, [0 0.2 0.2]);
          else %right
               disp("right");
              moveright(droneobj, 'Distance', 0.2,"Speed",1);
  
          end
      elseif centroidDifference(2)+50 < -tolerance
          %up
          disp("up");
          moveup(droneobj, 'Distance', 0.2,"Speed",1);
      elseif centroidDifference(2)+50 > tolerance
          %down
          disp("down");
          movedown(droneobj, 'Distance', 0.2,"Speed",1);
      end
   ```

3. 중심 좌표를 판단 후 이미지를 반전 시켜 원을 검출하고 다시 중심 좌표를 맞춘다.
```
if centroidDifference(1) > -tolerance && centroidDifference(1) < tolerance && centroidDifference(2)+50 > -tolerance &&centroidDifference(2)+50 < tolerance
        disp("반전");

            
                            %%네모 중간일때 
                            figure(1);
                            imshow(image);
                             imageCenter = [size(image, 2)/2, size(image, 1)/2];
                            % greenThresholdLow = [0, 100, 0];
                            % greenThresholdHigh = [100, 255, 100];
                             i=image;
                                 image1R = i(:,:,1);
                                if size(i, 3) >= 3 % 이미지가 3차원 배열인 경우
                                    image1G = i(:,:,2);
                                    image1B = i(:,:,3);
                                else % 이미지가 2차원 배열인 경우 또는 채널이 없는 경우
                                    image1G = i;
                                    image1B = i;
                                end
                            
                            image_only_B=image1B-image1R/2-image1G/2;
                                 binaryMask = image_only_B >63;
                            % Create a binary mask
                            % binaryMask = (image(:,:,1) >= greenThresholdLow(1) & image(:,:,1) <= greenThresholdHigh(1)) & ...
                            %              (image(:,:,2) >= greenThresholdLow(2) & image(:,:,2) <= greenThresholdHigh(2)) & ...
                            %              (image(:,:,3) >= greenThresholdLow(3) & image(:,:,3) <= greenThresholdHigh(3));
                            
                            % Apply Gaussian filter for noise reduction
                            filterSize = 5;
                            gaussianFilter = fspecial('gaussian', filterSize);
                            smoothedImage = imfilter(binaryMask, gaussianFilter);
                            
                            % Detect edges using the Canny method
                            edges = edge(smoothedImage, 'Canny');
                            
                            % Remove small connected components
                            minPixelCount = 500; % Adjust this based on the size of the small regions you want to remove
                            cleanEdges = bwareaopen(edges, minPixelCount);
                            
                            % Perform morphological operations
                            se = strel('square', 3);  % create a structuring element for dilation and erosion
                            dilatedEdges = imdilate(cleanEdges, se); % dilate the image
                            erodedEdges = imerode(cleanEdges, se); % erode the image
                            
                            % Find the inner edges
                            innerEdges = dilatedEdges & ~erodedEdges;
                            
                            % Fill the interior of the inner edges
                            filledEdges = imfill(innerEdges, 'holes');
                            
                            % Label the connected components
                            labeledImage = bwlabel(filledEdges);
                            
                            % Measure properties of the labeled regions
                            regionMeasurements = regionprops(labeledImage, 'Area', 'Centroid', 'BoundingBox');
                            
                            % Find the largest area
                            [maxArea, idx] = max([regionMeasurements.Area]);
                            
                        
                            
                        
                            if(idx>0)
                                % Get the centroid and bounding box of the largest area
                                
                                centroid = regionMeasurements(idx).Centroid;
                                boundingBox = regionMeasurements(idx).BoundingBox;
                                
                                % Print the centroid
                                fprintf('The centroid of the largest area is located at (x, y) = (%.2f, %.2f)\n', centroid(1), centroid(2));
                                
                                % Create a binary image with the largest region only
                                largestRegion = ismember(labeledImage, find([regionMeasurements.Area] == maxArea));
                                
                                % Display the binary image
                                imshow(largestRegion);
                                
                                % Hold on to draw on the same image
                                hold on;
                                
                                % Draw a circle at the centroid
                                plot(centroid(1), centroid(2), 'r*');
                                
                                % Release the hold
                                hold off;
                                
                                %중심점 찾기
                                
                                    centroidDifference = centroid - imageCenter;
                                           if centroidDifference(1) < -tolerance
                                                if centroidDifference(2)+50 < -tolerance
                                                    %left and up
                                                    disp("left and up");
                                                    move(droneobj, [0 -0.2 -0.2]);
                                                elseif centroidDifference(2)+50 > tolerance
                                                    %left and down
                                                    disp("left and down");
                                                    move(droneobj, [0 -0.2 0.2]);
                                                else %left
                                                    disp("left");
                                                    moveleft(droneobj, 'Distance', 0.2);
                                                end
                                            elseif centroidDifference(1) > tolerance
                                                if centroidDifference(2)+50 < -tolerance
                                                    %right and up
                                                     disp("right and up");
                                                    move(droneobj, [0 0.2 -0.2]);
                                                elseif centroidDifference(2)+50 > tolerance
                                                    %right and down
                                                     disp("right and down");
                                                    move(droneobj, [0 0.2 0.2]);
                                                else %right
                                                     disp("right");
                                                    moveright(droneobj, 'Distance', 0.2);
                                        
                                                end
                                        elseif centroidDifference(2)+50 < -tolerance
                                            %up
                                            disp("up");
                                            moveup(droneobj, 'Distance', 0.2);
                                        elseif centroidDifference(2)+50 > tolerance
                                            %down
                                            disp("down");
                                            movedown(droneobj, 'Distance', 0.2);
                                   
                                            else%################# 완료
                                                disp(" 돌격 1");
                                                % focal_length = 2; % 카메라 초점 거리 (mm)
                                                % sensor_width = 4; % 카메라 센서 너비 (mm)
                                                % image_width = size(image, 2); % 이미지의 너비 (픽셀)
                                                % 
                                                % % 원의 실제 지름과 픽셀 지름
                                                % actual_diameter = 570; % 원의 실제 지름 (mm)
                                                % pixel_diameter = radii; % 원의 픽셀 지름 (픽셀)
                                                % 
                                                % % 거리 계산 단위가 mm 단위이다.
                                                % distance = (focal_length * actual_diameter * image_width) / (pixel_diameter * sensor_width);
                                                % % cm 단위로 변환
                                                % distance = distance / 10;
                                                % distance = distance / 100;
                                                distance=0.2;
                                                disp("distance: ");
                                                disp(distance);
                                                % 카메라 영상 업데이트
                                                % set(hImage, 'CData', image);
                                                % drawnow;
                                                if distance>=0.2
                                                    
                                                    
                                                    movedown(droneobj, 'Distance', 0.2);
                                                    moveforward(droneobj,'Distance',2.2,'Speed',1);
                                                    flag=0;
                                                    stage=1;
                                                    count_circle=0;
                                                    break;
                                                end
                                                %####################
                                           end
                                
                                
                             else 
                             moveback(droneobj,"Distance",0.2,"Speed",1);
                         end
    end
end
```
       


### 4단계 알고리즘


# 각도 조정 알고리즘

각도를 찾는 방법은 여러가지가 있지만 그 중에서 벡터를 이용하여 사진의 왜곡된 정도를 이용하여 각도를 조정한다.

1. 3단계에서 45도 회전 후 앞으로 전진하여 링의 중심을 맞춘다.
2. 링의 각 꼭짓점을 검출하여 top과 bottom의 벡터를 생성한다.
   ```matlab
       % Get the pixel list of the largest area
        pixels = graindata(idxMax).PixelList;
        
        % Find the boundary of the largest area
        boundary = bwboundaries(smoothedImage, 8, 'noholes');
        boundary = boundary{idxMax};
        
        % Function to calculate Euclidean distance
        dist = @(a, b) sqrt(sum((a - b) .^ 2));
        
        % Find the vertices on the boundary
        distances = arrayfun(@(idx) dist(boundary(idx, :), [1, 1]), 1:size(boundary, 1));
        [~, idx] = min(distances);
        tl = boundary(idx, :);
        
        distances = arrayfun(@(idx) dist(boundary(idx, :), [1, size(image, 2)]), 1:size(boundary, 1));
        [~, idx] = min(distances);
        tr = boundary(idx, :);
        
        distances = arrayfun(@(idx) dist(boundary(idx, :), [size(image, 1), 1]), 1:size(boundary, 1));
        [~, idx] = min(distances);
        bl = boundary(idx, :);
        
        distances = arrayfun(@(idx) dist(boundary(idx, :), [size(image, 1), size(image, 2)]), 1:size(boundary, 1));
        [~, idx] = min(distances);
        br = boundary(idx, :);
        dist_t = tl(1) - tr(1);
        dist_b = bl(1) - br(1);
   ```
3. 벡터의 y부분만 추출하여 회전해야하는 방향을 결정한다.
   top의 y벡터 성분이 +이고 bottom의 y벡터 성분이 -이면 오른쪽으로 회전
   top의 y벡터 성분이 -이고 bottom의 y벡터 성분이 +이면 왼쪽으로 회전

  ```matlab
       % Determine the rotation direction for Tello
        if dist_t > 10 && dist_b < -10
            turn(droneobj, deg2rad(10));
            fprintf('Tello should rotate to the right.\n');
            % Include the command to make Tello rotate right here
        elseif dist_t < -10 && dist_b > 10
            turn(droneobj, deg2rad(-10));
            fprintf('Tello should rotate to the left.\n');
            % Include the command to make Tello rotate left here
        else
            fprintf('No rotation needed.\n');
            flag = 3;
        end
```

4. 회전하는 각도의 크기는 실험을 통해서 10도로 설정을 하였고 크기 10의 tolerance를 주어서 오차를 줄인다.

# 착지 알고리즘

앞으로 이동하면서 이미지에서 가장 큰 영역을 검출하고 경계 상자를 만들어 넓이를 통해서 거리를 검출후 착지한다.

```matlab
    % Find the largest connected component
        maxArea = 0;
        idxMax = 0 ;
        for idx = 1:length(graindata)
            if graindata(idx).Area > maxArea
                maxArea = graindata(idx).Area;
                idxMax = idx;
            end
        end
        
        if idxMax == 0
            moveback(droneobj,"Distance",0.2,"Speed",1);
        else

            % Get the bounding box
            boundingBox = round(graindata(idxMax).BoundingBox);
            
            % Create a new binary image
            newImage = false(size(imageR_combi));
            
            % Fill the bounding box area with 1
            newImage(boundingBox(2):(boundingBox(2)+boundingBox(4)), boundingBox(1):(boundingBox(1)+boundingBox(3))) = 1;
            
            % Calculate the area by summing the values within the bounding box (sum of ones)
            area = sum(sum(newImage));

            if area <2000
                moveforward(droneobj,'Distance',0.5,'Speed',1);
            elseif area <2440
                moveforward(droneobj,'Distance',0.2,'Speed',1);
            else
                disp("finish");
                land(droneobj);
                break;
            end
```
