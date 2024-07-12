clear;
drone = ryze('Tello');

takeoff(drone);
pause(1);

% 드론 카메라 중심의 y 좌표를 200 으로 설정
center_point = [480, 200];
cameraObj = camera(drone);

moveforward(drone, 'Distance', 0.5, 'Speed', 0.9);
% 1 st stage
dif = 20;
while true
    frame = snapshot(cameraObj);
    dif = dif + 15;

    [x, y] = square_detect(frame, 0, 0.06);
    if isnan(x) || isnan(y)
        [x, y] = square_detect(frame, 0.94, 1);
    end
    [x1, y1, boundingBox] = detect_from_frame(frame);

    % 링 너머 빨간색 색상 마크가 인식되지 않은 경우 드론 카메라 중심과 링의 중심이 일치하도록 조정
    if isnan(x) || isnan(y)
        disp('No red square detected.');

        % 링이 인식되지 않은 경우 드론이 뒤로 이동한 후 다시 링을 인식
        while isnan(boundingBox)
            disp('No bounding box detected.');
            moveback(drone, 'Distance', 0.2, 'Speed', 1);
            pause(0.5);
            [x1, y1, boundingBox] = detect_from_frame(frame);
        end

        move_to_center(drone, x1, y1, dif);

        centroid = [x1, y1];
        dis = centroid - center_point;

        if abs(dis(1)) <= 100 && abs(dis(2)) <= 100
            disp('Centered successfully!');
            break;
        end
    end

    % 드론 카메라 중심이 링 너머 빨간색 색상 마크의 중심과 일치하도록 조정
    move_to_center(drone, x, y, dif);
 
    centroid = [x, y];
    dis = centroid - center_point;
    centroid1 = [x1, y1];
    dis1 = centroid1 - center_point;

    if abs(dis(1)) <= dif && abs(dis(2)) <= dif
        % 빨간색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 작은 경우
        % 드론이 빨간색 색상 마크와 링의 중심에 위치했다고 판단
        if abs(dis1(1)) <= 100 && abs(dis1(2)) <= 100
            disp('Centered successfully!');
            break;
        % 빨간색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 큰 경우
        % 드론 카메라 중심과 링의 중심이 일치하도록 조정
        else
            move_to_center(drone, x1, y1, dif);
        end
    end
end

moveforward(drone, 'Distance', 3, 'Speed', 0.8);
pause(1.5);

% 2 nd stage
turn(drone, deg2rad(130));
pause(1.5);
turn_cnt = 0;
while true
    frame = snapshot(cameraObj);
    [x, y] = square_detect(frame, 0.30, 0.39);

    centroid = [x, y];
    if isnan(x)
        [x1, y1, boundingBox] = detect_from_frame(frame);
        centroid = [x1, y1];
        dis = centroid - center_point;
        if dis(1)>20
            turn(drone, deg2rad(6));
            disp("turned 5 degree");
            pause(1);
            turn_cnt = turn_cnt + 1;
        elseif dis(1)<-20
            turn(drone, deg2rad(-6));
            disp("turned -5 degree");
            pause(1);
            turn_cnt = turn_cnt + 1;
        else
            break;
        end
    end
    dis = centroid - center_point;
    if turn_cnt == 2
        break;
    end
    if dis(1)>20
        turn(drone, deg2rad(6));
        disp("turned 5 degree");
        pause(1);
        turn_cnt = turn_cnt + 1;
    elseif dis(1)<-20
        turn(drone, deg2rad(-6));
        disp("turned -5 degree");
        pause(1);
        turn_cnt = turn_cnt + 1;
    else
        break;
    end
end

 
moveforward(drone, 'Distance', 3.5, 'Speed', 1);
pause(1);

