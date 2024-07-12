# 2024 자율주행 드론대회
## 네드론닉스 팀(박준서, 김정현, 남정연)
### 차례)
1. Tello 드론 기능확인
2. 주행 맵, 가림막 분석
3. 중앙 찾기 알고리즘
4. 최종 알고리즘 설명
5. 코드 구성시 주의사항(문제점 및 해결책)
6. 팀원소개


### 1. Tello 드론 기능 확인
![image](https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/dbbca93c-37cc-4e1e-923d-3dec93eeb6b1)<br>
- 드론 종류: Ryze 토이 드론(쿼드콥터)
- 기능
  - 내장 비디오 프로세서를 이용한 사진 및 동영상 촬영가능
  - 최대비행시간: 13분
  - 최대 속도: 8m/s 
- 사용하는 MATLAB Toolbox
  - Computer Vision Toolbox
  - Image Processing Toolbox
  - Ryze Tello Drone Support Package


### 2. 주행 맵, 가림막 분석
<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/891edeae-d117-4cba-a979-41555ec30351" style="width: 40%; height: auto;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/a27c9ea9-65a7-44ee-a0a4-f22a0b4bcbd2" style="width: 52%; height: auto;">
</div>

- 경로1
  - 가림막 뒤의 원과 빨간색 색표지을 참조하여 중심을 기준으로 전진한다. 일정 거리에 도달하면 빨간색 색표지 앞에서 멈추고 오른쪽으로 120도 회전해야 한다.
- 경로2
  - 가림막 뒤의 원과 초록색 사각형을 참조하여 중심을 기준으로 전진한다. 가림막 앞에서 멈춘 후 왼쪽으로 120도에서 140도 사이로 회전해야 한다.
- 경로3
  - 가림막 뒤의 원과 보라색 사각형을 참조하여 중심을 기준으로 전진합니다. 가림막 앞에서 멈춘 후 오른쪽으로 200도에서 230도 사이로 회전해야 합니다.
- 경로4
  - 가림막 뒤의 원과 빨간색 사각형을 참조하여 중심을 기준으로 전진한다. 가림막을 통과한 후, 착지 지점에서 착륙한다.

코드를 직접 테스트해 보기 위해서 맵을 실제로 구성하여 테스트해보았다.
<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/f8109360-f96e-41ed-9728-a66338d1ebc5" style="width: 40%; height: auto;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/bdcf2436-9ddd-416d-953d-938a95938ae5" style="width: 40%; height: auto;">
</div>


### 3. 중앙 찾기 알고리즘
#### 1. 색상타깃 코드
- 목표코드: 색표시 인식, 위치 보정후 전진을 반복하는 코드를 구성
- 장점: 빨간색 색표지의 앞까지 가는 이동에 유리
- 단점: 가림막 통과시 원의 중심으로 가지 못함.(중앙으로 가지 못할경우 가림막과 부딪힐 우려가 있다.)<br>
<img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/a8fa91dd-36eb-4e18-a2c1-82768b0bda8d" width="300" /> <br>
(4배속 한 영상이며, 주어진 40초를 넘겼다.)



#### 2. 원 중앙 인식 코드
- 목표코드: 이미지 hsv 변환을 이용한 파란색 가림막 인식후 원의 중심 파악하고, 드론 자체 중심과 원 중심이 일치할 때 전진.
- 장점: 주행시 가림막 내부의 원 중심으로 주행하여 가림막과 부딪힐 확률 감소.
- 단점: 색상을 보지 않기 때문에 마지막 착륙 지점에 정확히 오지 않을 확률이 높다.
<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/6298f7d5-c478-4053-afb5-de44bce7ead7" style="width: 30%; height: auto;">



#### 3. 색상타깃 알고리즘 + 원인식 알고리즘
<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/e0d57e1e-010c-484c-b6bb-6dc43f689037" style="width: 40%; height: auto;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/71a52c7b-4c3e-4d9a-9059-33424bcf2109" style="width: 40%; height: auto;">
</div>

- 목표코드: 색상타깃 코드로 인식한 색표지와 원 중앙 인식 코드로 인식한 원 중앙의 좌표가 일치할때 동작하도록 코딩함. (첫번째 사진)
- 장점: 두 코드의 장점을 모두 구현 가능함.(의도한 정확한 색표지 앞으로 이동 및 가림막과의 충돌 방지)
- 단점: 색표지와 가림막을 구별하지 못함.(특히 보라색의 경우, 두번째 사진), 그 외의 가림막, 색표지와 그 외의 외부환경의 색과 구분하지 못함.

