# [2024 미니드론 경진대회] 기술 워크샵 - JHSM팀 

저희는 대회에서 제공된 미션을 성공적으로 수행하기 위해 아래 두 가지 요소가 중요하다고 판단하였으며, 이를 중점적으로 고려하여 결승 코드를 작성하였습니다. <br/>
+ 색상 타겟과 가림막을 활용하여 링의 중심을 정확하게 **인지**하는 것
+ 부딪힘 없이 링을 통과하고 올바른 goal point에 착지하기 위한 각도 및 주행 **제어**

## 목차
  1. 전체적인 주행 알고리즘
  2. Camera Calibration
  3. 링의 중심점 찾기 알고리즘
  4. Tello 제어 
  5. 주행 영상들
<br/>

## 1. 전체적인 주행 알고리즘
<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/81b39b8c-04e0-4faf-8f83-4f563c8d32ce" align="center" width="75%"> 
</p>  

  
대회 장소와 유사하게 아래와 같이 환경 세팅 후 주행 연습을 했습니다.

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/7fd7c50e-a0f8-402c-8ccf-2d9cd62c0f4d" align="center" width="75%"> 
</p>  


## 2. Camera Calibration
저희가 사용하는 tello의 pinhole 카메라를 포함하여 모든 카메라로 얻은 영상은 렌즈의 굴절률 때문에 직선이 휘어지는 왜곡이 발생할 수 밖에 없습니다.  

따라서 저희는 우선 정확한 영상 데이터를 얻기 위해 **Camera Calibration**을 수행하였습니다.  

이를 위해서 격자 패턴을 사용하는 Zhang의 방법 사용하였으며, 이는 MATLAB의 Computer Vision Toolbox가 제공하는 Camera Calibrator App을 통해서 손쉽게 할 수 있었습니다.  

먼저 격자 하나의 크기가 25mm 체스보드를 출력해 여러 각도로 촬영하고 이를 앱에 입력함으로써 영상 왜곡 보정에 쓰이는 CameraParams 파라미터 값을 얻었습니다.  

<p align="center">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/a08a48ba-a373-4956-871d-d59138e4c884" align="left" width="480" height="360">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/edabc25c-0e2e-46d4-a18f-2277a3981117" align="right" width="480" height="360">
</p>

카메라의 Calibration 값은 바뀌지 않기 때문에 CameraParams 파라미터 값을 caliubvar.mat 파일로써 save하고, 코드를 실행시킬 때마다 해당 파라미터 값을 load하여 사용하였습니다.  

load한 CameraParams 파라미터 값과 **undistortImage** 함수를 사용하여 드론으로부터 얻은 이미지의 왜곡을 보정하였고,  

```MATLAB
while true
    hold off;
    frame = snapshot(cameraObj);
    frame = undistortImage(frame, cameraParams);
```

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/3864cf22-0eae-4009-ba46-a0666e005968" align="center" width="50%"> 
</p>  
  
다음과 같이 육안으로 확인되진 않지만 최종적으로 비교적 정확한 영상 데이터를 가지고 인지와 제어를 할 수 있었습니다.  

## 3. 링의 중심점 찾기 알고리즘
충돌 없이 가림막을 통과하기 위해서 드론은 되도록 링의 중심점을 통과해야하며 이를 위해서는 링의 중심점을 찾을 필요가 있습니다.  

1. 먼저 입력 이미지를 hsv채널로 변환한 후 적절한 threshold로 파란색 영역(가림막의 색)만을 1로 표시하는 이진 영상을 만들었습니다.

```MATLAB
    % HSV 채널로 변경  
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    detect_ring = (0.53<h)&(h<0.625)&(0.55<s)&(s<0.9);
```
<br/>

2. 관심영역인 가림막 이외의 다른 영역도 1로 표현될 수 있기 때문에 Image Processing Toolbox의 `bwarefilt`함수를 통해 가장 큰 영역인 가림막만을 남기고 나머지는 제거해줍니다. 

