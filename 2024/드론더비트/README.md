
목차
===

이번 2024 미니 드론 대회에 대한 설명의 순서는 다음과 같다.

1. 대회 사전 규격 및 조건
2. 대회 진행 전략
3. 알고리즘 설명
4. 소스 코드 설명


대회 사전 규격 및 조건
===========
## 대회에 사용한 Toolbox
이번 대회에서 사용한 toolbox는 아래와 같고 대회에서 사용한 matlab 버전은 2023b로 사전 연습하였다. 

```
         Computer Vision Toolbox

	 Image Processing Toolbox

	 Ryze Tello Drone Support Package
```

## 대회에서 주어진 조건
먼저 대회에서 공지된 대회장의 규격은 아래 사진과 같다.   

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/953e1c5e-4c76-4d96-8004-d34188ed83d8" alt="image" width="550"/>
   
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/296b7656-9489-4262-956d-06b97e281047" alt="image" width="350"/>






또한 가림막의 링 크기는 각각   
1차 링 크기 : 57cm,   
2차 링 크기 : 46cm,    
3차 링 크기 : 46cm,   
4차 링 크기 : 52cm 이다.    
또한 가림막 링의 중심점의 높이는 80~100cm이다. 

아래 사진은 위의 사진과 유사한 규격의 연습장을 실제로 구성하여 진행한 사진이다.

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/4c1eb50d-28dd-4a66-82a0-9906a7f55b2f" alt="image" width="300"/>
    
    
    
    
stage 별로 구성을 설명하면 다음과 같다. 
+ 1st stage
	+ START 지점에서 이륙 후 1.6m 거리의 1차 가림막과 링, 그리고 붉은 색을 확인하고 링을 통과하여 이동 후, 우측 방향으로 120~140도 회전
+ 2nd stage
	+ 5.1m 거리의 2차 가림막과 링, 그리고 녹색을 확인하고 이동 후, 링을 통과하지 않고 좌측 방향으로 120~140도 회전
+ 3rd stage
	+ 2.7m 거리의 3차 가림막과 링, 그리고 보락색을 확인하고 이동 후, 링을 통과하지 않고 우측 방향으로 200~230도 회전
+ 4th stage
	+ 3.85m 거리의 4차 가림막과 링, 그리고 붉은 색을 확인하고 링을 통과하여 이동 후, 지름 20cm의 FINISH 지점에 착륙하도록 구성



대회 진행 전략
===========
위에서 설명한 대회 조건 및 규격에 따라 각 stage마다 전략을 달리하여 코드를 수정하였다. 

먼저 stage에서 공통적인 전략을 살펴보면 다음과 같다.

## 최적화된 원의 면적 계산 및 중심 인식
### 원의 면적

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/86e071f0-cd4a-42d4-ab9c-cc55c40fcd89" width="300"/>[1번 case가 실행된 경우의 사진]
   
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/89558be3-c4db-49a6-a729-df47169b2540" alt="image" width="300"/>[4번 case가 실행된 경우의 사진] 

   
반복적인 주행 연습 결과를 통해, 드론이 원의 이미지를 찍었을 때, 적절한 크기의 가림막의 원이 존재하는 적정 거리가 존재한다. 이는 드론이 측정한 원의 면적이 작을 수록, 드론은 원으로부터 멀리 떨어져 있고 반대로 원의 면적이 클수록, 드론이 원으로부터 가까이 존재하는 것을 의미한다.   
즉, 측정된 원의 면적에 따라 드론이 원에 가까이 가기 위해서는 앞으로 이동하는 거리가 달라져야한다. 이를 반복적인 과정을 통해 10개의 case로 구분하였다.


### 원의 중심

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/a94011f2-3889-4d75-86d8-67cd08b9e0a3" alt="image" width="400"/> [(480,200)에 중점이 존재하는 경우]   


위의 면적 사진을 통해 드론이 찍은 이미지를 hold on axis를 통해 확인하면 가로축은 0 부터 960, 세로축은 0부터 720 인것 을 확인할 수 있다. 드론이 찍은 이미지대로라면 원의 중심은 480, 360 일 것이다.    
그러나 실제로는 그렇지 않다. 드론이 바라보는 방향이 정중앙이 아니기 때문에, 반복적인 주행을 통해 200으로 조정하였다. 