![finalvideodrone2](https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/74c435cc-297e-46a6-b014-bffe26d13c26) <br>
(4배속 한 영상이며, 파란색과 보라색을 구분하지 못해 세번째 가림막에서 멈춘것을 확인할 수 있다.)



#### 4. 가림막 인식 알고리즘 변경
<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/d2c63ded-9d65-41df-a8a4-b2ae91bed254" style="width: 45%; height: auto;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/2e9dd254-7db2-42b0-a29d-5e091d7df18f" style="width: 45%; height: auto;">
</div>


  맵의 주변 환경들에 의해 색상 타깃을 잘못 인식하는 경우와, 보라색 색상타깃을 파란색 가림막과 구별하지 못하는 경우를 배제하기 위하여, 오류 가능성을 줄이기 위한 새로운 방법을 구상하였다. 
  가림막의 파란색 영역을 인식하여, 가림막 모양을 따라 사각형 모양의 선을 그려내고, 그 안에서 가장 큰 원을 인식하여 원을 검출해내도록 하였다. 이를 통해 링의 반지름, 중심 좌표를 이전보다 더욱 빠르게 찾고 계산할 수 있었다. 
  또한 가장 큰 원 부분의 영역만 남겨두고 나머지 영역은 모두 하얀색으로 칠하여 더욱 직관적으로 링의 내부를 볼 수 있게 하였고, 주변 환경들의 색상을 색상 타깃으로 잘못 인식하지 않도록 하기 위해 그 원 안에 들어 있는 색상 영역만 감지하도록 코드를 짰다. 원 안에 있는 색상 타깃을 감지한 후 색상 타깃 주위를 따라 작은 사각형을 그려 색상 타깃의 좌표 또한 찾아낼 수 있었다. 이러한 방법을 사용함으로써 이전에 원의 중심과 색상 타깃을 가림막 밖에서 잘못 인식하던 문제점을 해결하여 더욱 빠른 좌표 보정을 수행할 수 있게 되었다.<br>
  
정리하면 전체 알고리즘은 다음과 같다.

- 가림막의 파란색 영역 인식. 가림막 모양 따라 사각형 모양 선 따기
- 사각형 영역 안의 가장 큰 원 인식. 원을 제외한 나머지 부분은 하얗게 만듬.
- 원 안에 들어있는 색상만 인식. 색상 타깃 모양을 따라 사각형 형태 그려서 좌표 측정.

![finalvideodrone2](https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/bc309b67-9355-4e0e-a078-417f03ffd37a) 
(4배속 한 영상이며, 완주한 것을 확인할 수 있다.)
![final2-ezgif com-video-to-gif-converter](https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/68cb161d-75e0-44d3-b4ae-975bca0750f1)



### 4. 최종 알고리즘 설명
순서도<br>
- main 함수&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-사용자 정의함수
<div style="display: flex; justify-content: space-between; align-items: center;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/e1c89e39-c1f5-4a41-b731-3f9eca88ffe9" style="width: 60%; height: auto;">
  <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/00879722-b910-4d5c-959b-00fdae4f3bce" style="width: 30%; height: auto;">
</div>
 
알고리즘 분석
- main 함수 
1. 드론 및 카메라 설정
```
clear tello cameraObj; % 객체 초기화
% Tello 드론과의 연결 설정 및 이륙
tello = ryze();
cameraObj = camera(tello);
```

2. 드론 이륙과 허용오차 설정
```
% 드론 이륙
takeoff(tello);
% 허용 오차 설정
tolerance = 30;
```
   
3. 옵션 구조체 설정
```
% 옵션 구조체 정의
options = struct();
options.Camera = cameraObj;  % 카메라 객체
options.Tolerance = tolerance;  % 허용 오차
```

4. 첫번째~네번째 링 통과 후 방향 전환 및 이동
```
% 첫 번째 링 통과 (타깃: 빨강)
passThroughRing(tello, options, 57/2, 1);
% 첫 번째 링을 통과한 후 방향 전환 및 이동
turn(tello, deg2rad(130));
pause(1);
moveforward(tello, 'Distance', 3, 'Speed', 0.7);
pause(1);
% 두 번째 링 통과 (타깃: 초록)
passThroughRing(tello, options, 46/2, 2);
% 두 번째 링을 통과한 후 방향 전환 및 이동
turn(tello, deg2rad(-130));
pause(1);
% 세 번째 링 통과 (타깃: 보라)
passThroughRing(tello, options, 46/2, 2);
% 세 번째 링을 통과한 후 방향 전환 및 이동
turn(tello, deg2rad(215));
pause(1);
% 네 번째 링 통과 (타깃: 빨강)
passThroughRing(tello, options, 52/2, 3);
```
5. 드론 착륙
```
% 드론 착륙
land(tello);
```

  - 사용자 정의함수(passThroughRing)
