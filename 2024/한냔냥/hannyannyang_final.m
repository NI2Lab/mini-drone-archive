% 초기화
clear;
clc;

% 드론 및 카메라 초기화
drone = ryze();
cam = camera(drone);

% 드론 이륙
takeoff(drone);
moveup(drone,'distance',0.3,'Speed',0.5);

step = 1;

% 중심점과 이동해야 할 거리를 계산하는 함수
[offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
length = diameters; 

% 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
movedrone(drone, offsetX, offsetY, length, step);
   
% 카메라와 도형이 중심을 맞췄다면 드론 직진
moveforward(drone,'distance',2.2,'Speed',0.8);

% 빨간색을 마주하면 130도 회전하는 코드
DetectionRed(drone,cam,step);

% step2
step = step + 1;

moveup(drone,'distance',0.3,'Speed',0.8);

moveforward(drone,'distance',3,'Speed',0.8);

turn(drone,deg2rad(-20));

% 120~140도 중 최적의 각도 검색
findbestangle(drone,cam,step);

while 1
    % 중심점과 이동해야 할 거리를 계산하는 함수
    [offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
    length = diameters; 

    % 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
    centerfind = movedrone(drone, offsetX, offsetY, length, step);
    if centerfind
        disp('find center!');
        break;
    else 
        disp('not find center!');
    end   
end

% 초록색 검출 코드
DetectionGreen(drone,cam);

%step3
step = step + 1;

moveup(drone,'distance',0.3,'Speed',0.8);

% -120~-140도 중 최적의 각도 검색
findbestangle(drone,cam,step);

moveforward(drone,'distance',0.5,'Speed',0.8);

while 1
    % 중심점과 이동해야 할 거리를 계산하는 함수
    [offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
    length = diameters; 

    % 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
    centerfind = movedrone(drone, offsetX, offsetY, length, step);
    if centerfind
        disp('find center!');
        break;
    else 
        disp('not find center!');
    end   
end

moveforward(drone,'distance',1,'Speed',0.8);

DetectionPurple(drone,cam);

%step 4
step = step + 1;

moveforward(drone,'distance',1,'Speed',0.7);

moveup(drone,'distance',0.3,'Speed',0.8);

turn(drone,deg2rad(-15));

findbestangle(drone,cam,step);

count = 0;

while 1

    if count > 3
        moveback(drone,'Distance',0.3);
        count = 0;
    end

    % 중심점과 이동해야 할 거리를 계산하는 함수
    [offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
    length = diameters; 

    % 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
    centerfind = movedrone(drone, offsetX, offsetY, length, step);
    if centerfind
        disp('find center!');
        break;
    else 
        disp('not find center!');
    end   
    count = count + 1;

end

count = 0;

moveforward(drone,'distance',1,'Speed',0.5);

DetectionRed(drone,cam,step);

function bestAngle = findbestangle(drone, cam, step)

    switch step
        case 2 
            angles = 110:10:150;
        case 3
            angles = -110:-10:-150; 
        case 4
            angles = 200:7.5:230;
    end

    diameters = zeros(1, length(angles));

    for i = 1:length(angles)
        try
            img = snapshot(cam);
            blue = image_binarization(img, 0.535, 0.66, 0.5, 0.3);

            % 구멍을 채움
            bw2 = imfill(blue, 'holes');

            % 구멍을 채우기 전후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
            bw2 = bw2 & ~blue;

            % 작은 객체 제거
            bw2 = bwareaopen(bw2, 5000); % 5000 픽셀 이하의 객체 제거

            figure;
            imshow(bw2);

            stats = regionprops(bw2, 'Area', 'MajorAxisLength', 'MinorAxisLength');
            
            if isempty(stats)
                disp(['No objects detected at angle ', num2str(angles(i))]);
                diameters(i) = i * 1000;
            else
                [~, maxAreaIndex] = max([stats.Area]);
                majorAxis = stats(maxAreaIndex).MajorAxisLength;
                minorAxis = stats(maxAreaIndex).MinorAxisLength;
                diameter = (majorAxis + minorAxis) / 2;
                disp(diameter);

                diameters(i) = diameter;
            end
            
            disp(['Angle ', num2str(angles(i)), ': Diameter = ', num2str(diameters(i))]);
            interval = angles(2) - angles(1);
            turn(drone, deg2rad(interval));
            
        catch e
            disp(['Error at angle ', num2str(angles(i)), ': ', e.message]);
            diameters(i) = 0;
        end
    end
    
    [~, minIndex] = min(diameters);
    bestAngle = angles(minIndex);
   
    turn(drone, deg2rad(bestAngle - angles(end)));

    disp('best angle: ');
    disp(bestAngle);
end

function centerfind = movedrone(drone, offsetX, offsetY, length, step)

% 선형 회귀 분석을 통한 거리 공식
switch step
    case 1
        distance = exp(-1.057238*log(length)+6.577108);
    case {2, 3}
        distance = exp(-1.02150*log(length)+6.224586);
    case 4
        distance = exp(-1.029708*log(length)+6.363963);
end

% 이동 비율 계산 (pixels/m)
scale = 750 - 150 * distance;

threshold = scale * 0.2;

% 드론 이동 명령 (픽셀 값을 m로 변환하여 드론 이동)
moveX = offsetX / scale; % 이동 거리를 m 단위로 변환
moveY = offsetY / scale; % 이동 거리를 m 단위로 변환

disp(['distance: ', num2str(distance)]);
disp(['threshold: ', num2str(threshold)]);

if abs(offsetX) < threshold - abs(offsetX) && abs(offsetY) < threshold - abs(offsetY)
    centerfind = true;
    return;
else
    centerfind = false;

% X 값 조정
if abs(offsetX) < threshold && abs(offsetX) > threshold - abs(offsetX) 
    if moveX < 0 
        disp("move left small");
        moveleft(drone,'distance', 0.2,'Speed',0.5); % 왼쪽으로 이동
    elseif moveX > 0
        disp("move right small");
        moveright(drone,'distance', 0.2,'Speed',0.5); % 오른쪽으로 이동
    end
       
elseif abs(offsetX) > threshold
    if moveX < 0
        disp("move left");
        disp(moveX);
        moveleft(drone,'distance', -moveX,'Speed',0.5); % 왼쪽으로 이동
    elseif moveX > 0 
        disp("move right");
        disp(moveX);
        moveright(drone,'distance', moveX,'Speed',0.5); % 오른쪽으로 이동
    end
end
    
% Y 값 조정
if abs(offsetY) < threshold && abs(offsetY) > threshold - abs(offsetY)
     if moveY > 0
        disp("move up small");
        moveup(drone,'distance', 0.2,'Speed',0.5); % 위로 이동
     elseif moveY < 0
        disp("move down small");
        movedown(drone,'distance', 0.2,'Speed',0.5); % 아래로 이동
     end
elseif abs(offsetY) > threshold
    if moveY > 0
        disp("move up");
        disp(moveY);
        moveup(drone,'distance', moveY,'Speed',0.5); % 위로 이동
    elseif moveY < 0
        disp("move down");
        disp(moveY);
        movedown(drone,'distance', -moveY,'Speed',0.5); % 아래로 이동
    end
end
end
end


function [offsetX, offsetY, diameters] = calculateOffset(drone, cam)

count = 0;

while true
    % 카메라로 이미지 캡처
    img = snapshot(cam);
    % 이미지의 크기
    [imgHeight, imgWidth, ~] = size(img);

    blue = image_binarization(img, 0.535, 0.66, 0.5, 0.3);

    % 구멍을 채움
    bw2 = imfill(blue, 'holes');

    % 구멍을 채우기 전후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
    bw2 = bw2 & ~blue;

    % 작은 객체 제거
    bw2 = bwareaopen(bw2, 5000); % 5000 픽셀 이하의 객체 제거

    % 파란색 픽셀의 합 계산
    blue_pixel_sum = sum(blue(:));
    
    % 가장 큰 객체만 선택
    stats = regionprops('table', bw2, 'Centroid', 'MajorAxisLength','MinorAxisLength','Area');

    % 중심점이 있는지 확인
    if isempty(stats)
        disp('Cannot find the center of the object.');
        offsetX = NaN;
        offsetY = NaN;

        % 객체의 경계박스를 찾음
        stats_all = regionprops(blue, 'BoundingBox','Area');
        if isempty(stats_all)
            disp('No objects detected in the binary mask.');
            disp("try move back");
            moveback(drone, "Distance",0.3,'Speed',1);
            
        else
            % 가장 큰 객체의 경계박스 선택
            all_areas = [stats_all.Area];
            [~, max_index] = max(all_areas);
            bbox = stats_all(max_index).BoundingBox;

            % 모서리의 파란색 픽셀 검출
            corners = [blue(1,1), blue(1,imgWidth), blue(imgHeight,1), blue(imgHeight,imgWidth)];
                

            if all(corners)
                disp('too close!');
                moveback(drone, 'Distance', 0.3,'Speed',1);
            elseif count == 3
                disp('count over.');
                moveback(drone, 'Distance', 0.3,'Speed',1);
                count = 0;    
            else
                 if bbox(4) > imgHeight * 0.9
                     disp('move back');
                    moveback(drone, 'Distance',0.3,'Speed',0.5);
                 else
                     if bbox(1) > 1 && (bbox(1) + bbox(3) >= imgWidth)
                        disp("move right");
                        moveright(drone, 'Distance',0.2,'Speed',1);
                    elseif bbox(1) < 1 && (bbox(1) + bbox(3) < imgWidth)
                        disp("move left");
                        moveleft(drone, 'Distance',0.2,'Speed',0.5);
                     end

                     if bbox(2) > 1 && (bbox(2) + bbox(4) >= imgHeight)
                        disp("move down");
                        movedown(drone, "Distance",0.2,'Speed',0.5);
                     elseif bbox(2) < 1 && (bbox(2) + bbox(4) < imgHeight)
                        disp("move up");
                        moveup(drone, "Distance",0.2,'Speed',0.5);
                     end
                     count = count + 1; % 드론 이동 횟수
                 end
                     disp(['Blue Pixels: ' num2str(blue_pixel_sum)]);
                     imshow(blue); 
            end
        end
    else
        [~, maxIdx] = max(stats.Area);
        centroid = stats.Centroid(maxIdx, :);
        majorAxisLength = stats.MajorAxisLength(maxIdx);
        minorAxisLength = stats.MinorAxisLength(maxIdx);
        diameters = mean([majorAxisLength minorAxisLength],2);

        % 카메라의 중앙 좌표
        centerX = 480;
        centerY = 180;

        % 이동해야 할 방향 및 거리 계산
        offsetX = centroid(1) - centerX;
        offsetY = centerY - centroid(2);

        % 이동 방향 및 거리 출력
        disp(['Offset X: ', num2str(offsetX)]);
        
        disp(['Offset Y: ', num2str(offsetY)]);
   
        disp(['diameters: ', num2str(diameters)]);

        return;
    end
end
end

function DetectionGreen(drone, cam)

% 카메라로 이미지 캡처
img = snapshot(cam);

figure;
imshow(img);

image1R = img(:,:,1);
image1G = img(:,:,2);
image1B = img(:,:,3);

image_only_G = image1G - image1R / 2 - image1B / 2;
green = image_only_G > 30;

figure;
disp(sum(green(:)));
imshow(green);

distance = exp(-0.471769 * log(sum(green(:))) + log(64.104421));

disp(['distance: ', num2str(distance)]);

if  distance < 1.4 || sum(green(:)) == 0
    turn(drone,deg2rad(-110));
    return;
end

moveforward(drone,'Distance', distance - 1.2, 'Speed', 0.7);  
 
turn(drone,deg2rad(-110));

end


function DetectionRed(drone, cam, step)

% 카메라로 이미지 캡처
img = snapshot(cam);

image1R = img(:,:,1);
image1G = img(:,:,2);
image1B = img(:,:,3);

switch step 

    case 1
        image_only_R = image1R - image1G / 2 - image1B / 2;
        threshold= 80;
        red = image_only_R > threshold;

        figure;
        disp(sum(red(:)));
        imshow(red);

    case 4
        image_only_R = image1R - image1G*0.75 - image1B*0.5;
        threshold = 90;
        red = image_only_R > threshold;

        figure;
        disp(sum(red(:)));
        imshow(red);
end

distance = exp(-0.471769 * log(sum(red(:))) + log(64.104421));

disp(['distance: ', num2str(distance)]);


switch step
    case 1

    if  distance < 0.8 || sum(red(:)) == 0
         turn(drone,deg2rad(130));
        return;
    end

moveforward(drone,'Distance', distance - 0.6, 'Speed', 0.7);

turn(drone,deg2rad(130));

    case 4

if  distance < 0.85 || sum(red(:)) == 0
    land(drone);
    return;
end

moveforward(drone,'Distance', distance - 0.65, 'Speed', 0.7);
land(drone);

end
end


function DetectionPurple(drone, cam)

% 카메라로 이미지 캡처
img=snapshot(cam);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

scaling_factor=1.3;
purple_mask = (R > G) & (B > R) & (B > scaling_factor*G);
purple_mask = bwareaopen(purple_mask, 200); % 5000 픽셀 이하의 객체 제거

disp(sum(purple_mask(:)));
figure;
imshow(purple_mask);
  
distance = exp(-0.471769 * log(sum(purple_mask(:))) + log(64.104421));

disp(['distance: ', num2str(distance)]);

if  distance < 1.45 || sum(purple_mask(:)) == 0
    turn(drone,deg2rad(215));
    return;
end

moveforward(drone,'Distance', distance - 1.25, 'Speed', 0.7);  

turn(drone,deg2rad(215));

end

function color = image_binarization (img, h_down, h_up, s_down, v_down)

    % 이미지를 HSV로 변환
    hsv = rgb2hsv(img);
    h = hsv(:,:,1); % Hue 채널
    s = hsv(:,:,2); % Saturation 채널
    v = hsv(:,:,3); % Value 채널

    % 특정 조건으로 이진 마스크 생성 (파란색 검출)
    detect_h = (h > h_down) & (h < h_up); % H 값이 파란색 범위
    detect_s = s > s_down; % S 값이 충분히 높음
    detect_v = v > v_down; % V 값이 충분히 높음
    color = detect_h & detect_s & detect_v;

    % 노이즈 제거를 위해 모폴로지 연산 적용
    se = strel('disk', 5);
    color = imopen(color, se);
    color = imclose(color, se);

end


