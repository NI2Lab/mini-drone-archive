# 2023_MiniDrone_푸아앙_code

<br>

## 0. 목 차

1. 개요
2. 이미지 프로세싱
3. 링 중점 찾기
4. 각도 찾기
5. 회귀 분석을 통한  최종 이동 거리 계산
6. 최종 코드 설명

<br><br>

## 1. 개 요

1. 드론 이륙 후, 이미지 프로세싱을 통해 boundary의 개수를 세어 boundary의 개수가 2가 될 때까지 중심점쪽으로 조금씩 움직인다
2. boundary의 개수가 2인 경우 원이 완벽히 보인다고 판단하여 실제 원의 직경과 픽셀의 비율을 이용하여 중점에 정렬한다
3. 카메라의 각도가 아래로 향해 있기에 y축에 대한 보상 하고, <br>이동 거리가 정해져 있기 때문에 boundary의 개수를 세는 과정에서 후진한 만큼 보상하여 직진한다
4. 이후 90도를 회전하고 [Level 2], [Level 3]도 동일한 과정을 반복하지만 [Level 3]는 링 통과 이후 60도를 회전한다
5. [Level 4]에서 각이 30~60도 이기 때문에 60도에서 -3도씩 돌며 [Level 4]장애물의 높이가 카메라 상에서 같아질 때까지 회전한다
6. 높이가 같을 경우 카메라와 장애물이 수직이라고 판단하고 중심을 정렬 후 회귀 분석한 거리 -1m 만큼 직진 후 착륙한다

<br><br>

## 2. 이 미 지 프 로 세 싱

이미지의 rgb를 hsv로 바꾸고 h,s,v의 임계값을 충분한 실험을 걸쳐 적절하게 정하였다. <br>
우리는 이미지 프로세싱을 걸쳐 드론이 통과하게 되는 원을 찾아야 했기에 <br>
드론이 촬영한 이미지 상에서 원의 경계 또는 원 전체를 따는 것을 위한 코드를 작성하였다.<br>
코드는 아래와 같다.

```matlab
img = snapshot(cam);
hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
blue = ((0.58 < h)&(h < 0.67))&(0.3 < s)&(0.96 > v);
detectBlue = bwareafilt(blue, 1);
cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
cannyfill = imfill(cannybinaryImg, 4, "holes");
ring = bwareafilt(cannyfill, 1);

```

- ‘blue’는 충분한 실험을 통해 정한 임계값을  rgb 이미지를 hsv 이미지로 바꾼 후 적용한 이미지이다.
- ‘detectBlue’는 ‘blue’이미지에서 제일 큰 흰색 부분 하나만 남기고 나머지 부분은 없애는 “bwareafilt’ 코드를 이용하였다.
- ‘cannybinaryImg’는 보통 흰 화면에 검은색 동그라미가 있는 이미지인 ‘detectBlue’의 경계를 ‘edge’코드를 이용하여 추출한다.
- ‘cannyfill’은 앞서서 추출한 경계의 구멍을 채운 이미지이며 보통 흰색으로 채워진 동그라미에 네모난 경계를 가지고 있는 이미지이다.
- ‘ring’의 경우 제일 큰 부분 하나만 남겨진 이미지이기 때문에 흰색 동그라미 하나만 남겨지게 된다.

