clear;
drone = ryze();
cam = camera(drone);
takeoff(drone);

moveback(drone, 'Distance', 0.5, 'Speed', 1);   % 사각형 전체 한 번에 인식하기 위해 뒤로 이동

% 중심 점 설정
center_point = [480, 200];
centroid = zeros(size(center_point));
count = 0;

movecount = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1단계 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);
    blueNemo = detect_r & detect_g & detect_b;

    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox;
        if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue;
        else
            if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % 중심 점을 찾아 이동
    if abs(dis(1)) <= 35 && abs(dis(2)) <= 35  % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!");
        count = 1;
    
    elseif dis(2) <= 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end
    elseif dis(2) <= 0 && abs(dis(2)) > 35
        if dis(1) <= 0 && abs(dis(1)) > 30
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0 && abs(dis(1)) > 30
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 30
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);

        elseif dis(1) > 0 && abs(dis(1)) <= 30
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 30
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end        

    elseif dis(2) > 0 && abs(dis(2)) > 35
        if dis(1) <= 0 && abs(dis(1)) > 30
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end

        elseif dis(1) > 0 && abs(dis(1)) > 30
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 30
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);

        elseif dis(1) > 0 && abs(dis(1)) <= 30
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);            
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end        
    end
    
    % 중심 찾음; 이동 거리 계산
    if count == 1
        disp('Moving...');

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue = (0.535 < h) & (h < 0.69) & (0.4 < s) & (v > 0.1) & (v < 0.97);

        blue(1, :) = 1;
        blue(720, :) = 1;
        bw = imfill(blue, 'holes');
        for x = 1:720
            for y = 1:size(blue, 2)
                if blue(x, y) == bw(x, y)
                    bw(x, y) = 0;
                end
            end
        end

        % 속성 측정; 장축 길이 값 추출
        stats = regionprops('table', bw, 'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);

        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw, 'all') <= 10000
            moveforward(drone, 'Distance', 2, 'Speed', 1.5);

        elseif longAxis > 860
            moveforward(drone, 'Distance', 2, 'Speed', 1.5);

        else
            distance = (3E-06) * (longAxis)^2 - 0.0065 * longAxis + 4.3; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance + 0.5, 'Speed', 0.8);  
        end

        break;
    end
end

movecount = 0;

% 빨간 네모 중심을 찾기
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 151) & (r < 194);   
    g = frame(:,:,2);   detect_g = (g > 25) & (g < 99);
    b = frame(:,:,3);   detect_b = (b > 9) & (b < 99);
    redNemo = detect_r & detect_g & detect_b;
    
    areaNemo = regionprops(redNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox;
        if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue;
        else
            if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    %중심 점을 찾아 이동
    if abs(dis(1)) <= 70 && abs(dis(2)) <= 100  % x 좌표 차이, y 좌표 차이가 각각 50, 70보다 작을 경우 center point 인식
        disp("Find Red Center Point!");
        disp(sum(redNemo,'all'))
       % 빨간색 픽셀의 합이 10000 이상인지 확인
        if sum(redNemo,'all') >= 10000
            disp("Red pixels exceed 32000, stopping...");
            break;
        else
            disp("Moving forward to get closer...");
            moveforward(drone, 'Distance', 0.3, 'Speed', 0.5);
            break;
        end
        

    elseif dis(2) <= 0 && abs(dis(2)) <= 100 && abs(dis(1)) > 70
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end
    elseif dis(2) <= 0 && abs(dis(2)) > 100
        if dis(1) <= 0 && abs(dis(1)) > 70
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 70
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 70
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 70
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) <= 100 && abs(dis(1)) > 70
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) > 100
        if dis(1) <= 0 && abs(dis(1)) > 70
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 70
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 70
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 70
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        
    end
end
turn(drone, deg2rad(120)); %시계방향으로 120도 회전
disp('1st Stage Finish');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2단계 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
movecount = 0;

% 앞으로 이동
moveforward(drone, 'Distance', 3.5, 'Speed', 1);