1. 변수 초기화 및 이미지 캡처
```
match_count = 0; % 링과 타깃의 좌표가 일치한 횟수를 추적
move_speed = 0.8; % 드론의 이동 속도
tolerance = 30;

figure(1); % 이미지 창 생성
hold on;
```
2. 파란색 필터링 및 링 감지
```
img_rgb = snapshot(options.Camera);
frame = img_rgb;
hsvFrame = rgb2hsv(frame);
blueLower = [0.5, 0.3, 0.2]; 
blueUpper = [0.7, 1, 1]; 
blueMask = (hsvFrame(:,:,1) >= blueLower(1) & hsvFrame(:,:,1) <= blueUpper(1)) & ...
           (hsvFrame(:,:,2) >= blueLower(2) & hsvFrame(:,:,2) <= blueUpper(2)) & ...
           (hsvFrame(:,:,3) >= blueLower(3) & hsvFrame(:,:,3) <= blueUpper(3));
stats = regionprops(blueMask, 'BoundingBox', 'Area');
```
3. 원감지
```
grayFrame = rgb2gray(frame);
grayFrame(~nonBlueInsideBlueRectMask) = 0;
[centers, radii] = imfindcircles(grayFrame, [20 50], 'ObjectPolarity', 'bright', 'Sensitivity', 0.9);
```
4. 타깃 색상 인식
```
colorRanges = struct('red', struct('Lower', [140, 0, 0], 'Upper', [255, 100, 100]), 
                     'green', struct('Lower', [0, 100, 0], 'Upper', [80, 255, 100]), 
                     'magenta', struct('Lower', [85, 0, 110], 'Upper', [120, 105, 255]));
```
5. 거리 및 각도 계산
```
ring_distance = 1.8 * 156.448 / radius;
ring_distance_2=1.8*123.265/radius;
ring_distance_3=1.8*137.345/radius;

pixel_destance = radius * ring_distance * 100 / real_radius;
pixel_destance_2 = radius * ring_distance_2 * 100 / real_radius; %46cm 원
pixel_destance_3 = radius * ring_distance_3 * 100 / real_radius; %42cm 원

theta = atan((ring_center_x - img_center_x) / pixel_destance);
```
6. 드론 이동
```
if ring_center_y - radius > img_center_y
    movedown(tello, 'Distance', 0.2, 'Speed', move_speed);
end
turn(tello, theta);
if strcmp(detectedColor, 'red')
    moveforward(tello, 'Distance', ring_distance + 1.7, 'Speed', move_speed);
else
    moveforward(tello, 'Distance', ring_distance_2 - 0.4, 'Speed', move_speed);
end
```
7. 위치 조정
```
if ring_center_x < target_center_x - tolerance
    moveleft(tello, 'Distance', 0.2, 'Speed', move_speed);
elseif ring_center_x > target_center_x + tolerance
    moveright(tello, 'Distance', 0.2, 'Speed', move_speed);
end
if ring_center_y < target_center_y - tolerance
    moveup(tello, 'Distance', 0.2, 'Speed', move_speed);
elseif ring_center_y > target_center_y + tolerance
    movedown(tello, 'Distance', 0.2, 'Speed', move_speed);
end
```  
8. 결과 이미지 표시
```
figure(1);
imshow(resultFrame);
title('Detected Color Target');
```

### 5. 코드 구성시 주의사항(문제점 및 해결책)

  이 코드를 직접 구성한 맵에서 구동시켜보았을때, 가림막, 가림막 내부의 색과 장애물의 색을 구별하지 못하는 경우가 생긴다. 또한 두 중심이 일치할때까지 움직여 피드백하는 코드에서 최소로 움직일수 있는 주행거리가 0.2m이기 때문에 중심을 잘 찾지 못하는 경우 피드백하기 힘들었다. 그리고 빨간색과 초록색의 경우 가림막과 구분이 잘 되었지만 보라색의 경우 파란색과 색범위가 겹치기 때문에 흑백처리를 해주었을때 구별이 힘들었다. <br>