아래는 위 코드를 한 예시에 적용한 것이다.
<br>
![2](https://github.com/firmino23/PUAANG/assets/68437864/81233f3b-0dda-40ad-a2d9-1554b675f14c)
<br><br>

## 3. 링 중 점 찾 기

이미지 프로세싱을 거치고 난 후 이미지의 경계를 이용하여 원의 중점을 찾으려고 했다.<br>
링 중점 찾기에 앞서 우리는 이미지에 나타난 경계의 수가 1개, 2개, 그리고 그 외 개수일 때로 나누었다.

1. 경계의 수가 1개일 때

경계의 수가 원 전체가 보이면서 2개가 되기 위해 드론을 이동해야 한다. <br>
따라서 이때 바깥 경계의 좌표를 이용하여 드론이 이동을 하게 되는데 코드는 아래와 같다. 

```matlab
    try
    detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
    detectBlue_x = detectBlueProperty.BoundingBox(1);
    detectBlue_y = detectBlueProperty.BoundingBox(2);
    detectBlue_w = detectBlueProperty.BoundingBox(3); 
    detectBlue_h = detectBlueProperty.BoundingBox(4);
    ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
```

- ‘regionprops’ 코드의 “boundingbox”를 이용하여 왼쪽 맨 위의 좌표 x, y와 폭과 높이 w, h를 알 수 있다.

```matlab
if boundaryNum == 1
    if detectBlue_x <= 10
        moveleft(drone,'Distance', 0.3);
    elseif detectBlue_x + detectBlue_w >= 950
         moveright(drone,'Distance', 0.3);
    end
    if detectBlue_y <= 10
        moveup(drone,'Distance',0.3);
    elseif detectBlue_y + detectBlue_h >= 710
        movedown(drone,'Distance',0.3);
    end
end
```

- 위 코드에서 x축 방향에서는 10, 950과 y축 방향으로 10, 710으로 제한을 둔 이유는 드론으로 찍힌 이미지의 크기가 960*720 이기 때문이다.<br>
위 코드를 적용하기 전 예시는 아래와 같이 설명할 수 있다.<br>
<img width="40%" src="https://github.com/firmino23/PUAANG/assets/68437864/18f89c85-fa18-46b6-9af8-a02cb6159f1e"/>
<img src="https://github.com/firmino23/PUAANG/assets/68437864/cf60de1f-0691-4216-acfd-432b74b030d1" align="center">
<br>

- 오른쪽 이미지는 왼쪽 이미지의 ‘detectBlue’이다. ‘regionprops’를 이용하면 빨간 점의 좌표를 구할 수 있는데 <br>
좌표의 x가 0이기 때문에 드론은 왼쪽으로 이동할 것이다.<br>

- 경계를 추출하고 나서 매우 작은 경계들조차 포함된다면 중점이 제대로 찾아지지 않을 것이다. <br>
따라서 아래 코드에서 경계 위에 있는 픽셀 수가 200개 미만의 짧은 경계를 없애는 코드를 이용한다.<br>
1단계, 2단계, 3단계 모두 800으로 하였다. 이는 충분한 실험을 통해 정하였다. 해당 코드는 아래와 같다.

```matlab
boundary = bwboundaries(detectBlue);
boundaryCell = cellfun(@length,boundary);
i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 200
                boundary(i) = [];
                boundaryCell(i) = [];
               i = i - 1;
            end
        catch
            break 
        end
    end
```

- ‘boundaryCell’은 추출된 경계 위의 픽셀들의 각각의 좌표를  ‘cellfun’  코드를 이용하여 구한 것이다. <br>
나중 경계의 수가 2개일 때 ‘boundaryCell’에서 ‘min’ 코드를 이용하여 안쪽 원 경계 위 픽셀들의 위치 만을 구하는데 이용된다.<br>
2. 경계의 수가 2개일 때

경계가 2개 추출되었을  때는 안쪽 경계 원과 바깥쪽 사각 경계가 동시에 잡혔을 때이다. <br>
그런데 만약 통과 해야 할 원뿐만 아니라 다른 단계의 원의 경계가 잡혔을 때가 잇기 때문에<br>
이때는 원의 장축과 단축의 비율을 통해 타원일 경우 무시하게 코드를 설정하였고 그 코드는 아래와 같다. 

```matlab
if ringProperty.MinorAxisLength/ringProperty.MajorAxisLength <= 0.6
    moveleft(drone, 'Distance', 0.7)
    continue
end
```

- 경계가 2개가 추출되었을 때는 경계가 1개 추출되었을 때처럼 0.3m 씩 각 방향으로 한번 움직이지 않는다.<br>
제한 시간 내 빠른 통과를 한다면 1픽셀이 의미하는 실제 길이를 구해 중심으로 필요한 길이로<br>
(위 또는 아래), (왼쪽 또는 오른쪽)으로 각각 한 방향으로 한번만 움직이게 코드를 설정하였다. <br>
코드는 아래와 같다.

```matlab
  elseif boundaryNum == 2

        if ringProperty.MinorAxisLength/ringProperty.MajorAxisLength <= 0.6
            moveleft(drone, 'Distance', 0.7)
            continue
        end

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.57/ringDiameter; %% *
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));

```

- ‘1. 경계의 수가 1개일 때’ 부분에서 말했 듯이 ‘min’ 코드를 이용하여 원의 경계 위 픽셀들의 좌표를 구한다.<br>
‘ringMat’은 이 좌표들을 담은 행렬인데 1 열의 경우는 x축 방향, 2 열의 경우는 y축 방향의 좌표이다.<br>
- 1픽셀의 실제 거리를 구하기 위해 원의 직경을 구해야 한다. 원의 직경은 x축 방향에서의 원의 직경과 y축 방향에서의 원의 직경의 평균으로 하여 오차를 줄인다. <br>
각 축 방향으로의 원의 직경은 ‘max’와 ‘min’ 함수를 이용하여 두 좌표 간의 차이를 이용하여 구한다.<br>
- ‘regCo’는 1픽셀의 실제 거리를 의미하며 통과하려는 원의 지름을 직경(단위: 픽셀)로 나누어 계산한다.<br>

<img width="40%" src="https://github.com/firmino23/PUAANG/assets/68437864/13b4db3f-730e-48c1-a3f7-a4962b5eabe3"/>
<img src="https://github.com/firmino23/PUAANG/assets/68437864/731fd391-3c53-4d84-b066-b694e6c3120f" align="center">
<br>

- 위 사진은 코드를 설명하기 위한 예시이다. <br>
먼저 두 개의 빨강 점 중 x좌표가 더 큰 점이 ‘max(ringMat(:,1))’, 작은 점이 ‘min(ringMat(:,1))’이다.<br>
이와 같이 두 개의 파랑 점 중 y좌표가 더 큰 점이 ‘max(ringMat(:,2))’, 작은 점이 ‘min(ringMat(:,2))’이다.<br>
- 안쪽 원의 경계의 중심은 각 축 좌표의 최대와 최소의 평균을 계산하여 구했다.

드론이 이동하기 위해 필요한 것들은 미리 계산을 하였기 때문에 이를 이용하여 이제 이동만 하면 된다.<br>
드론은 한 번 움직일 때 최소 0.2m 움직이기 때문에 만약 경계가 2개가 잡힌 후 움직여야 하는 길이가 0.2m보다 작은 경우를  생각해야 한다.<br>
중심으로 이동해야 하는 거리가 0.1m보다 작을 때는 만약 0.2m 이동하게 된다면 처음보다 중심과의 거리가 멀어지는 것이기 때문에 움직이지 않는 것이 낫다.<br>
이동하는 거리가 0.1m~0.2m사이일 경우에는 해당 방향으로 0.2만 움직인다.<br>

```matlab
dx = ringCenter_x - 480;    
if dx < 0
    command_x = 'L';
elseif dx >0
    command_x = 'R';
end
actual_dx = abs(dx)*regCo;
command_dx = round(actual_dx, 1);
if  <= 0.1
command_x = 'S';
end
dy = ringCenter_y - 360;
if dy < 0
    command_y = 'U';
elseif dy >0
    command_y = 'D';
end
actual_dy = abs(dy)*regCo;
command_dy = round(actual_dy, 1);
if command_dy <= 0.1
    command_y = 'S';
end
```

- 위 코드는 드론이 원의 중심으로부터 어디에 있는 지에 따라 명령어가 나오는 코드이다.<br>
예를 들어 원의 중심으로부터 왼쪽에 있다면 ‘dx’가 0보다 작기 때문에  command_x=‘L’이다.<br>
‘command_x’와 ‘command_y’는 어디로 이동해야 하는 지에 대한 명령어이다.<br>
- 위 코드에서 ‘actual_dx’와 ‘actual_dy’는 이동해야 하는 실제 거리를 의미하며<br>
앞서 구했던 중심과드론의 x, y좌표 차이를 ‘regCo’에 곱해 계산한다.<br>

```matlab
        if command_x == 'L'
            moveleft(drone,'Distance',command_dx)
        elseif command_x == 'R'
            moveright(drone,'Distance',command_dx)
        elseif command_x == 'S'
            disp('no x move')
        end
        if command_y == 'U'
            moveup(drone,'Distance',command_dy)
        elseif command_y == 'D'
            movedown(drone,'Distance',command_dy)
        elseif command_y == 'S'
            disp('no ymove')
        end
        break
```

- 위 코드는 그 전 코드에서 계산한 값만큼 이동을 하게하는 코드이다.

<br><br>

## 4.  각 도   찾 기

4단계 표적 앞 1m 앞에 정확히 떨어지기 위해서는 드론이 4단계 표적의 90도 정면으로 서있어야 한다.<br>
따라서 3단계를 통과하고 적절하게 일정 각도를 돌면서 표적의 중점을 찾아야 한다.<br>
우리는 3단계를 통과한 후 3단계 표적 기준 최대 각도인 60도를 시계 방향으로 회전한 후 점차 반시계 방향으로 0.05 rad만큼 회전하도록 코드를 설계하였다.

```matlab
boundaryNum = length(boundary);  
    if detectBlue_y <= 10 || detectBlue_y + detectBlue_h >= 710
        moveright(drone, 'Distance', 0.2)
        moveback(drone, 'Distance', 0.2)
        continue
    end
```

- 위 코드의 경우는 사각 경계가 카메라를 꽉 채웠을 때 오른쪽으로 이동한 후 뒤로 이동하는 코드이다.<br>
다음과 같이 이동하는 이유는 반 시계 방향으로 회전하는 것을 멈추는 조건을 <br>
사각 경계의 왼쪽과 오른쪽 양쪽의 길이의 차이가 10보다 작을 때라고 했기 때문에 사각 경계가 완전히 보여야 한다.

```matlab
    if detectBlue_x + detectBlue_w >= 950 
        moveright(drone, 'Distance', 0.2)
        continue
    end
```

- 위 코드는 만약 반 시계 방향으로 회전할 시 오른쪽 세로 경계 부분이 잘려진다면 오른쪽으로 이동하라는 코드이다.

```matlab
    ones = find(detectBlue);
    for i = 1: length(ones)
        ones_x(i) = fix(ones(i)/720);
        ones_y(i) = rem(ones(i),720) - 1;
        if ones_y(i) == -1
            ones_x(i) = ones_x(i) - 1;
            ones_y(i) = ones_y(i) + 721;
        end
        topleft(i) = ones_x(i)^2 + ones_y(i)^2; 
        topright(i) = (ones_x(i)-960)^2 + ones_y(i)^2; 
        bottomleft(i) = ones_x(i)^2 + (ones_y(i) - 720)^2; 
        bottomright(i) = (ones_x(i)-960)^2 + (ones_y(i) - 720)^2;
    end
    [~, topleftNum] = min(topleft.^1/2);
    [~, toprightNum] = min(topright.^1/2);
    [~, bottomleftNum] = min(bottomleft.^1/2);
    [~, bottomrightNum] = min(bottomright.^1/2);
    sideRatio = (ones_y(bottomleftNum) - ones_y(topleftNum)) - (ones_y(bottomrightNum) - ones_y(toprightNum));
    if turnCount > 30
        break
    elseif sideRatio > 10
        turn(drone, -0.05)
        turnCount = turnCount + 1;
    elseif sideRatio <= 10
        break
    end
```

- 위 코드는 60도를 돌고 정렬했을 때 장애물의 좌측 변의 길이가 우측 변의 길이보다 길기 때문에<br>
반 시계로 돌면서 둘의 길이가 같아질 때 드론과 장애물이 수직이라고 판단하는 코드이다.

<br><br>

## 5. 회 귀 분 석 을 통 한 이 동 거 리 계 산

4단계에서 표적 중심으로부터 거리가 1m 앞에서 착륙하기 위해서는 회귀를 통해 표적으로부터 거리 1m 앞으로 이동해야 한다.<br>
회귀에는 거리(Y)와 원의 지름(X)을 이용한 비선형  회귀 분석을 이용하였다.<br>
원의 지름을 회귀 분석에 이용한 이유는 원 안의 픽셀수는 2차원이기 때문에 바라보는 각도에 따라 오차가 1차원인 원의 반지름에 비해 커지기 때문이다.<br>

표적으로부터 거리 2m부터 0.7m까지 0.02m 단위로 총 66개의 데이터를 측정하였다.

회귀 분석은 2차,3차에 비해 비선형 4차 회귀 함수의 결정계수(r)가 1에 가깝기 때문에 4차 함수로 회귀를 진행하였다.<br>
회귀에 쓰인 코드는 아래와 같다.

```matlab
D=readtable("regressioninfo.xlsx","VariableNamingRule","preserve");
a{1}=table2array(D(1:66,3)); a{2}=table2array(D(1:66,4));

y=a{1};x=a{2};

z=[ones(length(x),1) x x.^2 x.^3 x.^4];
S=(z'*z)\(z'*y);
Sr=sum((y-z*S).^2);
r2=1-Sr/sum((y-mean(y)).^2);
k=sqrt(r2);
X=linspace(150,450,100000);
Y=polyval([S(5) S(4) S(3) S(2) S(1)],X);
```
![5](https://github.com/firmino23/PUAANG/assets/68437864/26c8417d-0fc9-4608-a644-9683b17cf7e0)

<br><br>

## 6. 최 종 코 드 설 명

```matlab
% 초기 설정
clc; clear;
drone = ryze();
cam = camera(drone);
% 이륙
takeoff(drone);
% 1단계 시작 및 정확도 향상을 위한 드론 위치 조정
Level = 1
backCount = 0;
moveup(drone, 'Distance', 0.5, 'Speed', 1);
moveback(drone, 'Distance', 0.5, 'Speed', 1);
while 1
    img = snapshot(cam);
    % 이미지 분리
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    % 파란 부분만 찾기 위한 임계값 설정
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v); 
    % 가장 큰 1개 객체 남기기 - 필터
    detectBlue = bwareafilt(blue, 1);
    % 원의 이미지 경계 찾기
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10);
    % 원만 채우기
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    % 원만 남기기
    ring = bwareafilt(cannyfill, 1);
    try
        % 이진 이미지의 특성파악
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        % x,y - 장애물 좌상단, w,h - 장애물 폭과 높이
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    % 이진 이미지의 경계 파악
    boundary = bwboundaries(detectBlue);
    % 모든 경계 길이 계산
    boundaryCell = cellfun(@length, boundary);
    % 경계 길이가 너무 작은 경우 삭제
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 800
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    % 최종 경계의 개수
    boundaryNum = length(boundary);
    % 이진 이미지 좌표형식으로 변환   
    ones = find(detectBlue);
    for i = 1: length(ones)
        ones_x(i) = fix(ones(i)/720);
        ones_y(i) = rem(ones(i),720) - 1;
        if ones_y(i) == -1
            ones_x(i) = ones_x(i) - 1;
            ones_y(i) = ones_y(i) + 721;
        end
        topleft(i) = ones_x(i)^2 + ones_y(i)^2; 
        bottomleft(i) = ones_x(i)^2 + (ones_y(i) - 720)^2; 
    end
    % 장애물 왼쪽변의 중점 찾기
    [~, topleftNum] = min(topleft.^1/2);
    [~, bottomleftNum] = min(bottomleft.^1/2);
    leftSide_x = (ones_x(bottomleftNum) + ones_x(topleftNum))/2;
    % 장애물 왼쪽변의 중점이 우측에 있다면 시작 위치가 장애물의 좌측이라고 판단
    % 시간 단축을 위해 우측으로 크게 이동
    if leftSide_x > 300
        moveright(drone, 'Distance', 0.7);
        continue
    end
    % biundary의 개수가 1개일 경우(링을 찾지 못한 경우)
    % 원을 향해 조금씩 이동
    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.2);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.2);
        end
    % boundary의 개수가 2개일 경우(링이 완전히 보일 경우)
    elseif boundaryNum == 2
        % 다음 단계의 링에 의해 boundary 개수가 2개 됐을 경우
        % 다음 단계의 링은 타원으로 보일 것이기 때문에 무시하고 후진
        if ringProperty.MinorAxisLength/ringProperty.MajorAxisLength <= 0.6
            moveback(drone, 'Distance', 0.5);
            backCount = backCount + 1;
            continue
        end
        % 작은 boundary(링) 인덱싱
        [~, num] = min(boundaryCell);
        % 링의 좌표 구하기
        ringMat = cell2mat(boundary(num));
        % 링의 가장 긴 가로와 세로의 평균으로 직경 구하기
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        % 거리 계산 인자 구하기
        regCo = 0.78/ringDiameter; 
        % 링의 중점 구하기
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        % 움직일 방향 결정 및 움직일 거리 계산
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end
        break
    % boundary의 개수가 0일 경우(아무것도 보이지 않을 경우)
    % 또는 boundary 개수가 3 이상일 경우(다음 Level의 링이 인식될 경우)
    else
        % 후진하여 현재 Level의 링을 인식하거나 다음 Level의 링을 작게 만들어 무시
        moveback(drone,'Distance', 0.5, 'Speed',1);
        backCount = backCount + 1;

    end
end
% 드론 카메라의 각도에 의한 y축 보상
movedown(drone,'Distance', 0.4, 'Speed', 1);
% 드론을 링 중앙에 정렬하며 후진한 경우 backCount를 1씩 늘려 직진할 때 보상
moveforward(drone,'Distance', 3.0 + 0.5*backCount, 'Speed', 1);
% 다음 Level을 위해 90도 회전
turn(drone, deg2rad(90));
% 정확도 향상을 위해 드론 위치 조정
moveback(drone, 'Distance', 0.8, 'Speed', 1);

% Level 2는 Level 1과 동일하며
% Level 3는 마지막에 60도를 돌고 후진하지 않는 것을 
% 제외하고 모두 동일합니다

Level = 4
% 먼저 위의 코드와 동일하게 링의 중앙에 정렬
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    ...
    % 동일하기에 생략하겠니다
end
% 카메라 상에 장애물이 잘릴 경우 또는 장애물 전체가 보이기 위해 뒤나 위로 이동
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
    catch
        continue
    end
    if detectBlue_y <= 10 
        moveup(drone, 'Distance', 0.3)
    elseif detectBlue_y + detectBlue_h >= 710
        movedown(drone, 'Distance', 0.3)
    end
    break
end
turnCount = 0;
% 맵이 30 ~ 60도이므로 먼저 60도를 돈 상태에서 약 -3도씩 돌아 장애물과 드론의 수직을 정렬
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 200
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);  
    if detectBlue_y <= 10 || detectBlue_y + detectBlue_h >= 710
        moveright(drone, 'Distance', 0.2)
        moveback(drone, 'Distance', 0.2)
        continue
    end
    if detectBlue_x + detectBlue_w >= 950 
        moveright(drone, 'Distance', 0.2)
        continue
    end
    ones = find(detectBlue);
    for i = 1: length(ones)
        ones_x(i) = fix(ones(i)/720);
        ones_y(i) = rem(ones(i),720) - 1;
        if ones_y(i) == -1
            ones_x(i) = ones_x(i) - 1;
            ones_y(i) = ones_y(i) + 721;
        end
        topleft(i) = ones_x(i)^2 + ones_y(i)^2; 
        topright(i) = (ones_x(i)-960)^2 + ones_y(i)^2; 
        bottomleft(i) = ones_x(i)^2 + (ones_y(i) - 720)^2; 
        bottomright(i) = (ones_x(i)-960)^2 + (ones_y(i) - 720)^2;
    end
    [~, topleftNum] = min(topleft.^1/2);
    [~, toprightNum] = min(topright.^1/2);
    [~, bottomleftNum] = min(bottomleft.^1/2);
    [~, bottomrightNum] = min(bottomright.^1/2);

    % 60도를 돌고 정렬했을 때 장애물의 좌측변의 길이가 우측 변의 길이보다 길기 때문에
    % 반시계로 돌면서 둘의 길이가 같아질 때 드론과 장애물이 수직이라고 판단
    sideRatio = (ones_y(bottomleftNum) - ones_y(topleftNum)) - (ones_y(bottomrightNum) - ones_y(toprightNum));
    % 30 ~ 60도이기 떄문에 최대 -30도만 돌게 설정
    if turnCount > 30
        break
    elseif sideRatio > 10
        turn(drone, -0.05)
        turnCount = turnCount + 1;
    elseif sideRatio <= 10
        break
    end
end
% 위와 같이 링의 중앙으로 정렬
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 200
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);    

    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.3);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.3);
        end

    elseif boundaryNum == 2

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.50/ringDiameter; 
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end

        % 회귀 분석을 통한 이동 거리 계산
        realDistance = polyval([1.326476927048637e-10 -2.260626850551402e-07 1.504186358212177e-04 -0.048674850178656 7.580227872959118],ringDiameter);
        distance = (ceil(realDistance*10))/10;
        % 회귀 분석의 성능이 1.8m부터 높은 것으로 판단되어
        % 장애물까지 1.8m 남기고 이동 후 다시 정렬 후 1m 앞까지 전진
        % 1m보다 가깝다면 뒤로 후진
        if distance == 1.9
            moveforward(drone,'Distance', 0.2);
            continue
        elseif distance > 2.0
            moveforward(drone,'Distance', distance - 1.8);
            continue
        elseif distance < 1.2
            moveback(drone,'Distance', 1.8 - distance)
            continue
        else
            moveforward(drone,'Distance', distance - 1);
            break
        end

    else
   
        moveback(drone,'Distance', 0.2, 'Speed',1);

    end
end
% 착 륙
land(drone)
```
