# 2021 Mini-drone Narsha
- CNN, 다항식 곡선 피팅을 활용한 2021 mini-drone 기술 워크샵  
드론이 원형 구멍이 있는 장애물의 중점을 안전하고 신속하게 통과하여, 과녁에 있는 색을 인지하고, 회전과 착륙을 수행하도록 한다. 

--------------
## 목차
1. [사용 패키지](#1-사용-패키지)
2. [파일 구조](#2-파일-구조)
3. [대회진행 전략](#3-대회진행-전략)
4. [CNN 모델](#1-CNN-모델) 
5. [다항식 곡선 피팅](#2-다항식-곡선-피팅)
6. [각 단계별 알고리즘 정리](#3-각-단계별-알고리즘-정리)
7. [소스코드 설명](#4-소스코드-설명)	
8. [실제 비행 장면](#1-실제-비행-장면) 
9. [저자](#2-저자)

-------------------------

## 1. 사용 패키지
- [MATHLAB Support Package for Ryze Tello Drones](https://kr.mathworks.com/matlabcentral/fileexchange/74434-matlab-support-package-for-ryze-tello-drones?s_tid=srchtitle)
- [Deep Learning Toolbox Converter for ONNX Model Format](https://kr.mathworks.com/matlabcentral/fileexchange/67296-deep-learning-toolbox-converter-for-onnx-model-format)

## 2. 파일 구조
<pre>
<code>
├── cnn                 
│       └── model: drone_cnn.onnx      
├── regression                                         
│       ├── step1_p2.xls   - 1단계 장애물 다항식 곡선 피팅        
│       ├── step2_p3.xls   - 2단계 장애물 다항식 곡선 피팅          
│       └── step3_p3.xls   - 3단계 장애물 다항식 곡선 피팅          
└── main.m                
</code>
</pre>

## 3. 대회진행 전략
1) **장애물 중점 탐색**
: CNN 모델을 활용한 tello 드론의 이동방향 결정
- 상세: 본 대회에서 제공하는 맵은 장애물이 x,y,z축 상에서 고정되지 않고 변동이 가능하여, 장애물의 위치에 대한 수많은 다양성이 존재한다.        
        장애물의 중점과 같은 좌표값을 찾는 방식의 경우, 특정 상황에서만 적용 가능하기에 발생할 수 있는 모든 경우를 대처하기에는 제한적인 방식이라고 판단하였다. 따라서 장애물의 중점을 구체적인 좌표값으로 찾지 않고, 여러 상황에 대해서 처리가 가능한 CNN을 활용하였다.   
	최대한 많은 예외상황을 처리할 수 있는 CNN모델을 활용해 드론이 장애물을 바라보는 시점의 frame에서 장애물의 중점으로 이동하기 위한 방향을 얻은 후, 해당 방향으로 tello의 최소 거리 단위만큼 움직이도록 하는 방식을 채택하였다. 	

	
	
2) **장애물 통과를 위한 전진 거리 결정**
: 다항식 곡선 피팅을 활용한 각 단계별 구멍 크기에 따른 전진 거리 결정
- 상세: 중점을 찾은 후에 드론이 바라보는 구멍의 크기는 각 단계별로 고정되어 있는 크기이므로, 이에 기반하여, 드론이 장애물을 통과하기 위해 움직여야 하는 거리를 다항식 곡선 피팅을 활용하여 얻었다.  
	물론 드론이 앞으로 움직일 때 일정 거리부터 구멍의 윗부분이 잘리는 상황이 발생하였지만, 모든 1~3m 상황에서 증가되는 구멍 크기의 정도에는 차이가 있었더라도, 증가되는 경향은 계속 보였기 때문에, 각 거리와 구멍의 크기를 일대일 대응시킬 수 있었다. 



--------------

![is_center](https://user-images.githubusercontent.com/63354116/125572421-b3185ad1-8bd9-4616-9b18-ccbad96fb9c1.png)

> 여기서 장애물의 중점에 드론이 위치한다는 것은 장애물의 중점과 드론이 동일 축상에 위치한다는 것을 의미한다.

## 4. CNN 모델
> 연산량을 최대한으로 줄이기 위하여 input image는 tello가 얻는 frame을 마스킹 한 후에 추가적으로 0.3배 만큼 줄여서 `[216, 288, 1]`형태를 사용한다.

![cnn_model_architecture](cnn/cnn_model_architecture.PNG)
>결과적으로 드론은 장애물의 중점에 위치되도록 ryze tello drone이 제공하는 6가지 이동방향 `[back, forward, left, right, up, down]` 에 해당하는 결론을 내리게 된다.

![cnn_label_result](cnn/cnn_label_result.png)


## 5. 다항식 곡선 피팅
> CNN을 활용하여 장애물의 중점을 찾은 후에는 장애물을 통과하기 위한 moveforward의 distance에 해당하는 값을 알아내야 한다. 

![step3_6](regression/step3_6.png)

> 이에 대한 부분은, 1,2,3단계 모두 드론이 장애물의 중점에 위치해있다면 구멍의 크기는 고정되어 있는 상황이기 때문에, 이를 고려하여 각 단계의 장애물에서 구멍만을 추출한다. 

![step3_p2](regression/step3_p2.png)
> 추출된 구멍의 크기를 이용하여 드론과 장애물 사이의 거리를 예측할 수 있도록 다항식 곡선 피팅을 한다.   

> 드론이 앞으로 움직이면 일정 거리부터 구멍의 윗부분이 잘리는 상황이 발생했지만, 모든 1~3m 상황에서 증가되는 구멍 크기의 양에는 차이가 있더라도, 증가되는 경향은 계속 보였기 때문에,  데이터의 형태가 지수함수나 이차함수 꼴이라고 생각하였다. 각각의 오차율을 토대로 분석한 결과, 이차함수꼴이 더 타당하다는 결과를 얻을 수 있었다.


## 6. 각 단계별 알고리즘 정리
### 1) 1단계
> 1단계의 경우에는 장애물의 중점의 높이가 고정되어 있는 상황이므로, 이에 해당하는 높이로 드론을 위치시키고 미리 준비한 다항식 곡선 피팅 값을 활용하여 한번에 장애물을 통과하도록 한다.       
![step_1](image_sorce/step_1.PNG)   

>   통과한 후에는 시간을 최대한 줄이기 위하여 표식의 존재여부만을 마스킹을 통하여 확인하고 드론을 좌회전한다.   



### 2) 2,3단계
> 2, 3단계의 경우에는 장애물의 중점과 드론 사이에 존재하는 변수의 양이 늘어났기 때문에, 이를 CNN을 활용하여 처리한다. 
> 즉, CNN을 통해 드론을 장애물의 중점에 위치시키고,  마찬가지로 각 단계에 해당하여 미리 준비한 다항식 곡선 피팅 값을 활용하여 한번에 장애물을 통과하도록 한다.         
![step_2_3](image_sorce/step_2_3.PNG)    

> 통과한 후에는 시간을 최대한 줄이기 위하여 표식의 존재여부만을 마스킹을 통하여 확인하고 드론을 좌회전하거나 착지시킨다.

## 7. 소스코드 설명
### 1) HSV Transformation and Masking Processing
> 연산량을 줄이기 위해 tello가 얻는 frame을 HSV 색공간으로 변환한 후, 특정 색상만 검출되도록 마스킹 처리한다.       

> 장애물의 색상과 표식의 색상에 대해서만 마스킹 처리하였으며, 각 색상에 대한 마스킹 처리는 함수화한다. 
<pre>
<code>
function masked_blue = masking_blue(frame)
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);

    img = (0.57<h)&(h<0.7)&(0.4<s)&(v>0.3)&(v<0.97);
    masked_blue = imresize(img, 0.3);
end
</code>
</pre>
> 장애물 색상에 해당하는 파란색만 검출되도록 마스킹 처리한다. 마스킹 처리가 완료되면 3차원 배열인 RGB에서 흑백에 해당하는 2차원 배열로 변환되며, 파란색은 백색(1), 파란색을 제외한 나머지 색상은 흑색(0)으로 인식된다. 


<pre>
<code>
function masked_red = masking_red(frame)
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    masked_red = (0.95<h)+(h<0.1)&(0.4<s)&(v>0.1)&(v<0.97);
end
</code>
</pre>
> 1, 2단계 표식에 해당하는 빨간색만 검출되도록 마스킹 처리한다. 마스킹 처리가 완료되면 빨간색은 백색(1), 빨간색을 제외한 나머지 색상은 흑색(0)으로 인식된다.


<pre>
<code>
function masked_purple = masking_purple(frame)
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    masked_purple = (0.7<h)&(h<0.8)&(0.2<s)&(v>0.1)&(v<0.97);
end
</code>
</pre>
> 3단계 표식에 해당하는 보라색만 검출되도록 마스킹 처리한다. 마스킹 처리가 완료되면 보라색은 백색(1), 보라색을 제외한 나머지 색상은 흑색(0)으로 인식된다.


### 2) Distance prediction using multiburve fitting
> 장애물의 구멍 크기는 각 단계별로 고정된 값이므로, 이를 기반으로 하여 드론이 장애물을 통과하기 위해 전진해야하는 거리를 예측한다. 거리 예측은 **다항식 곡선 피팅**을 활용한다.
<pre>
<code>
function hole = finding_hole(detect_blue)
    for i=1:288
        detect_blue(1,i)=1;
    end
    for i=1:288
        detect_blue(216,i)=1;
     end

    hole = imfill(detect_blue,'holes');
    
    for x=1:216
        for y=1:288
            if detect_blue(x,y)==hole(x,y)
                hole(x,y)=0;
            end
        end
    end
end
</code>
</pre>
> imfill 함수를 통해 장애물의 구멍을 채운 후, 구멍을 채우기 전과 후를 비교한다. 값의 변화가 없으면 0, 있으면 1로 변환하여 구멍에 해당하는 데이터만 얻는다. 


<pre>
<code>
function final_dist = passing_obstacle(hole, p)
    dist = polyval(p, sum(sum(hole)));
    final_dist = round(dist,3)+0.4
end
</code>
</pre>
> 사전에 학습시켜둔 다항식 곡선 피팅값을 불러오고, 이를 통해 모든 거리에 대해서 드론이 전진해야 할 이동거리를 예측한다. 예측값은 final_dist라는 변수에 대입한다. 


### 3) Mark Recognition
#### 3-1) Red Mark Recognition
<pre>
<code>
function detecting_red(myDrone, cam)
    while 1
        frame = snapshot(cam);
        masked_red = masking_red(frame);
        detect_red_sum = sum(sum(masked_red))
        if detect_red_sum >= 400
            turn(myDrone,deg2rad(-90));
            moveforward(myDrone, "Distance", 1)
            pause(1);
            break
        else
            moveforward(myDrone, "Distance", 0.2)
        end
    end
end
</code>
</pre>
> 1, 2단계의 빨간색 표식을 인식한다. 빨간색 표식의 픽셀 수가 400이상이면 표식을 인식한 것으로 간주하고, 반시계 방향으로 90도 회전 한 후, 90cm 전진한다.            

> 픽셀 수가 400미만이면 표식을 인식하기에는 거리가 멀거나, 표식을 인식하지 못한 것으로 간주한다. 따라서 표식을 인식할 수 있도록(픽셀 수가 400이상이 되도록) 20cm씩 전진한다. 


#### 3-2) Purple Mark Recognition
<pre>
<code>
function detecting_purple(myDrone, cam)
    while 1
        frame = snapshot(cam);
        masked_purple = masking_purple(frame);
        detect_purple_sum = sum(sum(masked_purple))
        if detect_purple_sum >= 400
            land(myDrone)
            pause(1);
            break
        else
            moveforward(myDrone, "Distance", 0.2)
        end
    end
end
</code>
</pre>
> 3단계의 보라색 표식을 인식한다. 보라색 표식의 픽셀 수가 400이상이면 표식을 인식한 것으로 간주하고, 픽셀 수가 400이상이면 착지한다.                    

> 픽셀 수가 400미만이면 표식을 인식하기에는 거리가 멀거나, 표식을 인식하지 못한 것으로 간주한다. 따라서 표식을 인식할 수 있도록(픽셀 수가 400이상이 되도록) 20cm씩 전진한다.


### 4) Step 1_passing_obstacle
> 1단계 장애물은 장애물의 높이가 고정되어 있고, 좌우 이동이 없기 때문에 CNN을 별도로 사용하지 않는다.                

#### 4-1) Step1_find_center
<pre>
<code>
function step1_find_center(myDrone)
    [height, time] = readHeight(myDrone);
    dist_1 = 0.9-height
    if abs(dist_1) > 0.2 
        if dist_1<0
            movedown(myDrone, "Distance", dist_1)
        else
            moveup(myDrone, "Distance", dist_1)
        end
    end
end
</code>
</pre>
> 1단계 장애물의 중점과 드론이 동일 축상에 존재하도록 드론의 비행 높이를 조절한다. 드론이 이륙하고 호버링한 이후에 초기 비행 높이를 height라는 변수에 대입한다.    

> 장애물의 중점과 드론이 동일 축상에 존재하기 위해 드론이 상승해야 하는 높이를 찾는다. 1단계 장애물의 중점 높이는 99.5cm이지만 드론이 이동시 흔들리면서 발생하는 오차를 고려하여 90cm를 중점의 높이로 설정한다.                

> 중점의 높이와 height 간의 차가 양수일 경우에는 드론이 상승하도록 하고, 음수일 경우에는 하강하도록 한다. 


### 5) Step 2,3_passing_obstacle
> 2, 3단계 장애물은 많은 경우의 수가 존재하기에 CNN을 활용하여 드론의 이동방향을 결정한다. 
<pre>
<code>
function find_center(myDrone, label)
    if label == "right"
        fprintf("Moving the drone right\n")
        moveright(myDrone, "Distance", 0.2)
    elseif label == "left"
        fprintf("Moving the drone left\n")
        moveleft(myDrone, "Distance", 0.3)
    elseif label == "up"
        fprintf("Moving the drone up\n")
        moveup(myDrone, "Distance", 0.2)
    elseif label == "down"
        fprintf("Moving the drone down\n")
        movedown(myDrone, "Distance", 0.3)
    elseif label == "back"
        fprintf("Moving the drone back\n")
        moveback(myDrone, "Distance", 0.2)
    end
end
</code>
</pre>
> drone이 움직일 수 있는 최소의 거리는 20cm이므로 중점에서 10cm가 벗어난 상황에도 대응하기 위하여, 좌우, 위아래로 묶음지어 하나는 20cm, 반대 방향은 30cm가 이동하도록 한다. 


### 6) Passing_obstacle_using_CNN
> CNN을 이용한 장애물 통과 과정을 정리한 것이다. 해당 방식은 2,3단계 장애물을 통과할 때에만 적용된다. 
<pre>
<code>
while 1
    frame = snapshot(cam);
    masked_blue = masking_blue(frame);

    label = classify(net, masked_blue);
    
    if label == "forward"
         fprintf("Moving the drone forward\n")
        break
    else
        find_center(myDrone, label)
    end
end
</code>
</pre>
> CNN을 통해 예측한 이동 방향을 label 변수에 대입한다.       

> CNN이 예측한 이동방향이 forward일 경우에는 드론이 장애물의 중점과 동일한 축상에 위치한 것으로 간주하여 전진만 하면 된다고 인식한다. 따라서 forward일 경우에는 while문을 벗어나고, 더 이상 CNN을 사용하지 않는다. 


<pre>
<code>
frame = snapshot(cam);
masked_blue = masking_blue(frame);
hole = finding_hole(masked_blue);
final_dist = passing_obstacle(hole, p2)
while final_dist == inf
    moveforward(myDrone, "Distance", 0.2)
    final_dist = passing_obstacle(hole, p2)
end

moveforward(myDrone, "Distance", final_dist)
detecting_red(myDrone, cam)
moveforward(myDrone, "Distance", 0.2)
</code>
</pre>

> 드론이 장애물의 중점과 동일한 축상에 존재할 경우(label == forward일 경우)에는 다항식 곡선피팅을 이용하여 예측한 거리만큼 드론을 전진한다.                      


--------------

## 8. 실제 비행 장면
![testing](image_sorce/testing.gif)

## 9. 저자
#### :star: Team Narsha 
- 팀원: 황도현, 성강, 안온유 
