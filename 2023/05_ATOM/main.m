clear all;
close;
droneobj = ryze()
cameraObj = camera(droneobj);

tolerance = 55; % 늘려 봅시다
tolerance4 = 50;

count_circle=0;
takeoff(droneobj);

% 높이 설정 (1m)
disp('높이를 조정합니다...');
high = 1.5 - 0.6; % 0.7->0.6
moveup(droneobj, 'Distance', high,"Speed",1);
flag=0;
stage=0;
moveback(droneobj,"Distance",0.5,"Speed",1);
while stage==0

    image = snapshot(cameraObj);
    figure(1);
    imshow(image);

    imageCenter = [size(image, 2)/2, size(image, 1)/2];

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);
    
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
    
    % Fill the bounding box area with 1 필요 없는 부분 확인 용도
    smoothedImage(boundingBox(2):(boundingBox(2)+boundingBox(4)), boundingBox(1):(boundingBox(1)+boundingBox(3))) = 1;
    
    centerBoundingBox = [boundingBox(1)+boundingBox(3)/2, boundingBox(2)+boundingBox(4)/2];
    centerBoundingBox = round(centerBoundingBox);
    
    % Display the image
    figure(2);
    imshow(smoothedImage);
    hold on;

    % [row, col] = find(fillImage);


    % Display the center of the bounding box
    plot(centerBoundingBox(1), centerBoundingBox(2), 'r*');
    plot(imageCenter(1), imageCenter(2), 'b*');
    
    centroidDifference = centerBoundingBox - imageCenter;
    disp(['Centroid difference: ', num2str(centroidDifference)]);

    if centroidDifference(1) < -tolerance
        if centroidDifference(2)+50 < -tolerance
            %left and up
            disp("left and up");
            move(droneobj, [0 -0.2 -0.2],"Speed",1);
        elseif centroidDifference(2)+50 > tolerance
            %left and down
            disp("left and down");
            move(droneobj, [0 -0.2 0.2],"Speed",1);
        else %left
            disp("left");
            moveleft(droneobj, 'Distance', 0.2,"Speed",1);
        end
    elseif centroidDifference(1) > tolerance
        if centroidDifference(2)+50 < -tolerance
            %right and up
             disp("right and up");
            move(droneobj, [0 0.2 -0.2],"Speed",1);
        elseif centroidDifference(2)+50 > tolerance
            %right and down
             disp("right and down");
            move(droneobj, [0 0.2 0.2],"Speed",1);
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

     if centroidDifference(1) > -tolerance && centroidDifference(1) < tolerance && centroidDifference(2)+50 > -tolerance &&centroidDifference(2)+50 < tolerance
        disp("stage 1 사각형 중간 찾음");
            %%네모 중간일때 
        while(1)
            image = snapshot(cameraObj);
            figure(3);
            imshow(image);
            imageCenter = [size(image, 2)/2, size(image, 1)/2];

            image1R = image(:,:,1);
            image1G = image(:,:,2);
            image1B = image(:,:,3);
            
            image_only_B = image1B - image1R/2 - image1G/2;
            bw2 = image_only_B > 63;

            % Apply Gaussian filter for noise reduction
            filterSize = 5;
            gaussianFilter = fspecial('gaussian', filterSize);
            smoothedImage = imfilter(bw2, gaussianFilter);

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
                
                %중심점 찾기dddddddddddddddddddddddddddddddddddddddddddd
                % if numel(regionMeasurements)>1
                    disp("영역의 개수 : ");
                    disp(numel(regionMeasurements));
                    centroidDifference = centroid - imageCenter;
        
                    if centroidDifference(1) < -tolerance
                        if centroidDifference(2)+50 < -tolerance
                            %left and up
                            disp("left and up");
                            move(droneobj, [0 -0.2 -0.2],"Speed",1);
                        elseif centroidDifference(2)+50 > tolerance
                            %left and down
                            disp("left and down");
                            move(droneobj, [0 -0.2 0.2],"Speed",1);
                        else %left
                            disp("left");
                            moveleft(droneobj, 'Distance', 0.2, "Speed",1);
                        end
                    elseif centroidDifference(1) > tolerance
                        if centroidDifference(2)+50 < -tolerance
                            %right and up
                             disp("right and up");
                            move(droneobj, [0 0.2 -0.2],"Speed",1);
                        elseif centroidDifference(2)+50 > tolerance
                            %right and down
                             disp("right and down");
                            move(droneobj, [0 0.2 0.2],"Speed",1);
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
                        movedown(droneobj, 'Distance', 0.2, "Speed",1);
               
                    else%################# 완료
                        disp(" 돌격 1 ");
                        disp("원의 중심 ")
                        distance=0.2;
                        disp("distance: ");
                        disp(distance);
                        movedown(droneobj, 'Distance', 0.2, "Speed",1);
                        moveforward(droneobj,'Distance',2.4,'Speed',1);
                        flag=0;
                        stage=1;
                        count_circle=0;
                        break;
                    end     
                else 
                    moveback(droneobj,"Distance",0.2,"Speed",1);
                % end
            end
        end
    end
