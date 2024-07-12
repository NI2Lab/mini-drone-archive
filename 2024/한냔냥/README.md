# 2024 미니드론 경진대회 [한냔냥]

팀명 및 팀원 소개: 아주대학교 임베디드 소학회 COMP D&A 
팀 한냔냥(김정현, 안종원)

## 목차
1. 대회 진행 전략
2. 알고리즘 및 소스 코드 설명
3. 설계 시 마주한 문제점 및 해결방법
4. 개선 가능 사항

## 대회 진행 전략
### 1. 맵 상세 규격

![Untitled](https://github.com/jongwon1116/my_repository/assets/165548455/664da6d7-4af5-4095-ac0d-7ba4de781629)

  ### 1-1. 고정 사항
  - 1, 2, 3, 4 단계 링 지름: 57, 46, 46, 52cm
  - 2, 3, 4단계 색상표와 가림막 링 사이의 거리: 50, 75, 150cm

  ### 1-2. 변동 사항
  - 가림막 링 중심점의 높이 (80~100cm)
  - 1단계 출발점과 가림막 간의 거리(1.5~1.7m)
  - 1단계 가림막과 색상표 간의 거리(2.3~2.5m)
  - 1단계 회전 각도(120도~140도)
  - 2단계 출발점과 가림막 간의 거리(5.0~5.2m)
  - 2단계 회전 각도(120도~140도)
  - 3단계 출발점과 가림막 간의 거리(2.6~2.8m)
  - 3단계 회전 각도(200도~230도)
  - 4단계 출발점과 가림막 간의 거리(3.75~3.95m)
    
### 2. 주행 전략
#### 1. 회귀 분석 기반 알고리즘:

알고리즘 대부분이 회귀 분석 식으로 구성되어 있어 세밀하게 조정하여 안정적인 주행을 기대할 수 있다. 
   
ex) 드론의 이동 거리와 카메라 화면에서의 픽셀 이동 비율을 정확하게 계산하고, 드론과 크로마키 천 사이의 거리에 따라 이동 비율(scale)을 동적으로 계산

#### 2. 효율적인 이동 경로 설계

원의 중심을 찾고 드론을 이동시킬 때, 가능한 한 번에 목표 지점에 도달할 수 있도록 알고리즘을 설계하여 시간 단축 및 효율성을 극대화한다. 작은 이동과 큰 이동을 구분하여 필요한 경우에만 드론을 미세 조정함으로써 이동 시간을 최소화한다.
동적 임계값을 설정하여, 최소 이동 거리보다 작은 이동 값도 유의미하게 처리할 수 있도록 한다.

## 알고리즘 및 소스 코드 설명
### 1. Flowchart
<p align="center">
<img src="https://github.com/Jeomyo/My_repository/assets/162671161/29e67fcf-f045-47a5-b211-40276efbed5c" width="80%" height="40%">
</p>


### 2. 소스 코드 설명
   1. image_binarization
   2. calculateOffset
   3. movedrone
   4. findbestangle  
   5. Detectioncolor
   6. main.m

---

### 1. image_binarization

입력: 이미지, H_high 임계값, H_low 임계값, S_low 임계값, V_low 임계값
출력: 파란색 값을 1로 얻는 이진 이미지

가림막의 탐지를 위해 이미지와 임계값들을 입력으로 받아 hsv 차원에서 이진마스크를 생성하고 노이즈 제거를 수행한다. 

```
function color = image_binarization (img, h_down, h_up, s_down, v_down)
```
입력으로 받은 이미지를 각각 H, S, V 차원으로 나눈다. 이후 정량적 분석을 통해 구하여 입력으로 받은 임계값들을 사용하여 조건에 알맞는 이진마스크를 생성한다. 
```
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
```
strel 함수를 사용하여 반지름이 5인 원의 구조요소를 생성하고 이를 사용하여 모폴로지 팽창, 침식 동작을 수행하여 노이즈가 제거된 이진마스크를 출력으로 제공한다.
```
    % 노이즈 제거를 위해 모폴로지 연산 적용
    se = strel('disk', 5);
    color = imopen(color, se);
    color = imclose(color, se);

end
```

