% 은수 좋은날 결승 코드

clear;

global nStage;

drone = ryze();
cam = camera(drone);
%preview(drone)


takeoff(drone);


%% Stage 1
nStage = 1;

nFail = 0;
while true

    % 링 찾기
    [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam);

    % 링 찾았으면
    if is_ring

        % 링 중심 맞추기
        is_ring_centered = move_ring_centered(drone, cam, holeCenter, holeRad);

        % 전진까지 했으면
        if is_ring_centered     
            break;

        else
            nFail = nFail + 1;
            if nFail >= 7
                break;
            end
        end

    else
        nFail = nFail + 1;
        if nFail >= 7
            break;
        end
    end        
end

nFail = 0;
while true
     % 사각형 찾기
    [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam);

    % 사각형 찾았으면
    if is_rectangle

       % 사각형 중심 맞추기
       is_rectangle_centered = move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight);

       if is_rectangle_centered
           break;
       else
           nFail = nFail + 1;
           if nFail >= 7
               break;
           end
       end

    else
       nFail = nFail + 1;
       if nFail >= 7
           break;
       end
    end
end


turn(drone, deg2rad(120))

%% Stage 2
nStage = 2;

turntoRing(drone, cam);

nFail = 0;
while true

    % 링 찾기
    [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam);

    % 링 찾았으면
    if is_ring

        is_ring_centered = move_ring_centered(drone, cam, holeCenter, holeRad);

        % 전진까지 했으면
        if is_ring_centered     
            break;

        else
            nFail = nFail + 1;
            if nFail >= 7
                break;
            end
        end

    else
        nFail = nFail + 1;
        if nFail >= 7
            break;
        end
    end        
end

nFail = 0;
while true
     % 사각형 찾기
    [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam);

    % 사각형 찾았으면
    if is_rectangle

       % 사각형 중심 맞추기
       is_rectangle_centered = move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight);

       if is_rectangle_centered
           break;
       else
           nFail = nFail + 1;
           if nFail >= 7
               break;
           end
       end

    else
       nFail = nFail + 1;
       if nFail >= 7
           break;
       end
    end
end

turn(drone, deg2rad(-140));

%% Stage 3
nStage = 3;

turntoRing(drone, cam);

nFail = 0;
while true

    % 링 찾기
    [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam);

    % 링 찾았으면
    if is_ring

        is_ring_centered = move_ring_centered(drone, cam, holeCenter, holeRad);

        % 전진까지 했으면
        if is_ring_centered     
            break;

        else
            nFail = nFail + 1;
            if nFail >= 7
                break;
            end
        end

    else
        nFail = nFail + 1;
        if nFail >= 7
            break;
        end
    end        
end

while true
     % 사각형 찾기
    [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam);

    % 사각형 찾았으면
    if is_rectangle

       % 사각형 중심 맞추기
       is_rectangle_centered = move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight);

       if is_rectangle_centered
           break;
       else
           nFail = nFail + 1;
           if nFail >= 7
               break;
           end
       end

    else
       nFail = nFail + 1;
       if nFail >= 7
           break;
       end
    end
end

turn(drone, deg2rad(200));

%% Stage 4
nStage = 4;

turntoRing(drone, cam);

nFail = 0;

% 링 중심 맞추기
while true

    % 링 찾기
    [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam);

    % 링 찾았으면
    if is_ring

        is_ring_centered = move_ring_centered(drone, cam, holeCenter, holeRad);

        % 전진까지 했으면
        if is_ring_centered     
            break;

        else
            nFail = nFail + 1;
            if nFail >= 7
                break;
            end
        end

    else
        nFail = nFail + 1;
        if nFail >= 7
            break;
        end
    end        
end

nFail = 0;
% 사각형 중심 맞추기
while true
     % 사각형 찾기
    [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam);

    % 사각형 찾았으면
    if is_rectangle

       % 사각형 중심 맞추기
       is_rectangle_centered = move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight);

       if is_rectangle_centered
           break;
       else
           nFail = nFail + 1;
           if nFail >= 7
               break;
           end
       end

    else
       nFail = nFail + 1;
       if nFail >= 7
           break;
       end
    end
end

land(drone);
disp('finish')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 함수
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 반지름으로 픽셀 거리 계산
function ratio = Pix2Meter(imRad)
    global nStage;

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

%% 한 변의 길이로 픽셀 거리 계산
function ratio = Pix2Meter2(pixel)

    ratio = 0.09 / pixel;
