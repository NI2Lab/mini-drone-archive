# 쿠드론 GS(송경준, 박시현)

![likelion logo](https://github.com/songgyeongjun/my_repository/assets/131330133/0a3d8969-4ee5-48aa-843c-2556f30675f7)

---

# 목차 

### 1. 스테이지
### 2. 대회 진행 전략
### 3. 설치 
### 4. 알고리즘 

---

# 스테이지 

![likelion logo](https://github.com/songgyeongjun/my_repository/assets/131330133/25fb209e-c83b-46ae-bcfa-63560d9d2c91)


---

# 대회 진행 전략 

### * 이륙 후 원 중심 좌표 와 드론의 중심 좌표를 일치시키기 위해 드론을 일정거리 이동시켜 다음 단계로 넘어간다.
### * 회전단계에서는 드론을 일정 값 만큼 회전 시킨 후 원 과 드론이 수직이 되게끔 오차범위 만큼 회전 시켰다.

---

# 설치 

### 1. MATLAB:
  #### MATLAB이 시스템에 설치되어 있어야 합니다. 이 스크립트는 MATLAB 환경에서 작동하도록 설계되었습니다.

### 2. 하드웨어:
  #### * 호환되는 드론 (Tello)
  #### * 실시간 비디오 캡처를 위한 카메라 모듈

### 3. 종속성:
  #### * Image  Processing Toolbox
     
  #### * MATLAB Support Package for Ryze Tello

---

# 알고리즘 

### 1. 이진화 단계

<pre>
<code>
clear all
clc;

% 중심점 저장하는 배열
centroids = [];
% 영상크기는 960 x 720 그럼 센터점은 각각 1/2지점
center_pts = [480, 240];
% stage마다 다른 count 값을 주기 위해서 count 초기화
count = 0;
repeat_count = 0;

%%% RGB 기준값 %%%
% channel1,2,3 순서대로 RGB
% 색 이진화 앱에서 그대로 들고 온 값
% Define thresholds for channel 1 based on histogram settings
channel1Min = 4.000;
channel1Max = 58.000;
% Define thresholds for channel 2 based on histogram settings
channel2Min = 16.000;
channel2Max = 88.000;
% Define thresholds for channel 3 based on histogram settings
channel3Min = 69.000;
channel3Max = 165.000;

%%% HSV 기준값 %%%
% channel4,5,6 순서대로 HSV
% 색 이진화 앱에서 그대로 들고 온 값

% Define thresholds for channel 4 based on histogram settings
channel4Min = 0.318;
channel4Max = 0.701;
% Define thresholds for channel 5 based on histogram settings
channel5Min = 0.650;
channel5Max = 1.000;
% Define thresholds for channel 6 based on histogram settings
channel6Min = 0.000;
channel6Max = 1.000;


</pre>
</code>

### 2. stage 1 단계 


    % stage 1
    while 1
        frame = snapshot(cam);
        % 카메라 영상 실시간
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
    
        figure('Name', 'plot centroid', 'NumberTitle','off');
        imshow(frame)
        hold on
        %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off
    
        dis = centroid - center_pts;        % 사각형 중점과 center_point 차이

        if dis(1) <= 35 && dis(1) >= -35 && dis (2) <= 35 && dis(2) >= -35
            disp("stage1 end")
            break
        end

        if dis(1) > 35 && dis(1) <= 80
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 40 && dis(1) < 80")
        elseif dis(1) < -35 && dis(1) > -80
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -40 && dis(1) > -80")
        end

        if dis(2) > 35 && dis(2) <= 80
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 40 && dis(2) < 80, down")
        elseif dis(2) < -35 && dis(2) >= -80
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -40 && dis(2) > -80")
            
        end
        
        dis_cm_x = dis(1)/750;              % 2는 민감도니깐 계산 할 것
        dis_cm_y = dis(2)/750;              % 2는 민감도니깐 계산 할 것
                
        % x축에 관한 움직임
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축에 관한 움직임
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축에 관한 움직임
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축에 관한 움직임
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

    moveforward(drone, 'Distance', 3.5, 'Speed',1);
    turn(drone,deg2rad(130));
     
    disp("stage2 start")
    
### 3. stage 2 단계
    frame = snapshot(cam);
    % 카메라 영상 실시간
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);

    
    % 회전 전 회전을 위한 중심찾기
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
    %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중점과 center_point 차이
    dis_cm = dis(1)/2;       % 2는 민감도니깐 계산 할 것
    deg_rad = atan(dis_cm/350);
    turn(drone,-deg_rad);
    
    moveforward(drone, 'Distance', 2.5, 'Speed', 1);

    % stage 2 중심찾기

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
        
        % 회전한 후의 중심찾기
    
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
        %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

        dis = centroid - center_pts;  % 사각형 중점과 center_point 차이
        
        % x와 y축으로 움직이는 부분
        dis_cm_x = dis(1)/750;       % 2는 민감도니깐 계산 할 것
        dis_cm_y = dis(2)/750;       % 2는 민감도니깐 계산 할 것

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
        
        % x축에 관한 움직임
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축에 관한 움직임
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축에 관한 움직임
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축에 관한 움직임
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
    
    moveforward(drone, 'Distance', 2.5 , 'Speed', 1);
    turn(drone,deg2rad(-120));

    disp("stage3 centroid start")
    
    disp("stage3 start")
    
    % stage 3
    
    frame = snapshot(cam);
    % 카메라 영상 실시간
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);
    
    % 회전 전 회전을 위한 중심찾기
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
    %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중점과 center_point 차이
    dis_cm = dis(1)/2;       % 2는 민감도니깐 계산 할 것
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")