### 2. calcaulateOffset 함수

이 함수는 드론 카메라로 이미지를 캡처하고, 이 이미지를 binaryzation하여 파란색 객체를 식별한 후, 객체 중심점의 오프셋을 카메라 시점의 [480, 180]으로부터 차를 계산한다. 
여기서 카메라 시점의 중앙을 잡지 않고 특정 값을 잡은 이유는 드론 카메라가 정확히 정면을 바라보는 것이 아닌 아래로 비스듬히 바라보고 있기 때문에 이를 고려한 값이라고 할 수 있다.


먼저 regionprops로 객체를 검출하기 전 이미지 이진화를 진행한다.

```
blue = image_binarization(img, 0.535, 0.66, 0.5, 0.3);

% 구멍을 채움
bw2 = imfill(blue, 'holes');

% 구멍을 채우기 전후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
bw2 = bw2 & ~blue;

% 작은 객체 제거
bw2 = bwareaopen(bw2, 5000); % 5000 픽셀 이하의 객체 제거
```

이미지 이진화 후 bw2를 추출했을 때 이 함수가 판단하는 상황을 두 가지로 나눌 수 있다.


1. 크로마키 천의 구멍 (원)을 검출하였을 때
  
2. 크로마키 천의 구멍 (원)을 검출하지 못하였을 때

만약 1이었을 때는 원의 중점과 카메라 시점의 [480, 180] 값의 차를 계산하여 위치를 조정해야 할 offset과 원의 장축과 단축을 측정하여 평균을 내어 diameters를 반환한다.

```
% 가장 큰 객체만 선택
stats = regionprops('table', bw2, 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Area');

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
```

만약 2일 때는 크로마키 천 자체의 경계 박스를 추출한다.

```
% 객체의 경계박스를 찾음
stats_all = regionprops(blue, 'BoundingBox', 'Area');
if isempty(stats_all)
    disp('No objects detected in the binary mask.');
      disp("try move back");
      moveback(drone, "Distance",0.3,'Speed',1);
            
      else
         % 가장 큰 객체의 경계박스 선택
         all_areas = [stats_all.Area];
         [~, max_index] = max(all_areas);
         bbox = stats_all(max_index).BoundingBox;
```

후에는 경계 박스의 위치에 따라서 드론이 원을 검출하기 위해 이동해야 할 방향을 판단한다. 

판단의 기준은 다음과 같다.

1. 경계 박스의 왼쪽 상단 모서리의 x 좌표가 1보다 크고, 오른쪽 끝이 카메라의 오른쪽에 가려졌을 경우:
   
   드론을 오른쪽으로 이동하여 원을 다시 탐색하도록 한다.
```
   if bbox(1) > 1 && (bbox(1) + bbox(3) >= imgWidth)
    disp("move right");
    moveright(drone, 'Distance', 0.2, 'Speed', 1);
```

2. 경계 박스의 왼쪽 상단 모서리의 x 좌표가 1보다 작고, 오른쪽 끝이 카메라의 오른쪽에 가려지지 않았을 경우:
  
   드론을 왼쪽으로 이동하여 원을 다시 탐색하도록 한다.
```
elseif bbox(1) < 1 && (bbox(1) + bbox(3) < imgWidth)
    disp("move left");
    moveleft(drone, 'Distance', 0.2, 'Speed', 1);
```
 
3. 경계 박스의 위쪽 상단 모서리의 y 좌표가 1보다 크고, 아래쪽 끝이 카메라의 아래쪽에 가려졌을 경우:
  
    드론을 위쪽으로 이동하여 다시 탐색하도록 한다.
```
if bbox(2) > 1 && (bbox(2) + bbox(4) >= imgHeight)
    disp("move up");
    moveup(drone, "Distance", 0.2, 'Speed', 1);
```