end

%% 특정 거리만큼 움직임
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

%% 사각형과의 거리
function movetoforward(drone, cam)
    global nStage
    [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam);

    % 초점 거리
    focal_length = 925.0;

    % 실제 거리 계산 (m 단위)
    actual_distance = (0.09 * focal_length) / rectangleHeight;
    fprintf('사각형의 중심으로부터의 실제 거리: %.5f m\n', actual_distance);

    % nStage에 따른 이동 거리 설정
    switch nStage
        case 1
            target_distance = 0.5;
        case 2
            target_distance = 1.0;
        case 3
            target_distance = 1.25;
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

%% 링 중심으로 회전
function turntoRing(drone, cam)
    
    global nStage
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
        
        % 이미지의 중심 좌표 계산
        imageCenter = [960/2, 720/2]; % 이미지 중심 좌표 (x, y)
    
        % 링 중심점과 이미지 중심점 간의 거리 계산
        distanceToCenter = norm(holeCenter - imageCenter);
    
         % 각 단계별 distanceToCenter 출력
        disp(['Level: ' num2str(level) ', Distance to Center: ' num2str(distanceToCenter)]);
    
        if distanceToCenter <= mindist
            mindist = distanceToCenter;
            minlevel = level;
        end
    end
    
    angle = (-1)*5*(step - minlevel);
    
    disp(['최적 각도 : ', num2str(angle), '. 회전합니다.']);
    turn(drone, deg2rad(angle));
end



%% 링 중심 확인
function isCentered = move_ring_centered(drone, cam, ringCenter, ringRad)

    global nStage
    % 고친 부분
    switch nStage
        case 1
            xOffset = 0.0;
            yOffset = 0.5;
            divide_Offset = 1.0;
            forward_dist = 3.0;

        case 2

            xOffset = 0.0;
            yOffset = 0.3;
            divide_Offset = 2.0;
            forward_dist = 4.0;

        case 3
            xOffset = 0.0;
            yOffset = 0.3;
            divide_Offset = 2.0;
            forward_dist = 2.0;

        
        case 4
            xOffset = 0.0;
            yOffset = 0.3;
            divide_Offset = 1.0;
            forward_dist = 3.7;
            
        otherwise


    end

    
    image = snapshot(cam);
    
    % 이미지의 중심 좌표 계산
    [rows, cols, ~] = size(image);
    imageCenter = [cols / 2, rows / 2]; % 이미지 중심 좌표 (x, y)

    % 링 중심점과 이미지 중심점 간의 거리 계산
    distanceToCenter = norm(ringCenter - imageCenter);

    % 거리 임계값 설정 (예: 이미지 너비 또는 높이의 20% 이내로 설정)
    distanceThreshold = min(cols, rows) * 0.1;

    % 링 중심점이 이미지 중심 영역에 포함되는지 여부 판별
    isCentered = distanceToCenter <= distanceThreshold;
    disp(isCentered);

    if ~isCentered
        distance = ringCenter - imageCenter;
        ratio = Pix2Meter(ringRad);
        distance = ratio * distance;
        
        % 고친 부분
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
           movetoLocation(drone, distance(1), distance(2), 0); % distance(2) + 0.2
       end

    else
        disp('중심입니다. 링 내에 사각형이 존재하는지 확인합니다.')
        is_rectangle = find_rectangle_in_ring(cam, ringCenter, ringRad);

        if is_rectangle
           disp('링 내에 사각형이 존재합니다.')
        else 
           disp('링 내에 사각형이 존재하지 않습니다.')
        end

        disp('중심입니다. 전진합니다.')
        moveforward(drone, 'Distance', forward_dist, 'Speed', 1);
        
    end


end