```MATLAB
centroids = find_center(detect_ring);
                  .
                  .
                  .
function centroids = find_center(detect)
    % 오차 영역 제거를 위해 가장 큰 영역만 남기고 제거
    binary_res = bwareafilt(detect, 1);
```
<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/868803bd-fe0f-466b-8f0d-ae8754a55d63" align="center" width="85%"> 
</p> 

3. 가림막의 내부를 hole이 없도록 `imfill` 함수를 이용하여 채워줍니다.

```MATLAB
    sq_reg = binary_res;
  
    % 영역 내부를 hole이 없도록 채움 
    binary_res = imfill(binary_res, 'holes');
    subplot(2,2,3)
    imshow(binary_res);
```
<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/c562f299-dcc7-439d-aefe-55c51f0fafa0" align="center" width="45%"> 
</p>  

<br/>
 
4. 가림막만을 1로 만든 `sq_reg`와 가림막 내부도 채운 `binary_res`를 xor 연산자를 사용하여 hole 영역만을 뽑아냅니다.
   이때도 마찬가지로 `bwarefilt`함수를 통해 가장 큰 영역인 hole을 제외하고는 모두 제거해줍니다.

```MATLAB
    % xor 연산자를 이용해 hole 영역만 추출
    hole_reg = xor(sq_reg, binary_res);
    hole_reg = bwareafilt(hole_reg, 1);
```
<br/>

5. `regionprops` 함수를 이용해 뽑아낸 hole 영역의 중심좌표를 계산하고 표시해줍니다.

```MATLAB
    % hole 영역의 경계선 좌표들 계산 후 표시
    [B,L] = bwboundaries(hole_reg);

    % 가시성을 위한 경계선 표시
    imshow(hole_reg);
    hold on;
    for k = 1:length(B)
       boundary = B{k};
       plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
    end
    
    % hole 영역의 중심 좌표 계산 후 표시
    s = regionprops(hole_reg,'centroid');
    centroids = cat(1,s.Centroid);
    plot(centroids(:,1),centroids(:,2),'b*');
```
<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/c2d3a575-af05-4830-a1f3-c44b26eba097" align="center" width="85%" height="225"> 
</p> 

### 예외 상황 발생 및 해결과정  
위와 같은 알고리즘으로 링의 중심점을 찾는 코드를 짰지만 특정 상황에서 hole이 제대로 검출되지 않는 문제점이 발생했습니다. 여러 각도로 가림막을 찍어가며 실험해본 결과 특정 상황은 다음과 같았습니다.  
1. hole이 카메라 상의 모서리 쪽에 위치한 경우
2. hole이 아예 카메라 상에 없는 경우

#### 1번 상황 해결과정
1번 상황의 경우 아래 그림과 같습니다.

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/003c2589-1159-4915-be86-5a930cb4a1c2" align="center" width="480" height="360"> 
</p> 

위와 같이 가림막의 hole이 모서리 쪽에 위치한 경우 이진 영상에서 hole 영역이 모두 1로 둘려싸여있지 않기 때문에 `imfill` 함수를 사용했을 때 hole 영역이 채워지지 않습니다.   

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/737482a9-83fd-43e6-8e4d-2b51f106f652" align="center" width="520" height="420"> 
</p> 

+ **1번째 시도**
  이를 해결하기 위해서 처음엔 임의로 이진 영상의 가장자리 pixel들을 1로 만들어주었습니다.

  이때 가장자리 전부를 1로 만들면 `imfill` 함수로 이미지 전체가 1로 바뀌기 때문에 꼭짓점에 있는 몇 개의 pixel들은 1로 채우지 않았습니다.

  ```MATLAB
      for i = 3:957
          binary_res(1,i) = 1;
          binary_res(720,i) = 1;
      end
  
      for i = 3:717
          binary_res(i,1) = 1;
          binary_res(i,960) = 1;
      end
  ```
  <p align="left">
    <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/d5e424cf-9c46-4fdd-b818-7998d1e4e3de" align="center" width="520" height="420"> 
  </p> 

  이후 위 그림과 같이 hole이 이미지의 가장자리에 위치한 경우에도 hole을 검출하고 중심점을 찾을 수 있었습니다.  

  **하지만** 꼭짓점에 있는 pixel들은 채우지 않은 이유로 아래 그림과 같은 상황에서 다시 hole이 검출되지 않은 문제가 발생했습니다.

  <p align="left">
    <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/04e58e51-a360-4f92-9e6f-cf55d19914fb" align="center" width="85%"> 
  </p> 

