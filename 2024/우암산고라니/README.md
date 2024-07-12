2024 미니드론 자율비행 경진대회 우암산고라니팀
=
목차
-
1. 대회 진행 전략
2. 알고리즘 및 소스 코드 설명
3. 문제점

1 대회 진행 전략
=
저희의 대회 전략은 다음과 같습니다.
1) 이륙하고 가림막 원 중심 찾기
2) 드론을 원 중심으로 이동시키고 전진하기
3) 빨간색 인식 후 시계방향으로 130도 회전하기
4) 다시 1번 2번 실행하고 초록색 인식 후 시계반대방향으로 130도 회전하기
5) 다시 1번 2번 실행하고 보라색 인식 후 시계방향으로 215도 회전하기
6) 다시 1번 2번 실행하고 빨간색 인식 후 착륙하기

2 알고리즘 및 소스 코드 설명
=
먼저 드론의 센터 좌표를 설정하고 드론을 연결한다.
```
count = 0;                              % 전진 여부 확인 변수
center_point = [480,240];               % 센터 포인트 지정
centroid = zeros(size(center_point));   % 사각형 중심점

drone = ryze();                         
cam = camera(drone);
takeoff(drone); 
pause(1.2);
```

그 다음 링의 위치를 찾고 링의 위치 좌표와 센터 좌표를 비교하여 두 좌표를 맞춘다.
```
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
```

좌표를 맞추면 상황에 맞는 이동 거리만큼 이동한다.
```
    % 중심 찾음, 3.5m 이동
    if count == 1
        
        moveforward(drone,'Distance',3.5,'Speed', 0.8);
        pause(1);
        break;
    end
end
```

전진 후 색상 마커를 인식하여 다음에 동작할 코드를 if문을 통해 작성하였다.
```
% 이미지 받아오고 색 검출하기
while 1

    frame = snapshot(cam);
    pause(1);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_red = (h>1)|(h<0.05); % 빨간색 인식

    if sum(detect_red, 'all') >= 17000  % 인식하면 시계방향 130도 회전
        turn(drone,deg2rad(130));
        break
    end
end
```
빨간색, 녹색, 보라색 각각의 임계값을 찾아 대입하였다.

맨 위의 코드를 제외한 나머지 3개의 코드를 위의 대회 전략 순서에 맞게 조합하여 코드를 완성했다.

3 문제점
=
드론이 링의 중심을 찾으면 상황에 맞는 거리만큼 전진하도록 하였기 때문에 드론이 링의 중심을 앞, 뒤로 흔들리면서 찾게 되면 거리를 오버하는 문제점이 있다.