% 각도 조절을 위한 반복문
while true
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);

    blueNemo = detect_r & detect_g & detect_b;

    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox;
        if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue;
        else
            if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    
    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % 각도 조절
    pixel_ang = 60;
    if abs(dis(1)) > pixel_ang  
        
        if sign(dis(1)) == -1 
            turn(drone, deg2rad((60/960)*dis(1)));
            disp('turning...');
            continue;
        elseif sign(dis(1)) == 1
            turn(drone, deg2rad((60/960)*dis(1)));
            disp('turning...');
            continue;
        end

    end


    % 중심 점을 찾아 이동
    if abs(dis(1)) <= 100 && abs(dis(2)) <= 100  % x 좌표 차이, y 좌표 차이가 각각 50보다 작을 경우 center point 인식
        disp("Find Center Point!");
        moveforward(drone, 'Distance', 1.6, 'Speed', 0.5);
        break;
    elseif dis(2) <= 0 && abs(dis(2)) <= 100 && abs(dis(1)) > 100
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end

    elseif dis(2) <= 0 && abs(dis(2)) > 100
        if dis(1) <= 0 && abs(dis(1)) > 100
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) > 100
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) <= 0 && abs(dis(1)) <= 100
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 100
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 100 && abs(dis(1)) > 100
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end

    elseif dis(2) > 0 && abs(dis(2)) > 100
        if dis(1) <= 0 && abs(dis(1)) > 100
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) > 100
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) <= 0 && abs(dis(1)) <= 100
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 100
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
    end
end

% % 초록 네모 중심 찾기
% while 1
%     frame = snapshot(cam);
%     r = frame(:,:,1);   detect_r = (r > 0) & (r < 90);   
%     g = frame(:,:,2);   detect_g = (g > 95) & (g < 255);
%     b = frame(:,:,3);   detect_b = (b > 0) & (b < 180);
% 
%     greenNemo = detect_r & detect_g & detect_b;
% 
%     areaNemo = regionprops(greenNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
%     areaCh = 0;
%     for j = 1:length(areaNemo)
%         boxCh = areaNemo(j).BoundingBox;
%         if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
%             continue;
%         else
%             if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
%                 areaCh = areaNemo(j).Area;
%                 centroid = areaNemo(j).Centroid;
%             end
%         end
%     end
% 
%     dis = centroid - center_point;  % 사각형 중점과 center_point 차이
% 
%     % 중심 점을 찾아 이동
%     if abs(dis(1)) <= 50 && abs(dis(2)) <= 80  % x 좌표 차이, y 좌표 차이가 각각 35, 70보다 작을 경우 center point 인식
%         disp("Find green Center Point!");
%         disp(sum(greenNemo,'all'))
%         % 초록색 픽셀의 합이 10000 이상인지 확인
%         if sum(greenNemo,'all') >= 10000
%             disp("green pixels exceed 10000, stopping...");
%             break;
%         else
%             disp("Moving forward to get closer...");
%             moveforward(drone, 'Distance', 1, 'Speed', 0.5);
%             break;
%         end
% 
% 
%     elseif dis(2) <= 0 && abs(dis(2)) <= 80 && abs(dis(1)) > 60
%         if dis(1) <= 0
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end
%     elseif dis(2) <= 0 && abs(dis(2)) > 80
%         if dis(1) <= 0 && abs(dis(1)) > 60
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) > 60
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) <= 0 && abs(dis(1)) <= 60
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) <= 60
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end        
% 
%     elseif dis(2) > 0 && abs(dis(2)) <= 80 && abs(dis(1)) > 60
%         if dis(1) <= 0
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end        
% 
%     elseif dis(2) > 0 && abs(dis(2)) > 80
%         if dis(1) <= 0 && abs(dis(1)) > 60
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) > 60
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) <= 0 && abs(dis(1)) <= 60
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) <= 60
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end        
%     end
% end

disp('2nd Stage Finish');
turn(drone, deg2rad(-120));  % 반시계방향으로 120도 회전



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3단계 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
movecount = 0;

moveforward(drone, 'Distance', 0.5, 'Speed', 1);