4. 경계 박스의 위쪽 상단 모서리의 y 좌표가 1보다 작고, 아래쪽 끝이 카메라의 아래쪽에 가려지지 않았을 경우:
  
   드론을 아래쪽으로 이동하여 다시 탐색하도록 한다.
   
```
elseif bbox(2) < 1 && (bbox(2) + bbox(4) < imgHeight)
    disp("move down");
    movedown(drone, "Distance", 0.2, 'Speed', 1);
```

하지만 실제로 테스트해보는 과정에서 여러 가지 생각하지 못한 변수가 발생하였다. 따라서 몇 가지 변수들을 고려하여 추가적인 조건을 추가하였다.

1. 드론이 너무 가까워서 원을 화면에 다 담지 못해 검출을 못했을 경우:
아래와 같이 4개의 모서리의 파란색 픽셀 여부를 검출하여 모든 모서리에 픽셀이 검출되었을 시에 드론을 뒤로 이동시킨다. 
```
% 모서리의 파란색 픽셀 검출
 corners = [blue(1,1), blue(1,imgWidth), blue(imgHeight,1), blue(imgHeight,imgWidth)];
                
 if all(corners)
    disp('too close!');
    moveback(drone, 'Distance', 0.3,'Speed',1);
```
2. 경계 박스가 판단하여 이동할 때마다 count를 세어, count가 3이 될 때까지 원 검출이 되지 않았을 경우 정 위치에서 판단하기에는 무리가 있을 거라 판단하고 뒤로 후진하여 다시 경계 박스를 판단한다.
   
```
 elseif count == 3
        disp('count over.');
        moveback(drone, 'Distance', 0.3,'Speed',1);
        count = 0;
```

이 모든 과정은 원을 검출할 때까지 while 문을 통해 반복되며, 결과적으로 OffsetX, Y와 diameters를 반환한다.

### 3. movedrone 함수

이 함수는 CalculateOffset 함수에서 반환한 offsetX, offsetY 및 지름 값을 기반으로 이동해야 할 방향과 거리를 결정하여 드론을 이동하는 함수이다.
드론의 이동 거리는 선형, 비선형 회귀 분석을 통해 계산되며, 특정 임계 값을 기준으로 작은 이동과 큰 이동을 구분하여 명령을 실행한다.

#### 1. 크로마키 천과 드론 사이의 실제 거리 분석

이는 원의 지름 크기와 실제 거리의 관계에 기반해 진행하였다. 
원의 규격 종류가 3가지이므로 3가지의 데이터를 수집하였다.

회귀 분석은 아래와 같이 진행되었으며, 이를 통해 세운 공식은 아래와 같다.