### 최적화된 색깔 인식
   
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/00e786a1-5c70-49bb-9bf2-ca06192cec98" alt="image" width="300"/><img src="https://github.com/202020882/drone_the_bit/assets/127501452/a0fd3073-1aa4-4066-af12-5d21f8b3e844" alt="image" width="300"/><img src="https://github.com/202020882/drone_the_bit/assets/127501452/7c8f571e-4c84-4dd7-b7e4-2cff3cbf8c2f" alt="image" width="300"/>



코드의 가독성을 높이기 위해 붉은색, 녹색, 보라색을 인식하는 사용자 정의 함수를 선언하였다. 
   
```processImage_R```, ```processImage_G```,```processImeage_P``` 함수를 설정하는 과정에서 가장 중요한 것은 색상의 RGB의 조건을 정확하게 하는 것이었다. 우리가 선택한 RGB 구별 방식은 이미지의 R과 G, R과 B, G와 B의 값을 비교하여 어떤 값이 더 큰지, 즉 어느 값이 이미지에서 더 강하게 나타나는지를 비교하는 방식이다. 이미지를 찍고 RGB를 비교하는 반복적인 과정을 통해 조건의 임계값을 찾았고 이를 토대로 조건을 선택하였다.

### 드론 객체의 안정성 유지
   
아래의 코드 설명에서 확인할 수 있겠지만 드론이 움직인 다음에 ```pause(1.0)```이 포함되어있는 것을 확인할 수 있을 것이다. 이는 드론이 움직인 후에, 관성 혹은 가속력으로 인해 더 나아가는 것을 방지하기 위해 작성하였다.   
    
이와 마찬가지 이유로 속도값도 조정하였다. 반복적인 과정을 통해 확인한 결과, 0.8을 넘어가면 확률적으로 예상한 결과와의 오차가 더 자주, 더 크게 발생하였고 이를 방지하기위해 속도의 최댓값은 0.7로 설정하고 설계하였다.


### 수학적인 각도 분석

아래의 소스 코드 분석에서 설명하겠지만 색상을 인식하는 과정에서 각도가 틀어진 경우가 존재한다. 이 경우를 대비하여 드론이 색깔의 중심을 파악하고 기준으로 설정한 값과 비교하여 각도를 조절할 수 있도록 설계하였다. 기준 중심과 구한 색깔 중심 측정 값의 차가 양수라면 드론이 색깔의 좌측을 바라보고 있는 것이므로 드론이 우측으로 회전하도록 설계하였다. 각도를 회전한 횟수를 측정하여 색깔의 중심을 바라보고 다음 stage로 넘어가는 각도를 조정할 수 있도록 설계하였다. 

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/4dd3121f-4a5c-48a5-b9e5-9b2b3190cb30" alt="image" width="300"/>
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/00e786a1-5c70-49bb-9bf2-ca06192cec98" alt="image" width="300"/>


   
위에서 언급한 것과 같이 stage마다 진행 방식이 다르기 때문에, stage별로 다른 전략도 존재한다.   
   
+ 1 stage
  - 원의 중심을 올바르게 인식하기 위하여 첫 이륙 후, 드론은 한 번 더 위로 이동   
  - 중점을 찾고 상하좌우 조정 후에 색 인식   
  - 원을 통과하여 색 앞으로 이동 후 회전   

+ 2 stage
  - 주어진 각도만큼 회전 후, 원의 중심과 색을 인식하기 위해 적절한 거리만큼 앞으로 이동   
  - 중점을 찾고 상하좌우 조정 후에 색 인식   
  - 가림막 앞으로 이동 후 회전


+ 3 stage
  - 원의 중심과 색을 인식하기 위해 적절한 거리만큼 앞으로 이동   
  - 중점을 찾고 상하좌우 조정 후에 색 인식   
  - 가림막 앞으로 이동 후에 회전

+ 4 stage
  - 원의 중심과 색을 인식하기 위해 적절한 거리만큼 앞으로 이동
  - 원의 중심을 인식하고 가림막의 앞까지 이동
  - 색을 인식하고 색의 중심으로 각도를 회전
  - 적절한 거리 이동 후 착륙