% 각도 조절을 위한 반복문
while true
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);

    blueNemo = detect_r & detect_g & detect_b;

    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox;
        if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue;
        else
            if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    
    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % 각도 조절
    pixel_ang = 60;
    if abs(dis(1)) > pixel_ang  
        
        if sign(dis(1)) == -1 
            turn(drone, deg2rad((60/960)*dis(1)));
            disp('turning...');
            continue;
        elseif sign(dis(1)) == 1
            turn(drone, deg2rad((60/960)*dis(1)));
            disp('turning...');
            continue;
        end

    end

    moveforward(drone, 'Distance', 1, 'Speed', 1);
    
    % 중심 점을 찾아 이동
    if abs(dis(1)) <= 40 && abs(dis(2)) <= 50  % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!");
        break;
    
    elseif dis(2) <= 0 && abs(dis(2)) <= 50 && abs(dis(1)) > 40
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end
    elseif dis(2) <= 0 && abs(dis(2)) > 50
        if dis(1) <= 0 && abs(dis(1)) > 40
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 40
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 40
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 40
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 50 && abs(dis(1)) > 40
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end        

    elseif dis(2) > 0 && abs(dis(2)) > 50
        if dis(1) <= 0 && abs(dis(1)) > 40
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end

        elseif dis(1) > 0 && abs(dis(1)) > 40
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 40
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);

        elseif dis(1) > 0 && abs(dis(1)) <= 40
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);            
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end        
    end

end

disp("move forward")
moveforward(drone, 'Distance', 1.7, 'Speed', 1);

% % 보라 네모 중심 찾기
% 
% movecount = 0;
% while 1
%     frame = snapshot(cam);
%     r = frame(:,:,1); detect_r = (r > 60) & (r < 240);
%     g = frame(:,:,2); detect_g = (g > 30) & (g < 90);
%     b = frame(:,:,3); detect_b = (b > 95) & (b < 225);
%     purpleNemo = detect_r & detect_g & detect_b;
% 
% 
%     areaNemo = regionprops(purpleNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
%     areaCh = 0;
%     for j = 1:length(areaNemo)
%         boxCh = areaNemo(j).BoundingBox;
%         if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
%             continue;
%         else
%             if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
%                 areaCh = areaNemo(j).Area;
%                 centroid = areaNemo(j).Centroid;
%             end
%         end
%     end
% 
%     dis = centroid - center_point;  % 사각형 중점과 center_point 차이
% 
%     % 중심 점을 찾아 이동
%     if abs(dis(1)) <= 50 && abs(dis(2)) <= 70  % x 좌표 차이, y 좌표 차이가 각각 50, 70보다 작을 경우 center point 인식
%         disp("Find purple Center Point!");
%         disp(sum(purpleNemo,'all'))
%         % 빨간색 픽셀의 합이 10000 이상인지 확인
%         if sum(purpleNemo,'all') >= 10000
%             disp("purple pixels exceed 32000, stopping...");
%             break;
%         else
%             disp("Moving forward to get closer...");
%             moveforward(drone, 'Distance', 0.3, 'Speed', 0.5);
%             break;
%         end
% 
% 
%     elseif dis(2) <= 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
%         if dis(1) <= 0
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end
%     elseif dis(2) <= 0 && abs(dis(2)) > 70
%         if dis(1) <= 0 && abs(dis(1)) > 50
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) > 50
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) <= 0 && abs(dis(1)) <= 50
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) <= 50
%             disp("Move up");
%             moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end        
% 
%     elseif dis(2) > 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
%         if dis(1) <= 0
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end        
% 
%     elseif dis(2) > 0 && abs(dis(2)) > 70
%         if dis(1) <= 0 && abs(dis(1)) > 50
%             disp("Move left");
%             moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) > 50
%             disp("Move right");
%             moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) <= 0 && abs(dis(1)) <= 50
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
% 
%         elseif dis(1) > 0 && abs(dis(1)) <= 50
%             disp("Move down");
%             movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
%         end
%         movecount = movecount + 1;
%         if movecount >= 10
%             disp("Moving...");
%             break;
%          end        
%     end
% end