dif = 25;
while true
    frame = snapshot(cameraObj);
    dif = dif + 15;

    [x, y] = square_detect(frame, 0.30, 0.39);
    [x1, y1, boundingBox] = detect_from_frame(frame);
 
    % 링 너머 초록색 색상 마크가 인식되지 않은 경우 드론 카메라 중심과 링의 중심이 일치하도록 조정
    if isnan(x) || isnan(y)
        disp('No green square detected.');

        % 링이 인식되지 않은 경우 드론이 뒤로 이동한 후 다시 링을 인식
        while isnan(boundingBox)
            disp('No bounding box detected.');
            moveback(drone, 'Distance', 0.2, 'Speed', 1);
            pause(0.5);
            [x1, y1, boundingBox] = detect_from_frame(frame);
        end
        
        move_to_center(drone, x1, y1, dif);

        centroid = [x1, y1];
        dis = centroid - center_point;

        if abs(dis(1)) <= 100 && abs(dis(2)) <= 100
            disp('Centered successfully!');
            break;
        end
    end

    % 드론 카메라 중심이 링 너머 초록색 색상 마크의 중심과 일치하도록 조정
    move_to_center(drone, x, y, dif);
 
    centroid = [x, y];
    dis = centroid - center_point;
    centroid1 = [x1, y1];
    dis1 = centroid1 - center_point;

    if abs(dis(1)) <= dif && abs(dis(2)) <= dif
        % 초록색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 작은 경우
        % 드론이 초록색 색상 마크와 링의 중심에 위치했다고 판단
        if abs(dis1(1)) <= 100 && abs(dis1(2)) <= 100
            disp('Centered successfully!');
            break;
        % 초록색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 큰 경우
        % 드론 카메라 중심과 링의 중심이 일치하도록 조정
        else
            move_to_center(drone, x1, y1, dif);
        end
    end
end

moveforward(drone, 'Distance', 1.6, 'Speed', 1);
pause(1.5);

% 3 rd stage
turn(drone, deg2rad(-130));
pause(1);
turn_cnt = 0;
while true
    frame = snapshot(cameraObj);
    [x, y] = square_detect(frame, 0.69, 0.79);

    centroid = [x, y];
    dis = centroid - center_point;
    if isnan(x)
        [x1, y1, boundingBox] = detect_from_frame(frame);
        centroid = [x1, y1];
        dis = centroid - center_point;
        if dis(1)>20
            turn(drone, deg2rad(6));
            disp("turned 5 degree");
            pause(1);
            turn_cnt = turn_cnt + 1;
        elseif dis(1)<-20
            turn(drone, deg2rad(-6));
            disp("turned -5 degree");
            pause(1);
            turn_cnt = turn_cnt + 1;
        else
            break;
        end
    end
    if turn_cnt == 2
        break;
    end
    if dis(1)>20
        turn(drone, deg2rad(6));
        disp("turned 5 degree");
        pause(1);
        turn_cnt = turn_cnt + 1;
    elseif dis(1)<-20
        turn(drone, deg2rad(-6));
        disp("turned -5 degree");
        pause(1);
        turn_cnt = turn_cnt + 1;
    else
        break;
    end
end


dif = 25;
while true
    frame = snapshot(cameraObj);
    dif = dif + 15;

    [x, y] = square_detect(frame, 0.69, 0.79);
    [x1, y1, boundingBox] = detect_from_frame(frame);
 
    % 링 너머 보라색 색상 마크가 인식이 되지 않은 경우 드론 카메라 중심과 링의 중심 일치하도록 조정
    if isnan(x) || isnan(y)
        disp('No purple square detected.');

        % 링이 인식이 되지 않은 경우 드론이 뒤로 이동한 후 다시 링을 인식
        while isnan(boundingBox)
            disp('No bounding box detected.');
            moveback(drone, 'Distance', 0.2, 'Speed', 1);
            pause(0.5);
            [x1, y1, boundingBox] = detect_from_frame(frame);
        end
        
        move_to_center(drone, x1, y1, dif);

        centroid = [x1, y1];
        dis = centroid - center_point;

        if abs(dis(1)) <= 100 && abs(dis(2)) <= 100
            disp('Centered successfully!');
            break;
        end
    end

    % 드론 카메라 중심이 링 너머 보라색 색상 마크의 중심과 일치하도록 조정
    move_to_center(drone, x, y, dif);
 
    centroid = [x, y];
    dis = centroid - center_point;
    centroid1 = [x1, y1];
    dis1 = centroid1 - center_point;

    if abs(dis(1)) <= dif && abs(dis(2)) <= dif
        % 보라색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 작은 경우
        % 드론이 보라색 색상 마크와 링의 중심에 위치했다고 판단
        if abs(dis1(1)) <= 100 && abs(dis1(2)) <= 100
            disp('Centered successfully!');
            break;
        % 보라색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 큰 경우
        % 드론 카메라 중심과 링의 중심이 일치하도록 조정
        else
            move_to_center(drone, x1, y1, dif);
        end
    end