알고리즘 설명
==========
전체적인 알고리즘에 대한 설명은 순서도를 첨부하여 설명한다.   

## 1st stage   
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/9e434eb1-8d86-486c-a18a-92c3dfb8ef26" alt="image" width="500"/>   
   
드론 이륙 후, 효율적인 원 감지를 위해 0.3m만큼 위로 상승한다.    
   
사진 촬영 후 조건에 따라 이미지를 이진화 한 후, 이진화 된 이미지에서 원의 중심과 면적의 넓이를 계산한다.    
   
미리 설정한 원의 중심과 촬영한 원의 중심을 비교한 뒤, 33픽셀 이하일 경우 원의 중심에 위치한다 판단하여 미리 계산한 원의 넓이에 따라 전진한다.    
   
33픽셀 이상일 경우 설정한 case에 따라 상하좌우로 드론이 이동하여 원의 중심으로 이동한다.   
   
링의 앞으로 이동한 뒤 사진 촬영 후 색상 타겟을 인식한 뒤 미리 설정한 중심 좌표와 색상 타겟의 중심 좌표를 비교하여 30픽셀 이하 일 경우 일치한다 판단하여 타겟 앞으로 드론을 정지시킨다. 그러지 않을 경우 드론의 각도를 5도씩 조정하여 드론을 색상 타겟 앞으로 이동할 수 있도록 한다. 그 후 조정한 각도를 고려하여 다음 stage의 타겟을 바라볼 수 있도록 드론을 회전 시킨다.


## 2nd stage
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/9627ac80-dff6-4bd4-9201-4ab397ca08e1" alt="image" width="500"/>   
   
2stage에 진입하기 위해 드론을 약간 전진시킨 뒤 1stage와 마찬가지로 드론을 이용한 사진 촬영 후 원의 중심과 면적의 넓이를 계산한다.    
   
원의 중심과 촬영한 원의 중심을 비교한 뒤 40픽셀 이하일 경우 원의 중심에 위치한다 판단하여 원의 넓이에 따라 전진한다.    
   
이때 픽셀 차가 40에서 150일 경우 0.2m씩 드론을 상하좌우로 보정하고, 픽셀차가 150 이상일 경우 드론을 0.4m씩 보정한다.    
   
링의 앞으로 전진 한 뒤 색상 타겟을 인식하여 드론이 색상 타겟의 중심에 위치하도록 1stage와 같은 원리로 각도를 조정한다. 그 후 조정한 각도를 고려하여 다음 stage의 타겟을 바라볼 수 있도록 드론을 회전 시킨다.

   
## 3rd stage
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/d4ab209c-9b23-4d19-b509-78d649c2ad20" alt="image" width="500"/>   


3stage에 진입하기 위해 드론을 약간 전진시킨 뒤 위 stage와 마찬가지로 원의 중심과 면적의 넓이를 계산한다.   
   
2stage와 마찬가지로 원의 중심과 촬영한 원의 중심을 비교한 뒤 40픽셀 이하일 경우 원의 중심에 위치한다 판단하여 원의 넓이에 따라 전진한다.    
     
이때 픽셀 차가 40에서 150일 경우 0.2m씩 드론을 상하좌우로 보정하고, 픽셀차가 150 이상일 경우 드론을 0.4m씩 보정한다.  
   
링의 앞으로 전진 한 뒤 색상 타겟을 인식하여 드론이 색상 타겟의 중심에 위치하도록 1stage와 같은 원리로 각도를 조정한다. 그 후 조정한 각도를 고려하여 다음 stage의 타겟을 바라볼 수 있도록 드론을 회전 시킨다.

## 4th stage
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/2546f32f-3584-4589-9fa5-6e70db65d49d" alt="image" width="500"/>   
   

4stage에 진입하기 위해 드론을 약간 전진시킨 뒤 위 stage와 마찬가지로 원의 중심과 면적의 넓이를 계산한다.   

2stage와 마찬가지로 원의 중심과 촬영한 원의 중심을 비교한 뒤 40픽셀 이하일 경우 원의 중심에 위치한다 판단하여 원의 넓이에 따라 전진한다.   
이때 픽셀 차가 40에서 150일 경우 0.2m씩 드론을 상하좌우로 보정하고 픽셀차가 150 이상일 경우 드론을 0.4m씩 보정한다.    
   