end

while stage==1 % 1단계 통과후 turn and back
    stage=2;
    turn(droneobj,deg2rad(90));
    moveback(droneobj,"Distance",0.9,"Speed",1);
    % movedown(droneobj,"Distance",0.3);
    break;
end
%% 2단계 start
while stage==2
 image = snapshot(cameraObj);
    figure(1);
    imshow(image);

    imageCenter = [size(image, 2)/2, size(image, 1)/2];

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);
    
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
    
    centerBoundingBox = [boundingBox(1)+boundingBox(3)/2, boundingBox(2)+boundingBox(4)/2];
    centerBoundingBox = round(centerBoundingBox);
    
    % Display the image
    figure(2);
    imshow(smoothedImage);
    hold on;

    [row, col] = find(smoothedImage);

    % if (length(row) > 590000 && length(col) > 590000)
    %     disp("blue full")
    %     flag = 1;
    % end
    
    % Display the center of the bounding box
    plot(centerBoundingBox(1), centerBoundingBox(2), 'r*');
    plot(imageCenter(1), imageCenter(2), 'b*');
    
    centroidDifference = centerBoundingBox - imageCenter;
    disp(['Centroid difference: ', num2str(centroidDifference)]);

    if centroidDifference(1) < -tolerance
        if centroidDifference(2)+50 < -tolerance
            %left and up
            disp("left and up");
            move(droneobj, [0 -0.2 -0.2],"Speed",1);
        elseif centroidDifference(2)+50 > tolerance
            %left and down
            disp("left and down");
            move(droneobj, [0 -0.2 0.2],"Speed",1);
        else %left
            disp("left");
            moveleft(droneobj, 'Distance', 0.2,"Speed",1);
        end
    elseif centroidDifference(1) > tolerance
        if centroidDifference(2)+50 < -tolerance
            %right and up
             disp("right and up");
            move(droneobj, [0 0.2 -0.2],"Speed",1);
        elseif centroidDifference(2)+50 > tolerance
            %right and down
             disp("right and down");
            move(droneobj, [0 0.2 0.2],"Speed",1);
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
     if centroidDifference(1) > -tolerance && centroidDifference(1) < tolerance && centroidDifference(2)+50 > -tolerance &&centroidDifference(2)+50 < tolerance
        disp("반전");

    while(1)
        image = snapshot(cameraObj);
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
                % if numel(regionMeasurements)>1
                    disp("영역의 개수 : ");
                    disp(numel(regionMeasurements));
                    centroidDifference = centroid - imageCenter;
                           if centroidDifference(1) < -tolerance
                                if centroidDifference(2)+50 < -tolerance
                                    %left and up
                                    disp("left and up");
                                    move(droneobj, [0 -0.2 -0.2],"Speed",1);
                                elseif centroidDifference(2)+50 > tolerance
                                    %left and down
                                    disp("left and down");
                                    move(droneobj, [0 -0.2 0.2],"Speed",1);
                                else %left
                                    disp("left");
                                    moveleft(droneobj, 'Distance', 0.2, "Speed",1);
                                end
                            elseif centroidDifference(1) > tolerance
                                if centroidDifference(2)+50 < -tolerance
                                    %right and up
                                     disp("right and up");
                                    move(droneobj, [0 0.2 -0.2],"Speed",1);
                                elseif centroidDifference(2)+50 > tolerance
                                    %right and down
                                     disp("right and down");
                                    move(droneobj, [0 0.2 0.2],"Speed",1);
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
                            movedown(droneobj, 'Distance', 0.2, "Speed",1);
                   
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
                                    
                                    
                                    movedown(droneobj, 'Distance', 0.2, "Speed",1);
                                    disp("원의 중심 ")
                                    moveforward(droneobj,'Distance',2.7,'Speed',1);
                                    flag=0;
                                    stage=3;
                                    count_circle=0;
                                    break;
                                end
                                %####################
                           end
                           else 
                              moveback(droneobj,"Distance",0.2,"Speed",1);
                 end
                
                
             
             % end
        end
    end
