# 2022 Mini_drone 배민one

* Edge 검출, 이미지 좌표화, 다항식 회귀분석을 활용한 배민one 2022 기술 워크샵

* 드론이 장애물을 통과하는 과정을 두 단계로 나누었다
  * 드론과 과녁의 중심점 정렬 (Edge 검출 함수, 이미지 좌표화)
  * 회귀분석을 통해 전진 거리 설정

* Team 배민one
  * [김준엽](https://github.com/junyeobkim55) [임종건](https://github.com/Lim-Jong-geon)
  
***
  
## 목차

1. [사용 패키지](#1-사용-패키지)
2. [대회 진행 전략](#2-대회-진행)   
3. [중심점 찾기 알고리즘](#3-중심점-찾기-알고리즘)   
4. [각 단계별 과정](#4-각-단계별-과정)    
5. [소스 코드](#5-소스-코드)

***

## 1. 사용 패키지

* [MATLAB Support Package for Ryze Tello Drones](https://kr.mathworks.com/matlabcentral/fileexchange/74434-matlab-support-package-for-ryze-tello-drones?s_tid=srchtitle)
* [MATLAB Image Processing Toolbox](https://kr.mathworks.com/products/image.html)


## 2. 대회 진행

### 1) 장애물 중심점 탐색

  * 전략 : 카메라에 찍히는 장애물의 사진을 세 가지로 분류
    
  > * 장애물의 통과 부분(구멍)이 보이지 않는 경우
    장애물의 통과 부분이 보이지 않는 경우에는 카메라에 찍힌 장애물의 일부 부분만을 사진을 이진화 하여 추출한다.
    추출한 영역의 질량 중심을 regionprops함수를 이용하여 지정하고 드론을 지정한 중심 방향으로 이동시켜 장애물의 통과부분이 카메라 안에 들어오도록 유도한다.
  
  > * 통과 부분의 일부가 보이는 경우
    통과 부분의 일부가 보이는 경우에는 장애물의 edge를 각각 검출하여 구멍의 edge만을 추출한다.
    추출한 edge의 질량 중심을 regionprops함수를 이용하여 지정하고 드론을 지정한 중심 방향으로 이동시켜 궁극적으로는 통과부분이 온전히 카메라 안에 들어오도록 유도한다.
  
  > * 통과 부분이 온전히 보이는 경우
    중심점 찾기 코드를 적용하여 드론의 카메라 중심점과 장애물의 중심점을 일치시킨다.

### 2) 회귀분석을 통한 거리 계산 ,카메라 y축 보상
  
  * 전략 : 다항식 회귀분석을 통해 거리를 계산하고 구한 거리를 통해 y축 오차를 보상한다.
  
  > * 정확한 거리 측정을 위해 파란색 원을 출력하여 다양한 거리에서 촬영하였다. 거리에 따른 픽셀 수의 변화를 1/(이차함수) 형태로 fitting 하였고
    이후 실제 장애물 원 크기에 맞추어 scaling 을 진행하였다.
   
  > * 드론의 카메라가 하단부를 향하고 있어 카메라 중심과 장애물의 중심점을 정렬하여도 부득이한 y축 오차가 발생한다.
    카메라의 각도와 회귀분석을 통해 구한 거리를 통해 y축 오차만큼 드론을 하강한다.
    


![center classify flowchart](/image/centerclassify.png)

> * 장애물의 사진을 분류하는 flowchart (빨간색 점은 질량 중심)
> * 지령은 장애물 통과 부분의 중심점을 의미



![regression_50 plot](/image/regression_50.png)



> * 처음에는 [pixel] = a/(distance^2) + k 의 유리함수 형태로(a,k는 상수) 회귀분석을 진행하였으나 그래프의 기울기가 급격하여 가까운 1~2m의 가까운 거리에서 적절하지 않았다. 따라서 1/(ax^2+bx+c) 함수로 회귀분석을 진행하였다. 
> * 1~3m 의 데이터 만을 사용하였다.



![y_compensate](/image/ycompensate2.jpg)

> * 드론 카메라 방향으로 인해 생기는 부득이한 y축 에러를 각도 세타와 회귀분석으로 구한 거리를 통해 보상한다.

## 3. 중심점 찾기 알고리즘

 * 통과부분이 온전히 카메라 안에 들어온 후에 중심점을 찾는 알고리즘
   * 이미지 좌표화
  > (예시로는 사각형 장애물을 사용) 통과부분의 edge를 추출하고 edge의 centroid를 직교좌표계의 원점으로 한다. 이를 통해 사각형의 각 꼭짓점이 각각의 사분면에 위치하게 할 수 있다.
  
  ![coordinate](/image/coordinate.jpg)
  
  > 각 사분면에 따라 최댓값의 좌표를 갖는 지점을 꼭짓점으로 잡는다. 이 때 최댓값의 좌표가 여러 개가 나올 경우 평균화를 진행한다.
  
  ![coordinate2](/image/coordinate2.jpg)
  
 
  ![coordinate3](/image/coordinate3.jpg)
  
   * 중심점 찾기
  
  > 1,3 사분면 꼭짓점의 중점과 2,4 사분면 꼭짓점의 중점을 구하고 구한 두 중점을 평균화하여 최종적으로 **지령**(초록색 점)을 생성한다.
  
  ![coordinate4](/image/coordinate4.jpg)
  
## 4. 각 단계별 과정

### 1) 1단계

>![centerclassifyflow drawio](https://user-images.githubusercontent.com/102508367/178587284-047e9692-88a9-4658-a603-aec4f75a6d31.png)


> * 실험 초기, 1단계에서는 1차 중심점 정렬 & y축 오차보상 만을 수행하고 전진하게 했으나 거리가 멀어질 수록 드론의 전진 방향이 틀어지는 등의 문제가 발생하여 일정 거리 전진 후 중심점을 다시 정렬하게 하였다.

### 2) 2,3단계

>![flowchart23](/image/flowchart23.png)

> * 2,3 단계 에서도 과녁을 통과하는 과정은 동일하지만 거리가 멀 경우 1회 전진 후 2차 중심점 정렬을 시행하는 위치가 다르다. (2차는 과녁으로 부터 약 1.5m 3차는 약 1.45m)
> * 1,2,3차 과녁 크기에 따라 각각 다른 회귀분석 함수를 사용하였다.

## 5. 소스 코드
  
  ### 1) Imageprocess
  > Tello가 얻는 frame을 HSV 색 공간으로 변환하고 과녁의 파란색만 검출되도록 HSV 임계 값을 지정해 준다.
  
  > 결과적으로 2차원 이진화 행렬로 변환된다. (검출 픽셀 = 1 , 이외는 0)

```
function [detectblue_new,canny_img] = imageprocess(cam)

   frame = snapshot(cam);
   hsv_img=rgb2hsv(frame);

   h=hsv_img(:,:,1);
   s=hsv_img(:,:,2);

   detect_blue = ((h> 0.55) & (h < 0.7)) & (s> 0.4);
   detectblue_new=bwareafilt(detect_blue,1);
   detectblue_new_final=bwareafilt(detect_blue,1);
   for lr1=2:719
       for lr2=2:959
           if ((detectblue_new(lr1,lr2)==1)&& ...
                   (detectblue_new(lr1+1,lr2)==1)&& ...
                   (detectblue_new(lr1-1,lr2)==1)&& ...
                   (detectblue_new(lr1,lr2+1)==1)&& ...
                   (detectblue_new(lr1,lr2-1)==1))
               detectblue_new_final(lr1,lr2)=0;
           end
       end
   end
   canny_img = detectblue_new_final;
   canny_img(:,1:2)=0;
   canny_img(:,959:960)=0;
   canny_img(1:2,:)=0;
   canny_img(719:720,:)=0;
   canny_img=bwareaopen(canny_img,50);
   end
```

  > 이전에는 image processing toolbox에 내장된 canny를 이용하여 edge를 검출하는 방법을 사용.

  > 그러나 edge가 끊어져서 검출되는 불안정성이 나타나서 edge를 검출하는 새로운 방법을 고안하였다.

  > 이진화를 완료한 이미지에서 어떤 픽셀의 값이 1이고 그의 상,하,좌,우 픽셀들의 값이 모두 1일때 가운데에 위치한 픽셀의 값을 0으로 치환하였다.

  ### 2) Edge Detection
  
  ```
  function [BW3,BW4,B] = edge_detection(canny_img)

     count_BW2(1) = sum(bwareafilt(canny_img,1),'all');
     BW3(:,:,1) = bwareafilt(canny_img,1);
     for i = 2:5
         BW2 = bwareafilt(canny_img,i);
         count_BW2(i) = sum(BW2,'all');
         if count_BW2(i-1) == count_BW2(i)
             i = i - 1;
             break;
         else
             BW3(:,:,i) = BW2;
             for j = 1:i-1
                 BW3(:,:,i) = BW3(:,:,i) - BW3(:,:,j);
             end
         end
     end
```
  > 위에서 검출한 edge를 분류하는 작업이다. Edge를 bwareafilt함수를 사용하여 크기별로 분류한 뒤 BW3행렬에 분리된 각각의 edge를 3차원으로 저장한다. 

```
   for k = 1:i
       [xpoint,ypoint]=find(BW3(:,:,k)==1);
       if or((abs(max(xpoint)-min(xpoint)) < 30),(abs(max(ypoint)-min(ypoint)) < 30))
           BW3(:,:,k)=ones;
       else
           BW3(:,:,k)=BW3(:,:,k);
       end
       A(k)=sum(BW3(:,:,k),'all');
       B=find(A==min(A));
   end

   for z=1:i
       BW4(z)=sum(imfill(BW3(:,:,z),'holes'),'all');
       if  BW4(z)>10000
           BW4(z)=BW4(z);
       else
           BW4(z)=691200;
   end
   end
   end
```

> edge들을 각각 추출하여 분류한 뒤, 장애물의 통과 부분의 edge만을 추출하는 코드이다.

> imfill함수를 사용하여 닫힌 edge만을 추출하였다.

  ### 3) Case Classification
  
  ```
  % centroids_no
  if (length(BW4)==1&&min(BW4)==691200)
    s_no=regionprops(detectblue_new,'Centroid');
    centroids_no=cat(1,s_no.Centroid);

  % centroids_half
  elseif (length(BW4)>=2&&min(BW4)==691200)
    s_half=regionprops(BW3(:,:,B),'Centroid');
    centroids_half=cat(1,s_half.Centroid);

  % centroids_full
  else
    p=find((BW4==min(BW4)));
    canny_img=BW3(:,:,p);
    s_full=regionprops(canny_img,'Centroid');
    centroids_full=cat(1,s_full.Centroid);
  end
  ```
  
  > [2-1)](#1-장애물-중심점-탐색)에서 언급한대로 카메라에 찍히는 사진을 세 가지로 분류하였다.
  
  > * 열린 edge 한 개 : centroid_no
  > * 열린 edge 두 개 : centroid_half
  > * 닫힌 edge 존재  : centroid_full
  
  ### 4) Positioning Control

```
% x-positioning control
if (-0.1 <= distance_real_x)&&(distance_real_x <= 0.1)
   
elseif (0.1 < distance_real_x)&&(distance_real_x < 0.2)
    moveleft(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_x)&&(distance_real_x < -0.1)
    moveright(drone,'Distance',0.2,'Speed',0.7);
    
elseif distance_real_x >= 0.2
    moveleft(drone,'Distance',distance_real_x,'Speed',0.7);
    
elseif distance_real_x <= -0.2
    moveright(drone,'Distance',abs(distance_real_x),'Speed',0.7);
    
end

    % y-positioning control
if (-0.1 <= distance_real_y)&&(distance_real_y<= 0.1)
    
elseif (0.1 < distance_real_y)&&(distance_real_y< 0.2)
    movedown(drone,'Distance',0.2,'Speed',0.7);
    
elseif (-0.2 < distance_real_y)&&(distance_real_y < -0.1)
    moveup(drone,'Distance',0.2,'Speed',0.7);
 
elseif distance_real_y >= 0.2
    movedown(drone,'Distance',distance_real_y,'Speed',0.7);
    
elseif distance_real_y <= -0.2
    moveup(drone,'Distance',abs(distance_real_y),'Speed',0.7);
```
> 중심점이 인식되면 픽셀 거리를 바탕으로 카메라 중심과 과녁의 중심 사이의 실제 x축 거리와 y축 거리가 인식된다. 궁극적으로는 카메라 중심과 과녁의 중심의 차이가 10cm 이내를 목표로 한다.

```
function [distance,y_error] = distance_and_compensate(BW4,level)

    pixel_for_distance = min(BW4);

    % distance_dimension [m]
    if level==1
        distance = max(roots([2.41476873328480e-06 -2.95206178231860e-07 (2.48545546188223e-07)-(1/pixel_for_distance)]))-0.15;
        distance_for_y = max(roots([2.41476873328480e-06 -2.95206178231860e-07 (2.48545546188223e-07)-(1/pixel_for_distance)]))-0.1;
    elseif level==2
        distance = max(roots([4.81282626426305e-06 -5.88369407133181e-07 (4.95371053994430e-07)-(1/pixel_for_distance)]))-0.12;
        distance_for_y = max(roots([4.81282626426305e-06 -5.88369407133181e-07 (4.95371053994430e-07)-(1/pixel_for_distance)]))+0.05;
    elseif level==3
        distance = max(roots([5.87658118932178e-06 -7.18413755344577e-07 (6.04860441203445e-07)-(1/pixel_for_distance)]))-0.1;
        distance_for_y = max(roots([4.81282626426305e-06 -5.88369407133181e-07 (4.95371053994430e-07)-(1/pixel_for_distance)]));
    end

    % camera_compensate
    theta = atan(31.5/155);
    y_error = tan(theta)*distance_for_y;
end
```

> [2-2)](#2-회귀분석을-통한-거리-계산-카메라-y축-보상) 에서 언급한대로 y축 오차를 보상해주는 함수 이다. 전진거리를 그대로 y축 보상 회귀분석에 사용하지 않고 Data Tuning을 진행하여 적합한 offset값을 찾아냈다.

### 5) Center Rearrange

```
if level==1
    distance_stop=1.9;
elseif level==2
    distance_stop=1.5;
else
    distance_stop=1.45;
end

if distance > distance_stop
    moveforward(drone,'Distance',(distance-distance_stop+0.2),'Speed',0.4);

while 1 ...

```

> 드론의 전진을 위해 moveforward함수를 사용하는데 정확히 직진하지 못하는 경우가 종종 발생하였다. 이를 보완하기 위해 과녁과 드론의 거리가 일정 이상이면 적당한 거리를 먼저 직진하고 중심점을 다시 정렬하는 방안을 채택하였다.

***