링의 앞으로 전진 한 뒤 올바른 착륙 지점에 착륙하기 위해 색상 타겟을 인식하여 드론이 색상 타겟의 중심에 위치하도록 1stage와 같은 원리로 각도를 조정한다. 그 후 드론을 전진시켜 링을 통과함과 동시에 착륙한다.

소스 코드 설명
===========
```matlab
%메인문 

count_go = 0;  % 전진한 횟수를 세주는 변수
area_circle = 0;  % 각 스테이지 별 원의 면적
center = [480, 200];  % 기준 중심 위치
centroid = zeros(size(center));  % 원의 중심 좌표를 저장할 변수
count = 0; % 상하좌우 전진 횟수
color_pixel = 0; % 색 감지 변수

drone = ryze();  % 드론 객체 선언
cam = camera(drone);  % 드론의 카메라 객체 선언
takeoff(drone);  % 드론 이륙
moveup(drone, 'Distance', 0.3, 'Speed', 0.2);
pause(1.0);

```   
변수를 초기화하고 드론 객체와 카메라 객체를 선언하였고, 위에서 언급한 것처럼 기준 중심의 위치를 480,200으로 선언하였다.    
```count_go``` 변수는 드론이 앞으로 진행했는지 여부를 확인하는 변수이다. 0이면 진행하지 않은 것이고 1이면 앞으로 나아간 것으로 판단한다.  
   
```arar_circle``` 변수는 각 스테이지마다 원의 면적을 저장하는 변수이다. 원의 면적을 저장하고 이를 토대로 원과 드론 사이의 거리를 추정하여 원을 통과하거나 앞에 멈추도록 설계하였다.   
   
```center```은 전략에서 언급한 것과 같이 기준 중심 좌표를 저장하는 전역 변수이다. 이를 가지고 측정한 중심 값과 비교하여 상하좌우 혹은 앞으로 나아갈지에 대한 여부를 판단한다.   
   
```centroid```변수는 측정한 중심 값을 저장하는 변수이다.   

```count```는 상하좌우의 이동 횟수를 저장하는 변수이다.   


#### 가림막 인식
```matlab
while 1
    frame = snapshot(cam);  % 카메라로부터 이미지 캡처
    img = double(frame);  % 이미지를 double 형으로 변환
    [R, C, X] = size(img);  % 이미지의 크기를 저장

    % 특정 색상 조건에 따라 이미지를 이진화
    img2 = zeros(R, C, X);
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) > -5 || img(i, j, 1) - img(i, j, 3) > -5 || img(i, j, 2) - img(i, j, 3) > -40
                img2(i, j, :) = 255;
            else
                img2(i, j, :) = 0;
            end
        end
    end
```
  
드론이 이미지를 찍고 이중 반복 과정을 통해 RGB 조건에 해당하는 픽셀은 흰색으로, 해당하지 않으면 검정색으로 바꾸는 과정이다.    
이는 푸른색 가림막을 인식하고 푸른색 부분은 흰색으로 나머지 부분은 검정색으로 변환하여 저장한다. 
   
#### 원의 중심과 면적
```matlab
    % 이진화된 이미지에서 원의 중심과 면적을 찾음
    circle_ring = img2 / 255;
    circle_ring_Gray = rgb2gray(circle_ring);
    circle_ring_bi = imbinarize(circle_ring_Gray);
    bi2 = imcomplement(circle_ring_bi);
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);
    se = strel('disk', 10);
    bw2 = imclose(bw, se);
    bw3 = bwareaopen(bw2, 8000);
    [B, L] = bwboundaries(bw3, 'noholes');
    figure(1), imshow(bw3); 
    % 원의 중심 좌표 찾는 과정 출력
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 그림
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:, 2), boundary(:, 1), 'w', 'LineWidth', 2);
    end
```