|57cm|52cm|46cm|
|------|---|---|
|![image](https://github.com/Jeomyo/My_repository/assets/162671161/9bc34563-bc6e-425d-b38d-69384aa4dd67)|![image](https://github.com/Jeomyo/My_repository/assets/162671161/9bc34563-bc6e-425d-b38d-69384aa4dd67)|![image](https://github.com/Jeomyo/My_repository/assets/162671161/49803835-3f49-4355-8a28-60591201822f)|

```
switch step
    case 1
        distance = exp(-1.057238 * log(length) + 6.577108);
    case {2, 3}
        distance = exp(-1.02150 * log(length) + 6.224586);
    case 4
        distance = exp(-1.029708 * log(length) + 6.363963);
end
```

#### 2. 드론이 이동하는 실제 거리와 카메라 화면에서의 이동하는 픽셀 값의 비율

드론의 이동 거리와 카메라 화면에서의 픽셀 이동 비율은 드론과 크로마키 천 사이의 거리 및 0.2m 이동 시 변화하는 픽셀값을 기반으로 분석되었다. 

드론의 이동 시마다 약간의 오차가 발생했지만, 이를 감안한 평균값을 통해 다음과 같은 공식을 도출할 수 있었다: 

<p align="center">
<img src="https://github.com/Jeomyo/My_repository/assets/162671161/54678a78-f49f-4207-8d8b-5ccac3dab0dc" width="40%" height="40%">
</p>

```
% 이동 비율 계산 (pixels/m)
scale = 750 - 150 * distance;
```

예를 들어, 드론과 크로마키 천 사이의 거리, distance가 1.5m라면, 드론은 이 지점에서 수평 및 수직으로 525 pixel/m 만큼 움직이는 것으로 계산할 수 있다. 이를 통해 드론이 중점을 맞출 때 좀 더 정확한 위치 조정을 할 수 있었다.
```
threshold = scale * 0.2;

% 드론 이동 명령 (픽셀 값을 m로 변환하여 드론 이동)
moveX = offsetX / scale; % 이동 거리를 m 단위로 변환
moveY = offsetY / scale; % 이동 거리를 m 단위로 변환
```

Tello 드론의 최소 이동 거리가 0.2m 이므로 이를 threshold로 잡고, OffsetX,Y를 scale로 나누어주어 pixel 이동거리는 m로 반환한다. 그리고 이 값만큼 이동시키면 원의 중점에 맞출 수 있다.
```
% X 값 조정
elseif abs(offsetX) > threshold
    if moveX < 0
        disp("move left");
        disp(moveX);
        moveleft(drone,'distance', -moveX,'Speed',1); % 왼쪽으로 이동
    elseif moveX > 0 
        disp("move right");
        disp(moveX);
        moveright(drone,'distance', moveX,'Speed',1); % 오른쪽으로 이동
    end
end

elseif abs(offsetY) > threshold
    
% Y값 조정
if moveY > 0
        disp("move up");
        disp(moveY);
        moveup(drone,'distance', moveY,'Speed',1); % 위로 이동
    elseif moveY < 0
        disp("move down");
        disp(moveY);
        movedown(drone,'distance', -moveY,'Speed',1); % 아래로 이동
    end
end
```
하지만 실제 이동 거리를 계산했을 때, 0.19m나 0.18m처럼 최소 이동 거리(0.2m)보다 작지만 유의미하게 움직여야 하는 값이 있을 수 있다. 이를 처리하기 위해 다음과 같은 조건을 설정하였다:

```
% X 값 조정
if abs(offsetX) < threshold && abs(offsetX) > threshold - abs(offsetX) 
    if moveX < 0 
        disp("move left small");
        moveleft(drone,'distance', 0.2,'Speed',1); % 왼쪽으로 이동
    elseif moveX > 0
        disp("move right small");
        moveright(drone,'distance', 0.2,'Speed',1); % 오른쪽으로 이동
    end

% Y 값 조정
if abs(offsetY) < threshold && abs(offsetY) > threshold - abs(offsetY)
     if moveY > 0
        disp("move up small");
        moveup(drone,'distance', 0.2,'Speed',1); % 위로 이동
     elseif moveY < 0
        disp("move down small");
        movedown(drone,'distance', 0.2,'Speed',1); % 아래로 이동
     end
```

쉽게 설명하자면, moveX 또는 moveY 값이 threshold / 2보다 큰 경우, 중점을 정확히 맞출 수는 없지만, 0.2m를 이동함으로써 이동하지 않은 것보다 더 중점에 가까운 결과를 얻을 수 있다. 
이러한 접근 방식은 드론의 이동을 보다 정밀하게 조정하여 목표 지점에 더욱 가까워지도록 할 수 있다. 
```
if abs(offsetX) < threshold - abs(offsetX) && abs(offsetY) < threshold - abs(offsetY) 
    centerfind = true;
    return;
```
마지막은 moveX 또는 moveY 값이 threshold / 2보다 작아지면 이 함수를 종료한다.

### 4. findbestangle 함수

이 함수는 드론이 단계에 따라 각도 범위 내에서 회전하면서 각도별로 촬영한 이미지에서 크로마키 천의 원의 지름을 측정하여, 가장 작은 지름을 갖는 각도를 찾아 반환한다. 
이러한 이유는 드론이 같은 위치에서 회전할 때 화면과 원의 관계가 수직에 가장 가까울 때 원의 지름이 가장 작게 측정되기 때문이다.

```
function bestAngle = findbestangle(drone, cam, step)

    switch step
        case 2 
            angles = 110:10:150;
        case 3
            angles = -120:-5:-140; 
        case 4
            angles = 200:7.5:230; 
    end

    diameters = zeros(1, length(angles));
```

먼저 step 값에 따라 적절한 각도 배열 angles를 생성하고, 이 배열의 요소 개수에 맞춰 원의 지름을 저장할 배열 diameters를 초기화한다. 
여기서 case 2와 case 4의 각도가 대회장 각도 규격과 다른 이유는, 드론이 색상표를 인식한 후 바로 각도를 찾는 것이 아니라 먼저 절반 길이를 직진한 후 각도를 찾기 때문이다. 
절반 길이를 먼저 직진하는 이유는 각도를 탐색하던 중 다른 크로마키 천과 겹쳐 인식이 될 수 있기 때문이다.

<p align="center">
<img src="https://github.com/Jeomyo/My_repository/assets/162671161/6ec8a0c1-e4ee-4438-bf3b-e00186b5f1ba" width="60%" height="60%">
</p>

case 2를 예로 들면 먼저 130도로 회전하여 각도 범위의 중앙으로 이동한다. 이렇게 하면 모든 각도에 대응하기 용이해진다.
색상 인식 후, 드론이 회전한 다음 절반 길이인 2.5m를 간다면 우리가 5도씩 탐색하려 했던 각을 10도씩 회전한다면 절반 길이를 가지 않고 bestangle을 탐색한 것과 같은 효과를 얻을 수 있다.

##### 최적 각도 찾기

각 각도에서 이미지를 캡처하고, 이진화하여 파란색 객체(크로마키 천의 원)를 식별한 후, 객체의 지름을 계산하여 배열에 저장한다. 
만약 객체가 감지되지 않으면, 지름 값을 큰 값(1000)으로 설정하여 후속 처리에서 무시되도록 한다. 모든 각도에 대해 탐색한 후, 지름이 가장 작은 각도를 찾아 반환한다.

```
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
            diameters(i) = 1000;
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
```
탐색이 끝났다면 최적의 각도로 드론을 재회전 시킨다. 
```
[~, minIndex] = min(diameters);
bestAngle = angles(minIndex);

turn(drone, deg2rad(bestAngle - angles(end)));

disp('best angle: ');
disp(bestAngle);
```


### 5. Detectioncolor 알고리즘

hsv 형식으로 색 인식을 진행 할 경우, 임계값 조정 계산이 복잡하여 구현에 어려움이 있었다. 따라서 RGB값을 사용하여 색 인식을 진행하였다. 
먼저 입력 인자로 받은 cam을 통해 snapshot을 하여 이미지를 얻은 후, 이미지를 각각 R차원, G차원, B차원으로 나눈다.
우리가 인식해야 할 색상표가 Red, Green, Purple 3가지 이므로 임계값을 그에 맞게 정해준다. 

우리는 좀 더 세밀한 조정을 위해서 여기서도 회귀 분석을 진행하였다. 드론과 색상표의 거리를 예측할 수 있게 되면 고려할 사항이 줄어든다.
거리 예측은 binarzation된 색상의 픽셀 합과 실제 거리의 관계를 기반으로 분석하였다. 이를 통해 세운 공식은 다음과 같다.

<img width="695" alt="image" src="https://github.com/Jeomyo/My_repository/assets/162671161/1252c4ae-465e-4d03-a4c2-0a10e40c2fde">

```
distance = exp(-0.471769 * log(sum(purple (:))) + log(64.104421));
```


### 5-1. DetectionRed 

먼저 입력 인자로 받은 cam을 통해 snapshot을 하여 이미지를 얻은 후, 이미지를 각각 R차원, G차원, B차원으로 나눈다. 
```
img = snapshot(cam);
image1R = img(:,:,1);
image1G = img(:,:,2);
image1B = img(:,:,3);
```

그 다음 Red의 탐지를 용이하게 하기 위해 G차원과, B차원의 값을 절반으로 감소시킨다. 거리에 따른 정량적 분석을 통해 임계값을 조정하였다.  Red의 경우, step1, step4에서 동일하게 사용되므로 step1의 임계값과 step4의 임계값의 범위 사이의 값으로 설정하였다. 

```
image_only_R = image1R - image1G / 2 - image1B / 2;
threshold=50;
red = image_only_R > threshold;
```

다음으로 거리에 따른 R픽셀의 총합을 데이터셋으로 만들어, 비선형 회귀분석을 실시하여 R픽셀의 총합(x축)과 거리(y축)의 그래프와 수식을 도출하였다. 

```
distance = exp(-0.471769 * log(sum(red(:))) + log(64.104421));
```
step에 따른 케이스를 나누고 step1의 경우, 측정 시 충분히 가까워(0.7m) 더 이상 앞으로 갈 필요가 없을 경우 또는 너무 가까워 빨간색 픽셀이 탐지되지 않을 경우를 조건문으로 사용하여, 
드론의 회전을 진행하였다. 거리가 0.7m보다 멀 경우에는 색상표와 드론의 거리(distance)와 색상표와 드론의 임계 거리(0.5m)의 차만큼 이동한 후 회전을 진행한다.
```
switch step
    case 1

if  distance < 0.7 || sum(red(:)) == 0
    turn(drone,deg2rad(130));
    return;
end

moveforward(drone,'Distance', distance - 0.5, 'Speed', 1);

turn(drone,deg2rad(130));

    case 2

if  distance < 0.95 || sum(red(:)) == 0
    land(drone);
    return;
end
moveforward(drone,'Distance', distance - 0.75, 'Speed', 1);
land(drone);
end
```
### 5-2. DetectionGreen 

먼저 입력 인자로 받은 cam을 통해 snapshot을 하여 이미지를 얻은 후, 이미지를 각각 R차원, G차원, B차원으로 나눈다. 
```
img = snapshot(cam);
image1R = img(:,:,1);
image1G = img(:,:,2);
image1B = img(:,:,3);
```
그 다음 Green의 탐지를 용이하게 하기 위해 R차원과, B차원의 값을 절반으로 감소시킨다. 거리에 따른 정량적 분석을 통해 임계값을 조정하였다.
```
image_only_G = image1G - image1R / 2 - image1B / 2;
threshold=30;
green = image_only_G > threshold;

```
다음으로 거리에 따른 G픽셀의 총합을 데이터셋으로 만들어, 비선형 회귀분석을 실시하여 G픽셀의 총합(x축)과 거리(y축)의 그래프와 수식을 도출하였다. 

```distance = exp(-0.471769 * log(sum(green (:))) + log(64.104421));```

측정 시 충분히 가까워(1m) 더 이상 앞으로 갈 필요가 없을 경우 또는 너무 가까워 초록색 픽셀이 탐지되지 않을 경우를 조건문으로 사용하여, 드론의 회전을 진행하였다. 거리가 1m 보다 멀 경우에는 색상표와 드론의 거리(distance)와 색상표와 드론의 임계 거리(0.8m)의 차만큼 이동한 후 회전을 진행한다.
```
if  distance < 1 || sum(green(:)) == 0
    turn(drone,deg2rad(-135));
    return;
end

moveforward(drone,'Distance', distance - 0.8, 'Speed', 1);  
 
turn(drone,deg2rad(-135));

end
```

### 5-3. DetectionPurple

먼저 입력 인자로 받은 cam을 통해 snapshot을 하여 이미지를 얻은 후, 이미지를 각각 R차원, G차원, B차원으로 나눈다. 
```
img = snapshot(cam);
image1R = img(:,:,1);
image1G = img(:,:,2);
image1B = img(:,:,3);
```

그 다음 주어진 purple의 색상값과 거리에 따른 정량적 분석을 토대로 R값과 B값에 비해 G값이 덜 유동적이라는 것을 발견하였다. 따라서 G값에 scaling_factor를 곱하여 일정 범위의 보라색만을 탐지하였다.
```
scaling_factor=1.1;
purple = (R > G) & (B > R) & (B > scaling_factor*G);
```

다만 보라색의 경우, 그림자가 탐지되는 경우가 많이 발생하였다. 이에 작은 객체를 제거하여 오차의 가능성을 최대한 제거하였다.

```purple = bwareaopen(purple, 200);```
 
다음으로 거리에 따른 RGB픽셀의 총합을 데이터셋으로 만들어, 비선형 회귀분석을 실시하여 G픽셀의 총합(x축)과 거리(y축)의 그래프와 수식을 도출하였다. 

```distance = exp(-0.471769 * log(sum(purple (:))) + log(64.104421));```

측정 시 충분히 가까워(1m) 더 이상 앞으로 갈 필요가 없을 경우 또는 너무 가까워 초록색 픽셀이 탐지되지 않을 경우를 조건문으로 사용하여, 드론의 회전을 진행하였다. 거리가 1m 보다 멀 경우에는 색상표와 드론의 거리(distance)와 색상표와 드론의 임계 거리(0.8m)의 차만큼 이동한 후 회전을 진행한다.
```
if  distance < 1.3 || sum(purple_mask(:)) == 0
    turn(drone,deg2rad(215));
    return;
end

moveforward(drone,'Distance', distance - 1.15, 'Speed', 0.7);  

end
```


### 6. main 코드

위의 알고리즘을 바탕으로 구동되는 main 함수이다.

- #### step1

calculateOffset함수를 사용하여 offset들과 원의 직경을 반환받는다. 이후 movedrone를 사용하여 직경을 받아 step 별 회귀분석식으로 구한 scale을 통해 얻은 임계값과 offset들을 비교하여 드론의 수직 수평운동을 결정한다.

일정 거리 전진 후, DetectionRed 함수의 step1일 때의 움직임을 실행하여 색상판과 드론과의 거리가 0.5m가 되게 한다. 마지막으로 130도 회전하고 step을 1 상승시키면서 마무리한다.

```
%step1
step = 1;

% 중심점과 이동해야 할 거리를 계산하는 함수
[offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
length = diameters; 

% 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
movedrone(drone, offsetX, offsetY, length, step);

% 카메라와 도형이 중심을 맞췄다면 드론 직진
moveforward(drone,'distance',2.2,'Speed',1);

% 빨간색을 마주하면 130도 회전하는 코드
DetectionRed(drone,cam,step);

step = step + 1;

```

- #### step2

step1 이후 드론의 위치가 너무 낮아졌을 수 있으므로 0.3m 상승시킨다. 
일정 거리 전진 후, 반시계 방향으로 20도 회전한 상태에서 findbestangle을 실행하여 step에 따른 최적의 각도를 도출한다. 
이후 반복문을 사용하여 calculateOffset함수를 사용하여 구한 offset들의 오차를 최소로 한다. 

이후 movedrone를 사용하여 직경을 받아 구한 scale을 통해 얻은 임계값과 offset들을 비교하여 드론의 수직 수평운동을 결정한다.
일정 임계값보다 offset이 적게 나온다면 반복문을 빠져나온다.DetectionGreen을 사용하여 색상판과 드론과의 거리가 1m 될 때까지 이동한다. 마지막으로 반시계 방향으로 120도 회전하고 step을 1 상승시키면서 마무리한다.

```
%step2
moveup(drone,'distance',0.3,'Speed',1);
moveforward(drone,'distance',2.3,'Speed',0.8);

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

step = step + 1;
```
- #### step3

 step2 이후 바로 findbestangle을 실행하여 step에 따른 최적의 각도를 도출한다. 
 일정 거리 전진 후, calculateOffset과 movedrone함수를 사용하여 드론의 중점을 링의 중심에 맞춘다. 
 
 다음 DetectionPurple 사용하여 색상판과 드론과의 거리가 1.25m 될 때까지 이동한다. 시계 방향으로 215도 회전한다. 마지막으로 step을 1 상승시키면서 마무리한다.
 
```
% -120~-140도 중 최적의 각도 검색
findbestangle(drone,cam,step);

moveforward(drone,'distance',0.3,'Speed',1);

% 중심점과 이동해야 할 거리를 계산하는 함수
[offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
length = diameters; 

% 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
movedrone(drone, offsetX, offsetY, length, step);

moveforward(drone,'distance',1,'Speed',1);

DetectionPurple(drone,cam);

step = step + 1;
```

- #### step4
 일정 거리 전진 후, 시계 방향으로 20도 회전한 상태에서 findbestangle을 실행하여 step에 따른 최적의 각도를 도출한다. 이후 calculateOffset과 movedrone함수를 사용하여 드론의 중점을 링의 중심에 맞춘다.
 
 0.3m 전진 후, 다시 한 번 calculateOffset과 movedrone함수를 사용하여 드론의 중점을 링의 중심에 맞춘다. DetectionRed의 step4일 때의의 움직임을 수행하여 색상판과 드론과의 거리가 0.75m 될 때까지 이동한다. 
 마지막으로 land하며 최종적으로 모든 움직임을 마무리한다.
 
```
moveforward(drone,'distance',1,'Speed',0.5);

turn(drone,deg2rad(20));

findbestangle(drone,cam,step);

% 중심점과 이동해야 할 거리를 계산하는 함수
[offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
length = diameters; 

% 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
movedrone(drone, offsetX, offsetY, length, step);

moveforward(drone,'distance',0.3,'Speed',0.5);

% 중심점과 이동해야 할 거리를 계산하는 함수
[offsetX, offsetY,  diameters] = calculateOffset(drone, cam);
length = diameters; 

% 중심점과의 거리를 구했다면 그만큼 드론을 이동시키는 함수
movedrone(drone, offsetX, offsetY, length, step);

DetectionRed(drone,cam,step);
```
---

## 설계 시 마주한 문제점 및 해결방법

1. [문제점]
  - MATLAB Support Package for Ryze Tello가 지원하는 드론 최소 이동거리가 0.2m라는 문제점이 있었다.
  - 드론의 실제 위치가 카메라 상의 중심점이 아닌 좀 더 위에 위치한다는 문제점이 있었다.
  - 드론의 speed 1로 할 시 드론이 살짝씩 밀리는 현상이 보였다.


2. [해결방안]  
  - 임계값의 절반 보다 크면 이동하고, 작으면 이동하지 않는 코드를 넣어 문제를 해결하였다. 
  - 카메라의 중심점인 (480, 360)이 아닌 (480,180)으로 설정하여 드론이 안정적으로 원을 통과할 수 있도록 하였다.
  - 보다 정밀한 조정이 필요한 원 중점 맞추기나 boundingbox 로직 구현에 있어 speed가 1이 아닌 speed를 0.5로 설정하였다.


## 개선 가능 사항

- findbestangle 시 회전하는 각도를 줄일수록 더 정확한 각도를 찾을 수 있었지만 시간 관계 상 적절한 크기의 회전각을 설정하였다. 회전각을 위 코드보다 작게 설정한다면 가림막과 드론이 완전히 수평이 될 수 있을 것으로 보인다.   
- MATLAB Support Package for Ryze Tello Toolbox에 의한 제한 사항(최소 이동 거리, 최대 속도 etc…)이 다수 존재하였다. 매트랩 Toolbox 사용이 아닌 Tello SDK를 사용하는 방식으로 코드를 구성한다면 많은 요소를 개선할 수 있을 것으로 보인다.


---
                                                           한냔냥 
                                                       김정현, 안종원


