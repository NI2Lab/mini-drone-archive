# 대한전기학회 2023 미니드론 자율비행 경진대회
대한전기학회 2023 미니드론 자율비행 경진대회  
팀 국민대통합 기술워크샵
<p align="center"><img src="image/map1.png" width="44%" height="33%"></img>
<img src="image/map2.png" width="44%" height="33%"></img></p>             

***
## 대회 진행 전략
* 맵 상세 규격
  * 고정 사항
    * 드론 이륙 지점과 1단계 링 사이 거리 : 1m
    * 1, 2, 3, 4단계 링 지름 : 78cm, 78cm, 57cm, 50cm
    * 1, 2, 3단계 링과 표식 사이 거리 : 2m
    * 4단계 링과 표식 사이 거리 : 1m
    * 드론 착륙 지점과 4단계 링 사이 거리 : 1m
  
  * 변동 사항
    * 링의 높이(바닥과 천 사이 간격) : 50 ~ 150cm 이내
    * 링의 좌우 : -2 ~ 2m 이내
    * 링의 각도 : 30 ~ 60° 이내

 * 링 중점 찾기
    * 파란색 RGB 설정
    * center_point 설정
    * regionprops 함수로 파란색 사각형[^1] 중심 좌표 계산
    * center_point와 파란색 사각형 중심 좌표 상하좌우 차이를 이용하여 드론 위치 조절
    * 오차 범위 내에 드론 위치하면 중점으로 인식    

>  **사각형**을 검출하여 중심 좌표를 얻도록 한다.

<img src="image/blueNemo.png" width="44%" height="33%">   

* 링 통과하기

  * 파란색 HSV 설정
  * 원 검출 후 regionprops 함수로 장축 길이 측정
  * 장축 길이에 따른 드론과 링 사이 거리 값 추출
  * 추출한 값들로 회귀 분석을 통해 드론 이동 거리 식 도출
  * 드론 이동시켜 링 통과

> **원**을 검출하여 장축의 길이로부터 드론의 이동 거리를 얻도록 한다.

<img src="image/blueO.png" width="44%" height="33%">                

* 링 통과 후 드론 제어
  * 드론이 링을 통과하면 바로 단계에 맞게 명령 코드[^2]를 입력하여 제어
  * 1, 2단계 : 90도 우회전
  * 3단계 : 30 ~ 60° 사이 회전
  * 4단계 : 착륙

* 4단계 각도 조절
  * 각도 변동 범위가 30 ~ 60° 이내이므로 30°부터 5°씩 회전시키며 최적의 각도[^3] 탐색
***
## 알고리즘 및 소스 코드
**변수 선언**
```MATLAB
count = 0;                              % 전진 여부 확인 변수
center_point = [480,240];               % 사각형 중심점이 center_point와 일치해야 통과
centroid = zeros(size(center_point));   % 사각형 중심점
```
**ryze 객체 만들기 → 드론의 카메라에 연결 → 드론 이륙**
```MATLAB
drone = ryze();                         
cam = camera(drone);
takeoff(drone);
```
**링 중점 찾기**
+ 파란색 RGB 설정
```MATLAB
frame = snapshot(cam);
r = frame(:,:,1);   detect_r = (r < 50);   
g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
blueNemo = detect_r & detect_g & detect_b;
```
+ 파란색 사각형 중심 좌표 계산
```MATLAB
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
```
+ center point와 사각형 중심 좌표와 차이를 이용해 드론 위치 조절
<p align="center">
    <img src="image/case.png" width="80%" height="60%">
</p>         

> 드론이 천을 바라보았을 때의 경우를 크게 상하좌우 4가지로 나누었다. 그 후 세부적으로 경우의 수를 따져 아래와 같이 여러 case에 따라 드론 위치를 조절하는 코드를 작성했다.       

```MATLAB
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
**링 통과하기**
+ 파란색 HSV 설정 및 원 검출
```MATLAB
hsv = rgb2hsv(frame);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
blue = (0.535<h)&(h<0.69)&(0.4<s)&(v>0.1)&(v<0.97);

blue(1,:) = 1;
blue(720,:) = 1;
bw = imfill(blue,'holes');
for x=1:720
    for y=1:size(blue,2)
        if blue(x,y)==bw(x,y)
            bw(x,y)=0;
        end
    end
end

% 속성 측정; 장축 길이 값 추출
stats = regionprops('table',bw,'MajorAxisLength');
longAxis = max(stats.MajorAxisLength);
```
+ 회귀 분석을 통해 장축 길이에 따른 드론 이동 거리 관계식 도출
<p align="center">
    <img src="image/reGressionAnalysis_1,2.png" width="44%" height="33%">
</p>                     

```MATLAB
% 1단계
if sum(bw,'all') <= 10000
    moveforward(drone, 'Distance', 2, 'Speed', 1);
    
elseif longAxis > 860
    moveforward(drone, 'Distance', 2, 'Speed', 1);
    