먼저 이미지를 0과 255 사이의 값을 0과 1로 정규화하고, 그레이 스케일로 바꾼다. 이를 다시 이진화하여 보수하는 과정을 거쳐서 픽셀이 8000 이하의 작은 객체는 제거하고 남은 객체의 경계선을 찾는다. 이에 대한 이미지를 출력하는 부분에서는 경계를 하얀색 선을 추가하여 보다 더 정확하게 판단할 수 있도록 설계하였다.
   

```matlab
    % 원의 면적과 중심 좌표를 계산
    stats = regionprops(L, 'Area', 'Centroid');
    threshold = 0.7;
    for k = 1:length(B)
        boundary = B{k};
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq, 2)));
        area = stats(k).Area;
        metric = 4 * pi * area / perimeter^2;
        metric_string = sprintf('%2.2f', metric);

        if metric > threshold
            area_circle = stats(k).Area;
            centroid = stats(k).Centroid;
            plot(centroid(1), centroid(2), 'r');
        end

        text(boundary(1, 2) - 35, boundary(1, 1) + 13, metric_string, 'Color', 'r', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end
```

원의 둘레와 면적을 계산하고 이를 바탕으로 원형 지표를 구하여 임계값보다 큰 경우, 이를 붉은 색 텍스트로 중심 좌표로 표시한다. 

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/04434d65-aa95-4746-9b0a-57969731afdc" alt="image" width="400"/>  


#### 드론 이동
```matlab

    % 드론의 이동 결정
    dis = centroid - center;
    if (abs(dis(1)) < 33 && abs(dis(2)) < 33) || count == 3

        % 드론을 앞으로 이동
        if 30000 <= area_circle && area_circle < 40000
            moveforward(drone, 'Distance', 3.8, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(-1);
        elseif 40000 <= area_circle && area_circle < 50000
            moveforward(drone, 'Distance', 3.75, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(0);
        elseif 50000 <= area_circle && area_circle < 60000
            moveforward(drone, 'Distance', 3.7, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(1);
        elseif 60000 <= area_circle && area_circle < 70000
            moveforward(drone, 'Distance', 3.65, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(2);
        elseif 70000 <= area_circle && area_circle < 85000
            moveforward(drone, 'Distance', 3.6, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(3);
        elseif 85000 <= area_circle && area_circle < 100000
            moveforward(drone, 'Distance', 3.5, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(4);
        elseif 100000 <= area_circle && area_circle < 130000
            moveforward(drone, 'Distance', 3.4, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(5);
        elseif 130000 <= area_circle && area_circle < 160000
            moveforward(drone, 'Distance', 3.3, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(6);
        elseif 160000 <= area_meas
            moveforward(drone, 'Distance', 3.1, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(7);
        else
            moveforward(drone, 'Distance', 3.85, 'Speed', 0.7);
            count_go = 1;
            pause(1.0);
            disp(12);
        end

```
   
   
위에서 언급한 것처럼 드론이 인식한 원의 면적에 따라 가림막과 드론 사이의 거리가 다르기 때문에, 조건문을 통해 드론이 가야하는 거리를 다르게 설정하였다. 드론이 앞으로 이동한 경우, ```count_go```변수를 1로 초기화하였고 이는 앞으로 간 것을 판단하는 변수이다.
   
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/258b4ce7-0b69-4190-a143-7571e1c34864" alt="image" width="300"/>[1 stage의 4번째 case] <img src="https://github.com/202020882/drone_the_bit/assets/127501452/5e510d81-1c12-4ff8-9ced-e3061a35096a" alt="image" width="300"/>[2 stage의 -1번째 case]


<img src="https://github.com/202020882/drone_the_bit/assets/127501452/4999d91f-2270-4961-b869-516c9a05195f" alt="image" width="300"/>[3 stage의 -1번째 case] <img src="https://github.com/202020882/drone_the_bit/assets/127501452/4e144497-75e3-4cf8-bd45-1b903414caf8" alt="image" width="300"/>[3 stage의 -1번째 case]




