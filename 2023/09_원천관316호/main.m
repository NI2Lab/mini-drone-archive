droneObj = ryze();
cameraObj = camera(droneObj);
preview(cameraObj);
% land(droneObj)
takeoff(droneObj);
moveup(droneObj, 'Distance', 0.6);
moveback(droneObj, 'Distance', 0.5);
sw = 1;
pass = 0;
found = 0;
trial = 1;
tic

while sw ~= 9
    if sw == 1
        frame = snapshot(cameraObj);
        pass = detectCircles78(frame, droneObj);
    end
    if sw == 2
        frame = snapshot(cameraObj);
        pass= detectCircles78(frame, droneObj);
    end
    if sw == 3
        frame = snapshot(cameraObj);
        pass = detectCircles57(frame, droneObj);
    end
    if sw == 4
        frame = snapshot(cameraObj);
        sw = detectCircles50(frame, droneObj);
    end
    if sw == 5
        frame = snapshot(cameraObj);
        sw = lookforPurple(frame, trial, droneObj);
        trial = trial + 1;
        if trial >= 4
            sw = 9;
        end
    end
    if sw == 6
        frame = snapshot(cameraObj);
        [found, xp, yp] = findPurple(frame);
        if found == 0
            fprintf('sw6 error\n');
            sw = 5;
            trial = 1;
        end
        if found == 1
            [sw, xc, yc] = findCircle(frame);
        end
    end
    if sw == 7
        frame = snapshot(cameraObj);
        sw = calibrationR(frame, xc, yc, xp, yp, droneObj);
    end


    if pass == 1
        toc
        tic
        moveup(droneObj, 'Distance', 0.2);
        frame = snapshot(cameraObj);
        y = analyzePaper(frame);

        if y == 1
            moveforward(droneObj, 'Distance', 0.3);
            turn(droneObj, deg2rad(90));
            moveback(droneObj, 'Distance', 0.3);
            pass = 0;
            sw = sw + 1;
        elseif y == 2
            moveforward(droneObj, 'Distance', 0.3);
            turn(droneObj, deg2rad(45));
            moveforward(droneObj, 'Distance', 0.5);
            pass = 0;
            sw = 4;
        elseif y == 3
            pass = 0;
            sw = 9;
        elseif y == 0
            fprintf('Color 인식 error\n');
            pass = 1;
            sw = 9;
        else
            fprintf('MASK 인식 error\n');
            pass = 1;
            sw = 9;
        end
    end
end
toc
moveforward(droneObj, 'Distance', 0.4);
land(droneObj);



function [xpos, ypos] = dronePosition(circleDiameter, radii, xcenter, ycenter)
% 거리별 드론의 이동 제어
%  
    pixMeterConstant = 0.0016;
    %드론과 원의 실제 거리를 비례식으로 계산
    droneDistance = (circleDiameter / 200 / pixMeterConstant) / radii * 1.5;
    
    %1pix당 실제 횡이동하는 거리를 계산
    movePerPixel = pixMeterConstant * droneDistance / 1.3;

    %드론 카메라 중점을 기준으로 한 원 중점의 위치벡터 계산
    xpos = round(movePerPixel * (xcenter - 480), 1);
    ypos = round(movePerPixel * (ycenter - 300), 1);
    
    if abs(xpos) < 0.2
        xpos = 0;
    end
    if abs(ypos) < 0.2
        ypos = 0;
    end 
    fprintf("위치 보정 진행, 원으로부터 %.1fm만큼의 거리에서 우측으로 %.1fm만큼, 아래로 %.1fm만큼 이동합니다\n",droneDistance, xpos, ypos);
end






