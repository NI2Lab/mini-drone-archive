# 쿠드론 LPJ (이현수, 박은수, 제갈양)
![쿠드론 LPJ 사진](https://github.com/LEEHYUNSOO1/my_repository/assets/131329840/983fa35c-dd89-4cdb-baab-b0345537ec84)


# 대회 진행 전략
![대회 상세 맵](https://github.com/LEEHYUNSOO1/my_repository/assets/131329840/ce7bbc5b-0914-40d1-ab8a-8b8b28f9e481)


우선 맵 상세도를 보게되면 출발지점에서부터 4단계의 미션을 진행하여야한다. 주어진 조건은
- 1차 링 지름 : 57cm
- 2차 링 지름 : 46cm
- 3차 링 지름 : 46cm
- 4차 링 지름 : 52cm
- 가림막 링 중심점의 높이 80~100cm
 로 나타나 있는 것을 볼 수 있다.

# 알고리즘 설명
팀 전략은 간략하게 원의 중심을 찾아 중심점과 드론이 촬영한 위치의 차이점을 비교하여 일치시키기 위하여 이동을 반복하고 어느 정도 일치하게 되면 전진하는 알고리즘을 사용하였다. 다음으로는 각 단계에서 다음 단계로 넘어갈 때 회전을 진행해야 하는데 회전 각도 변수를 찾기 위하여 정해진 일정 각도 회전 후 중심점을 찾아 찾은 중심점과 드론이 촬영한 위치의 차이점을 비교하여 드론이 회전할 수 있도록 코딩을 진행하였다.


# Toolbox
-사용한 Toolbox (2가지)    
*Image  Processing Toolbox
     
*MATLAB Support Package for Ryze Tello 


# 기본 코딩 설명

객체 생성 및 초기화:drone = ryze("TELLO-XXXXXX"); 및 cam = camera(drone, 'FPV');를 통해 Tello 드론과 FPV 카메라를 생성하고 초기화.
드론 이륙: takeoff(drone);.
영상 캡처 및 실시간 미리보기: frame = snapshot(cam);을 사용하여 현재 카메라 영상을 캡처.
preview(cam);을 통해 실시간으로 카메라 영상을 추출.


객체 감지를 위한 색상 이진화: RGB 및 HSV 색상 기준값을 설정하여 특정 색상을 감지.
rgb2hsv(frame);을 사용하여 RGB 영상을 HSV로 변환.
blueMask_hsv 변수를 통해 설정된 HSV 범위 내의 픽셀을 이진화.


객체의 중심점 및 영역 계산: regionprops 함수를 사용하여 객체의 BoundingBox, Centroid, Area 속성을 추출.
가장 큰 영역을 가진 객체의 중심점을 찾아 centroid 변수에 저장.


드론 이동 제어:드론의 현재 위치와 객체 중심점 간의 차이를 계산하여 드론을 이동.
moveright, moveleft, moveup, movedown 함수를 사용하여 드론을 x축 및 y축 방향으로 이동.
moveforward 함수를 사용하여 드론을 전진.
turn 함수를 사용하여 드론을 회전.


# 소스 코드 설명

## 초기 설정
clear all
clc;

% 배열에 중심점 저장
centroids = [];
% 영상의 크기는 960 x 720, 그러나 드론 카메라의 위치 이슈로 인해 센터 포인트는 각 축의 1/2 지점에서 약간의 조정
center_pts = [480, 240];
% 단계별로 다른 카운트 값을 주기 위해서 count 초기화
count = 0;
repeat_count = 0;


## RGB 및 HSV 기준값 설정
% RGB 기준값 %
channel1Min = 4.000;
channel1Max = 58.000;
channel2Min = 16.000;
channel2Max = 88.000;
channel3Min = 69.000;
channel3Max = 165.000;

% HSV 기준값 %
channel4Min = 0.318;
channel4Max = 0.701;
channel5Min = 0.650;
channel5Max = 1.000;
channel6Min = 0.000;
channel6Max = 1.000;


## 단계 1: 객체 감지 및 중심점 이동
        while 1
        frame = snapshot(cam);
        preview(cam);
        pause(1);

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
        (channel5Min<s)&(s<channel5Max)&...
        (v>channel6Min)&(v<channel6Max);

        areaNemo = regionprops(blueMask_hsv,'BoundingBox','Centroid','Area');
        areaCh = 0;
        for j = 1:length(areaNemo)
            boxCh = areaNemo(j).BoundingBox; 
            if(boxCh(3) == 960 || boxCh(4) == 720)
                continue;
            else
                if areaCh <= areaNemo(j).Area
                    areaCh = areaNemo(j).Area;
                    centroid = areaNemo(j).Centroid;
                end
            end
        end

        figure('Name', 'plot centroid', 'NumberTitle','off');
        imshow(frame);
        hold on;
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off;

        dis = centroid - center_pts;

        if dis(1) <= 35 && dis(1) >= -35 && dis (2) <= 35 && dis(2) >= -35
            disp("stage1 end");
            break;
        end

        if dis(1) > 35 && dis(1) <= 80
            moveright(drone, "Distance", 0.2);
        elseif dis(1) < -35 && dis(1) > -80
            moveleft(drone, "Distance", 0.2);
        end

        if dis(2) > 35 && dis(2) <= 80
            movedown(drone, "Distance", 0.2);
        elseif dis(2) < -35 && dis(2) >= -80
            moveup(drone, "Distance", 0.2);
        end

        dis_cm_x = dis(1)/750;
        dis_cm_y = dis(2)/750;

        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2);
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2);
        end

        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2);
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2);
        end

        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x);
        elseif dis(1) < -150
            moveleft(drone, "Distance", dis_cm_x);
        end

        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y);
        elseif dis(2) < -150
            moveup(drone, "Distance", dis_cm_y);
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 3
            disp("count break");
            break;
        end
    end

    moveforward(drone, 'Distance', 3.5, 'Speed',1);
    turn(drone,deg2rad(130));


## 단계 2: 객체 감지, 회전 및 중심점 이동
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
    
    moveforward(drone, 'Distance', 2.5, 'Speed', 1);

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
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 3
            disp("count break")
            break
        end

        % if count == 2
        %     disp("stage 2 count break")
        %     break
        % end 
    end
    
    moveforward(drone, 'Distance', 2.5 , 'Speed', 1);
    turn(drone,deg2rad(-120));


## 단계 3: 객체 감지, 회전 및 중심점 이동
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
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 3
            disp("count break")
            break
        end
              
    end

    moveforward(drone, 'Distance', 2.6);
    turn(drone, deg2rad(220))


## 단계 4: 객체 감지, 회전 및 중심점 이동 후 착지
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
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축으로의 이동
        if dis(2) > 150
            movedown(drone, "Distance", dis_cm_y)
            disp("dis(2) > 150, down")
        elseif dis(2) < -150
            moveup(drone, "Distance", dis_cm_y)
            disp("dis(2) < -150")
        end

        repeat_count = repeat_count + 1;

        if repeat_count == 4
            disp("count break")
            break
        end
              
    end

    moveforward(drone, 'Distance', 3.85, 'Speed',1 )

    land(drone);
         

    catch error
    disp(error);
       end