```matlab
    else
        while 1
            if dis(1) > 0 && abs(dis(1)) > 33 && dis(2) < 33
                disp("Moving drone right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 33 && dis(2) < 33
                disp("Moving drone left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 33 && dis(2) > 0 && abs(dis(2)) > 33
                disp("Moving drone down");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif abs(dis(1)) < 33 && dis(2) < 0 && abs(dis(2)) > 33
                disp("Moving drone up");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) > 0 && abs(dis(1)) > 33
                disp("Moving right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            elseif dis(1) < 0 && abs(dis(1)) > 33
                disp("Moving left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.2);
                count = count + 1;
                pause(1.0);
                break;
            else
                break;
            end
        end

    end
    if count_go == 1
        break;
    end
end

count_go = 0;
count = 0;
turn(drone, deg2rad(130));

```   
   
앞서 전역 변수와 코드에서 찾은 중앙값을 비교하여 33보다 작은 경우, 색을 인식하는 코드를 실행하였다. 그러나 33보다 큰 경우라면 중점을 찾지 못한 것으로 인식하고 드론의 위치를 조정할 필요가 있다. 따라서 이 경우에 추가적인 조건문을 생성하여 중점을 찾는 과정을 반복하도록 설정하였다.    

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/9d4e4d9a-d86f-464b-a818-3a2d3bcc7a06" alt="image" width="400"/>

   
원의 영역을 나누어서 표시하면 위와 같은 그림으로 나타낼 수 있다. 즉 출력되는 이미지에서의 원의 위치가 좌측에 있으면 오른쪽으로 이동하는 문구가 출력되고, 우측에 있으면 왼쪽으로 이동하는 문구가 출력된다. 위아래도 원리는 동일하다. 

그러나 2 stage에서나 3 stage에서 가림막으로 나아가는 이동 거리가 부족하거나 넘치는 경우, 다음 스테이지에서 시간적인 소비가 많이 발생한다. 이는 원의 중점을 찾기 위해 반복되는 횟수가 많기 때문이다. 비행 시간을 줄이기 위해 추가적인 조건을 생성했다.



```matlab

        % 드론이 원의 중심과 멀리 떨어져 있을 경우
    elseif dis(1) > 0 && abs(dis(1)) > 200 && dis(2) < 40
        disp("Moving drone more right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 200 && dis(2) < 40
        disp("Moving drone more left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 40 && dis(2) > 0 && abs(dis(2)) > 200
        disp("Moving drone more down");
        movedown(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif abs(dis(1)) < 40 && dis(2) < 0 && abs(dis(2)) > 200
        disp("Moving drone more up");
        moveup(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) > 0 && abs(dis(1)) > 200
        disp("Moving right");
        moveright(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    elseif dis(1) < 0 && abs(dis(1)) > 200
        disp("Moving left");
        moveleft(drone, 'Distance', 0.4, 'Speed', 0.3);
        pause(1.0);
    end

    if count_go == 1
        break;
    end
end
```
<img src="https://github.com/202020882/drone_the_bit/assets/127501452/000263fd-ed29-4690-b778-d856f6a05d34" alt="image" width="400"/>
   

 따라서 이를 줄이기 위한 대비책으로 추가적인 조건을 통해 드론이 상하좌우로 움직이는 거리와 속도를 증가시켰다. 사소한 차이지만 드론이 상하좌우로 움직이는 횟수를 줄이는 효과를 발생시키고 이를 통해 전체 시간을 줄일 수 있었다.


```matlab
frame = snapshot(cam);
colorcenter = processImage_R_a(frame); % 링의 앞에서 붉은색 타겟의 중점 찾음
dis_c = colorcenter - center;
count_a = 0; % 각도 조정 횟수 변수
% 각도 조정을 통해 붉은색 타겟의 중점과 원의 중심을 일치
while abs(dis_c(1)) > 30
    frame = snapshot(cam);
    colorcenter = processImage_R_a(frame);
    dis_c = colorcenter - center;
    if dis_c(1)>0
        turn(drone, deg2rad(5));
        count_a = count_a + 1;
    else
        turn(drone, deg2rad(-5));
        count_a = count_a - 1;
    end
end
moveforward(drone, 'Distance', 2.3, 'Speed', 1.0);
pause(0.5);


turn(drone, deg2rad(130 - count_a * 5));
count_go = 0;
count = 0;

```
색상의 앞까지 이동하기 전에 색깔을 인식하고 색깔의 중점을 반환하는 사용자 정의 함수를 실행하여 앞서 전역 변수로 설정한 기준 중심과 비교한다. 
   