end

while stage==3% 2단계 통과 후 turn and back
    stage=4;
    turn(droneobj,deg2rad(90));
    moveback(droneobj,"Distance",0.7);
    % moveup(droneobj,"Distance",0.3); %%이단 보정
    break;
end

%% 3단계 start
while stage==4

    image = snapshot(cameraObj);
    figure(1);
    imshow(image);

    imageCenter = [size(image, 2)/2, size(image, 1)/2];

    image1R = image(:,:,1);
    image1G = image(:,:,2);
    image1B = image(:,:,3);
    
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
    
    centerBoundingBox = [boundingBox(1)+boundingBox(3)/2, boundingBox(2)+boundingBox(4)/2];
    centerBoundingBox = round(centerBoundingBox);
    
    % Display the image
    figure(2);
    imshow(smoothedImage);
    hold on;

    [row, col] = find(smoothedImage);

    % if (length(row) > 590000 && length(col) > 590000)
    %     disp("blue full")
    %     flag = 1;
    % end
    
    % Display the center of the bounding box
    plot(centerBoundingBox(1), centerBoundingBox(2), 'r*');
    plot(imageCenter(1), imageCenter(2), 'b*');
    
    centroidDifference = centerBoundingBox - imageCenter;
    disp(['Centroid difference: ', num2str(centroidDifference)]);

    if centroidDifference(1) < -tolerance
        if centroidDifference(2)+50 < -tolerance
            %left and up
            disp("left and up");
            move(droneobj, [0 -0.2 -0.2],"Speed",1);
        elseif centroidDifference(2)+50 > tolerance
            %left and down
            disp("left and down");
            move(droneobj, [0 -0.2 0.2],"Speed",1);
        else %left
            disp("left");
            moveleft(droneobj, 'Distance', 0.2,"Speed",1);
        end
    elseif centroidDifference(1) > tolerance
        if centroidDifference(2)+50 < -tolerance
            %right and up
             disp("right and up");
            move(droneobj, [0 0.2 -0.2],"Speed",1);
        elseif centroidDifference(2)+50 > tolerance
            %right and down
             disp("right and down");
            move(droneobj, [0 0.2 0.2],"Speed",1);
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
     if centroidDifference(1) > -tolerance && centroidDifference(1) < tolerance && centroidDifference(2)+50 > -tolerance &&centroidDifference(2)+50 < tolerance
        disp("내부 원 중심 찾기 ");

        while (1)
            %%네모 중간일때 
            image = snapshot(cameraObj);
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
                % if numel(regionMeasurements)>1
                    disp("영역의 개수 : ");
                    disp(numel(regionMeasurements));
                    centroidDifference = centroid - imageCenter;
                           if centroidDifference(1) < -tolerance
                                if centroidDifference(2)+50 < -tolerance
                                    %left and up
                                    disp("left and up");
                                    move(droneobj, [0 -0.2 -0.2],"Speed",1);
                                elseif centroidDifference(2)+50 > tolerance
                                    %left and down
                                    disp("left and down");
                                    move(droneobj, [0 -0.2 0.2],"Speed",1);
                                else %left
                                    disp("left");
                                    moveleft(droneobj, 'Distance', 0.2, "Speed",1);
                                end
                            elseif centroidDifference(1) > tolerance
                                if centroidDifference(2)+50 < -tolerance
                                    %right and up
                                     disp("right and up");
                                    move(droneobj, [0 0.2 -0.2],"Speed",1);
                                elseif centroidDifference(2)+50 > tolerance
                                    %right and down
                                     disp("right and down");
                                    move(droneobj, [0 0.2 0.2],"Speed",1);
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
                            movedown(droneobj, 'Distance', 0.2, "Speed",1);
                   
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
                                    
                                    
                                    movedown(droneobj, 'Distance', 0.2, "Speed",1);
                                    moveforward(droneobj,'Distance',2.4,'Speed',1);
                                    flag=0;
                                    stage=5;
                                    count_circle=0;
                                    break;
                                end
                                %####################
                           end
                        else
                            moveback(droneobj,"Distance",0.2,"Speed",1);
                    end
                
                
             % else 
             % 
            % end
        end
    end