end

moveforward(drone, 'Distance', 2.7, 'Speed', 1);
pause(1);

% 4 th stage
turn(drone, deg2rad(215));
pause(1);
turn_cnt = 0;
while true
    frame = snapshot(cameraObj);
    [x, y] = square_detect(frame, 0, 0.06);
    if isnan(x) || isnan(y)
        [x, y] = square_detect(frame, 0.94, 1);
    end

    centroid = [x, y];
    if isnan(x)
        [x1, y1, boundingBox] = detect_from_frame(frame);
        centroid = [x1, y1];
        dis = centroid - center_point;
        if dis(1)>20
            turn(drone, deg2rad(5));
            disp("turned 5 degree");
            pause(1);
            turn_cnt = turn_cnt + 1;
        elseif dis(1)<-20
            turn(drone, deg2rad(-5));
            disp("turned -5 degree");
            pause(1);
            turn_cnt = turn_cnt + 1;
        else
            break;
        end
    end
    dis = centroid - center_point;
    if turn_cnt == 3
        break;
    end
    if dis(1)>20
        turn(drone, deg2rad(5));
        disp("turned 5 degree");
        pause(1);
        turn_cnt = turn_cnt + 1;
    elseif dis(1)<-20
        turn(drone, deg2rad(-5));
        disp("turned -5 degree");
        pause(1);
        turn_cnt = turn_cnt + 1;
    else
        break;
    end
end

moveforward(drone, 'Distance', 2, 'Speed', 0.9);
pause(1);

dif = 20;
while true
    frame = snapshot(cameraObj);
    dif = dif + 15;

    [x, y] = square_detect(frame, 0, 0.06);
    if isnan(x) || isnan(y)
        [x, y] = square_detect(frame, 0.94, 1);
    end
    [x1, y1, boundingBox] = detect_from_frame(frame);
 
    % 링 너머 빨간색 색상 마크가 인식되지 않은 경우 드론 카메라 중심과 링의 중심이 일치하도록 조정
    if isnan(x) || isnan(y)
        disp('No red square detected.');

        % 링이 인식되지 않은 경우 드론이 뒤로 이동한 후 다시 링을 인식
        while isnan(boundingBox)
            disp('No bounding box detected.');
            moveback(drone, 'Distance', 0.2, 'Speed', 1);
            pause(0.5);
            [x1, y1, boundingBox] = detect_from_frame(frame);
        end
        
        move_to_center(drone, x1, y1, dif);

        centroid = [x1, y1];
        dis = centroid - center_point;

        if abs(dis(1)) <= 100 && abs(dis(2)) <= 100
            disp('Centered successfully!');
            break;
        end
    end

    % 드론 카메라 중심이 링 너머 빨간색 색상 마크의 중심과 일치하도록 조정
    move_to_center(drone, x, y, dif);
 
    centroid = [x, y];
    dis = centroid - center_point;
    centroid1 = [x1, y1];
    dis1 = centroid1 - center_point;

    if abs(dis(1)) <= dif && abs(dis(2)) <= dif
        % 빨간색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 작은 경우
        % 드론이 빨간색 색상 마크와 링의 중심에 위치했다고 판단
        if abs(dis1(1)) <= 100 && abs(dis1(2)) <= 100
            disp('Centered successfully!');
            break;
        % 빨간색 색상 마크의 중심 (드론의 위치) 와 링의 중심의 차이가 100 보다 큰 경우
        % 드론 카메라 중심과 링의 중심이 일치하도록 조정
        else
            move_to_center(drone, x1, y1, dif);
        end
    end