비교한 값이 30보다 크고 ```dis_c(1)```이 양수이면 드론이 색깔의 좌측을 바라보고 있는 것이므로 색깔을 바라볼 수 있도록 5도씩 우측으로 회전한다. 
   
계속 반복하여 30보다 작아지면 반복문을 종료하고 색상의 앞으로 이동한다. 다음 스테이지로 넘어가기 위해 회전하는 각도는 앞서 측정한 횟수에서 빼거나 더하면서 각도를 조정하도록 설계하였다.

```matlab
function [centerX, centerY] = processImage_R_a(frame)

% 이미지 읽기
img = double(frame);
[R, C, X] = size(img);
img3 = zeros(R, C, X);  % img3 변수를 초기화

% 빨간색 픽셀의 개수를 초기화
redPixelCount = 0;

% 빨간색 픽셀의 좌표를 저장할 배열
redPixels = [];

for i = 1:R
    for j = 1:C
        % 빨간색이 아닌 색들을 제거하기 위한 조건
        if img(i,j,1) - img(i,j,2) >= 55 && img(i,j,1) - img(i,j,3) >= 10 && img(i,j,2) - img(i,j,3) <= 30
            % 빨간색으로 판단되는 경우
            img3(i, j, 1) = 255;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
            redPixelCount = redPixelCount + 1;
            redPixels = [redPixels; [i, j]];
        else
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
        end
    end
end

% 빨간색 픽셀의 중심 좌표 계산
if redPixelCount > 0
    centerX = mean(redPixels(:, 2));
    centerY = mean(redPixels(:, 1));
else
    centerX = NaN;
    centerY = NaN;
    disp('빨간색 네모를 찾을 수 없습니다.');
end

% 결과 시각화
figure;
imshow(uint8(img3));
hold on;
if ~isnan(centerX) && ~isnan(centerY)
    plot(centerX, centerY, 'g+', 'MarkerSize', 30, 'LineWidth', 2);
    title('빨간색 네모의 중심 좌표');
end
hold off;

% 중심 좌표 출력
fprintf('빨간색 네모의 중심 좌표: (%.2f, %.2f)\n', centerX, centerY);


end

```
이는 빨간색을 인식하고 인식한 빨간색의 중점을 반환하는 사용자 정의 함수이다. 
   
이미지를 인식하고 RGB 조건을 통해 빨간색을 인식하지 않는 부분은 검정색으로 바꿔서 저장한다. 조건을 살펴보면 R 값이 G,B 값에 비해 크게 측정되는 경우 실행되는 것을 확인할 수 있다.
   
빨간색으로 인식한 픽셀 수가 0보다 크면 mean 함수를 통해 중심 좌표를 계산한다. 그러나 픽셀 값이 측정되지 않은 경우에는, 측정되지 않았음을 출력하도록 하였다. 결과를 시각화할 때는, 중심 좌표를 초록색의 x자 표시를 통해 표시한다.
이에 대한 결과는 아래의 사진들과 같다.
 

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/00e786a1-5c70-49bb-9bf2-ca06192cec98" alt="image" width="400"/>

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/128130f4-ed4c-43cb-96fb-8f2ddfdd5447" alt="image" width="400"/>



```matlab


% 초록색 이미지 처리 함수
function [centerX, centerY] = processImage_G(frame)

% 이미지 읽기
img = double(frame);
[R, C, X] = size(img);
img3 = zeros(R, C, X);  % img3 변수를 초기화

% 초록색 픽셀의 개수를 초기화
greenPixelCount = 0;

% 초록색 픽셀의 좌표를 저장할 배열
greenPixels = [];

for i = 1:R
    for j = 1:C
        % 초록색이 아닌 색들을 제거하기 위한 조건
        if img(i,j,1) - img(i,j,2) <= 25 && img(i,j,1) - img(i,j,3) <= 5 && img(i,j,2) - img(i,j,3) >= 17 %조건이 애매하다
            % 초록색으로 판단되는 경우
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 255;
            img3(i, j, 3) = 0;
            greenPixelCount = greenPixelCount + 1;
            greenPixels = [greenPixels; [i, j]];
        else
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
        end
    end
end

% 초록색 픽셀의 중심 좌표 계산
if greenPixelCount > 0
    centerX = mean(greenPixels(:, 2));
    centerY = mean(greenPixels(:, 1));
else
    centerX = NaN;
    centerY = NaN;
    disp('초록색 네모를 찾을 수 없습니다.');
end

% 결과 시각화
figure;
imshow(uint8(img3));
hold on;
if ~isnan(centerX) && ~isnan(centerY)
    plot(centerX, centerY, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
    title('초록색 네모의 중심 좌표');
end
hold off;

% 중심 좌표 출력
fprintf('초록색 네모의 중심 좌표: (%.2f, %.2f)\n', centerX, centerY);


end

```

