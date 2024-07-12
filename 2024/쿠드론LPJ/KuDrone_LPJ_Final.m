clear all
clc;

% 배열에 중심점 저장
centroids = [];
% 영상의 크기는 960 x 720, 그러나 드론 카메라의 위치 이슈로 인해 센터 포인트는 각 축의 1/2 지점에서 약간의 조정
center_pts = [480, 240];
% 단계별로 다른 카운트 값을 주기 위해서 count 초기화
count = 0;
repeat_count = 0;

% RGB 기준값 %
% channel1,2,3 순서대로 RGB
% 색 이진화 앱에서 가져온 값
% Define thresholds for channel 1 based on histogram settings
channel1Min = 4.000;
channel1Max = 58.000;
% Define thresholds for channel 2 based on histogram settings
channel2Min = 16.000;
channel2Max = 88.000;
% Define thresholds for channel 3 based on histogram settings
channel3Min = 69.000;
channel3Max = 165.000;

% HSV 기준값 %
% channel4,5,6 순서대로 HSV
% 색 이진화 앱에서 가져온 값

% Define thresholds for channel 4 based on histogram settings
channel4Min = 0.318;
channel4Max = 0.701;
% Define thresholds for channel 5 based on histogram settings
channel5Min = 0.650;
channel5Max = 1.000;
% Define thresholds for channel 6 based on histogram settings
channel6Min = 0.000;
channel6Max = 1.000;

