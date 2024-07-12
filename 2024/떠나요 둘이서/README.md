<대회 진행 전략>

아래의 경기장을 총 4단계로 구성하였다.
![image](https://github.com/hyeonjood/minidrone/assets/131336782/f3b98db0-6033-4f3c-bf20-f4e02269e81e)


1단계 : 이륙 -> 첫 번째 링 통과 후 빨간색 마커 앞에서 시계방향 120도 회전

2단계 : 초록색 마커 앞의 두 번째 링 앞까지 전진 후 반시계방향 120도 회전

3단계 : 보라색 마커 앞의 세 번쨰 링 앞까지 전진 후 시계방향 215도 회전

4단계 : 네 번째 링 통과 후 빨간색 마커 앞에서 착륙

경기장과 유사한 환경을 조성하기 위해서 학교 강의실을 빌려 정확한 치수를 계산해 물품들을 세팅하였다.

![image](https://github.com/hyeonjood/minidrone/assets/131336782/ebdac061-f99a-41a7-856c-912d768df4ef)


<알고리즘 설명>

1단계 : 드론이 이륙한 후 뒤로 후진하여 파란색 사각형의 중심을 찾기 쉽도록 한다. 파란색 사각형의 중점을 맞춘 뒤 장축 거리를 계산해 전진하여 첫 번째 링을 통과한다. 빨간색 마커의 RGB 범위를 계산하여 화면의 빨간색 픽셀 값이 10000 이상이 되면 드론이 충분히 전진했다고 판단하여 시계 방향으로 120도 회전한다. 픽셀 값이 10000 이하라면 10000 이상이 될 때까지 상하좌우로 조금씩 움직인다. 

2단계 : 3미터 앞으로 전진하고 파란색 사각형의 중점을 맞춘다. 초록색 마커의 중심을 찾고 RGB 범위를 계산하여 화면의 초록색 픽셀 값이 10000 이상이 되면 드론이 충분히 전진했다고 판단하여 반시계 방향으로 120도 회전한다. 픽셀 값이 10000 이하라면 추가로 1미터 전진한다.

3단계 : 파란색 사각형의 중점을 맞춘다. 앞으로 1.2미터 전진하고 보라색 마커의 RGB 범위를 계산하여 화면의 보라색 픽셀 값이 10000 이상이 되면 드론이 충분히 전진했다고 판단하여 시계 방향으로 215도 회전한다. 픽셀 값이 10000 이하라면 추가로 0.2미터 전진한다.

4단계 : 파란색 사각형의 중점을 맞춘 뒤 장축의 거리를 계산해 전진하여 네 번째 링을 통과한다. 화면의 빨간색 픽셀 값이 10000 이상이 되면 드론이 충분히 전진했다고 판단하여 그 자리에서 착륙한다. 픽셀 값이 10000 이하라면 10000 이상이 될 때까지 상하좌우로 움직인다.


제한시간 조건을 만족하기 위하여 전진 시 속도는 오차가 크게 발생하지 않는 한 최대한 빠르게 설정해야 한다. 중심 좌표의 허용오차의 범위에 따라 소요시간이 달라지므로 코드를 직접 테스트해보며 조정하였다.


![알고리즘 다이어그램](https://github.com/hyeonjood/minidrone/assets/131336782/4780089a-a19d-467c-aaa2-95b0305455a7)

![1단계 알고리즘 (2)](https://github.com/hyeonjood/minidrone/assets/131336782/7ba8c3bc-8e04-4262-9a8f-76dcfa885d15)

![2단계 알고리즘](https://github.com/hyeonjood/minidrone/assets/131336782/a2a92445-5461-43d0-b2f0-dd805ab2b161)

![3단계 알고리즘](https://github.com/hyeonjood/minidrone/assets/131336782/0df07ecb-d7a8-432d-ba21-a9ed0fa03ba7)

![4단계 알고리즘](https://github.com/hyeonjood/minidrone/assets/131336782/4307c3fe-6a09-4c3a-8ca1-3fe579e6537a)


<소스코드 설명>

파란색 천, 빨간색 마커, 초록색 마커, 보라색 마커의 RGB 범위 설정은 아래와 같이 이미지의 색을 감지하는 코드를 이용하였다.
```ruby
clear;

% 현재 작업 폴더에 있는 이미지 파일 이름
imagePath = '1720594857653.jpg';

% 이미지 읽기
frame = imread('1720594857653.jpg');

% 파란색 사각형 RGB 범위 설정
r = frame(:,:,1);   detect_r = (r > 151) & (r < 194);   
g = frame(:,:,2);   detect_g = (g > 25) & (g < 99);
b = frame(:,:,3);   detect_b = (b > 9) & (b < 99);

% 파란색 영역 감지
blueNemo = detect_r & detect_g & detect_b;

% 감지된 영역 시각화
imshow(blueNemo);

% 감지된 픽셀 수 출력
disp(sum(blueNemo,'all'));
```

1단계
```ruby
clear;
drone = ryze();
cam = camera(drone);
takeoff(drone);

moveback(drone, 'Distance', 0.5, 'Speed', 1);  % 사각형 전체 한 번에 인식하기 위해 뒤로 이동

% 중심 점 설정
center_point = [480, 200];
centroid = zeros(size(center_point));
count = 0;

movecount = 0;

% 1단계
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);  % 파란색 사각형 RGB 범위 설정
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);
    blueNemo = detect_r & detect_g & detect_b;

    % 파란색 사각형 중심 찾기
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

    dis = centroid - center_point;  % 파란색 사각형 중점과 center_point 차이

    % 중심 점을 찾아 이동
    if abs(dis(1)) <= 35 && abs(dis(2)) <= 35  % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!");
        count = 1;
    
    elseif dis(2) <= 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);  % 0.2미터씩 속도 1로 이동
        
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
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
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
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        movecount = movecount + 1;
        if movecount >= 10
            disp("Move forward...");
            break;
        end

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

        % 장축 길이 값 추출
        stats = regionprops('table', bw, 'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);

        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw, 'all') <= 10000
            moveforward(drone, 'Distance', 2, 'Speed', 1);

        elseif longAxis > 860
            moveforward(drone, 'Distance', 2, 'Speed', 1);

        else
            distance = (3E-06) * (longAxis)^2 - 0.0065 * longAxis + 4.3; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance + 0.5, 'Speed', 0.5);  
        end

        break;
    end
end

% 빨간색 마커 중심 찾기
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 151) & (r < 194);   % 빨간색 마커 RGB 범위 설정
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

    % 빨간색 마커의 중심 점 찾아 이동
    if abs(dis(1)) <= 50 && abs(dis(2)) <= 70  % x 좌표 차이, y 좌표 차이가 각각 50, 70보다 작을 경우 center point 인식
        disp("Find Red Center Point!");
        disp(sum(redNemo,'all'))
        % 빨간색 픽셀의 합이 10000 이상인지 확인
        if sum(redNemo,'all') >= 10000
            disp("Red pixels exceed 10000, stopping...");
            break;
        else
            disp("Moving forward to get closer...");
            moveforward(drone, 'Distance', 0.25, 'Speed', 0.5);  % 빨간색 픽셀의 합이 10000 이하라면 속도 0.5로 0.25미터씩 추가 전진
            break;
        end
        

    elseif dis(2) <= 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);  % 0.2미터씩 속도 0.5로 이동
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end
    elseif dis(2) <= 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
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

    elseif dis(2) > 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
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
turn(drone, deg2rad(120)); % 시계방향으로 120도 회전
disp('1st Stage Finish');  % 1단계 완료
```

2단계
```ruby
% 2단계
movecount = 0;

moveforward(drone, 'Distance', 3, 'Speed', 1);

while true
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   % 파란색 사각형의 RGB 범위 설정
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);
    blueNemo = detect_r & detect_g & detect_b;

    % 파란색 사각형 중심 찾기
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

    % 파란색 사각형의 중심 점 찾아 이동
    if abs(dis(1)) <= 35 && abs(dis(2)) <= 50  % x 좌표 차이, y 좌표 차이가 각각 35, 50보다 작을 경우 center point 인식
        disp("Find Center Point!");
        count = 1;
        break;
    elseif dis(2) <= 0 && abs(dis(2)) <= 50 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);  % 0.2미터씩 속도 0.5로 이동
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end

    elseif dis(2) <= 0 && abs(dis(2)) > 50
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 35
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 35
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 35
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 50 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end

    elseif dis(2) > 0 && abs(dis(2)) > 50
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 35
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 35
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 35
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
    end
        
end

% 초록색 마커 중심 찾기
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 90);  % 초록색 마커의 RGB값 설정
    g = frame(:,:,2);   detect_g = (g > 95) & (g < 255);
    b = frame(:,:,3);   detect_b = (b > 0) & (b < 180);
    greenNemo = detect_r & detect_g & detect_b;
    
    areaNemo = regionprops(greenNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
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

    % 초록색 마커의 중심 점 찾아 이동
    if abs(dis(1)) <= 50 && abs(dis(2)) <= 70  % x 좌표 차이, y 좌표 차이가 각각 50, 70보다 작을 경우 center point 인식
        disp("Find green Center Point!");
        disp(sum(greenNemo,'all'))
        % 초록색 픽셀의 합이 10000 이상인지 확인
        if sum(greenNemo,'all') >= 10000
            disp("green pixels exceed 10000, stopping...");
            break;
        else
            disp("Moving forward to get closer...");
            moveforward(drone, 'Distance', 1, 'Speed', 0.5);  % 초록색 픽셀의 합이 10000 이하라면 속도 0.5로 1미터씩 추가 전진
            break;
        end
        

    elseif dis(2) <= 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);  % 0.2미터씩 속도 0.5로 이동
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end
    elseif dis(2) <= 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
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

    elseif dis(2) > 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
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

disp('2nd Stage Finish');    % 2단계 완료
turn(drone, deg2rad(-120));  % 반시계방향으로 120도 회전
```

3단계
```ruby
%3단계
movecount = 0;

while true
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   % 파란색 사각형의 RGB 범위 설정
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);
    blueNemo = detect_r & detect_g & detect_b;

    % 파란색 사각형 중심 찾기
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
        break;
    
    elseif dis(2) <= 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);  % 0.2미터씩 속도 0.5로 이동
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end
    elseif dis(2) <= 0 && abs(dis(2)) > 35
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 35
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 35
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 35
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end

    elseif dis(2) > 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
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

    elseif dis(2) > 0 && abs(dis(2)) > 35
        if dis(1) <= 0 && abs(dis(1)) > 35
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 1);
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end

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
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
        end        
    end

end

disp("move forward")
moveforward(drone, 'Distance', 1.2, 'Speed', 1);  % 1.2미터 속도 1로 전진

% 보라색 마커 중심 찾기

movecount = 0;
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 70) & (r < 220);   % 보라색 마커의 RGB 범위 설정
    g = frame(:,:,2);   detect_g = (g > 0) & (g < 128);
    b = frame(:,:,3);   detect_b = (b > 128) & (b < 210);
    purpleNemo = detect_r & detect_g & detect_b;
    

    areaNemo = regionprops(purpleNemo, 'BoundingBox', 'Centroid', 'Area'); % 속성 측정; BoundingBox, Centroid, Area 값 추출
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
    if abs(dis(1)) <= 50 && abs(dis(2)) <= 70  % x 좌표 차이, y 좌표 차이가 각각 50, 70보다 작을 경우 center point 인식
        disp("Find purple Center Point!");
        disp(sum(purpleNemo,'all'))
        % 보라색 픽셀의 합이 10000 이상인지 확인
        if sum(purpleNemo,'all') >= 10000
            disp("purple pixels exceed 10000, stopping...");
            break;
        else
            disp("Moving forward to get closer...");
            moveforward(drone, 'Distance', 0.2, 'Speed', 0.5);  % 보라색 픽셀의 합이 10000 이하라면 속도 0.5로 0.2미터씩 추가 전진
            break;
        end
        

    elseif dis(2) <= 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
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
    elseif dis(2) <= 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
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

    elseif dis(2) > 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
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

disp('3rd Stage Finish');   % 3단계 완료
turn(drone, deg2rad(215));  % 시계방향으로 215도 회전
```

4단계
```ruby
% 4단계

movecount = 0;


moveforward(drone, 'Distance', 2, 'Speed', 1);
while true
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 0) & (r < 40);   % 파란색 사각형 RGB 범위 설정
    g = frame(:,:,2);   detect_g = (g > 8) & (g < 250);
    b = frame(:,:,3);   detect_b = (b > 35) & (b < 210);
    blueNemo = detect_r & detect_g & detect_b;
    % 파란색 사각형 중심 찾기
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

    % 파란색 사각형의 중심 점 찾아 이동
    if abs(dis(1)) <= 35 && abs(dis(2)) <= 35  % x 좌표 차이, y 좌표 차이가 35보다 작을 경우 center point 인식
        disp("Find Center Point!");
        count = 1;
    
    elseif dis(2) <= 0 && abs(dis(2)) <= 35 && abs(dis(1)) > 35
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 1);  % 0.2미터씩 속도 1로 이동
        
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

        % 장축 길이 값 추출
        stats = regionprops('table', bw, 'MajorAxisLength');
        longAxis = max(stats.MajorAxisLength);

        % 장축 길이에 따라서 거리 계산 후 이동
        if sum(bw, 'all') <= 10000
            moveforward(drone, 'Distance', 0.2, 'Speed', 1);

        elseif longAxis > 460
            moveforward(drone, 'Distance', 0.2, 'Speed', 1);

        else
            distance = (1E-05) * (longAxis)^2 - 0.0124 * longAxis + 4.5996; % 드론과 링 사이의 거리
            moveforward(drone, 'Distance', distance+0.3, 'Speed', 1);   
        end

        break;
    end
end

% 빨간색 마커 중심 찾아서 정지
while 1
    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r > 151) & (r < 194);   % 빨간색 마커 RGB 범위 설정
    g = frame(:,:,2);   detect_g = (g > 25) & (g < 99);
    b = frame(:,:,3);   detect_b = (b > 9) & (b < 99);
    redNemo = detect_r & detect_g & detect_b;
    
% 빨간색 마커 중심 찾기
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

    % 빨간색 마커 중심 점 찾아 이동
    if abs(dis(1)) <= 50 && abs(dis(2)) <= 70  % x 좌표 차이, y 좌표 차이가 각각 50, 70보다 작을 경우 center point 인식
        disp("Find Red Center Point!");
        disp(sum(redNemo,'all'))
        % 빨간색 픽셀의 합이 10000 이상인지 확인
        if sum(redNemo,'all') >= 10000
            disp("Moving...");
            break;
        else
            disp("Moving forward to get closer...");
            moveforward(drone, 'Distance', 0.3, 'Speed', 0.5);  % 빨간색 픽셀의 합이 10000 이하라면 속도 0.5로 0.3미터씩 추가 전진
            break;
        end
        

    elseif dis(2) <= 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
        if dis(1) <= 0
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);  % 0.2미터씩 속도 0.5로 이동
        
        elseif dis(1) > 0
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end
    elseif dis(2) <= 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
            disp("Move up");
            moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
        movecount = movecount + 1;
        if movecount >= 10
            disp("Moving...");
            break;
         end        

    elseif dis(2) > 0 && abs(dis(2)) <= 70 && abs(dis(1)) > 50
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

    elseif dis(2) > 0 && abs(dis(2)) > 70
        if dis(1) <= 0 && abs(dis(1)) > 50
            disp("Move left");
            moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) > 0 && abs(dis(1)) > 50
            disp("Move right");
            moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
        
        elseif dis(1) <= 0 && abs(dis(1)) <= 50
            disp("Move down");
            movedown(drone, 'Distance', 0.2, 'Speed', 0.5);

        elseif dis(1) > 0 && abs(dis(1)) <= 50
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

disp('4th Stage Finish');  % 4단계 완료
disp('Mission Complete!'); % 미션 성공
land(drone);  % 착륙
```