#### <이동 거리 오차 발생 문제>

문제점 1: 초반에는 맵 규격에 맞춰 total distance를 설정하고, 정해진 거리만 날아가게 코드를 작성하였는데, 이렇게 짜니 드론 속도에 따라서도 관성에 의한 오차가 발생하고, 또 가림막의 각도를 변경함에 따라 두 번째 세 번째 링 안까지 드론이 들어가는 경우가 발생했다. 

문제 해결 방안: 따라서 가림막으로부터 드론의 실제 위치(거리)를 측정하는 방법을 고안하였다. 가림막으로부터 드론의 실제 위치를 ring distance라는 변수로 정의하고, 두 번째 세 번째 구간에서는 가림막의 0.4m 앞까지 오게 하는 것을 목표로 설정하였다.

문제점 2: 처음에는 가림막으로부터 0.4m 앞에서 드론을 띄워 원의 픽셀 단위 반지름을 구하기 위해 원 좌표를 찾으려 시도해 보았다. 하지만 0.4m 앞에서는 드론이 가림막 너머의 사진을 찍기 때문에 원의 픽셀 반지름을 구할 수 없었다.
 <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/0b00c073-a5c7-4b62-a6ef-3013aef0d1a1" style="width: 50%; height: auto;"> <br>
문제 해결 방안: 가림막 사진을 찍을 수 있는 임의의 거리(1.8m)를 선정하여 그 거리에서의 원의 실제 반지름 대비 픽셀 단위 반지름의 비율을 계산하였다.
따라서 ring distance는 드론의 시야에서 보이는 링의 반지름을 알 수 있다면 그때의 드론이 링으로부터 얼마나 멀리 있는지 비율로 계산이 가능하게 되었다.


#### <각도 조절 오차 발생 문제>

문제점 1: 원과 색상좌표가 일치하여 드론이 앞으로 전진하였지만 링의 정중앙을 통과하지는 않을 수도 있다는 문제가 발생하였다. 

문제 해결 방안: 링의 중심과 색상 좌표를 일직선상으로 그은 선에 드론이 평행하게 위치할 수 있도록 각도를 조정하여 문제를 해결하기로 하였다. arctan를 이용해 각도를 계산하는 삼각측량법을 적용해 드론이 원의 중심을 정확하게 통과할 수 있도록 각도를 조정할 수 있었다.

문제점 2: 이전에는 정해진 맵 규격의 길이를 사용하여 세타값을 구했는데, 맵이 극단적으로 각도가 변경될 경우에는 불안정 할수 있다는 문제가 발생하였다. <br>
 <img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/6cf66797-0e7a-4a5b-a435-13d4540afacb" style="width: 50%; height: auto;"> <br>
문제 해결 방안: 따라서 드론과 가림막 까지의 거리(ring distance)를 측정하여 세타값을 구하는데 사용하였다. 이를 통해 더욱 정밀한 각도 조정이 가능해졌다.

#### <드론의 카메라가 드론 본체 아래에 달려있다는 문제>
문제점 1: 드론의 카메라가 드론 본체의 살짝 아래를 바라보는 방향으로 달려있기 때문에 드론 입장에서는 링의 중심 좌표와 색상 타깃이 일직선 상이라고 생각하고, 드론 몸체 또한 그와 평행하다고 생각할 것이다. 하지만 사실 드론은 카메라 윗부분의 날개 부분이 달려 있고, 이로 인해 링의 윗부분에 걸릴 위험이 있었다. <br>
<img src="https://github.com/qkrwnstjdkwneo/Nedronics/assets/144573163/7afe4952-1982-408c-aaa2-58fd60812f56" style="width: 50%; height: auto;"> <br>
문제 해결 방안: 드론의 카메라 상 중심 y 좌표가 링의 중심으로부터 y 좌표에서 반지름만큼 올린 y 값보다 더 높다고 판단될 때 20cm를 무조건 하강하여 링이 가림막에 걸리지 않고 주행할 수 있도록 위치 보정을 하였다.

### 6. 팀원소개
[아주대학교 전자공학과](https://www.ajou.ac.kr/ece/index.do) 
네트로닉스 소학회, 일레븐 소학회 소속
|직책|이름|
|----|----|
|팀장|박준서|
|팀원|김정현|
|팀원|남정연|
