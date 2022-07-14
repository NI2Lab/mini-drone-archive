# longsil_longsil팀 코드

## 0. 목차

1. 개요
2. 이미지 프로세싱
3. 회귀분석을 통한 거리 계산
4.  중심점 찾기
5.  원 인식
6.  최종 주행 코드 설명
7.  번외

***
## 1. 개요

+ **순서도**

1. 드론 이륙후, "원->파랑 네모" 순서대로 장애물을 감지한다. 
2. 원과 파랑네모가 모두 보이지 않을 경우는 없겠지만, 만일을 대비하여 상하좌우로 조금씩 움직이며 파랑네모를 먼저 찾는다. 
3. 원은 보이지 않지만 파랑네모가 보이는 경우, 파랑네모의 중심점을 활용하여 중심으로 오게 하고, 이동할 거리는 반지름과 픽셀의 거리로 추정하여 이동한다. 
4. 원이 다보이는 경우 원의 중심을 맞추고, 회귀분석으로 구한 전진거리만큼 전진한다.
5. 위의 1부터 4의 과정을 반복하며 빨간색이 보이면 90도 회전, 초록색이 보이면 135도 회전, 보라색이 보이면 착륙하도록 한다.      

***
## 2. 이미지 프로세싱

+ __장애물의 색상 Blue 인식__

이미지의 rgb를 hsv로 바꾸어 적절히 h,s,v의 임계값을 실험을 통해 조절하여 파랑색만 검출될 수 있도록 조절하였다.

아래의 코드에서 maksed_blue는 파랑색을 검출한 이미지이고,
bw2는 masked_blue를 반전시켜 저장한 이미지이며, bwareaopen이라는 matlab 내장함수를 이용하여 불필요한 픽셀들이 함께 포착되는 것을 방지하려고 1000 픽셀 이하의 것들은 무시하도록 하였다.  

```Matlab
function bw2 = make_snap(cam)
    snap = snapshot(cam);
    img = snap;
    hsv = rgb2hsv(img);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    masked_blue = (0.535<h)&(h<0.69)&(0.4<s)&(v>0.1)&(v<0.97);

    bw2 = ~masked_blue;
    bw2 = bwareaopen(bw2,1000);

end
```

***
 ## 3. 회귀분석을 통한 거리 계산

드론과 장애물과의 거리를 파악하기 위한 방법을 생각해보다가 다양한 거리에서 직접 드론으로 장애물을 촬영하여 원의 픽셀 수를 얻어 X(원의 픽셀 수), Y(드론과 장애물과의 거리)의 관계를 선형 피팅을 통해 추정하는 방법을 사용하게 되었다.

이 때, 장애물의 원(구멍)의 픽셀만을 따오기 위하여 아래의 코드를 이용해 원의 픽셀만을 데이터로 수집하였다. 2.이미지  프로세싱 과정에서 장애물의 색상인 Blue를 hsv값을 이용하여 감지한 이미지인 masked_blue를 matlab 내장함수인 imfill을 이용하여 holes(원/구멍)를 채운 픽셀 holes에서 Blue의 픽셀인 blue를 빼주면 우리가 원하는 원(구멍)의 픽셀만을 알아낼 수 있다.

```Matlab
    hole = imfill(masked_blue,'holes'); %maksed_blue는 2.에서 얻은 Blue detect한 이미지
    holes = sum(hole,'all');
    blue = sum(masked_blue,"all");
    pixel = holes - blue;
```