이는 초록색을 인식하는 함수이다. 전체적인 코드의 형태는 빨간색을 측정하는 함수와 동일하다. 
   
이미지를 인식하고 RGB 조건을 통해 초록색으로 인식하지 않는 부분은 검정색으로 바꿔서 저장한다. 조건을 살펴보면 G 값이 R, B에 비해 크게 측정되는 경우에 조건이 실행되도록 한 것을 확인할 수 있다. 
   
초록색으로 인식한 픽셀 수가 0보다 크면 mean 함수를 통해 중심 좌표를 계산하고 픽셀이 측정되지 않은 경우에는, 측정되지 않았음을 출력한다. 결과를 출력할 때는, 위의 코드와 마찬가지로 중심 좌표에 초록색의 x자 표시를 통해 표시한다.

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/a0fd3073-1aa4-4066-af12-5d21f8b3e844" alt="image" width="400"/>

```matlab

function [centerX, centerY] = processImage_P(frame)

img = double(frame);
[R, C, X] = size(img);
img3 = zeros(R, C, X);  % img3 변수를 초기화

% 보라색 픽셀의 개수를 초기화
purplePixelCount = 0;

% 보라색 픽셀의 좌표를 저장할 배열
purplePixels = [];

for i = 1:R
    for j = 1:C
        % 보라색이 아닌 색들을 제거하기 위한 조건
        if img(i,j,1) - img(i,j,2) >= 11 && img(i,j,1) - img(i,j,3) <= 0 && img(i,j,2) - img(i,j,3) <= 20
            % 보라색으로 판단되는 경우
            img3(i, j, 1) = 255;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 255;
            purplePixelCount = purplePixelCount + 1;
            purplePixels = [purplePixels; [i, j]];
        else
            img3(i, j, 1) = 0;
            img3(i, j, 2) = 0;
            img3(i, j, 3) = 0;
        end
    end
end

% 보라색 픽셀의 중심 좌표 계산
if purplePixelCount > 0
    centerX = mean(purplePixels(:, 2));
    centerY = mean(purplePixels(:, 1));
else
    centerX = NaN;
    centerY = NaN;
    disp('보라색 네모를 찾을 수 없습니다.');
end

% 결과 시각화
figure;
imshow(uint8(img3));
hold on;
if ~isnan(centerX) && ~isnan(centerY)
    plot(centerX, centerY, 'g+', 'MarkerSize', 30, 'LineWidth', 2);
    title('보라색 네모의 중심 좌표');
end
hold off;

% 중심 좌표 출력
fprintf('보라색 네모의 중심 좌표: (%.2f, %.2f)\n', centerX, centerY);


end
```

이는 보라색을 인식하는 함수이다. 이미지를 인식하고 RGB 조건을 통해 보라색으로 인식하지 않는 부분은 검정색으로 바꿔서 저장한다. 
   
이론상, 보라색의 RGB는 R=120, G=50, B=200이다. 즉 R과 B값이 G값보다 크게 인식되거나 G가 B보다 크더라도 너무 크면 조건이 실행되지 않도록 설정하였다. 
   
이를 통해 보라색으로 인식한 픽셀 수가 0보다 크면 mean 함수를 통해 중심 좌표를 계산하고 0이면 찾지 못했다고 인식한다. 결과를 출력할 때는, 중심 좌표에 초록색의 x자 표시를 통해 표시한다.

<img src="https://github.com/202020882/drone_the_bit/assets/127501452/7c8f571e-4c84-4dd7-b7e4-2cff3cbf8c2f" alt="image" width="400"/>