+ **2번째 시도** (해결 완료!!)
  
  가장자리에 있는 hole들을 검출하기 위해서는 가장자리의 pixel들을 1로 채워야하지만 그렇다고 모든 가장가리를 1로 채워서는 안됩니다.

  이를 위해서 저희는 다음과 같이 우선 가림막 영역의 최소 x, y값, 최대 x, y값으로 가림막의 중심 좌표를 계산한 후,

  <p align="left">
    <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/7b92910a-1fee-4bf9-add6-054ed37432d8" align="center" width="75%"> 
  </p> 
  
  중심좌표와 이미지의 중점(width / 2, height / 2)과의 대소비교를 통해 가까운 쪽의 가장자리 pixel들만 1로 채웠습니다.

  ```MATLAB
    [row, col] = find(binary_res);
    locmin = [min(row), min(col)];
    locmax = [max(row), max(col)];
    screen_center = (locmin + locmax) / 2;
    
    % disp(screen_center);
    % 처음 사용 알고리즘 
    % for i = 3:957
    %     binary_res(1,i) = 1;
    %     binary_res(720,i) = 1;
    % end
    % 
    % for i = 3:717
    %     binary_res(i,1) = 1;
    %     binary_res(i,960) = 1;
    % end

    if screen_center(1) <= 360
        for i = 1:960
            binary_res(1,i) = 1;
        end
    else
        for i = 1:960
            binary_res(720,i) = 1;
        end
    end

    if screen_center(2) <= 480
        for i = 1:720
            binary_res(i,1) = 1;
        end
    else
        for i = 1:720
            binary_res(i,960) = 1;
        end
    end
  ```
  <br/>

  그 결과, 다음과 같이 hole이 이미지의 꼭짓점 부근에 있어도 잘 검출하며, hole이 카메라 이미지 내에 존재하는한 hole과 그 중심 좌표를 잘 찾게 되었습니다.
  
  <p align="left">
    <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/bb728c7f-e33e-4dc1-8a65-c9c0fb500790" align="center" width="45%"> 
  </p> 

### 2번 상황 해결과정
2번 상황은 아래 그림과 같이 아예 hole이 카메라 이미지 내에 존재하지 않고 가림막의 파란색 부분만 존재할 경우입니다.  

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/26046143-8cd2-41e6-981d-2af9d35d6b56" align="center" width="45%"> 
</p> 

hole이 아예 없기 때문에 hole의 중심점은 당연히 찾지 못하지만 가림막만을 보고 드론을 hole이 있는 쪽으로 제어할 필요가 있습니다.  

이를 위해서 저희는 xor 연산 결과의 픽셀값 합이 터무니없이 작다면, hole이 이미지 내에 없다고 간주하고 가림막의 중심좌표를 구하여 이 방향으로 드론을 제어하였습니다.  

```MATLAB
    % hole 없을 때 가림막의 중심좌표를 구해야하기 때문에 저장해둠
    no_hole = binary_res;
            .
            .
            .
    % xor 연산자를 이용해 hole 영역만 추출
    hole_reg = xor(sq_reg, binary_res);
    hole_reg = bwareafilt(hole_reg, 1);
    
    % hole 영역이 존재하지 않는 경우
    % disp(sum(hole_reg,'all'));
    if sum(hole_reg,'all') < 500
        disp("no hole detected");
        % 파랑 크로마키의 중심으로의 제어 
        hole_reg = no_hole;
    end

```
<br/>