%% 링 탐색
function [holeCenter, holeRad, is_ring] = find_hole_center(drone, cam)

    image = snapshot(cam);
    %image = imread('test.jpg');

    %%find_blue -> 천막을 찾지 못했을 때의 예외처리 해야할까?

    % 이미지 전처리 (파란색 천막 찾기)
    hsvImage = rgb2hsv(image);

    % 파란색 범위 설정 (필요 시 조정)
    blueThreshLow = [0.5, 0.4, 0.2]; % 파란색의 낮은 임계값 [색상, 채도, 명도]
    blueThreshHigh = [0.7, 1.0, 1.0]; % 파란색의 높은 임계값 [색상, 채도, 명도]

    % 파란색 영역에 대한 이진 마스크 생성
    blueMask = (hsvImage(:,:,1) >= blueThreshLow(1)) & (hsvImage(:,:,1) <= blueThreshHigh(1)) & ...
               (hsvImage(:,:,2) >= blueThreshLow(2)) & (hsvImage(:,:,2) <= blueThreshHigh(2)) & ...
               (hsvImage(:,:,3) >= blueThreshLow(3)) & (hsvImage(:,:,3) <= blueThreshHigh(3));
 
    % 노이즈 제거
    blueMask = imopen(blueMask, strel('disk', 5));
    blueMask = imclose(blueMask, strel('disk', 15));

    % imshow(blueMask)
    % close(gcf); % 현재 figure 창을 닫음

    % 반전된 이미지에서 Hough Transform을 이용한 원 찾기
    invertedMask = ~blueMask;
    
    % 원 검출을 위해 추가적인 전처리
    invertedMask = imerode(invertedMask, strel('disk', 5));
    invertedMask = imdilate(invertedMask, strel('disk', 5));

    % Hough Transform 파라미터 조정
    [centers, radii, metric] = imfindcircles(invertedMask, [40 1000], 'ObjectPolarity', 'bright', 'Sensitivity', 0.92);
    

    if ~isempty(centers)
        is_ring = true;
        
        % 가장 큰 원 선택 (필요 시 조건 조정)
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

        % case 분류를 위해 파란 영역 비율 구하기

        % 이진 마스크에서 파란색 영역의 픽셀 개수 세기
        bluePixelCount = sum(blueMask(:));

        % 전체 이미지의 픽셀 수 계산
        totalPixels = numel(blueMask);
        
        % 파란색 영역의 비율 계산
        blueRatio = bluePixelCount / totalPixels;
        
        % 결과 출력
        disp(['파란색 영역의 비율: ', num2str(blueRatio * 100), '%']);
        

        % case1 & case2
        if (blueRatio >= 50 || blueRatio == 0) % 너무 가까이 있어서 천막 많이 보일 때 / 아예 안보일 때
            d = -0.2;
        
        % case 3 
        else 

            [y_coords, x_coords] = find(blueMask);
    
            % 이미지 크기 가져오기
            imageSize = size(blueMask)
            imageWidth = imageSize(2);
            imageHeight = imageSize(1);
            
            % 파란색 영역의 중심 좌표 계산
            if ~isempty(x_coords) && ~isempty(y_coords)
                blue_center_x = mean(x_coords);
                blue_center_y = mean(y_coords);
    
                % 파란색 영역 중심에 따른 드론 이동
                if (blue_center_y >= imageHeight*2/5) && (blue_center_y <= imageHeight*3/5) && (blue_center_x >= imageWidth*2/5) && (blue_center_x <= imageWidth*3/5)
                    % 링 가까이에 있으면서 중앙에 있을 때
                    fprintf('너무 근접합니다. 뒤로 물러섭니다.')
                    d = -0.2; % 뒤로
                end

                if blue_center_y < imageHeight*2/5
                    % 파란색 영역이 이미지의 상단에 위치할 때
                    fprintf('파란색 영역이 상단에 있습니다.\n');
                    y = -0.2; 
    
      
                elseif blue_center_y > imageHeight*3/5
                    % 파란색 영역이 이미지의 하단에 위치할 때
                    fprintf('파란색 영역이 하단에 있습니다.\n');
                    y = 0.2;
    
                end
            
                if blue_center_x < imageWidth*2/5
                    % 파란색 영역이 이미지의 좌측에 위치할 때
                    fprintf('파란색 영역이 좌측에 있습니다.\n');
                    x = -0.3;
    
                    
                elseif blue_center_x > imageWidth*3/5
                    % 파란색 영역이 이미지의 우측에 위치할 때
                    fprintf('파란색 영역이 우측에 있습니다.\n');
                    x = 0.3;
                    
                end
            end
        end
        disp('링을 감지하지 못하여, 이동합니다.')
        movetoLocation(drone, x, y, d)
    end

    % 이미지에 중심 표시
    imshow(image);
    hold on;
    if ~isnan(holeCenter(1))
        viscircles(holeCenter, radii(idx), 'EdgeColor', 'b');
        plot(holeCenter(1), holeCenter(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    end

    % 중점 좌표 출력
    % disp(['원 중심: (', num2str(holeCenter(1)), ', ', num2str(holeCenter(2)), ')']);
end

%% 링 내에 존재하는 사각형 찾기 (수경 완료)
function is_rectangle = find_rectangle_in_ring(cam, ringCenter, ringRad)
    global nStage
    is_rectangle = false;
    image = snapshot(cam);

    % 이미지 전처리 (색 공간 변환)
    hsvImage = rgb2hsv(image);

    % 각 색깔의 임계값 설정
    switch nStage
        case 1 % red
            colorThreshLow1 = [0, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.1, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [0.9, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh2 = [1.0, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도]
        case 2 % green
            colorThreshLow1 = [0.3, 0.4, 0.2]; % 초록색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.5, 1.0, 1.0]; % 초록색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [];
            colorThreshHigh2 = [];
        case 3 % purple
            colorThreshLow1 = [0.7, 0.4, 0.2]; % 보라색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.9, 1.0, 1.0]; % 보라색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [];
            colorThreshHigh2 = []; 
        case 4 % red
            colorThreshLow1 = [0, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.1, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [0.9, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh2 = [1.0, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도] 
        otherwise
            error('지원되지 않는 색깔입니다.');
    end
    
   
    % 색깔 영역에 대한 이진 마스크 생성
    colorMask1 = (hsvImage(:,:,1) >= colorThreshLow1(1)) & (hsvImage(:,:,1) <= colorThreshHigh1(1)) & ...
                (hsvImage(:,:,2) >= colorThreshLow1(2)) & (hsvImage(:,:,2) <= colorThreshHigh1(2)) & ...
                (hsvImage(:,:,3) >= colorThreshLow1(3)) & (hsvImage(:,:,3) <= colorThreshHigh1(3));
    
    if ~isempty(colorThreshLow2) && ~isempty(colorThreshHigh2)
        colorMask2 = (hsvImage(:,:,1) >= colorThreshLow2(1)) & (hsvImage(:,:,1) <= colorThreshHigh2(1)) & ...
                    (hsvImage(:,:,2) >= colorThreshLow2(2)) & (hsvImage(:,:,2) <= colorThreshHigh2(2)) & ...
                    (hsvImage(:,:,3) >= colorThreshLow2(3)) & (hsvImage(:,:,3) <= colorThreshHigh2(3));
        colorMask = colorMask1 | colorMask2; % 두 마스크 결합
    else
        colorMask = colorMask1;
    end

    % 노이즈 제거
    colorMask = imopen(colorMask, strel('disk', 5));
    colorMask = imclose(colorMask, strel('disk', 15));

    % 사각형 좌표와 중심점 초기화
    rectangleCoords = [];
    rectangleCenter = [];

    % 링 영역 생성
    [rows, cols, ~] = size(image);
    [X, Y] = meshgrid(1:cols, 1:rows);
    ringMask = sqrt((X - ringCenter(1)).^2 + (Y - ringCenter(2)).^2) <= ringRad;

    % 사각형 찾기 (bounding box 사용)
    stats = regionprops(colorMask & ringMask, 'BoundingBox', 'Centroid');
    numRectangles = numel(stats);
    
    if numRectangles > 0

        is_rectangle = true;

        % 가장 큰 사각형 선택 (필요 시 조건 조정)
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
        % 사각형이 없는 경우 처리
        warning('링 내에서 원하는 색깔의 사각형을 찾지 못했습니다.');
    end

     % 이미지에 사각형 그리기 (테스트용)
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

%% 사각형 중심 탐색
function isCentered = move_rectangle_centered(drone, cam, rectangleCenter, rectangleHeight)
        
        
        image = snapshot(cam);
    
        % 이미지의 중심 좌표 계산
        [rows, cols, ~] = size(image);
        imageCenter = [cols / 2, rows / 2]; % 이미지 중심 좌표 (x, y)
    
        % 링 중심점과 이미지 중심점 간의 거리 계산
        distanceToCenter = norm(rectangleCenter - imageCenter);
    
        % 거리 임계값 설정 (예: 이미지 너비 또는 높이의 20% 이내로 설정)
        distanceThreshold = min(cols, rows) * 0.05;
    
        % 링 중심점이 이미지 중심 영역에 포함되는지 여부 판별
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
               movetoLocation(drone, distance(1), distance(2) + 0.3, 0); % distance(2) + 0.2
           end
        
        else
          
            disp('중심입니다. 거리를 계산합니다.')
            movetoforward(drone, cam)            
        end
end

%% 사각형이 링 중심에 위치하는지 확인(완성)
function isCentered = is_rectangle_centered_in_ring(ringCenter, ringRad, rectangleCenter)
    % 링 중심 내에 사각형 중심이 있는지 확인 (임의의 작은 반지름 사용)
    smallRad = ringRad * 0.5; % 작은 반지름 설정 (필요시 조정)
    
    % 사각형 중심이 작은 반지름 내에 있는지 확인
    isCentered = norm(ringCenter - rectangleCenter) <= smallRad;

    if isCentered
        disp('사각형이 중심에 존재합니다.')
    else
        disp('사각형이 중심에 있지 않습니다.')
    end

end


%% 사각형 탐색 (완성형)
function [rectangleCenter, rectangleHeight, is_rectangle] = find_rectangle(cam)
    global nStage

    image = snapshot(cam);
    
    % 이미지 전처리 (색 공간 변환)
    hsvImage = rgb2hsv(image);

    % 각 색깔의 임계값 설정
    switch nStage
        case 1 % red
            colorThreshLow1 = [0, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.1, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [0.9, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh2 = [1.0, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도]
        case 2 % green
            colorThreshLow1 = [0.3, 0.4, 0.2]; % 초록색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.5, 1.0, 1.0]; % 초록색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [];
            colorThreshHigh2 = [];
        case 3 % purple
            colorThreshLow1 = [0.7, 0.4, 0.2]; % 보라색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.9, 1.0, 1.0]; % 보라색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [];
            colorThreshHigh2 = []; 
        case 4 % red
            colorThreshLow1 = [0, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh1 = [0.1, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도]
            colorThreshLow2 = [0.9, 0.4, 0.2]; % 빨간색의 낮은 임계값 [색상, 채도, 명도]
            colorThreshHigh2 = [1.0, 1.0, 1.0]; % 빨간색의 높은 임계값 [색상, 채도, 명도] 
        otherwise
            error('지원되지 않는 색깔입니다.');
    end
    
  
    % 색깔 영역에 대한 이진 마스크 생성
    colorMask1 = (hsvImage(:,:,1) >= colorThreshLow1(1)) & (hsvImage(:,:,1) <= colorThreshHigh1(1)) & ...
                (hsvImage(:,:,2) >= colorThreshLow1(2)) & (hsvImage(:,:,2) <= colorThreshHigh1(2)) & ...
                (hsvImage(:,:,3) >= colorThreshLow1(3)) & (hsvImage(:,:,3) <= colorThreshHigh1(3));

    if ~isempty(colorThreshLow2) && ~isempty(colorThreshHigh2)
        colorMask2 = (hsvImage(:,:,1) >= colorThreshLow2(1)) & (hsvImage(:,:,1) <= colorThreshHigh2(1)) & ...
                    (hsvImage(:,:,2) >= colorThreshLow2(2)) & (hsvImage(:,:,2) <= colorThreshHigh2(2)) & ...
                    (hsvImage(:,:,3) >= colorThreshLow2(3)) & (hsvImage(:,:,3) <= colorThreshHigh2(3));
        colorMask = colorMask1 | colorMask2; % 두 마스크 결합
    else
        colorMask = colorMask1;
    end

    % 노이즈 제거
    colorMask = imopen(colorMask, strel('disk', 5));
    colorMask = imclose(colorMask, strel('disk', 15));

    imshow(colorMask)

    % 사각형 좌표와 중심점 초기화
    rectangleCoords = [];
    rectangleCenter = [];
    rectangleSize = [];

    % 사각형 찾기 (bounding box 사용)
    stats = regionprops(colorMask, 'BoundingBox', 'Centroid');
    numRectangles = numel(stats);

    if numRectangles > 0
        % 가장 큰 사각형 선택 (필요 시 조건 조정)
        maxArea = 0;
        for i = 1:numRectangles
            area = stats(i).BoundingBox(3) * stats(i).BoundingBox(4);
            if area > maxArea
                maxArea = area;
                rectangleCoords = stats(i).BoundingBox;
                rectangleCenter = stats(i).Centroid;
                rectangleSize = [stats(i).BoundingBox(3), stats(i).BoundingBox(4)];
                % 사각형의 한 변의 픽셀 거리 (Bounding Box의 너비와 높이의 평균 사용)
                rectangleHeight = mean(rectangleSize);
            end
        end
    else
        % 사각형이 없는 경우 처리
        warning('사각형이 이미지에서 찾지 못했습니다.');
    end

    % 이미지에 사각형 그리기 (테스트용)
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