### 4. stage 3 단계

    
    frame = snapshot(cam);
    % 카메라 영상 실시간
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);
    
    % 회전 전 회전을 위한 중심찾기
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
    %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중점과 center_point 차이
    dis_cm = dis(1)/2;       % 2는 민감도니깐 계산 할 것
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")

     % stage 3 중심찾기

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
    
        
        % 회전한 후의 중심찾기
    
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
        %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

        dis = centroid - center_pts;  % 사각형 중점과 center_point 차이
        
        % x와 y축으로 움직이는 부분
        dis_cm_x = dis(1)/750;       % 2는 민감도니깐 계산 할 것
        dis_cm_y = dis(2)/750;       % 2는 민감도니깐 계산 할 것

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
        
        % x축에 관한 움직임
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축에 관한 움직임
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축에 관한 움직임
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축에 관한 움직임
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

    disp("stage4 centroid start")
    
    disp("stage4 start")
    
    % stage 4
    
    frame = snapshot(cam);
    % 카메라 영상 실시간
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);

    % 회전 전 회전을 위한 중심찾기
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
    %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중점과 center_point 차이
    dis_cm = dis(1)/2;       % 2는 민감도니깐 계산 할 것
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")



### 5. stage 4 단계

   frame = snapshot(cam);
    % 카메라 영상 실시간
    preview(cam)
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blueMask_hsv = (channel4Min<h)&(h<channel4Max)&...
    (channel5Min<s)&(s<channel5Max)&...
    (v>channel6Min)&(v<channel6Max);

    % 회전 전 회전을 위한 중심찾기
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
    %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
    plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
    hold off

    dis = center_pts - centroid;  % 사각형 중점과 center_point 차이
    dis_cm = dis(1)/2;       % 2는 민감도니깐 계산 할 것
    deg_rad = atan(dis_cm/500);
    turn(drone,-deg_rad);

    frame = snapshot(cam);
    imwrite(frame, "after_turn_frame.jpg")

    
    
    % stage 4 중심찾기

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
        
        % 회전한 후의 중심찾기
    
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
        %%% 원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
        plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

        dis = centroid - center_pts;  % 사각형 중점과 center_point 차이
        
        % x와 y축으로 움직이는 부분
        dis_cm_x = dis(1)/750;       % 2는 민감도니깐 계산 할 것
        dis_cm_y = dis(2)/750;       % 2는 민감도니깐 계산 할 것

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
        
        % x축에 관한 움직임
        if dis(1) > 80 && dis(1) <= 150
            moveright(drone, "Distance", 0.2)
            disp("dis(1) > 80 && dis(1) < 150")
        elseif dis(1) < -80 && dis(1) >= -150
            moveleft(drone, "Distance", 0.2)
            disp("dis(1) < -80 && dis(1) > -150")
        end

        % y축에 관한 움직임
        if dis(2) > 80 && dis(2) <= 150
            movedown(drone, "Distance", 0.2)
            disp("dis(2) > 80 && dis(2) < 150, down")
        elseif dis(2) < -80 && dis(2) >= -150
            moveup(drone, "Distance", 0.2)
            disp("dis(2) < -80 && dis(2) > -150")
        end

        % x축에 관한 움직임
        if dis(1) > 150
            moveright(drone, "Distance", dis_cm_x)
            disp("dis(1) > 150")
        elseif dis(1) < -150
            moveleft(drone, "Distance", dis_cm_x)
            disp("dis(1) < -150")
        end

        % y축에 관한 움직임
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



  





  