function pass = detectCircles78(frame, droneObj)
    % 기본 변수
    variable = 4;
    radiiRange = [100 1000];
    sensitivityValue = 0.97;

    hueMean = 0.6170;
    hueVariance = 5.1249e-04;
    saturationMean = 0.2507;
    saturationVariance = 0.0020;

    image = frame;
    hsvImage = rgb2hsv(image);

    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(image));
    outputImage(hueMask & saturationMask) = 255;
    grayImage = rgb2gray(outputImage);
    blurred_image = imgaussfilt(grayImage, 5); 
    edges = edge(blurred_image, 'Canny');
    imshow(edges);
    hold on;
    [centers, radii, ~] = imfindcircles(edges, radiiRange, 'Sensitivity', sensitivityValue);
    pass = 0;
    fprintf('원이 %f 개\n', size(centers, 1));
    if size(centers, 1) > 0
        [~, maxIndex] = max(radii);
        maxCenter = centers(maxIndex, :);
        maxRadius = radii(maxIndex);
        maxArea = pi * maxRadius * maxRadius;

        viscircles(maxCenter, maxRadius, 'EdgeColor', 'b');
        fprintf('최대 원의 중심점 X = %f, Y = %f, 반지름 = %f\n', maxCenter(1), maxCenter(2), maxRadius);
        plot(maxCenter(1), maxCenter(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        % fprintf('최대 원의 넓이 = %f\n', maxArea);
        % fprintf('최대 원의 거리 = %f\n', maxDistance);

        xcenter = maxCenter(1);
        ycenter = maxCenter(2);
        radii = maxRadius;
        circleDiameter = 78;
        [xpos, ypos] = dronePosition(circleDiameter, radii, xcenter, ycenter);

        if xpos > 0
            moveright(droneObj, distance = xpos)
        elseif xpos < 0
            moveleft(droneObj, distance = -xpos)
        else
            fprintf('X 오차 없음 ');
        end
        if ypos > 0
            movedown(droneObj, distance = ypos)
        elseif ypos < 0
            moveup(droneObj, distance = -ypos)
        else
            fprintf('Y 오차 없음\n');
        end

        if  maxArea < 100000
            moveforward(droneObj, 'Distance', 0.4);
        elseif (maxArea >= 100000) && (maxArea < 140000)
            pass = 1;
            fprintf('중앙 인식 step 1,2(so far)\n');
            movedown(droneObj, distance = 0.3);
            moveforward(droneObj, 'Distance', 2.5);
        elseif (maxArea >= 140000) && (maxArea < 170000)
            pass = 1;
            fprintf('중앙 인식 step 1,2(far)\n');
            movedown(droneObj, distance = 0.3);
            moveforward(droneObj, 'Distance', 2.3);
        else
            pass = 1;
            fprintf('중앙 인식 step 1,2(near)\n');
            movedown(droneObj, distance = 0.2);
            moveforward(droneObj, 'Distance', 2.1);
        end
    else
        moveup(droneObj, 'Distance', 0.3);
        moveback(droneObj, 'Distance', 0.6);
    end
end




function pass = detectCircles57(frame, droneObj)
    % 기본 변수
    variable = 4;
    radiiRange = [100 1000];
    sensitivityValue = 0.97;

    hueMean = 0.6170;
    hueVariance = 5.1249e-04;
    saturationMean = 0.2507;
    saturationVariance = 0.0020;

    image = frame;
    hsvImage = rgb2hsv(image);

    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(image));
    outputImage(hueMask & saturationMask) = 255;
    grayImage = rgb2gray(outputImage);
    blurred_image = imgaussfilt(grayImage, 5); 
    edges = edge(blurred_image, 'Canny');
    imshow(edges);
    hold on;
    [centers, radii, ~] = imfindcircles(edges, radiiRange, 'Sensitivity', sensitivityValue);
    pass = 0;
    fprintf('원이 %f 개\n', size(centers, 1));
    if size(centers, 1) >= 1
        [~, maxIndex] = max(radii);
        maxCenter = centers(maxIndex, :);
        maxRadius = radii(maxIndex);
        maxArea = pi * maxRadius * maxRadius;

        viscircles(maxCenter, maxRadius, 'EdgeColor', 'b');
        fprintf('최대 원의 중심점 X = %f, Y = %f, 반지름 = %f\n', maxCenter(1), maxCenter(2), maxRadius);
        plot(maxCenter(1), maxCenter(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        % fprintf('최대 원의 넓이 = %f\n', maxArea);
        % fprintf('최대 원의 거리 = %f\n', maxDistance);

        xcenter = maxCenter(1);
        ycenter = maxCenter(2);
        radii = maxRadius;
        circleDiameter = 57;
        [xpos, ypos] = dronePosition(circleDiameter, radii, xcenter, ycenter);

        if xpos > 0
            moveright(droneObj, distance = xpos)
        elseif xpos < 0
            moveleft(droneObj, distance = -xpos)
        else
            fprintf('X 오차 없음 ');
        end
        if ypos > 0
            movedown(droneObj, distance = ypos)
        elseif ypos < 0
            moveup(droneObj, distance = -ypos)
        else
            fprintf('Y 오차 없음\n');
        end

        if  maxArea < 50000
            moveforward(droneObj, 'Distance', 0.4);
        elseif (maxArea >= 50000) && (maxArea < 70000)
            pass = 1;
            fprintf('중앙 인식 step 3(so far)\n');
            movedown(droneObj, distance = 0.2);
            moveforward(droneObj, 'Distance', 2.2);
        elseif (maxArea >= 70000) && (maxArea < 110000)
            pass = 1;
            fprintf('중앙 인식 step 3(far)\n');
            movedown(droneObj, distance = 0.2);
            moveforward(droneObj, 'Distance', 1.9);
        else
            pass = 1;
            fprintf('중앙 인식 step 3(near)\n');
            movedown(droneObj, distance = 0.2);
            moveforward(droneObj, 'Distance', 1.7);
        end
    else
        moveup(droneObj, 'Distance', 0.3)
        moveback(droneObj, 'Distance', 0.6);
    end
end







function sw = detectCircles50(frame, droneObj)
    % 기본 변수
    variable = 4;
    radiiRange = [70 1000];
    sensitivityValue = 0.96;


    hueMean = 0.6170;
    hueVariance = 5.1249e-04;
    saturationMean = 0.2507;
    saturationVariance = 0.0020;

    image = frame;
    hsvImage = rgb2hsv(image);

    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(image));
    outputImage(hueMask & saturationMask) = 255;
    grayImage = rgb2gray(outputImage);
    blurred_image = imgaussfilt(grayImage, 5); 
    edges = edge(blurred_image, 'Canny');
    imshow(edges);
    hold on;
    [centers, radii, ~] = imfindcircles(edges, radiiRange, 'Sensitivity', sensitivityValue);
    sw = 4;
    fprintf('원이 %f 개\n', size(centers, 1));
    if size(centers, 1) >= 1
        [~, maxIndex] = max(radii);
        maxCenter = centers(maxIndex, :);
        maxRadius = radii(maxIndex);
        maxArea = pi * maxRadius * maxRadius;

        viscircles(maxCenter, maxRadius, 'EdgeColor', 'b');
        fprintf('최대 원의 중심점 X = %f, Y = %f, 반지름 = %f\n', maxCenter(1), maxCenter(2), maxRadius);
        plot(maxCenter(1), maxCenter(2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        % fprintf('최대 원의 넓이 = %f\n', maxArea);
        % fprintf('최대 원의 거리 = %f\n', maxDistance);

        xcenter = maxCenter(1);
        ycenter = maxCenter(2);
        radii = maxRadius;
        circleDiameter = 50;
        [xpos, ypos] = dronePosition(circleDiameter, radii, xcenter, ycenter);

        if xpos > 0
            moveright(droneObj, distance = xpos)
        elseif xpos < 0
            moveleft(droneObj, distance = -xpos)
        else
            fprintf('X 오차 없음 ');
        end
        if ypos > 0
            movedown(droneObj, distance = ypos)
        elseif ypos < 0
            moveup(droneObj, distance = -ypos)
        else
            fprintf('Y 오차 없음\n');
        end

        if  maxArea < 40000
            moveforward(droneObj, 'Distance', 0.6);
        elseif (maxArea >= 40000) && (maxArea < 60000)
            moveforward(droneObj, 'Distance', 0.4);
        elseif (maxArea >= 80000) && (maxArea < 60000)
            moveforward(droneObj, 'Distance', 0.2);
        else
            sw = 5;
            fprintf('중앙 인식 step 4\n');
        end
    else
        moveback(droneObj, 'Distance', 0.2);
    end
end




function [sw, xc, yc] = findCircle(frame, droneObj)
    % 기본 변수
    variable = 4;
    radiiRange = [100 1000];
    sensitivityValue = 0.96;

    hueMean = 0.6170;
    hueVariance = 5.1249e-04;
    saturationMean = 0.2507;
    saturationVariance = 0.0020;
    xc = 0;
    yc = 0;
    sw = 6;

    image = frame;
    hsvImage = rgb2hsv(image);

    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(image));
    outputImage(hueMask & saturationMask) = 255;
    grayImage = rgb2gray(outputImage);
    blurred_image = imgaussfilt(grayImage, 5); 
    edges = edge(blurred_image, 'Canny');
    imshow(edges);
    hold on;
    [centers, radii, ~] = imfindcircles(edges, radiiRange, 'Sensitivity', sensitivityValue);
    if size(centers, 1) == 1
        fprintf('count가 1\n');
        viscircles(centers, radii, 'EdgeColor', 'b');
        plot(480, 330, 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        for i = 1:size(centers, 1)
            fprintf('원 %d의 중심점 X = %f, Y = %f, 반지름 = %f\n', i, centers(i, 1), centers(i, 2), radii(i));
            plot(centers(i, 1), centers(i, 2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
            xc = centers(i, 1);
            yc = centers(i, 2);
            pause(1);
            sw = 7;
        end
    else
        moveback(droneObj, 'Distance', 0.2);
    end
end




function sw = calibrationR(frame, xc, yc, xp, yp, droneObj)
    image = frame;
    imshow(image);
    hold on;
    plot(xc, yc, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    plot(xp, yp, 'b+', 'MarkerSize', 10, 'LineWidth', 2);
    xi = xp + (xp - xc);
    x_distance = xi - xc;
    xline(xi, 'g', LineWidth=2);
    theta = fix(x_distance/16.7); %16.7은 변수
    
    if abs(theta) > 5
        turn(droneObj, deg2rad(theta))
        if theta > 0
            moveleft(droneObj, distance = 0.2)
        else
            moveright(droneObj, distance = 0.2)
        end
        sw = 4;
    else
        sw = 9;
    end
end



function result = analyzePaper(frame)
% 흰 종이 내부의 표식을 감지하고, 그 색상을 읽는다.
%   자세한 설명 위치
    result = 0;
    
    frame_hsv = rgb2hsv(frame);
    
    binImage = whiteMasking(frame);
    
    %흰색 검출 이미지에서 사각형을 탐색
    cc = bwconncomp(binImage);
    regions = regionprops(cc, 'BoundingBox', 'Centroid');
    
    %검출 결과를 plot
    imshow(binImage)
    hold on
    validRegions = [];
    for i = 1 : numel(regions)
        verhorRatio(i) = (regions(i).BoundingBox(3) / regions(i).BoundingBox(4));
        if (regions(i).BoundingBox(3) * regions(i).BoundingBox(4) <= 20000) && ...
                (regions(i).BoundingBox(3) * regions(i).BoundingBox(4) >= 200) && ...
                verhorRatio(i) <= 1.2 && ...
                verhorRatio(i) >= 0.84 && ...                                                                           
                (norm([(480 - regions(i).Centroid(1)), (360 -regions(i).Centroid(2))]) <= 300)   %객체의 중심이 중앙에 충분히 가까우면 Valid
            validRegions = [validRegions, regions(i)];
        end
    end
    
    for i = 1 : numel(regions)
        rectangle('Position', regions(i).BoundingBox, 'EdgeColor' ,'c', 'LineWidth', 2);
    end

    for i = 1 : numel(validRegions)
        viscircles([480 360], 300, 'Color' ,'b', 'LineWidth', 1);
        rectangle('Position', validRegions(i).BoundingBox, 'EdgeColor' ,'y', 'LineWidth', 2);
        plot(validRegions(i).Centroid(1), validRegions(i).Centroid(2), 'y+', 'MarkerSize', 10);
    end
    
        % RED mask
        red_hue_mean = 0.035006836738102;
        red_hue_variance = 8.451444823239685e-04;
        red_saturation_mean = 0.801194701249392;
        red_saturation_variance = 8.123921822952889e-04;
        
        % GREEN mask
        green_hue_mean = 0.2974;
        green_hue_variance = 6.0420e-05;
        green_saturation_mean = 0.3800;
        green_saturation_variance = 0.0045;
        
        % PURPLE mask
        purple_hue_mean = 0.724754819881663;
        purple_hue_variance = 8.608107141373810e-05;
        purple_saturation_mean = 0.496633620639431;
        purple_saturation_variance = 0.003079431542493;
    
    %모든 유효한 영역에서 이미지를 검출
    for i = 1 : numel(validRegions)
        croppedFrame = imcrop(frame, [validRegions(i).BoundingBox(1), validRegions(i).BoundingBox(2) ...
            validRegions(i).BoundingBox(3) , validRegions(i).BoundingBox(4)]);
        % 잘려진 프레임을 HSV 색 공간으로 변환
        cr_frame_hsv = rgb2hsv(croppedFrame);
        % 잘려진 프레임의 도형 색상 분류 (HSV 색 공간)
        cr_hue = cr_frame_hsv(:, :, 1);
        cr_saturation = cr_frame_hsv(:, :, 2);
        variable = 7;

        % 적색 영역 검출
        red_mask = (abs(cr_hue - red_hue_mean) <= variable * sqrt(red_hue_variance)) & ...
            (abs(cr_saturation - red_saturation_mean) <= variable * sqrt(red_saturation_variance));
        % 녹색 영역 검출
        green_mask = (abs(cr_hue - green_hue_mean) <= variable * sqrt(green_hue_variance)) & ...
            (abs(cr_saturation - green_saturation_mean) <= variable * sqrt(green_saturation_variance));
        % 자색 영역 검출
        purple_mask = (abs(cr_hue - purple_hue_mean) <= variable * sqrt(purple_hue_variance)) & ...
            (abs(cr_saturation - purple_saturation_mean) <= variable * sqrt(purple_saturation_variance));
        
        %각각의 색이 종이에서 차지하는 비율 검출
        red_probability = sum(red_mask(:));
        green_probability = sum(green_mask(:));
        purple_probability = sum(purple_mask(:));
        
        probability(i, :) = [red_probability, green_probability, purple_probability];
        
        verhorRatio(i) = validRegions(i).BoundingBox(4) / validRegions(i).BoundingBox(3);
        %현재 잘라낸 이미지를 확인
        %imshow(croppedFrame)
    end
    
    if numel(validRegions) ~= 0
        if any(probability(:))
             [~, idx] = max(max(probability, [], 2));
             [~, result] = max(probability(idx, :));
             fprintf("총 %d개의 유효한 객체를 확인, 결과에 사용된 객체의 종횡비는 %.3f입니다. 결과 : %d\n", numel(validRegions), verhorRatio(idx), result);
             if result == 1
                 rectangle('Position', validRegions(idx).BoundingBox, 'EdgeColor' ,'r', 'LineWidth', 2);
                 plot(validRegions(idx).Centroid(1), validRegions(idx).Centroid(2), 'r+', 'MarkerSize', 10);
             elseif result == 2
                 rectangle('Position', validRegions(idx).BoundingBox, 'EdgeColor' ,'g', 'LineWidth', 2);
                 plot(validRegions(idx).Centroid(1), validRegions(idx).Centroid(2), 'g+', 'MarkerSize', 10);
             else
                 rectangle('Position', validRegions(idx).BoundingBox, 'EdgeColor' ,'m', 'LineWidth', 2);
                 plot(validRegions(idx).Centroid(1), validRegions(idx).Centroid(2), 'm+', 'MarkerSize', 10);
             end
             hold off
             return;
        end
    else
        variable = 5;
        hue = frame_hsv(:, :, 1);
        saturation = frame_hsv(:, :, 2);
        red_mask = (abs(hue - red_hue_mean) <= variable * sqrt(red_hue_variance)) & ...
            (abs(saturation - red_saturation_mean) <= variable * sqrt(red_saturation_variance));
        green_mask = (abs(hue - green_hue_mean) <= variable * sqrt(green_hue_variance)) & ...
            (abs(saturation - green_saturation_mean) <= variable * sqrt(green_saturation_variance));
        purple_mask = (abs(hue - purple_hue_mean) <= variable * sqrt(purple_hue_variance)) & ...
            (abs(saturation - purple_saturation_mean) <= variable * sqrt(purple_saturation_variance));
        [~, result] = max([sum(red_mask(:)), sum(green_mask(:)), sum(purple_mask(:))]);
        fprintf("유효한 표식지를 탐색하지 못하였습니다. 모든 사진 영역에서의 색 검출을 시도합니다. 결과 : %d\n", result);
    end
end







function result = whiteMasking(frame)
% 입력한 이미지(RGB)로부터 흰색을 제외한 부분을 추출한 이미지를 출력하는 함수
%   자세한 설명 위치
    
   for i = 1 : size(frame, 1)
       for j = 1 : size(frame, 2)
           rgbPixel = [frame(i, j, 1), frame(i, j, 2), frame(i, j, 3)];
           if mean(rgbPixel) >= 240 || ...
                   rgbPixel(3) >= 165 && ...                 %픽셀의 B가 165 이상이고
                   max(rgbPixel) - min(rgbPixel) <= 40   %RGB 범위가 40 이하이며
               result(i, j) = 0;
           else
               result(i, j) = 1;
           end
       end
   end
end







%{ 
보라색 사각형의 중점을 검출하는 함수.
세개의 인수를 1 by 3 행렬로 반환, [found, x, y] = findsquareCenter(frame)
사각형의 중점 탐색 성공 시 found = 1, x = 중점의 x좌표, y = 중점의 y좌표
중점 탐색 실패 시 found = 0, x = 0, y = 0
%}
function [found, xp, yp] = findPurple(frame)
    found = 0;
    xp = 0;
    yp = 0;

    %보라 사각형 검출
    hueMean = 0.724754819881663;
    hueVariance = 8.608107141373810e-05;
    saturationMean = 0.496633620639431;
    saturationVariance = 0.003079431542493;
    variable = 4;
    
    hsvImage = rgb2hsv(frame);
    hueRange = [hueMean - variable * sqrt(hueVariance), hueMean + variable * sqrt(hueVariance)];
    saturationRange = [saturationMean - variable * sqrt(saturationVariance), saturationMean + variable * sqrt(saturationVariance)];
    hueMask = (hsvImage(:,:,1) >= hueRange(1)) & (hsvImage(:,:,1) <= hueRange(2));
    saturationMask = (hsvImage(:,:,2) >= saturationRange(1)) & (hsvImage(:,:,2) <= saturationRange(2));

    outputImage = zeros(size(frame));
    outputImage(hueMask & saturationMask) = 255;
    outputImage = im2gray(outputImage);
    binImage = imbinarize(outputImage);
    
    regions = regionprops(binImage, 'BoundingBox', 'Area');

    minWidth = 5; 
    minHeight = 20; 
    
    %invPurple = numel(regions)
    if ~isempty(regions)
        validRegions = [];
        for i = 1:numel(regions)
            if regions(i).BoundingBox(3) >= minWidth && regions(i).BoundingBox(4) >= minHeight
                validRegions = [validRegions, regions(i)];
            end
        end
    end

    %valPurple = numel(validRegions)
    if numel(validRegions) == 1
        found = 1;
        xp = validRegions(1).BoundingBox(1) + validRegions(1).BoundingBox(3) / 2;
        yp = validRegions(1).BoundingBox(2) + validRegions(1).BoundingBox(4) / 2;
        imshow(frame);
        hold on;
        plot(xp, yp, 'r+', 'MarkerSize', 10);
        hold off;
        return;
    end
end





%{
4단계를 완료하여 마지막 원에 근접한 후 5단계에서 보라색을 탐색하는 과정
보라색을 탐색하지 못하면 좌우로 이동 및 5도(degree) 회전 과정을 반복(최대 6회)
결과적으로 보라색을 탐색하면 pass = 1하여 다음 단계로 이행
%}
function sw = lookforPurple(frame, trial, droneObj)
    sw = 5;
    [found, ~, ~] = findPurple(frame);
    if found == 1
        sw = 6;
        return;
    else
        if mod(trial, 2) == 1
            moveright(droneObj, 'Distance', 0.2 * trial);
            turn(droneObj, deg2rad(-5 * trial));
        else
            moveleft(droneObj, 'Distance', 0.2 * trial);
            turn(droneObj, deg2rad(5 * trial));
        end
    end
end