end

while stage==5 % 3단계 통과 후 바로 4단계
    stage=6;
    break;
end


%% 3단계 에는 다 통과까지한거
if stage==6
    flag =0;
    moveup(droneobj,"Distance",0.2,"Speed",1);
    while(flag==0) %초록찾기


        image = snapshot(cameraObj);
        figure(1);
        imshow(image);

        % Convert the RGB image to HSV
        hsvImage = rgb2hsv(image);
        
        % Separate the H, S, and V components
        image1H = hsvImage(:,:,1);
        image1S = hsvImage(:,:,2);
        image1V = hsvImage(:,:,3);
        
        % Thresholding based on HSV values
        imageR_H = image1H <= 0.35 & image1H >= 0.25;
        imageR_S = image1S >= 0.28 & image1S <= 0.6;
        imageR_V = image1V >= 0.4 & image1V <= 0.8;
        
        % Combine the thresholds
        imageR_combi = imageR_H & imageR_S & imageR_V;
        
        % Find connected components
        cc = bwconncomp(imageR_combi);
        graindata = regionprops(cc, 'Area', 'BoundingBox');
        
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
            turn(droneobj, deg2rad(45));
            flag =1;
        else
        % Get the bounding box
            boundingBox = round(graindata(idxMax).BoundingBox);
            
            % Create a new binary image
            newImage = false(size(imageR_combi));
            
            % Fill the bounding box area with 1
            newImage(boundingBox(2):(boundingBox(2)+boundingBox(4)), boundingBox(1):(boundingBox(1)+boundingBox(3))) = 1;
            
            % Calculate the area by summing the values within the bounding box (sum of ones)
            area = sum(sum(newImage));
    
            % Print the area
            fprintf('The area of the bounding box is: %d\n', area);
            
            % Display the new image
            figure(2);
            imshow(newImage);
    
            if area <6600
                moveforward(droneobj,'Distance',0.2,'Speed',1);
            else
                turn(droneobj, deg2rad(45));
                moveforward(droneobj,'Distance',0.7,'Speed',1);
                disp("turn");
                flag = 1;
            end
        end

    end
 
    while(flag==1) %사각형 중심 맞추기
        disp("last")

        image = snapshot(cameraObj);
        figure(1);
        imshow(image);

        image1R = image(:,:,1);
        image1G = image(:,:,2);
        image1B = image(:,:,3);
        
        image_only_B = image1B - image1R/2 - image1G/2;
        bw2 = image_only_B > 63;

        imageCenter = [size(image, 2)/2, size(image, 1)/2];


        % Apply Gaussian filter for noise reduction
        filterSize = 10;
        gaussianFilter = fspecial('gaussian', filterSize);
        smoothedImage = imfilter(bw2, gaussianFilter);

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
        if idxMax == 0 %안보이면
            disp(" 안보이는 right");
            moveright(droneobj, 'Distance', 0.4,"Speed",1); % Assuming 'droneobj' is your drone object
        else
            % Get the bounding box
            boundingBox = round(graindata(idxMax).BoundingBox);

            % Fill the bounding box area with 1
            smoothedImage(boundingBox(2):(boundingBox(2)+boundingBox(4)), boundingBox(1):(boundingBox(1)+boundingBox(3))) = 1;
            
            centerBoundingBox = [boundingBox(1)+boundingBox(3)/2, boundingBox(2)+boundingBox(4)/2];
            centerBoundingBox = round(centerBoundingBox);
            
            % Display the image
            figure(2);
            imshow(smoothedImage);
            hold on;
        
            [row, col] = find(smoothedImage);
            
            % Display the center of the bounding box
            plot(centerBoundingBox(1), centerBoundingBox(2), 'r*');
            plot(imageCenter(1), imageCenter(2), 'b*');
            
            centroidDifference = centerBoundingBox - imageCenter;
            disp(['Centroid difference: ', num2str(centroidDifference)]);
        
            if centroidDifference(1) < -tolerance
                if centroidDifference(2)+50 < -tolerance
                    %left and up
                    disp("left and up");
                    move(droneobj, [0 -0.2 -0.2],"Speed",1);
                elseif centroidDifference(2)+50 > tolerance
                    %left and down
                    disp("left and down");
                    move(droneobj, [0 -0.2 0.2],"Speed",1);
                else %left
                    disp("left");
                    moveleft(droneobj, 'Distance', 0.2, "Speed",1);
                end
            elseif centroidDifference(1) > tolerance
                if centroidDifference(2)+50 < -tolerance
                    %right and up
                     disp("right and up");
                    move(droneobj, [0 0.2 -0.2],"Speed",1);
                elseif centroidDifference(2)+50 > tolerance
                    %right and down
                     disp("right and down");
                    move(droneobj, [0 0.2 0.2],"Speed",1);
                else %right
                     disp("right");
                    moveright(droneobj, 'Distance', 0.5,"Speed",1);
        
                end
            elseif centroidDifference(2)+50 < -tolerance
                %up
                disp("up");
                moveup(droneobj, 'Distance', 0.2,"Speed",1);
            elseif centroidDifference(2)+50 > tolerance
                %down
                disp("down");
                movedown(droneobj, 'Distance', 0.2, "Speed",1);
            end
        
            if centroidDifference(1) > -tolerance && centroidDifference(1) < tolerance && centroidDifference(2)+50 > -tolerance &&centroidDifference(2)+50 < tolerance
                disp("angle_조정");
                movedown(droneobj, 'Distance', 0.2, "Speed",1);
                flag = 2;
            end
        end
    end
    
    while(flag==2) % angle 수정
        image = snapshot(cameraObj);
        figure(1);
        imshow(image);

        image1R = image(:,:,1);
        image1G = image(:,:,2);
        image1B = image(:,:,3);

        image_only_B = image1B - image1R/2 - image1G/2;
        bw2 = image_only_B > 63;

        % Apply Gaussian filter for noise reduction
        filterSize = 10;
        gaussianFilter = fspecial('gaussian', filterSize);
        smoothedImage = imfilter(bw2, gaussianFilter);

        figure(1);
        imshow(smoothedImage);

        % Find connected components
        cc = bwconncomp(smoothedImage);
        graindata = regionprops(cc, 'Area', 'PixelList');

        % Find the largest connected component
        maxArea = 0;
        idxMax = 0;
        for idx = 1:length(graindata)
            if graindata(idx).Area > maxArea
                maxArea = graindata(idx).Area;
                idxMax = idx;
            end
        end

        if idxMax ==0
            moveforward(droneobj,"Distance",0.2,"Speed",1);

        else

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
    
            % Display the image
            figure(2);
            imshow(smoothedImage);
            hold on;
    
            % Plot the vertices on the image
            plot(tl(2), tl(1), 'r*'); % top-left vertex
            plot(tr(2), tr(1), 'r*'); % top-right vertex
            plot(bl(2), bl(1), 'r*'); % bottom-left vertex
            plot(br(2), br(1), 'r*'); % bottom-right vertex
    
            % Print the coordinates
            fprintf('The coordinates of the vertices are:\n');
            fprintf('Top left: x=%d, y=%d\n', tl(2), tl(1));
            fprintf('Top right: x=%d, y=%d\n', tr(2), tr(1));
            fprintf('Bottom left: x=%d, y=%d\n', bl(2), bl(1));
            fprintf('Bottom right: x=%d, y=%d\n', br(2), br(1));
    
            dist_t = tl(1) - tr(1);
            dist_b = bl(1) - br(1);
            fprintf('top: x=%d\n', dist_t);
            fprintf('Bottom: x=%d\n', dist_b);
    
            %% 여기 수정
            % Determine the rotation direction for Tello
            if dist_t > 10 && dist_b < -10
                turn(droneobj, deg2rad(10));
                fprintf('Tello should rotate to the right.\n');
                % Include the command to make Tello rotate right here
            elseif dist_t < -10 && dist_b > 10
                turn(droneobj, deg2rad(-10));
                fprintf('Tello should rotate to the left.\n');
                % Include the command to make Tello rotate left here
            % elseif dist_t > 1 && dist_b > 10
            %     turn(droneobj, deg2rad(-10));
            %     fprintf('Tello should rotate to the left.\n');
            % elseif dist_t < -1 && dist_b < -10
            %     turn(droneobj, deg2rad(-10));
            %     fprintf('Tello should rotate to the left.\n');
            else
                fprintf('No rotation needed.\n');
                flag = 3;
            end
        end
    end

    while(flag==3)% 원 중심 맞추기
        image = snapshot(cameraObj);
        figure(3);
        imshow(image);

        imageCenter = [size(image, 2)/2, size(image, 1)/2];

        image1R = image(:,:,1);
        image1G = image(:,:,2);
        image1B = image(:,:,3);
        
        image_only_B = image1B - image1R/2 - image1G/2;
        bw2 = image_only_B > 63;

        % Apply Gaussian filter for noise reduction
        filterSize = 5;
        gaussianFilter = fspecial('gaussian', filterSize);
        smoothedImage = imfilter(bw2, gaussianFilter);

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

            if centroidDifference(1) < -tolerance4
                if centroidDifference(2)+50 < -tolerance4
                    %left and up
                    disp("left and up");
                    move(droneobj, [0 -0.2 -0.2],"Speed",1);
                elseif centroidDifference(2)+50 > tolerance4
                    %left and down
                    disp("left and down");
                    move(droneobj, [0 -0.2 0.2],"Speed",1);
                else %left
                    disp("left");
                    moveleft(droneobj, 'Distance', 0.2, "Speed",1);
                end
            elseif centroidDifference(1) > tolerance4
                if centroidDifference(2)+50 < -tolerance4
                    %right and up
                     disp("right and up");
                    move(droneobj, [0 0.2 -0.2],"Speed",1);
                elseif centroidDifference(2)+50 > tolerance4
                    %right and down
                     disp("right and down");
                    move(droneobj, [0 0.2 0.2],"Speed",1);
                else %right
                     disp("right");
                    moveright(droneobj, 'Distance', 0.2,"Speed",1);
        
                end
            elseif centroidDifference(2)+50 < -tolerance4
                %up
                disp("up");
                moveup(droneobj, 'Distance', 0.2,"Speed",1);
            elseif centroidDifference(2)+50 > tolerance4
                %down
                disp("down");
                movedown(droneobj, 'Distance', 0.2, "Speed",1);
       
            else%################# 완료
                disp(" 돌격 1 ");
                disp("원의 중심 ")
                distance=0.2;
                disp("distance: ");
                disp(distance);
                movedown(droneobj, 'Distance', 0.2, "Speed",1);

                flag=4;
                stage=6;
                count_circle=0;
                break;
            end     
        else 
            moveback(droneobj,"Distance",0.2,"Speed",1);
        end
    end

    while (flag==4)
        image = snapshot(cameraObj);
        figure(1);
        imshow(image);

        % Convert the RGB image to HSV
        hsvImage = rgb2hsv(image);
        
        % Separate the H, S, and V components
        image1H = hsvImage(:,:,1);
        image1S = hsvImage(:,:,2);
        image1V = hsvImage(:,:,3);
        
        % Thresholding based on HSV values
        imageP_H = image1H <= 0.8 & image1H >= 0.7;
        imageP_S = image1S >= 0.3 & image1S <= 0.8;
        imageP_V = image1V >= 0.4 & image1V <= 0.7;
        
        % Combine the thresholds
        imageP_combi = imageP_H & imageP_S & imageP_V;
        
        % Find connected components
        cc = bwconncomp(imageP_combi);
        graindata = regionprops(cc, 'Area', 'BoundingBox');
        
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
    
            % Print the area
            fprintf('The area of purple the bounding box is: %d\n', area);
            
            % Display the new image
            figure(2);
            imshow(newImage);

            if area <2000
                moveforward(droneobj,'Distance',0.5,'Speed',1);
            elseif area <2440
                moveforward(droneobj,'Distance',0.2,'Speed',1);
            else
                disp("???");
                % land(droneobj);
                flag = 5;
            end
            
        end

    end

    while(flag==5)% 원 중심 맞추기
        image = snapshot(cameraObj);
        figure(3);
        tolerance4=90;
        imshow(image);

        imageCenter = [size(image, 2)/2, size(image, 1)/2];

        image1R = image(:,:,1);
        image1G = image(:,:,2);
        image1B = image(:,:,3);
        
        image_only_B = image1B - image1R/2 - image1G/2;
        bw2 = image_only_B > 63;

        % Apply Gaussian filter for noise reduction
        filterSize = 5;
        gaussianFilter = fspecial('gaussian', filterSize);
        smoothedImage = imfilter(bw2, gaussianFilter);

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

            if centroidDifference(1) < -tolerance4
                if centroidDifference(2)+50 < -tolerance4
                    %left and up
                    disp("left and up");
                    move(droneobj, [0 -0.2 -0.2],"Speed",1);
                elseif centroidDifference(2)+50 > tolerance4
                    %left and down
                    disp("left and down");
                    move(droneobj, [0 -0.2 0.2],"Speed",1);
                else %left
                    disp("left");
                    moveleft(droneobj, 'Distance', 0.2, "Speed",1);
                end
            elseif centroidDifference(1) > tolerance4
                if centroidDifference(2)+50 < -tolerance4
                    %right and up
                     disp("right and up");
                    move(droneobj, [0 0.2 -0.2],"Speed",1);
                elseif centroidDifference(2)+50 > tolerance4
                    %right and down
                     disp("right and down");
                    move(droneobj, [0 0.2 0.2],"Speed",1);
                else %right
                     disp("right");
                    moveright(droneobj, 'Distance', 0.2,"Speed",1);
        
                end
            elseif centroidDifference(2)+50 < -tolerance4
                %up
                disp("up");
                moveup(droneobj, 'Distance', 0.2,"Speed",1);
            elseif centroidDifference(2)+50 > tolerance4
                %down
                disp("down");
                movedown(droneobj, 'Distance', 0.2, "Speed",1);
       
            else%################# 완료
                disp(" 돌격 1 ");
                disp("원의 중심 ")
                distance=0.2;
                disp("distance: ");
                disp(distance);
                % movedown(droneobj, 'Distance', 0.2, "Speed",1);
                % 
                % flag=4;
                % stage=6;
                % count_circle=0;
                % break;
                land(droneobj);
                break;
            end     
        else 
            moveback(droneobj,"Distance",0.2,"Speed",1);
        end
    end

end