그 결과 다음 그림과 같이 hole 영역이 존재하지 않을 경우, 가림막의 중심좌표를 잘 찾았으며 이를 활용해 가림막의 중심으로 제어를 할 수 있었습니다. 

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/07d1dc4d-0152-4002-837b-041bf98ea40d" align="center" width="45%"> 
</p> 


## 4. Tello 제어

<img width="581" alt="스크린샷 2024-07-10 오후 5 42 23" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/d8f748b6-3c46-42ac-9809-36168f69a84e">

먼저 텔로를 제어하기 전에 텔로의 축을 알아야 합니다.

위 사진과 같이 x축이 앞을 바라보는 방향입다.

### 4-1. Y-Z Control

<img width="710" alt="스크린샷 2024-07-10 오후 6 00 24" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/1c41c80d-ea43-4129-9dfd-019b608f6c55">

드론을 이륙하면 위와 같은 상황일 것입니다.

먼저 드론을 링에 통과시키기 위해서는 링 중앙에 드론을 위치하게끔 제어를 해야합니다.


<img width="716" alt="스크린샷 2024-07-10 오후 6 05 39" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/947b174d-cd2a-4065-bfbc-ebf1c8bcdc7f">


드론을 링 중앙에 위치시키기 위해서 검출된 원의 중심 좌표와 드론 이미지의 중심 좌표의 차이를 이용해 제어를 했습니다.

노란 점선과 하늘 점선은 이미지 중심 좌표와 검출된 원의 중심 좌표의 차이를 시각화 한 것입니다.

사진에서 알 수 있듯이 원의 중심을 이미지의 중심으로 오게끔 하려면, 드론을 대각선 방향으로 보내면 됩니다.

Tello의 내장 함수인 move 함수를 사용하여 Y-Z 방향으로 픽셀 차이의 가중치를 곱해 이동을 시켰습니다.

<img width="716" alt="스크린샷 2024-07-10 오후 6 05 44" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/7aed365c-b389-449b-a0b5-7a0079b01c7f">

이동 시킨 결과 너무 많이 움직였습니다.

원인을 찾아본 결과 Tello의 최소 이동 단위는 [m]이고 최소 값은 0.2 였습니다.
즉, 0.2m 씩만 움직일 수 있다는 것이었습니다.
이 문제를 해결하기 위해 offset 값을 도입했고, offset값보다 큰 경우 이미지 x,y축 방향으로
움직이게끔 제어를 했습니다.

<img width="716" alt="스크린샷 2024-07-10 오후 6 05 47" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/fc40dbcf-da9a-45c9-a697-51d079419cc4">


위 이미지에서는 이미지상에서 y축 픽셀 차이가 없으므로 x축 즉, 드론의 Y축 방향으로만 제어값을 주면 됩니다.

<img width="716" alt="스크린샷 2024-07-10 오후 6 05 52" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/95cc8bb5-0b2b-4c0f-bfd4-d8c678064482">


위 이미지에서는 마찬가지로 하나의 축은 픽셀 차이가 없으므로, 이미지 상에서 상하 이동 시킬 수 있게 제어하면 됩니다.

<img width="716" alt="스크린샷 2024-07-10 오후 6 05 55" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/b97d62ce-6264-49b7-bfa0-fea81bbddca2">


최소 제어 거리 때문에 한 번에 중심 좌표를 맞추긴 어렵지만, 여러 번 제어를 마치면 offset 값 아래로 떨어져서 
원의 중심과 이미지의 중심이 어느 정도 맞는 것을 확인 할 수 있었습니다.

이제 다음 단계로 넘어가면 됩니다! 

```MATLAB
function [centroids, move_vector] = process_detected_objects(detect, center, offset)
    centroids = find_center(detect);
    displace = centroids - center;
    move_vector = [0, 0.2 * ((displace > offset) - (displace < -offset))];
end
```

### 4-2. X-Y-Z Control 

다음 단계는 사각형을 기준으로 제어를 해야합니다. 

<img width="716" alt="스크린샷 2024-07-10 오후 9 04 39" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/2e9f803d-af0b-41db-8b23-3729e33bf2d3">