else
    distance = (3E-06)*(longAxis)^2 - 0.0065*longAxis + 4.3399; % 드론과 링 사이의 거리
    moveforward(drone, 'Distance', distance + 1, 'Speed', 1);   % 링과 표식 사이 거리의 절반만큼 추가 이동
    distance
end
```
```MATLAB
% 2단계
if sum(bw,'all') <= 10000
    moveforward(drone, 'Distance', 2.2, 'Speed', 1);
    
elseif longAxis > 860
    moveforward(drone, 'Distance', 2.2, 'Speed', 1);    % 1.2m+1m
    
else
    distance = (3E-06)*(longAxis)^2 - 0.0065*longAxis + 4.3399; % 드론과 링 사이의 거리
    moveforward(drone, 'Distance', distance + 1, 'Speed', 1);   % 링과 표식 사이 거리의 절반만큼 추가 이동
    distance
end
```
<p align="center">
    <img src="image/reGressionAnalysis_3.png" width="44%" height="33%">
</p>           

```MATLAB
% 3단계
if sum(bw,'all') <= 10000
    moveforward(drone, 'Distance', 1.7, 'Speed', 1);
    
elseif longAxis > 860
    moveforward(drone, 'Distance', 1.7, 'Speed', 1);    % 1.2m+0.5m
    
else
    distance = (7E-06)*(longAxis)^2 - 0.0102*longAxis + 4.5856; % 드론과 링 사이의 거리
    moveforward(drone, 'Distance', distance + 0.8, 'Speed', 1); % 링과 표식 사이 거리의 절반만큼 추가 이동
    distance
end
```
<p align="center">
    <img src="image/reGressionAnalysis_4.png" width="44%" height="33%">
</p>           

```MATLAB
% 4단계
if sum(bw,'all') <= 10000
    moveforward(drone, 'Distance', 0.2, 'Speed', 1);
    
elseif longAxis > 460
    moveforward(drone, 'Distance', 0.2, 'Speed', 1);
    
else
    distance = (1E-05)*(longAxis)^2 - 0.0124*longAxis + 4.5996; % 드론과 링 사이의 거리
    moveforward(drone, 'Distance', distance - 0.8, 'Speed', 1);   % 링과 표식 사이 거리의 절반만큼 추가 이동
    distance
    
end
```
**링 통과 후 드론 제어**
```MATLAB
% 1단계
turn(drone, deg2rad(90));   % 1단계 통과 후 90도 회전
moveback(drone,'Distance',1,'Speed',1);   % 사각형 전체 한 번에 인식하기 위해 뒤로 이동   
count = 0;
```
```MATLAB
% 2단계
turn(drone, deg2rad(90));   % 2단계 통과 후 90도 회전
moveback(drone,'Distance',1,'Speed',1);   % 사각형 전체 한 번에 인식하기 위해 뒤로 이동
count = 0;
```
```MATLAB
% 3단계
turn(drone, deg2rad(30));   % 3단계 통과 후 30도 회전
count = 0;
```
```MATLAB
% 4단계
land(drone);
```
**4단계 각도 조절**
+ 30°부터 5°씩 회전시키며 최적의 각도 계산
```MATLAB
% 5도씩 회전하며 탐색
maxsum = 0;

for level = 1:7
    if level > 1
        turn(drone, deg2rad(5));
    end

    frame = snapshot(cam);
    r = frame(:,:,1);   detect_r = (r < 50);   
    g = frame(:,:,2);   detect_g = (g > 10) & (g < 120);
    b = frame(:,:,3);   detect_b = (b > 50) & (b < 190);
    blueNemo = detect_r & detect_g & detect_b;
    sumblueNemo = sum(sum(blueNemo));

    if sumblueNemo > maxsum
        maxsum = sumblueNemo;
        maxlevel = level;
    end
end
```
```MATLAB
% 최적 각도
angle = (-1) * 5 * (7 - maxlevel);
turn(drone, deg2rad(angle));
```
***
<p align="center">
  국민대통합<br/>
  정현우 이효빈 김주영
</p>

***
<p align="center">
 <img src="image/KIEE.png" width="120px" height="40px">
 <img src="image/MathWorks.png" width="268px" height="56px">
</p>

***
[^1]: 원이 아닌 사각형 중심 좌표를 계산한다. 왜? 2단계 링과 3단계 링의 거리가 가까울 때 2단계에서 원을 추출하려 하면 3단계 원까지 함께 인식되는 문제점이 발생한다. 이를 해결하고자 원이 아닌 파란색 사각형을 추출하는 방식을 이용한다.

[^2]: 빨간색, 초록색, 보라색 표식을 보고 이를 인식하여 드론 제어를 하는 것이 아닌, 드론이 링을 통과하면 바로 단계에 맞게 명령 코드를 입력하여 제어하는 방식을 이용한다. 이는 실측 시간을 감소시키기 위함이다.

[^3]: 드론이 천을 일직선으로 바라보는 각도가 최적의 각도이다. 이때 파란색 픽셀 수가 가장 많이 검출된다. 이를 이용해 드론 각도를 조절한다.