disp('3rd Stage Finish');
turn(drone, deg2rad(215));  % 시계방향으로 215도 회전


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4단계 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count = 0;
movecount = 0;


moveforward(drone, 'Distance', 1, 'Speed', 1);

% 각도 조절을 위한 반복문
while true
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);

    blueNemo = detect_r & detect_g & detect_b;

    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox;
        if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue;
        else
            if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    
    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % 각도 조절
    pixel_ang = 60;
    if abs(dis(1)) > pixel_ang  
        
        if sign(dis(1)) == -1 
            turn(drone, deg2rad((60/960)*dis(1)));
            disp('turning...');
            continue;
        elseif sign(dis(1)) == 1
            turn(drone, deg2rad((60/960)*dis(1)));
            disp('turning...');
            continue;
        end

    end


    % 중심 점을 찾아 이동
    if abs(dis(1)) <= 35 && abs(dis(2)) <= 35  % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!");
        count = 1;
    
    elseif dis(2) <= 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
        end

    elseif dis(2) <= 0 && abs(dis(2)) > 35
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0 && abs(dis(1)) > 35
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 35
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);

        elseif dis(1) > 0 && abs(dis(1)) <= 35
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 1);
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
        end

    elseif dis(2) > 0 && abs(dis(2)) > 35
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) > 0 && abs(dis(1)) > 35
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 35
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);

        elseif dis(1) > 0 && abs(dis(1)) <= 35
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        end
    end
    
    % 중심 찾음; 이동 거리 계산
    if count == 1
        disp('Moving...');

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blue = (0.535 < h) & (h < 0.69) & (0.4 < s) & (v > 0.1) & (v < 0.97);

        blue(1, :) = 1;
        blue(720, :) = 1;
        bw = imfill(blue, 'holes');        
        for x = 1:720
            for y = 1:size(blue, 2)
                if blue(x, y) == bw(x, y)
                    bw(x, y) = 0;
                end
            end
        end

        % 속성 측정; 장축 길이 값 추출
        stats = regionprops('table', bw, 'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);

        % % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw, 'all') <= 10000
            moveforward(drone, 'Distance', 0.2, 'Speed', 1);

        elseif longAxis > 460
            moveforward(drone, 'Distance', 0.2, 'Speed', 1);

        else
            distance = (1E-05) * (longAxis)^2 - 0.0124 * longAxis + 4.5996; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance+0.75, 'Speed', 1);   
        end

        break;
    end
end

% 빨간 네모 중심을 찾아서 정지
movecount = 0;

while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 151) & (r < 194);   
    g = frame(:,:,2);   detect_g = (g > 25) & (g < 99);
    b = frame(:,:,3);   detect_b = (b > 9) & (b < 99);
    redNemo = detect_r & detect_g & detect_b;
    
% 빨간 네모 중심 찾기
    areaNemo = regionprops(redNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox;
        if boxCh(3) == 960 || boxCh(4) == 720  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue;
        else
            if areaCh <= areaNemo(j).Area  % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % 중심 점을 찾아 이동
    if abs(dis(1)) <= 60 && abs(dis(2)) <= 100  % x 좌표 차이, y 좌표 차이가 각각 60,100보다 작을 경우 center point 인식
        disp("Find Red Center Point!");
        disp(sum(redNemo,'all'))
        % 빨간색 픽셀의 합이 12000 이상인지 확인
        if sum(redNemo,'all') >= 12000
            disp("land...");
            break;
        else
            disp("Moving forward to get closer...");
            moveforward(drone, 'Distance', 0.2, 'Speed', 0.5);
            break;
        end
        

    elseif dis(2) <= 0 && abs(dis(2)) <= 100 && abs(dis(1)) > 60
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end
    elseif dis(2) <= 0 && abs(dis(2)) > 100
        if dis(1) <= 0 && abs(dis(1)) > 60
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 60
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 60
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 60
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) <= 100 && abs(dis(1)) > 60
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) > 100
        if dis(1) <= 0 && abs(dis(1)) > 60
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 60
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 60
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 60
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        
    end
end

disp('4th Stage Finish');
land(drone);