try
    % 객체 선언 및 생성
    drone = ryze();
    cam = camera(drone, 'FPV');
    takeoff(drone);
    moveback(drone, 'Distance', 0.3);
    moveup(drone, 'Distance', 0.2);

    % 코드 진행 전에 잠시 딜레이
    pause(1)
   
    % frame이라는 변수에 현재 카메라 영상 캡처하여 저장
    % 단계 1
    while 1
        frame = snapshot(cam);
        % 카메라 영상 실시간 미리보기
        preview(cam)
        pause(1);
    
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
        (channel5Min<s)&(s<channel5Max)&...
        (v>channel6Min)&(v<channel6Max);
    
        % 속성 측정; BoundingBox, Centroid, Area 값 추출
        areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   
        areaCh = 0;
        for j = 1:length(areaNemo)
            boxCh = areaNemo(j).BoundingBox; 
            if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
                continue
        
            else
                if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                    areaCh = areaNemo(j).Area;
                    centroid = areaNemo(j).Centroid;
                end
            end
        end
    
        figure('Name', 'plot centroid', 'NumberTitle','off');
        imshow(frame)
        hold on
        % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off
    
        dis = centroid - center_pts;  % 사각형 중심과 센터 포인트의 차이

        if dis(1) <= 35 && dis(1) >= -35 && dis (2) <= 35 && dis(2) >= -35
            disp("stage1 end")
            break
        end

        if dis(1) > 35 && dis(1) <= 80
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 35 && dis(1) < 80")
        elseif dis(1) < -35 && dis(1) > -80
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -35 && dis(1) > -80")
        end

        if dis(2) > 35 && dis(2) <= 80
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 35 && dis(2) < 80, down")
        elseif dis(2) < -35 && dis(2) >= -80
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -35 && dis(2) > -80")
            
        end
        
        dis_cm_x = dis(1)/750;  % 2는 민감도에 대한 계산
        dis_cm_y = dis(2)/750;  % 2는 민감도에 대한 계산
                
        % x축으로의 이동
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축으로의 이동
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축으로의 이동
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", -dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", -dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 2
            disp("count break")
            break
        end

    end

    moveforward(drone, 'Distance', 3.7, 'Speed',1);
    turn(drone,deg2rad(130));
     
    disp("stage2 start")
    moveforward(drone, 'Distance', 2.2, 'Speed',1);
    
    % 단계 2
    
    frame = snapshot(cam);
    % 카메라 영상 실시간 미리보기
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);

    % figure('Name', 'blueMask_rgb', 'NumberTitle','off');
    % imshow(blueMask_hsv)
    
    % 회전 전 중심 찾기
    areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue
    
        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    figure('Name', 'before turn plot centroid', 'NumberTitle','off');
    imshow(frame)
    hold on
    % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중심과 센터 포인트의 차이
    dis_cm = dis(1)/2;  % 2는 민감도에 대한 계산
    deg_rad = atan(dis_cm/350);
    turn(drone,-deg_rad);
    
    moveforward(drone, 'Distance', 1.2, 'Speed', 0.8);

    % 단계 2 중심 찾기

    center_pts = [480, 200];

    disp("stage2 centroid start")
    
    repeat_count = 0;
    while 1

        frame = snapshot(cam);
        
        figure('Name', 'after turn', 'NumberTitle','off');
        imshow(frame)

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
        (channel5Min<s)&(s<channel5Max)&...
        (v>channel6Min)&(v<channel6Max);
    
        
        % 회전 후 중심 찾기
    
        areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
        areaCh = 0;
        for j = 1:length(areaNemo)
            boxCh = areaNemo(j).BoundingBox; 
            if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
                continue
        
            else
                if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                    areaCh = areaNemo(j).Area;
                    centroid = areaNemo(j).Centroid;
                end
            end
        end

        figure('Name', 'after turn centroid', 'NumberTitle','off');
        imshow(frame)
        hold on
        % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

        dis = centroid - center_pts;  % 사각형 중심과 센터 포인트의 차이
        
        % x와 y축으로 이동
        dis_cm_x = dis(1)/750;  % 2는 민감도에 대한 계산
        dis_cm_y = dis(2)/750;  % 2는 민감도에 대한 계산

        if dis(1) <= 20 && dis(1) >= -20 && dis (2) <= 20 && dis(2) >= -20
            disp("stage2 end")
            break
        end

        if dis(1) > 20 && dis(1) <= 80
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 40 && dis(1) < 80")
        elseif dis(1) < -20 && dis(1) > -80
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -40 && dis(1) > -80")
        end

        if dis(2) > 20 && dis(2) <= 80
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 40 && dis(2) < 80, down")
        elseif dis(2) < -20 && dis(2) > -80
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -40 && dis(2) > -80")
            
        end      
        
        % x축으로의 이동
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축으로의 이동
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축으로의 이동
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", -dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", -dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 4
            disp("count break")
            break
        end


    end
    
    moveforward(drone, 'Distance', 1.8 , 'Speed', 0.7);
    turn(drone,deg2rad(-120));

    disp("stage3 centroid start")
    
    disp("stage3 start")
    
    % 단계 3
    
    frame = snapshot(cam);
    % 카메라 영상 실시간 미리보기
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);

    % figure('Name', 'blueMask_rgb', 'NumberTitle','off');
    % imshow(blueMask_hsv)
    
    % 회전 전 중심 찾기
    areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue
    
        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    figure('Name', 'before turn plot centroid', 'NumberTitle','off');
    imshow(frame)
    hold on
    % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중심과 센터 포인트의 차이
    dis_cm = dis(1)/2;  % 2는 민감도에 대한 계산
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")

    moveforward(drone, 'Distance', 1, 'Speed', 0.8);

    % 단계 3 중심 찾기

    disp("stage3 centroid start")
    
    repeat_count = 0;
    while 1

        frame = snapshot(cam);
        
        figure('Name', 'after turn', 'NumberTitle','off');
        imshow(frame)

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
        (channel5Min<s)&(s<channel5Max)&...
        (v>channel6Min)&(v<channel6Max);
    
        
        
        % 회전 후 중심 찾기
    
        areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
        areaCh = 0;
        for j = 1:length(areaNemo)
            boxCh = areaNemo(j).BoundingBox; 
            if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
                continue
        
            else
                if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                    areaCh = areaNemo(j).Area;
                    centroid = areaNemo(j).Centroid;
                end
            end
        end

        figure('Name', 'after turn centroid', 'NumberTitle','off');
        imshow(frame)
        hold on
        % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

        dis = centroid - center_pts;  % 사각형 중심과 센터 포인트의 차이
        
        % x와 y축으로 이동
        dis_cm_x = dis(1)/750;  % 2는 민감도에 대한 계산
        dis_cm_y = dis(2)/750;  % 2는 민감도에 대한 계산

        if dis(1) <= 20 && dis(1) >= -20 && dis (2) <= 20 && dis(2) >= -20
            disp("stage1 end")
            break
        end

        if dis(1) > 20 && dis(1) <= 80
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 40 && dis(1) < 80")
        elseif dis(1) < -20 && dis(1) > -80
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -40 && dis(1) > -80")
        end

        if dis(2) > 20 && dis(2) <= 80
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 40 && dis(2) < 80, down")
        elseif dis(2) < -20 && dis(2) > -80
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -40 && dis(2) > -80")
            
        end      
        
        % x축으로의 이동
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축으로의 이동
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축으로의 이동
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", -dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", -dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 3
            disp("count break")
            break
        end
              
    end

    frame = snapshot(cam);
    % 카메라 영상 실시간 미리보기
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);

    % figure('Name', 'blueMask_rgb', 'NumberTitle','off');
    % imshow(blueMask_hsv)
    
    % 회전 전 중심 찾기
    areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue
    
        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    figure('Name', 'before turn plot centroid', 'NumberTitle','off');
    imshow(frame)
    hold on
    % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중심과 센터 포인트의 차이
    dis_cm = dis(1)/2;  % 2는 민감도에 대한 계산
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")
    
    
    moveforward(drone, 'Distance', 1.8, 'Speed', 0.8);

    turn(drone, deg2rad(220))

    disp("stage4 centroid start")
    
    disp("stage4 start")
    
    % 단계 4
    
    frame = snapshot(cam);
    % 카메라 영상 실시간 미리보기
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);


    
    % 회전 전 중심 찾기
    areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
    areaCh = 0;
    for j = 1:length(areaNemo)
        boxCh = areaNemo(j).BoundingBox; 
        if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
            continue
    
        else
            if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                areaCh = areaNemo(j).Area;
                centroid = areaNemo(j).Centroid;
            end
        end
    end

    figure('Name', 'before turn plot centroid', 'NumberTitle','off');
    imshow(frame)
    hold on
    % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중심과 센터 포인트의 차이
    dis_cm = dis(1)/2;  % 2는 민감도에 대한 계산
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")

    moveforward(drone, 'Distance', 1, 'Speed', 0.8);

    % 단계 4 중심 찾기

    disp("stage4 centroid start")
    
    repeat_count = 0;
    while 1

        frame = snapshot(cam);
        
        figure('Name', 'after turn', 'NumberTitle','off');
        imshow(frame)

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
        (channel5Min<s)&(s<channel5Max)&...
        (v>channel6Min)&(v<channel6Max);
    

        
        % 회전 후 중심 찾기
    
        areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
        areaCh = 0;
        for j = 1:length(areaNemo)
            boxCh = areaNemo(j).BoundingBox; 
            if(boxCh(3) == 960 || boxCh(4) == 720)  % 화면 전체를 사각형으로 인식하는 경우 예외 처리
                continue
        
            else
                if areaCh <= areaNemo(j).Area   % 가장 큰 영역일 때 속성 추출
                    areaCh = areaNemo(j).Area;
                    centroid = areaNemo(j).Centroid;
                end
            end
        end

        figure('Name', 'after turn centroid', 'NumberTitle','off');
        imshow(frame)
        hold on
        % 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

        dis = centroid - center_pts;  % 사각형 중심과 센터 포인트의 차이
        
        % x와 y축으로 이동
        dis_cm_x = dis(1)/750;  % 2는 민감도에 대한 계산
        dis_cm_y = dis(2)/750;  % 2는 민감도에 대한 계산

        if dis(1) <= 20 && dis(1) >= -20 && dis (2) <= 20 && dis(2) >= -20
            disp("stage1 end")
            break
        end

        if dis(1) > 20 && dis(1) <= 80
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 40 && dis(1) < 80")
        elseif dis(1) < -20 && dis(1) > -80
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -40 && dis(1) > -80")
        end

        if dis(2) > 20 && dis(2) <= 80
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 40 && dis(2) < 80, down")
        elseif dis(2) < -20 && dis(2) > -80
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -40 && dis(2) > -80")
            
        end      
        
        % x축으로의 이동
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축으로의 이동
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축으로의 이동
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", -dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", -dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 4
            disp("count break")
            break
        end
              
    end

    moveforward(drone, 'Distance', 2.8, 'Speed',1 )

    land(drone);
         

catch error
    disp(error);
end