![9장](https://user-images.githubusercontent.com/77524884/178676420-0cec2069-8bff-4f5f-99b2-29d5bdab089d.png)

위와 같은 사진을 1,2,3차 장애물마다 5cm 단위로 장애물과 드론의 거리 약 0.5 m에서부터 3.0 m까지 모두 촬영하여 엑셀파일로 저장 후 아래의 코드로 선형 피팅을 진행하여 원의 픽셀 수(X)에 따른 드론과 장애물 사이의 거리(Y)를 추정할 수 있도록 하였다.

```Matlab
 function [fitresult, gof] = createFit(Y, X)
 Data = xlsread('2차장애물.xlsx',1,'A2:B33');
 X = Data(:,1);
 Y = Data(:,2);
 [xData, yData] = prepareCurveData( Y, X );
 ft = fittype( 'rat11' );
 opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
 opts.Display = 'Off';
 opts.StartPoint = [0.489252638400019 0.337719409821377 0.900053846417662];
 [fitresult, gof] = fit( xData, yData, ft, opts );
 figure( 'Name', 'untitled fit 1' );
 h = plot( fitresult, xData, yData );
 legend( h, 'X vs. Y', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
 % 좌표축에 레이블을 지정하십시오.
 xlabel( 'Y', 'Interpreter', 'none' );
 ylabel( 'X', 'Interpreter', 'none' );
 grid on
```     

* 예시로 위의 코드는 2차 장애물에서 matlab의 Curve Fitting Toolbox를 이용하여 선형 피팅을 진행한 것이다. 이와 마찬가지로 1,3차도 동일하게 진행하였다.

<img width="400" alt="md_1" src = "https://user-images.githubusercontent.com/77524884/178656721-e43aa857-0fb7-4a5d-909b-d954220030c6.png">

* 예시로 보여준 위의 이미지는 3차 장애물에서의 회귀분석 함수의 그래프이다. 1,2차도 함수의 형태는 조금 다르지만 같은 원리라 생략하였다.

**_1차 장애물_**
> 
> 1차 장애물은 높이제어와 전진거리만 제어해주면 통과 할 수있다. 따라서 1차 장애물 통과의 핵심은 얼마나 잘 높이 제어와 전진거리 제어를 하는 것이 관건이다. 
> * 높이는 처음 이륙하면 드론이 약 0.7m 높이로 호버링을 한다. 이에 0.5m  추가 moveup하여 1.2m로 초기  높이를 맞춘다. 
> * 파랑 네모와, 원의 중점을 찾고, 중점 중앙에 오도록 한다. 
> * 회귀분석을 활용하여 전진거리를 구한다.
>> 아래는 1차 장애물의 X(원의 픽셀 수)와 Y(드론과 장애물까지의 거리)의 관계를 약 35개의 데이터를 이용해 회귀분석한 함수이다. 최종 코드에서 편의를 위해 지정함수로 함수화 해둔 코드이다.

```Matlab
function Go_1 = first_go(Circle)
    x_1 = Circle;
    p1 = 0.5997; %1st 장애물 회귀분석함수
    p2 = 2.154e+05;
    q1 = 3.494e+04;
    
    Distance = (p1*x_1 + p2) / (x_1 + q1); %장애물-드론이 거리
    Go_1 = round(Distance,1) + 0.6; %드론이가 가야하는 거리
end
```

**_2차 장애물_**
>
>  2차 장애물은 1차 장애물을 통과 후에 turn(drone,deg2rad(90))으로 우회전을 한 이후 배치된 위치에 따라서 제어를 해줘야 한다. 장애물의 구멍은 보이지 않고 파랑색 부분만 보이는 경우에는 matlab 내장함수인 regionprops 함수의 boudingbox property를 이용하여 파랑색 부분영역을 포함하는 박스를 만들어서 그 박스의 중심을 찾아 드론의 중심과 일치시킨다. 이 방법에 대해서는 4. 중심점 찾기에서 자세히 다룰 것이다.
> * 그렇게 서서히 이동을 시키다 보면 장애물의 구멍이 보이게 될 것이고, 구멍이 보이게 된다면 그때 역시 matlab 내장함수인 regionprops의 Centroid property를 이용하여 원의 중심을 찾는다. 그리고 드론의 중심을 그 점으로 이동시켜 드론이 구멍의 중심을 잘 통과할 수 있도록 제어한다.
> * 회귀분석을 활용하여 전진거리를 구한다.
>> 아래는 2차 장애물의 X(원의 픽셀 수)와 Y(드론과 장애물까지의 거리)의 관계를 약 34개의 데이터를 이용해 회귀분석한 함수이다. 최종 코드에서 편의를 위해 지정함수로 함수화 해둔 코드이다.

```Matlab
function Go_2 = second_go(Circle)
    x_2 = Circle;
    p1 = 0.6098; 
    p2 = 1.182e+05;
    q1 = 1.941e+04;
    Distance = (p1*x_2 + p2) / (x_2 + q1); 
    Go_2 = round(Distance,1) + 0.6; 
end
```

**_3차 장애물_**
>
> * 3차 장애물은 각도가 어떻게 놓여있는 지 알 수 없는 상황이기때문에 중간 값인 135도를 2차 장애물을 통과한 후 돌고, 1,2차 장애물과 마찬가지로 원(구멍)의 픽셀수와 거리의 관계를 회귀분석 모델로 만들어서 직진거리를 구하고 직진한다.
> * 회귀분석을 활용하여 전진거리를 구한다.
>> 아래는 3차 장애물의 X(원의 픽셀 수)와 Y(드론과 장애물까지의 거리)의 관계를 약 32개의 데이터를 이용해 회귀분석한 함수이다. 최종 코드에서 편의를 위해 지정함수로 함수화 해둔 코드이다.

```Matlab
function Go_3 = third_go(Circle)
    x_3 = Circle;
    a = 2.838;
    b = -7.117e-05;
    c = 2.576;
    d = -7.089e-06;
    Distance = a*exp(b*x_3) + c*exp(d*x_3);
    Go_3 = round(Distance,1) + 0.6;
end
```

***

### 4. 중심점 찾기
* 2,3차 장애물은 상하좌우가 어떻게 변동되는지 모르기 때문에 장애물의 중심을 찾아서 전진을 시켜야 한다.

우선 원(구멍)이 다 보일 때 원의 중심을 찾기 위해서 matlab의 내장함수인 regionprops의 property 중 Centroid를 이용하여 원의 질량중심을 판단한다. 원의 특성상 질량중심이 원의 중심이므로 오차가 안클 것이라고 예상하였고, 예상대로 원의 중심을 잘 찾음을 확인할 수 있어서 이 방법으로 진행하였다.

```Matlab
function [Centroid,Diameter] = Hole_Center(bw2)

    props = regionprops(bw2,'BoundingBox', 'Centroid', 'Area','Circularity','MajorAxisLength','MinorAxisLength');
    length = size(props(:,1));
    length = length(:,1);


    for i = 1:length 
        c(i) = props(i,:).Circularity;
    end

    [~,num] = max(c);
    Cir = props(num,:).Circularity;
    MaxD = props(num,:).MajorAxisLength;
    MinD = props(num,:).MinorAxisLength;

    pixel = checking_circle_half(~bw2);
    fprintf("Pixel : %d\n",pixel);
    if pixel < 20
        Centroid = [-1,-1];
        Diameter = 0;
    else
        x = props(num,:).Centroid(1);
        y = props(num,:).Centroid(2);
        
    Centroid = [x, y];
    Diameter = (MaxD + MinD) / 2;
    end
end
```

length 변수에 props배열의 열 개수를 저장하여 for문으로 props배열의 모든 열을 탐색한다. 탐색했을 때에 Circularity의 최댓값이 있는 열을 사용하려고 하였지만, Circularity가 원이 확실한 상황에서도 0.7 미만으로 나오는 것을 실험을 통해 알 수 있었다. Circularity를 이용하여 원인지 아닌지 판별하는 것은 위험하다고 판단되어 다른 방법으로 판별하였다. 이 판별법에 대해서는 5. 원 인식에서 자세히 설명하였다.

* 2,3차 장애물은 상하좌우가 어떻게 변동되는지 모르기 때문에 장애물의 중심을 찾아서 전진을 시켜야 한다. 우선 원(구멍)이 다 보일 때 원의 중심을 찾기 위해서 matlab의 내장함수인 regionprops의 property 중 Centroid를 이용하여 원의 질량중심을 판단한다. 원의 특성상 질량중심이 원의 중심이므로 오차가 안클 것이라고 예상하였고, 예상대로 원의 중심을 잘 찾음을 확인할 수 있어서 이 방법으로 진행하였다.

***

### 5. 원 인식
> 드론 카메라에 잡힌 사진을 이진화 하고, 거기에 반전을 시켜 네모파랑이 검정게 보이는 상황에서 "4. 중심점 찾기"의 Regionprops에서 Centriod을 사용하면 원과 배경 두개가 모두 인식되기때문에 이둘을 구별 할 수 있는 코딩이 별도로 필요하다. 즉, 원을 제대로 사용하기 위해서는 정확한 __원 인식 단계__ 가 필요하다 
 
* __"3. 회귀분석을 통한 거리 계산"에서 활용한 pixel 코딩을 살펴보자.__ 완벽한 원인 경우 파랑만 인식하는 masked_blue에서 imfill 함수를 활용하면 구멍뚤린 네모파랑 픽셀만 얻게 되고, hole을 모두 채우면 구멍뚤린 네모파랑과 원의 픽셀을 가져오게 된다. holes에서 blue 빼게 되면 원의 픽셀만 갖게 된다.  즉, (구멍뚤린네모파랑+원) - (구멍뚤린 파랑네모 픽셀)=pixel로 정확히 원의 픽셀을 가져온다. 

* imfill함수는 무조건 짤린부위없이 네면이 모두 갇혀있을때 안쪽을 채워주는 함수로, 원이 짤려있는 상태는 네모파랑테두리 네면이 모두 직선으로 채워지지 않은 상태임으로 pixel수의 변화가 없다. 즉, pixel이 일정한 숫자 이상이면, 완벽한 원으로 인식하고 아니면 완벽한 원을 인식하지 못한것이므로 다시 원의 중심점 찾기 함수로 이동한다.   
```Matlab
    hole = imfill(masked_blue,'holes'); %maksed_blue는 2.에서 얻은 Blue detect한 이미지
    holes = sum(hole,'all');
    blue = sum(masked_blue,"all");
    pixel = holes - blue;
``` 

*  즉,  pixel의 수가 20보다 작으면 원이 아니므로, 다시 원의 중심점을 찾기위해 이동하고, 20보다 크면 정확한 원모양이라고 판단해서 해당 pixel수에 맞는 전진거리만큼 이동하는 코딩으로 넘어가도록 한다. 아래 코딩이 pixel 수에 따른 원 인식 코딩이다.

```Matlab

    pixel = checking_circle_half(~bw2);
    fprintf("Pixel : %d\n",pixel);
    if pixel < 20
        Centroid = [-1,-1];
        Diameter = 0;
    else
        x = props(num,:).Centroid(1);
        y = props(num,:).Centroid(2);
        
    Centroid = [x, y];
    Diameter = (MaxD + MinD) / 2;
    end

```


***
### 6. 최종 주행 코드 설명


##### (0) Initial Setting
Tello 드론을 연결하고, 카메라를 연결해준다. level 변수는 아래의 while 문에서 한 바퀴를 돌 때마다 장애물 1차, 2차, 3차를 통과하는 것으로 가정한다. 그래서 초기 level 변수는 1로 설정한다.

k 변수에는 루프에 갇혔을 때 나오기 위해서 최대 루프 도는 횟수를 제한해두었다. 원과 원이 아닐 때를 구분할 때에 주행을 실험했을 때 드론이 위 아래로 왔다 갔다 하며 원의 중심으로 도달하지 못하고 파랑 네모의 중심만 찾으며 루프에 갇힐 때가 있었다. 이 루프에 갇힐 때에서 빠져 나오기 위해 k가 5 이상이 될 때 드론의 높이를 0.5 m 만큼 크게 변동시켜 다시 원을 찾도록 하였다. 이는 "%드론 좌우 제어 구문"에 나타나있다.
```Matlab
%% (0) Initial Setting
clear; clc;
drone = ryze();
cam = camera(drone); 
level = 1;
k = 1;
D = 0.78;
%% (0.1) Hovering
takeoff(drone); %이륙
moveup(drone,'Distance',0.5,'Speed',1);
```

#### (1) First_Step
while문을 이용하여 반복되는 코드를 단순화하여 나타내었다.
```Matlab
%% (1) First_Step
while 1
    while 1
        img = make_snap(cam);
        [Centroids,Diameter] = Hole_Center(img);
        if Centroids(1) < 0 
            Centroids = Box_center(img);
            k = k + 1;
        end
        x = Centroids(1);
        y = Centroids(2);
        imshow(img);
        hold on
        plot(x,y,'r*');
        hold off
```

### 드론 좌우 제어
u = 드론 카메라의 중심의 x값 480과 원의 중심으로 찾은 x값과의 차의 절댓값
p = 드론 카메라 중심의 y값과 원의 중심으로 찾은 y값과의 차의 절댓값
> 드론 카메라 중심의 y값은 720/2 = 360이지만 Tello의 카메라가 아래쪽을 향해있기 때문에 실험을 통해서 215를 중심의 y값으로 간주하는 것이 맞다고 판단하여 215를 이용하였다.

그러나 u와 p값은 픽셀 수이므로 드론이 실제로 이동하는 거리를 구해주어야한다.

> (원의 지름의 픽셀) : (u또는 p) = (원의 실제 지름) : (드론이 이동해야할 거리)
>> 원의 실제 지름은 1차 장애물은 0.78 m, 2차 장애물은 0.57 m, 3차 장애물은 0.5 m이다.

위의 비례식을 이용하여 드론이 실제 이동해야 할 거리를 계산하였다.
```Matlab
        %드론 좌우 제어 구문
        u = abs(x - 480);
        p = abs(y - 215);
        dx = D*(u)/Diameter;
        dy = D*(p)/Diameter;

        if k > 4
            moveup(drone,'Distance',0.5);
            k = 1;
        else
            if Diameter < 100
                if 20 < u || 20 < p
                    if 20 < u && 480 < x
                        moveright(drone,'distance',0.3);
                    elseif 20 < u && x < 480
                        moveleft(drone,'distance',0.3);
                    end
                    if 20 < p && 215 < y
                        movedown(drone,'distance',0.3);
                    elseif 20 < p && y < 215
                        moveup(drone,'distance',0.3);
                    end
                else
                    moveup(drone,'distance',0.2);
                end
            else
                if 0.2 < dx || 0.2 < dy
                    if 0.2 < dx && 480 < x
                        moveright(drone,'distance',round(dx,1));
                    elseif 0.2 < dx && x < 480 
                        moveleft(drone,'distance',round(dx,1));
                    end
                    if 0.2 < dy && 215 < y
                        movedown(drone,'distance',round(dy,1));
                    elseif 0.2 < dy && y < 215 
                        moveup(drone,'distance',round(dy,1));
                    end
                else
                    break;
                end
            end
        end
    end
```

#### 드론 전진 제어

3. 회귀분석을 통한 거리 계산에서 설명한 방법을 이용하여 전진 거리를 계산하고, 그 거리는 장애물과 드론과의 거리이기 때문에 0.5 ~ 0.7 사이의 값을 적절히 더하여 그 거리만큼 드론을 전진시켰다.
```Matlab
        %드론 전진 제어 구문
        img = make_snap(cam);
        pixel = checking_circle_half(~img);
        if level == 1
            distance = first_go(pixel);
            movedown(drone,'distance',0.3,'Speed',1);
            moveforward(drone,'distance',distance,'Speed',1);

            turn(drone,deg2rad(90));

            moveforward(drone,'Distance',1.2,'Speed',1);
            level = level + 1;
            D = 0.57;
        elseif level == 2
            
            distance = second_go(pixel);

            moveforward(drone,'distance',distance,'Speed',1.0);
            H = readHeight(drone);
            if H < 0.75
                moveup(drone,'distance',0.5);
            end
            moveright(drone,'Distance',1.4,'Speed',1.0);
            turn(drone,deg2rad(135));
            moveforward(drone,'Distance',0.4,'Speed',1.0);
            level = level + 1;
            D = 0.5;
        else

            distance = third_go(pixel);

            moveforward(drone,'distance',distance,'Speed',1);
            land(drone);
        end

end
```

***
### 7. 번외
2,3차 장애물을 발견하는 방법중에 CNN을 활용할 생각이었습니다. 허나, 실험과정에서 계속되는 오차와 오류를 해결하지 못했습니다. 따라서 본 main코딩에는 파랑 네모의 중점과 원의 중점을 이용하여 장애물을 파악하여 2,3차 장애물 파악하였다. 연구과정에서 CNN을 활용했던 방법에 대해 간략하게 소개해보겠습니다.
 * CNN
   
   <img width="703" alt="함수데이터" src="https://user-images.githubusercontent.com/102950917/178659512-a7274b83-a498-4d5b-9961-734899cdb0bb.png">
   
   * 네모파랑은 보이고 원이 완전히 보이지 않을때를 구간별로 LAbeling을 해주고, 50장씩 사진을 찍어 CNN의 데이터로 축적한다.
   
   
   
   * CNN안에 Alexnet, Squeezenet, Inception-V3등 여러 함수들이 내포되어있습니다. 내포되어있는 함수들마다 Layer와 Filter가 다르며 정확도도 다르며 크기도 다르다. 장애물을 인식하고 판단하는데에 있어 RGB까지 필요하지 않으므로 이진화된 그림으로 용량을 줄일 수 있도록 자체적으로 Layer와 Filter수를 조절하는 CNN을 쓰기로한다. 롱실롱실팀은 Alexnet과Squeezenet, Inception-V3, Filter & Layer 수를 바꾼 총 4개의 함수를 비교분석하여 정확도가 높은 함수를 CNN에 활용하고자한다. 
   
   *  Alextnet(초코,딸기,바나나,흰우유 데이터에 대한 훈련결과)
   
      <img width="600" alt="alexnet" src="https://user-images.githubusercontent.com/102950917/178687446-756d03e7-c25e-43a4-b248-0eeb9a56067d.png">
      
   * googlenet(초코,딸기,바나나,흰우유 데이터에 대한 훈련결과)
   
      <img width="600" alt="googlenet" src="https://user-images.githubusercontent.com/102950917/178655936-29d56875-fb77-47c5-815f-0154fe1bb4c4.png">
      
   * Inception-V3(초코,딸기,바나나,흰우유 데이터에 대한 훈련결과)
   
    <img width="600" alt="inception-v3" src="https://user-images.githubusercontent.com/102950917/178656192-cd953819-2968-45a6-aa6f-615ff62af9e1.png">
    
   * Filter & Layer 수를 바꾼 함수
   
    <img width="600" alt="이진화로 함수 정확도" src="https://user-images.githubusercontent.com/102950917/178656214-cc4e2072-1ee2-4a1c-b1a9-81c687a590f4.png">
    
    * __4개의 함수를 비교분석해본 결과, Filter & Layer 수를 바꾼 함수의 정확도가 높게 나와, 해당 함수로 훈련과 검증을 반복하였다. __
    
    
    * __CNN을 활용하지 못한 이유__
    
    <img width="400" alt="이진화로 함수 정확도" src="https://user-images.githubusercontent.com/102950917/178659528-7e2eeae2-4865-4a33-8549-8b405cbb98a2.png">
    
    이진화된 장애물 그림을 보았을때 label이 left & up 이 아닌 left label로 결과값이 나왔다. 해당 그림외에도 10번의 반복검증 중 단 한번만이 정확한 결과값이 출력되었으며 이는 훈련과 검증 사이에 차이가 있음을 알 수 있다. 훈련에서의 정확도가 80퍼이상이였음에도 불구하고, 새로운 그림으로 검증을 하였을때 정확도가 현저히 떨어졌다.이는 실제 훈련에서도 오류가 발생할 확률이 높아 드론이 주행하는데 사용하기에 적합하지 않다고 판단이 되어 CNN을 사용하지 않게 되었다.