end

moveforward(drone, 'Distance', 1.85, 'Speed', 0.8);
pause(1);

land(drone);

% 파란색 가림막 링의 중심 좌표를 return 하는 함수
function [center_x, center_y, boundingBox] = detect_from_frame(frame)
    blue_th_down = 0.54;
    blue_th_up = 0.66;

    tohsv = rgb2hsv(frame);
    h = tohsv(:,:,1);
    s = tohsv(:,:,2);

    toBinary = (blue_th_down < h) & (h < blue_th_up) & (s > 0.5);
    filtered = imcomplement(toBinary);

    area = regionprops(filtered, 'BoundingBox', 'Area');
    tmpArea = 0;
    boundingBox = [];
    
    for j = 1:length(area)
        tmpBox = area(j).BoundingBox;

        % boundingBox 의 크기가 드론 카메라 frame 의 크기와 같은 경우 예외 처리
        if(tmpBox(3) == size(frame, 2) || tmpBox(4) == size(frame, 1))
            continue;
        else
            if tmpArea <= area(j).Area
                tmpArea = area(j).Area;
                boundingBox = area(j).BoundingBox;
            end
        end
    end
    
    % boundingBox 가 존재하는 경우 가림막 링의 중심 좌표 추출
    if ~isempty(boundingBox)
        center_x = boundingBox(1) + (0.5 * boundingBox(3));
        center_y = boundingBox(2) + (0.5 * boundingBox(4));
        
        inner_region = imcrop(frame, boundingBox);
        gray_inner = rgb2gray(inner_region);
        edges_inner = edge(gray_inner, 'Canny');
        
        [centers, radii] = imfindcircles(edges_inner, [20 100]);
        
        if ~isempty(centers)
            % 크기가 가장 큰 원의 중심 좌표 추출
            [~, max_idx] = max(radii);
            circle_center = centers(max_idx, :);
            
            center_x = boundingBox(1) + circle_center(1);
            center_y = boundingBox(2) + circle_center(2);
        end
    else
        center_x = NaN;
        center_y = NaN;
    end
end

% 드론이 색상 마크 혹은 가림막 링의 중심 좌표로 이동하도록 하는 함수
function move_to_center(drone, target_x, target_y, dif)
    center_point = [480, 200];
    dis = [target_x, target_y] - center_point;

    if abs(dis(1)) <= dif && abs(dis(2)) <= dif
        disp('Find Center Point!');
        
    elseif abs(dis(1)) > 40
        if dis(1) < 0
            disp('Move left');
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
        else
            disp('Move right');
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
        end
    end
    
    if abs(dis(2)) > 40
        if dis(2) < 0
            disp('Move up');
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        else
            disp('Move down');
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        end
    end
    
    pause(1);
end

% 색상 마크의 중심 좌표를 return 하는 함수
function [center_x, center_y] = square_detect(frame, th_down, th_up)
    tohsv = rgb2hsv(frame);
    h = tohsv(:,:,1);
    s = tohsv(:,:,2);
    v = tohsv(:,:,3);

    toBinary = (th_down < h) & (h < th_up) & (s > 0.4) & (v > 0.2);
    area = regionprops(toBinary, 'BoundingBox', 'Area');
    tmpArea = 0;
    boundingBox = [];
    
    for j = 1:length(area)
        tmpBox = area(j).BoundingBox;
        if tmpBox(3) < size(frame, 2) * 0.9 && tmpBox(4) < size(frame, 1) * 0.9
            if tmpArea <= area(j).Area
                tmpArea = area(j).Area;
                boundingBox = area(j).BoundingBox;
            end
        end
    end
    
    if isempty(boundingBox)
        center_x = NaN;
        center_y = NaN;
        return;
    end
    
    center_x = boundingBox(1) + (0.5 * boundingBox(3));
    center_y = boundingBox(2) + (0.5 * boundingBox(4));
end
