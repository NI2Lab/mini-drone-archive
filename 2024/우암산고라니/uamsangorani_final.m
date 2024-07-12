clear;

count = 0;                              % 전진 여부 확인 변수
center_point = [480,240];               % 센터 포인트 지정
centroid = zeros(size(center_point));   % 사각형 중심점

drone = ryze();                         
cam = camera(drone);
takeoff(drone); 
pause(1.2);

% step 1
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
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

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 3
    elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 5
    elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음, 3.4m 이동
    if count == 1
        
        moveforward(drone,'Distance',3.4,'Speed', 0.8);
        pause(1);
        count = 0; % 초기화
        break;
    end
end

% 이미지 받아오고 색 검출하기
while 1

    frame = snapshot(cam);
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_red = (h>1)|(h<0.05); % 빨간색 인식

    if sum(detect_red, 'all') >= 17000  % 인식하면 시계방향 130도 회전
        turn(drone,deg2rad(130));
        pause(1);
        moveforward(drone,'Distance',2.5,'Speed',0.8);
        pause(1);
        break
    end
end

% step 2
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
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

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 3
    elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 5
    elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음, 2.5m 이동
    if count == 1
        
        moveforward(drone,'Distance',2.5,'Speed', 0.8);
        pause(1);
        count = 0; % 초기화
        break;
    end
end

% 이미지 받아오고 색 검출하기
while 1

    frame = snapshot(cam);
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_green = (h>0.275)&(h<0.325); % 녹색 인식

    if sum(detect_green, 'all') >= 14000  % 인식하면 반시계방향 130도 회전
        turn(drone,deg2rad(-130));
        break
    end
end

%step 3
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
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

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 3
    elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 5
    elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음, 2.6m 이동
    if count == 1
        
        moveforward(drone,'Distance',2.6,'Speed', 0.8);
        pause(1);
        count = 0; % 초기화
        break;
    end
end

% 이미지 받아오고 색 검출하기
while 1

    frame = snapshot(cam);
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_purple = (h>0.7)&(h<0.75); % 보라색 인식

    if sum(detect_purple, 'all') >= 16000  % 인식하면 시계방향 215도 회전
        turn(drone,deg2rad(215));
        break
    end
end

%step 4
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    
    % 사각형 중심 찾기
    areaNemo = regionprops(blueNemo,'BoundingBox','Centroid','Area');   % 속성 측정; BoundingBox, Centroid, Area 값 추출
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

    dis = centroid - center_point;  % 사각형 중점과 center_point 차이

    % case 1
    if(abs(dis(1))<=35 && abs(dis(2))<=35)    % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!"); 
        count = 1;
   
    % case 2
    elseif(dis(2)<=0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 3
    elseif(dis(2)<=0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
       
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move up");
            moveup(drone,'Distance',0.2,'Speed',1);
        end

    % case 4
    elseif(dis(2)>0 && abs(dis(2))<=35 && abs(dis(1))>35)
        if(dis(1)<=0)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
        end    

    % case 5
    elseif(dis(2)>0 && abs(dis(2))>35)
        if(dis(1)<=0 && abs(dis(1))>35)
            disp("Move left");
            moveleft(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)>0 && abs(dis(1))>35)
            disp("Move right");
            moveright(drone,'Distance',0.2,'Speed',1);
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        
        elseif(dis(1)<=0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);

        elseif(dis(1)>0 && abs(dis(1))<=35)
            disp("Move down");
            movedown(drone,'Distance',0.2,'Speed',1);
        end
    end
    
    % 중심 찾음, 3.75m 이동
    if count == 1
        
        moveforward(drone,'Distance',3.75,'Speed', 0.8);
        pause(1);
        count = 0; % 초기화
        break;
    end
end

% 이미지 받아오고 색 검출하기
while 1

    frame = snapshot(cam);
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_red = (h>1)|(h<0.05); % 빨간색 인식

    if sum(detect_red, 'all') >= 17000  % 인식하면 시계방향 130도 회전
        land(drone);
        break
    end
end