여기서는 X축 제어도 하여 사각형에 근접할 수 있게 제어를 했습니다.
사각형의 중심 좌표를 이미지 중심 좌표에 맞추는 방식은 Y-Z Control 부분과 동일하게 사용을 했고,
X축 방향 제어는 사각형의 픽셀 합이 임계값이 넘을 때까지 앞으로 갔습니다.

<img width="716" alt="스크린샷 2024-07-10 오후 9 04 43" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/d368a196-6772-4a8d-b890-8cfc40ff54d4">

X-Y-Z 축 제어를 했기 때문에 사각형의 중심이 이미지 중심에 맞춰지면서,
사각형의 크기가 커지는 것을 확인 할 수 있습니다.

<img width="716" alt="스크린샷 2024-07-10 오후 9 04 47" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/77c610ce-ce78-46a3-a352-302ef6f028a6">

사각형의 중심과 이미지의 중심이 맞고, 사각형의 픽셀 합이 임계값을 넘으면 다음 단계로 넘어 갈 수 있습니다!

```MATLAB
function move_vector = align_to_color(drone, detect, center, offset, threshold, forward_distance, turn_angle)
    binary = bwareafilt(detect, 1);
    if sum(binary, 'all') <= threshold
        move_vector = [0.2, 0.0, 0.0];
        s = regionprops(binary, 'centroid');
        if ~isempty(s)
            displace = s.Centroid - center;
            move_vector = [0.2, 0.2 * ((displace > offset) - (displace < -offset))];
        end
        move(drone, move_vector, 'WaitUntilDone', true);
    else
        turn(drone, deg2rad(turn_angle));
        if ~(forward_distance == 0)
            moveforward(drone, 'Distance', forward_distance, 'Speed', 1, 'WaitUntilDone', true);
        end
        move_vector = [];
    end
end
```

<br/>

위와 같이 색상 pixel들의 합이 특정 임계값 이상이 될 때까지 0.2m 씩 앞으로만 가다가, 특정 임계값에 도달하면 Y-Z Control을 통해 사각형의 중심과 이미지의 중심을 맞춰줍니다.

### 4-3. Yaw Control


<img width="716" alt="스크린샷 2024-07-10 오후 9 21 00" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/71b3060e-0abb-4dcb-9bca-b723ec303896">


<img width="716" alt="스크린샷 2024-07-10 오후 9 21 06 복사본" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/27a6e591-af68-47c3-b53b-74e4052f319d">


위 사진에서 볼 수 있듯이 Yaw가 틀어지면 도착지점이 매우 달라집니다.
마지막 미션이 착륙지점에 정확하게 착륙하는 것이기 때문에 yaw를 맞추고 링을 통과하는 게 중요하다고 생각했습니다. 

<img width="716" alt="스크린샷 2024-07-10 오후 9 21 11" src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/74603ca3-2873-4ea7-91b0-dbff07cdd9c4">

링을 통과하기 전에 원의 중심 x값과 이미지 중심 좌표의 x 값의 차이에 가중치를 곱해 드론이 원의 중심을 바라보게끔 제어를 했습니다.

```MATLAB
        case 6
            % Rotate to align yaw
            centroids = find_center(detect_ring);
            diff_x = centroids(:,1) - width_ / 2;
            disp("Rotating to align yaw, diff_x : " + diff_x);
            if abs(diff_x) > 15
                turn(drone, deg2rad(diff_x * 0.1));
            else
                moveforward(drone, 'Distance', 1.8, 'Speed', 1, 'WaitUntilDone', true);
                mode = 7;
            end
```

<br/>

## 5.주행 영상들
<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/6a97df43-5b69-40a6-bec4-041674a613e0" align="center" width="55%"> 
</p> 

<p align="left">
  <img src="https://github.com/goodhsm2000/2024_drone_JHSM/assets/73740089/f5cc3155-b122-4a0f-87ab-73a9ab80ffd4" align="center" width="55%"> 
</p> 