ෆ은수 좋은날ෆ
=============

2024 대한전기학회 미니드론 자율비행 경진대회 본선 진출 팀 은수 좋은날입니다.
--------------------------------------------------------------------------------
<img src="https://github.com/yousukyoung/2024-Mini-Drone-Autonomous-Flight-Contest/assets/108873470/4abb43c7-c6e4-49af-9008-f353a9b208d1" alt="day" width="400"/>

I. 소개
========
이 대회는 MATLAB을 활용하여 Tello 드론의 비행을 제어하고, 영상 처리 기술을 이용해 미션을 수행하는 것을 목표로 합니다. 따라서, 드론의 카메라를 통해 수집한 영상을 실시간으로 처리하여, 지정된 경로를 따라 이동하고, 특정 목표물을 인식하며 임무를 완수해야 합니다.

II. 요구사항
=============
+ MATLAB 및 Ryze Tello 지원 패키지 설치
+ Tello 드론
+ 드론이 안전하게 작동할 수 있는 환경

III. 주요 활동
==============
+ **영상 처리**: MATLAB을 사용하여 드론의 카메라로 촬영된 영상을 실시간으로 분석합니다. 영상 처리 기술을 통해 링과 사각형 같은 목표물을 인식하고 그 중심을 파악합니다.
+ **드론 제어**: 인식된 목표물을 기반으로 드론의 비행 경로를 조정합니다. 드론은 링을 통과하고, 사각형 중심에 위치하며, 지정된 경로를 따라 안전하게 이동합니다.
+ **미션 수행**: 드론은 지정된 경로를 따라 이동하며, 각 지점에서 요구되는 임무를 수행합니다. 예를 들어, 링을 통과하거나, 사각형을 인식하여 중심에 맞추는 작업 등이 포함됩니다.

IV. 경로 설명
===============
![image](https://github.com/yousukyoung/2024-Mini-Drone-Autonomous-Flight-Contest/assets/108873470/9a2d7f8b-1635-4537-9f92-bdbadc7569fe)
+ 출발점(START)에서 이륙하여 링을 통과하고 이젤 앞까지 비행 후, 회전
+ 2차 타겟 앞까지 비행 후, 3차 타겟을 보기 위해 회전
+  3차 타겟 앞까지 비행 후, 4차 타겟을 보기 위해 회전
+  링을 통과하고 4차 타겟 앞으로 비행 후, 도착점(END)에 착륙.

IV. 대회 진행 전략
========================
**1. 링 찾기**
  + 링 찾기는 파란 가림막에 뚫려있는 구멍을 인식하는 첫 번째 단계입니다.
  + 드론은 실시간으로 카메라 영상을 처리하여 링을 찾습니다.
  + 링을 찾으면 링의 중심 좌표와 반경을 계산합니다.
  + 만약 링을 찾지 못하면 드론의 위치를 조정하여 다시 링을 찾도록 합니다.

**2. 링 중심 파악 및 드론 위치 조정**
  + 드론이 링 중심에 맞춰진 후 링 내에 있는 사각형을 찾습니다.
  + 드론은 카메라 영상을 분석하여 사각형을 찾고, 사각형의 중심 좌표를 계산합니다.
  + 사각형이 링 중심 내에 있는지 확인합니다.
  + 사각형이 링 중심 내에 있으면 드론은 다음 단계로 진행합니다.
    
**3. 사각형 찾기 & 링 중심 내에 사각형 중심이 있는지 확인**
  + 드론이 링 중심에 맞춰진 후 링 내에 있는 사각형을 찾습니다.
  + 드론은 카메라 영상을 처리하여 사각형을 찾고, 사각형의 중심 좌표를 계산합니다.
  + 사각형이 링 중심 내에 있는지 확인합니다.
  + 사각형이 링 중심 내에 있으면 드론은 다음 단계로 진행합니다.

**4. 링 통과**
  + 드론은 링을 통과하여 다음 경로로 이동합니다.
  + 드론이 링 중심에 맞춰지면 앞으로 이동하여 링을 통과합니다.
  + 드론은 링을 통과한 후 다음 목표를 찾기 위해 위치를 조정합니다.
    
**5. 색상표 감지**
  + 드론은 경로를 따라 이동하면서 특정 색상의 표식을 감지합니다.
  + 드론은 카메라 영상을 분석하여 지정된 색상의 표식을 찾습니다.
  + 색상표를 찾으면 드론은 해당 위치에서 다음 목표를 찾기 위해 회전합니다.
    
**6. 사각형과 드론 사이의 거리 측정 맟 이동**
  + 드론은 사각형과의 거리를 측정하고 적절한 위치로 이동합니다.
  + 드론은 카메라 영상을 분석하여 사각형의 중심과의 거리를 계산합니다.
  + 계산된 거리를 기반으로 드론은 사각형 중심으로 이동합니다.
  + 드론은 목표 위치에 도달하면 미션을 완수합니다.

V. 알고리즘 흐름도 
==================
<img src="https://github.com/yousukyoung/2024-Mini-Drone-Autonomous-Flight-Contest/assets/108873470/359bd0eb-3b63-4bb3-848b-581f62b38bb1" alt="im" width="400"/>

위 알고리즘 흐름도는 Tello 드론이 비행하면서 링과 색상표를 인식하고, 중심을 맞추며 목표 지점으로 이동하는 과정을 나타냅니다. 

**Stage Start**
  + 이 단계는 드론의 비행이 시작되는 지점입니다. 드론은 초기 설정과 이륙 준비를 완료합니다.
    
**링 탐지**
  + 드론은 카메라를 통해 링을 탐지합니다.
    + Y/N 조건
      + Y: 색상표를 성공적으로 탐지한 경우 다음 단계로 이동합니다.
      + N: 색상표를 탐지하지 못한 경우 드론의 위치를 조정하고 다시 색상표를 탐지 시도합니다.
        
**링 중심 확인**
  + 드론은 링의 중심을 맞춥니다.
    + Y/N 조건
      + Y: 링의 중심을 성공적으로 맞춘 경우 다음 단계로 이동합니다.
      + N: 중심을 맞추지 못한 경우 드론의 위치를 조정하고 다시 중심을 맞추는 시도를 합니다.
        
**링 내 색상표 확인**
  + 드론은 링 내에서 특정 색상표를 탐지합니다.
    + Y/N 조건
      + Y: 색상표를 성공적으로 탐지한 경우 다음 단계로 이동합니다.
      + N: 색상표를 탐지하지 못한 경우 드론의 위치를 조정하고 다시 색상표를 탐지 시도합니다.
        
**전진**
  + 드론은 링 내에서 특정 색상표를 탐지합니다.
    + Y/N 조건
      + 이 단계는 무조건 전진 후 다음 단계로 이동합니다.
        
**색상표 탐지**
  + 드론은 새로운 위치에서 색상표를 탐지합니다.
    + Y/N 조건
      + Y: 색상표를 성공적으로 탐지한 경우 다음 단계로 이동합니다.
      + N: 색상표를 탐지하지 못한 경우 드론의 위치를 조정하고 다시 색상표를 탐지 시도합니다.
        
**색상표 중심 및 거리 확인**
  + 드론은 색상표의 중심을 맞추고, 색상표와의 거리를 확인합니다.
    + Y/N 조건
      + Y: 중심을 맞추고 거리를 확인한 경우 스테이지를 완료합니다.
      + N: 중심을 맞추지 못한 경우 드론의 위치를 조정하고 다시 중심 맞추기를 시도합니다.

**Stage Finish**
  + 이 단계는 드론의 비행이 완료되는 지점입니다. 드론은 목표 지점에 도착하여 임무를 완수합니다.

VI. 소스 코드 설명
==================
메인 스크립트는 4단계 stage를 통해 드론이 링을 찾고, 링의 중심을 맞추고, 사각형을 찾고, 사각형의 중심을 맞추며 진행합니다. 각 stage 드론이 특정 행동을 수행하는 시퀀스를 가지고 있습니다.

### Pix2Meter(imRad)
반지름을 통해 픽셀 거리 비율을 계산합니다.
```matlab
function ratio = Pix2Meter(imRad)
    switch nStage
        case 1
            realRad = 0.57 / 2;
        case 2
            realRad = 0.46 / 2;
        case 3 
            realRad = 0.46 / 2;
        case 4
            realRad = 0.52 / 2;
    end
    ratio = realRad / imRad;
end
```

### Pix2Meter2(pixel)
한 변의 길이를 통해 픽셀 거리 비율을 계산합니다.
```matlab
function ratio = Pix2Meter2(pixel)
    ratio = 0.09 / pixel;
end
```

### movetoLocation(drone, x, y, d)
드론을 특정 거리만큼 움직입니다.
```matlab
function movetoLocation(drone, x, y, d)
   if abs(x) < 0.2 && abs(y) < 0.2 && abs(d) < 0.2
       disp({d, x, -y});
       disp('Do not move')
       land(drone);
   else
      disp({d, x, -y});
      move(drone, [d, x, y], 'Speed', 1)
   end
end
```

### movetoforward(drone, cam)
사각형과의 거리를 측정하고, 이동 거리를 설정하여 드론을 전진시킵니다.
```matlab
function movetoforward(drone, cam)
    [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam, 'red');
    focal_length = 925.0;
    actual_distance = (0.09 * focal_length) / rectangleHeight;
    fprintf('사각형의 중심으로부터의 실제 거리: %.5f m\n', actual_distance);
    switch nStage
        case 1
            target_distance = 0.5;
        case 2
            target_distance = 1.5;
        case 3
            target_distance = 1.75;
        case 4
            target_distance = 0.75;
        otherwise
            error('지원되지 않는 stage입니다.');    
    end
   if abs(actual_distance - target_distance) >= 0.2
       distance = actual_distance - target_distance;
       fprintf('%.5f m 만큼 전진합니다.', distance);
       movetoLocation(drone, 0, 0, distance);
   end
end
```

### turntoRing(drone, cam)
링을 찾기 위해 드론을 회전시킵니다.
```matlab
function turntoRing(drone, cam)
    mindist = 3000;
    switch nStage
        case 3
            step = 7;
        otherwise 
            step = 5;
    end
    for level = 1:step
        if level > 1
            turn(drone, deg2rad(5));
        end
        while true
            [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam);
            if is_ring
                break;
            end
        end
        imageCenter = [960/2, 720/2];
        distanceToCenter = norm(holeCenter - imageCenter);
        disp(['Level: ' num2str(level) ', Distance to Center: ' num2str(distanceToCenter)]);
        if distanceToCenter <= mindist
            mindist = distanceToCenter;
            minlevel = level;
        end
    end
    angle = (-1)*5*(step - minlevel);
    disp(['최적 각도 : ', num2str(angle), '. 회전합니다.']);
    pause;
    turn(drone, deg2rad(angle));
end
```
### move_ring_centered(drone, cam, ringCenter, ringRad)
링 중심을 맞추기 위한 함수입니다.
```matlab
function isCentered = move_ring_centered(drone, cam, ringCenter, ringRad)
    switch lower(nStage)
        case 1
            xOffset = 0.0;
            yOffset = 0.3;
            divide_Offset = 1;
            forward_dist = 3;
        case 2
            xOffset = -0.3;
            yOffset = 0.3;
            divide_Offset = 2;
            forward_dist = 3;
        case 3
            xOffset = -0.3;
            yOffset = 0.3;
            divide_Offset = 2;
            forward_dist = 2;
        case 4
            xOffset = 0.0;
            yOffset = 0.5;
            divide_Offset = 1;
            forward_dist = 3.5;
        otherwise
    end
    image = snapshot(cam);
    [rows, cols, ~] = size(image);
    imageCenter = [cols / 2, rows / 2];
    distanceToCenter = norm(ringCenter - imageCenter);
    distanceThreshold = min(cols, rows) * 0.12;
    isCentered = distanceToCenter <= distanceThreshold;
    disp(isCentered);
    if ~isCentered
        distance = ringCenter - imageCenter;
        ratio = Pix2Meter(ringRad);
        distance = ratio * distance;
        distance = distance / divide_Offset;
        distance(1) = distance(1) + xOffset;
        distance(2) = distance(2) + yOffset;
       if abs(distance(1)) < 0.2 && abs(distance(2)) < 0.2
           isCentered = true;
           disp('중심과 가깝습니다. 링 내에 사각형이 존재하는지 확인합니다.');
           is_rectangle = find_rectangle_in_ring(cam, ringCenter, ringRad);
           if is_rectangle
               disp('링 내에 사각형이 존재합니다.')
           else 
               disp('링 내에 사각형이 존재하지 않습니다.')
           end
           disp('중심과 가깝습니다. 전진합니다.');
           moveforward(drone, 'Distance', forward_dist, 'Speed', 1);
       else 
           disp('중심이 아닙니다. 중심으로 위치합니다.')
           movetoLocation(drone, distance(1), distance(2), 0);
       end
    else
        disp('중심입니다. 링 내에 사각형이 존재하는지 확인합니다.')
        is_rectangle = find_rectangle_in_ring(cam, holeCenter, holeRad);
        if is_rectangle
           disp('링 내에 사각형이 존재합니다.')
        else 
           disp('링 내에 사각형이 존재하지 않습니다.')
        end
        disp('중심입니다. 전진합니다.')
        moveforward(drone, 'Distance', forward_dist, 'Speed', 1);
    end
end
```

### find_hole_center(drone, cam)
링을 찾기 위한 함수입니다.
```matlab
function [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam)
    image = snapshot(cam);
    hsvImage = rgb2hsv(image);
    blueThreshLow = [0.5, 0.4, 0.2];
    blueThreshHigh = [0.7, 1.0, 1.0];
    blueMask = (hsvImage(:,:,1) >= blueThreshLow(1)) & (hsvImage(:,:,1) <= blueThreshHigh(1)) & ...
               (hsvImage(:,:,2) >= blueThreshLow(2)) & (hsvImage(:,:,2) <= blueThreshHigh(2)) & ...
               (hsvImage(:,:,3) >= blueThreshLow(3)) & (hsvImage(:,:,3) <= blueThreshHigh(3));
    blueMask = imopen(blueMask, strel('disk', 5));
    blueMask = imclose(blueMask, strel('disk', 15));
    invertedMask = ~blueMask;
    invertedMask = imerode(invertedMask, strel('disk', 5));
    invertedMask = imdilate(invertedMask, strel('disk', 5));
    [centers, radii, metric] = imfindcircles(invertedMask, [40 1000], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92);
    if ~isempty(centers)
        is_ring = true;
        [~, idx] = max(radii .* metric);
        holeCenter = centers(idx, :);
        holeRad = radii(idx);
        disp('링을 찾았습니다.')
    else
        is_ring = false;
        holeCenter = [NaN, NaN];
        holeRad = NaN;
        warning('파란 천막에 뚫린 원이 감지되지 않았습니다.');
        d = 0;
        x = 0;
        y = 0;
        bluePixelCount = sum(blueMask(:));
        totalPixels = numel(blueMask);
        blueRatio = bluePixelCount / totalPixels;
        disp(['파란색 영역의 비율: ', num2str(blueRatio * 100), '%']);
        if (blueRatio >= 50 || blueRatio == 0)
            d = -0.2;
        else 
            [y_coords, x_coords] = find(blueMask);
            imageSize = size(blueMask);
            imageWidth = imageSize(2);
            imageHeight = imageSize(1);
            if ~isempty(x_coords) && !isempty(y_coords)
                blue_center_x = mean(x_coords);
                blue_center_y = mean(y_coords);
                if (blue_center_y >= imageHeight*2/5) && (blue_center_y <= imageHeight*3/5) && (blue_center_x >= imageWidth*2/5) && (blue_center_x <= imageWidth*3/5)
                    fprintf('너무 근접합니다. 뒤로 물러섭니다.')
                    d = -0.2;
                end
                if blue_center_y < imageHeight*2/5
                    fprintf('파란색 영역이 상단에 있습니다.\n');
                    y = -0.2;
                elseif blue_center_y > imageHeight*3/5
                    fprintf('파란색 영역이 하단에 있습니다.\n');
                    y = 0.2;
                end
                if blue_center_x < imageWidth*2/5
                    fprintf('파란색 영역이 좌측에 있습니다.\n');
                    x = -0.3;
                elseif blue_center_x > imageWidth*3/5
                    fprintf('파란색 영역이 우측에 있습니다.\n');
                    x = 0.3;
                end
            end
        end
        disp('링을 감지하지 못하여, 이동합니다.')
        movetoLocation(drone, x, y, d)
    end
    imshow(image);
    hold on;
    if !isnan(holeCenter(1))
        viscircles(holeCenter, radii(idx), 'EdgeColor', 'b');
        plot(holeCenter(1), holeCenter(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    end
end
```

### find_rectangle_in_ring(cam, ringCenter, ringRad)
링 내에서 사각형을 찾는 함수입니다.
```matlab
function is_rectangle = find_rectangle_in_ring(cam, ringCenter, ringRad)
    is_rectangle = false;
    image = snapshot(cam);
    hsvImage = rgb2hsv(image);
    switch nStage
        case 1
            colorThreshLow1 = [0, 0.4, 0.2];
            colorThreshHigh1 = [0.1, 1.0, 1.0];
            colorThreshLow2 = [0.9, 0.4, 0.2];
            colorThreshHigh2 = [1.0, 1.0, 1.0];
        case 2
            colorThreshLow1 = [0.3, 0.4, 0.2];
            colorThreshHigh1 = [0.5, 1.0, 1.0];
            colorThreshLow2 = [];
            colorThreshHigh2 = [];
        case 3
            colorThreshLow1 = [0.7, 0.4, 0.2];
            colorThreshHigh1 = [0.9, 1.0, 1.0];
            colorThreshLow2 = [];
            colorThreshHigh2 = [];
        case 4
            colorThreshLow1 = [0, 0.4, 0.2];
            colorThreshHigh1 = [0.1, 1.0, 1.0];
            colorThreshLow2 = [0.9, 0.4, 0.2];
            colorThreshHigh2 = [1.0, 1.0, 1.0];
        otherwise
            error('지원되지 않는 색깔입니다.');
    end
    colorMask1 = (hsvImage(:,:,1) >= colorThreshLow1(1)) & (hsvImage(:,:,1) <= colorThreshHigh1(1)) & ...
                (hsvImage(:,:,2) >= colorThreshLow1(2)) & (hsvImage(:,:,2) <= colorThreshHigh1(2)) & ...
                (hsvImage(:,:,3) >= colorThreshLow1(3)) & (hsvImage(:,:,3) <= colorThreshHigh1(3));
    if ~isempty(colorThreshLow2) && ~isempty(colorThreshHigh2)
        colorMask2 = (hsvImage(:,:,1) >= colorThreshLow2(1)) & (hsvImage(:,:,1) <= colorThreshHigh2(1)) & ...
                    (hsvImage(:,:,2) >= colorThreshLow2(2)) & (hsvImage(:,:,2) <= colorThreshHigh2(2)) & ...
                    (hsvImage(:,:,3) >= colorThreshLow2(3)) & (hsvImage(:,:,3) <= colorThreshHigh2(3));
        colorMask = colorMask1 | colorMask2;
    else
        colorMask = colorMask1;
    end
    colorMask = imopen(colorMask, strel('disk', 5));
    colorMask = imclose(colorMask, strel('disk', 15));
    rectangleCoords = [];
    rectangleCenter = [];
    [rows, cols, ~] = size(image);
    [X, Y] = meshgrid(1:cols, 1:rows);
    ringMask = sqrt((X - ringCenter(1)).^2 + (Y - ringCenter(2)).^2) <= ringRad;
    stats = regionprops(colorMask & ringMask, 'BoundingBox', 'Centroid');
    numRectangles = numel(stats);
    if numRectangles > 0
        is_rectangle = true;
        maxArea = 0;
        for i = 1:numRectangles
            area = stats(i).BoundingBox(3) * stats(i).BoundingBox(4);
            if area > maxArea
                maxArea = area;
                rectangleCoords = stats(i).BoundingBox;
                rectangleCenter = stats(i).Centroid;
            end
        end
    else
        is_rectangle = false;
        warning('링 내에서 원하는 색깔의 사각형을 찾지 못했습니다.');
    end
    if ~isempty(rectangleCoords)
        figure;
        imshow(image);
        hold on;
        rectangle('Position', rectangleCoords, 'EdgeColor', 'r', 'LineWidth', 2);
        plot(rectangleCenter(1), rectangleCenter(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        title(['Stage ', num2str(nStage), '에서 찾은 사각형']);
        hold off;
    end
end
```

### move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight)
사각형 중심을 맞추기 위한 함수입니다.
```matlab
function isCentered = move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight)
    image = snapshot(cam);
    [rows, cols, ~] = size(image);
    imageCenter = [cols / 2, rows / 2];
    distanceToCenter = norm(rectangleCenter - imageCenter);
    distanceThreshold = min(cols, rows) * 0.05;
    isCentered = distanceToCenter <= distanceThreshold;
    disp(isCentered);
    if ~isCentered
        distance = rectangleCenter - imageCenter;
        ratio = Pix2Meter2(rectangleHeight);
        distance = ratio * distance;
       if abs(distance(1)) < 0.2 && abs(distance(2) + 0.3) < 0.2
           isCentered = true;
           disp('중심과 가깝습니다. 거리를 계산합니다.');
           movetoforward(drone, cam)
       else 
           disp('중심이 아닙니다. 중심으로 위치합니다.')
           movetoLocation(drone, distance(1), distance(2) + 0.3, 0);
       end
    else
        disp('중심입니다. 거리를 계산합니다.')
        movetoforward(drone, cam)
    end
end
```

### is_rectangle_centered_in_ring(ringCenter, ringRad, rectangleCenter)
사각형이 링 중심에 위치하는지 확인합니다.
```matlab
function isCentered = is_rectangle_centered_in_ring(ringCenter, ringRad, rectangleCenter)
    smallRad = ringRad * 0.5;
    isCentered = norm(ringCenter - rectangleCenter) <= smallRad;
    if isCentered
        disp('사각형이 중심에 존재합니다.')
    else
        disp('사각형이 중심에 있지 않습니다.')
    end
end
```

### find_rectangle(cam)
사각형을 찾는 함수입니다.
```matlab
function [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam)
    image = snapshot(cam);
    hsvImage = rgb2hsv(image);
    switch lower(nStage)
        case 1
            colorThreshLow1 = [0, 0.4, 0.2];
            colorThreshHigh1 = [0.1, 1.0, 1.0];
            colorThreshLow2 = [0.9, 0.4, 0.2];
            colorThreshHigh2 = [1.0, 1.0, 1.0];
        case 2
            colorThreshLow1 = [0.3, 0.4, 0.2];
            colorThreshHigh1 = [0.5, 1.0, 1.0];
            colorThreshLow2 = [];
            colorThreshHigh2 = [];
        case 3
            colorThreshLow1 = [0.7, 0.4, 0.2];
            colorThreshHigh1 = [0.9, 1.0, 1.0];
            colorThreshLow2 = [];
            colorThreshHigh2 = [];
        case 4
            colorThreshLow1 = [0, 0.4, 0.2];
            colorThreshHigh1 = [0.1, 1.0, 1.0];
            colorThreshLow2 = [0.9, 0.4, 0.2];
            colorThreshHigh2 = [1.0, 1.0, 1.0];
        otherwise
            error('지원되지 않는 색깔입니다.');
    end
    colorMask1 = (hsvImage(:,:,1) >= colorThreshLow1(1)) & (hsvImage(:,:,1) <= colorThreshHigh1(1)) & ...
                (hsvImage(:,:,2) >= colorThreshLow1(2)) & (hsvImage(:,:,2) <= colorThreshHigh1(2)) & ...
                (hsvImage(:,:,3) >= colorThreshLow1(3)) & (hsvImage(:,:,3) <= colorThreshHigh1(3));
    if ~isempty(colorThreshLow2) && ~isempty(colorThreshHigh2)
        colorMask2 = (hsvImage(:,:,1) >= colorThreshLow2(1)) & (hsvImage(:,:,1) <= colorThreshHigh2(1)) & ...
                    (hsvImage(:,:,2) >= colorThreshLow2(2)) & (hsvImage(:,:,2) <= colorThreshHigh2(2)) & ...
                    (hsvImage(:,:,3) >= colorThreshLow2(3)) & (hsvImage(:,:,3) <= colorThreshHigh2(3));
        colorMask = colorMask1 | colorMask2;
    else
        colorMask = colorMask1;
    end
    colorMask = imopen(colorMask, strel('disk', 5));
    colorMask = imclose(colorMask, strel('disk', 15));
    imshow(colorMask)
    rectangleCoords = [];
    rectangleCenter = [];
    rectangleSize = [];
    stats = regionprops(colorMask, 'BoundingBox', 'Centroid');
    numRectangles = numel(stats);
    if numRectangles > 0
        maxArea = 0;
        for i = 1:numRectangles
            area = stats(i).BoundingBox(3) * stats(i).BoundingBox(4);
            if area > maxArea
                maxArea = area;
                rectangleCoords = stats(i).BoundingBox;
                rectangleCenter = stats(i).Centroid;
                rectangleSize = [stats(i).BoundingBox(3), stats(i).BoundingBox(4)];
                rectangleHeight = mean(rectangleSize);
            end
        end
    else
        warning('사각형이 이미지에서 찾지 못했습니다.');
    end
    if ~isempty(rectangleCoords)
        is_rectangle = true;
        figure;
        imshow(image);
        hold on;
        rectangle('Position', rectangleCoords, 'EdgeColor', 'r', 'LineWidth', 2);
        plot(rectangleCenter(1), rectangleCenter(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        title(['Stage ', num2str(nStage), '에서 찾은 사각형']);
        hold off;
    else
        is_rectangle = false;
    end
end
```
