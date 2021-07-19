# 자율주행 드론 경진대회 날아조

## 서론

드론은 공간의 제약에서 자유롭고 정확한 비행을 할 수 있기 때문에 실시간으로 모니터링이 필요한 상황에서 활용되고 있고, 활용 분야는 계속 확장되고 있다. 드론의 무인자율비행은 자신의 길을 찾고 장애물은 피해서 가야한다. 우리는 2020 미니드론 자율비행 경진대회를 통해 드론이 길을 찾아가는 알고리즘을 고안했다. 드론의 카메라를 이용한 이미지 처리와 드론에 내장되어있는 센서를 이용한 위치제어를 주로 사용했다.

## 본론
### 1. 대회진행 전략
1. 드론은 정면 카메라를 통해 이미지를 습득하고 색 필터를 이용해 링을 인식한다.
2. 색 필터는 링 통과 알고리즘과 미션 수행 알고리즘을 구별하여 각 상황에 맞는 코드를 작성한다.
3. 색 필터를 한 이미지를 이진화 데이터로 출력 후 노이즈 제거를 하고 중점을 연산한다.
4. 중점과의 오차를 계산하고 링의 중점을 드론이 보는 이미지의 중심에 맞도록 드론을 상하좌우 이동시킨다.
5. 정확성을 위해 상하, 좌우 위치  조정 코드를 2회 반복하여 정확성을 높힌다.
6. 링의 중심이 드론의 중심과 일치 할 때 전진하여 링을 통과한다.
7. 링을 통과 후 미션을 수행하기 위해 다른 색 필터를 사용하여 미션 색을 찾은 후 중심을 맞춘다.
8. 빨강색, 파랑색 중심을 맞춘 후 일정 픽셀 수 이상이 되도록 전진후 일정 픽셀 수 이상 인식시 회전 및 착륙한다.
9. 이미지 또는 센서값이 들어오지 않을 경우를 대비한 코드를 상황에 맞게 넣어어준다.
10. 드론이 정확한 각도로 회전을 못했을 경우 또는 비행시 틀어지는 각도를 보상해주는 코드 또한 각 단계마다 넣어준다.

### 2. 알고리즘 설명

![알고리즘](https://user-images.githubusercontent.com/59357494/87501099-36ce3100-c699-11ea-84e1-f6ad38139d19.png)

#### - 링통과 알고리즘  

#### ![ring](https://user-images.githubusercontent.com/59357494/87499905-40a26500-c696-11ea-83ca-1d036ff81621.png)

#### - 미션 수행 알고리즘  

#### ![color](https://user-images.githubusercontent.com/59357494/87506311-f3c68a80-c6a5-11ea-86ef-55ecea203704.png)

### 3. 소스 코드 설명  
#### - delay
드론 비행중 정지상태가 아닐때 동작을 입력받으면 오작동 우려가 있으므로 드론의 속도가 0이 될때까지 동작명령을 대기시키는 코드이다.
```matlab
while 1 
      [speed,time] = readSpeed(drone);
      if sum(speed) ~= 0 
           pause(0.3)
      else
           break
      end
end
```

#### - 이미지 이진화 함수
장애물과 미션수행 장소를 인식하기 위해 드론 카메라에서 습득한 이미지를 HSV기준으로 이진화 해주는 코드이다. 각각 녹색 적색 청색을 이진화 하는 코드를 함수로 작성함.
```matlab
function [BW,maskedRGBImage] = d_green_detection(RGB)

I = rgb2hsv(RGB);

channel1Min = 0.287;
channel1Max = 0.386;

channel2Min = 0.000;
channel2Max = 1.000;

channel3Min = 0.000;
channel3Max = 1.000;

sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;

maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
```
```matlab
function [BW,maskedRGBImage] = d_red_detection(RGB)

I = rgb2hsv(RGB);

channel1Min = 0.964;
channel1Max = 0.037;

channel2Min = 0.074;
channel2Max = 1.000;

channel3Min = 0.072;
channel3Max = 1.000;

sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;

maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
```
```matlab
function [BW,maskedRGBImage] =  d_blue_detection(RGB)

I = rgb2hsv(RGB);

channel1Min = 0.617;
channel1Max = 0.701;

channel2Min = 0.067;
channel2Max = 1.000;

channel3Min = 0.000;
channel3Max = 1.000;

sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

maskedRGBImage = RGB;

maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
```

#### - 이미지 축소
이미지를 축소시 연산량이 줄어들어 드론 카메라를 통해 습득한 이미지의 해상도를 감소 시키는 코드이다. 
```matlab
img = snapshot(cam);
if size(img) ~= 0
   img2 = imresize(img,0.5);
   img2(1,:)=0;
   img2(:,1)=0;
   img2(:,480) =0;
   img2(360,:)=0;
end
```
#### - 이진화 이미지 노이즈 제거
이진화 필터를 거친 이진화 이미지의 노이즈를 제거하기 위한 코드이다.
```matlab
bw = 색필터함수(img2);
bwJ = imerode(bw,SE2);
bwim= imclose(bwJ,SE1);
```

#### - 중점찾기
드론이 장애물과 미션장소를 옳바르게 추적하기 위해 이진화된 이미지의 중앙점을 계산을 위한 코드이다.
```matlab
edgee = edge(bwim,'Canny');
[B,L,n,A]  = bwboundaries(edgee,8);
bw_L =(L==max(L(:)));    
s = regionprops(bw_L,'centroid');
```

#### - 상/하 에러에 따른 드론 상/하동작 명령
드론의 위치와 이미지 중앙점을 연산하여 양의 값이면 상승 음의 값이면 하강 명령을 주는 코드.  

![상하](https://user-images.githubusercontent.com/59357494/87144804-505f2980-c2e3-11ea-996d-7d42e0a52a4c.gif)
```matlab
error_y = 120-s.Centroid(2)
if error_y>=-30 && error_y<=10
   error_y=0;
else
   error_y=error_y+0;
end

if error_y>0 
   moveup(drone,'Distance',0.2,'WaitUntilDone',true);
elseif error_y<0
   movedown(drone,'Distance',0.2,'WaitUntilDone',true);
else
    break
end
```

#### - 좌/우 에러에 따른 드론 좌/우동작 명령
드론의 위치와 이미지 중앙점을 연산하여 양의 값이면 우측 이동 음의 값이면 좌측 이동 명령을 주는 코드이다.  

![좌우](https://user-images.githubusercontent.com/59357494/87144803-505f2980-c2e3-11ea-959b-67fa7d130fea.gif)  
```matlab
error_x = s.Centroid(1)-240
if error_x>=-30 && error_x<=30
  error_x=0;
else
  error_x=error_x+0;
end

if error_x>0
   moveright(drone,'Distance',0.2,'WaitUntilDone',true);
elseif error_x<0
   moveleft(drone,'Distance',0.2,'WaitUntilDone',true);
else
   break
end
```

#### - 전진 명령
장애물의 이진화 이미지를 인식할때까지만 전진하여 장애물을 통과하는 코드이다.  

![전진](https://user-images.githubusercontent.com/59357494/87144796-4f2dfc80-c2e3-11ea-801c-026da988a7a6.gif)  
```matlab
if sum(bw3, 'all') >= 500
  moveforward(drone, 'Distance', 0.4,'WaitUntilDone',true);
else
  break
end
```

#### - 미션 인식 동작
미션 인식 동작시 일정 픽셀수 이상 인식되면 적색에선 회전을 청색에선 착륙 명령을 주고 적색 청색이 보이지 않을 때 상하좌우 알고리즘을 추가로 넣어 위치를 조정후 동작하게 만듬.   

![색인식](https://user-images.githubusercontent.com/59357494/87144801-4fc69300-c2e3-11ea-9493-7e1e801d8ed0.gif)  
```matlab
while 1

    if sum(bw2 ,'all') >= 1200
        %%빨간색일때%%
        turn(drone,deg2rad(-85));
        moveforward(drone, 'Distance', 0.1 ,'WaitUntilDone',true);       
        break
        %%파란색%%
        land(drone)
        
    elseif sum(bw2 ,'all') >= 100
        step = '색 근접 동작';
        moveforward(drone, 'Distance',0.2,'WaitUntilDone',true);
     
    else
        moveback(drone, 'Distance',0.2,'WaitUntilDone',true);
        상하좌우 조정 알고리즘 동작
    end
```

#### - 각도 조정
드론의 이륙 전 각도를 통해 잘못된 방향 지향시 옳바른 방향으로 조정해주는 코드이다
```matlab
[angles,time]= readOrientation(drone);
if angles(1)<0
    turn(drone,-pi-(angles(1)-ref_angle));
elseif angles(1)>0
    turn(drone,pi-(angles(1)-ref_angle));
end
```

```matlab
[angles,time]= readOrientation(drone);
turn(drone,-pi/2+ref_angle-angles(1));
ref_angle =ref_angle
sense_angle =angles(1)
drone_angle =angles(1)-ref_angle
```

```matlab
[angles,time]= readOrientation(drone);
drone_angle =angles(1)-ref_angle
turn(drone,(ref_angle-angles(1)))
```


#### - 고도 조정
비행 시작점에서 이륙후 고도를 측정하면 장애물 통과 후 고도와 비교하여 시작점 고도로 조정해주는 코드이다.
```matlab
while 1
    
    [height,time] = readHeight(drone);
    
    while size(height) == [0 1]
        [height,time] = readHeight(drone);
    end
    
    sense_height = height;
    error_height = ref_height-sense_height;
    
    if error_height>=0.2
        moveup(drone, 'Distance', 0.3,'WaitUntilDone',true);
       
    elseif error_height<=-0.2 
        movedown(drone, 'Distance', 0.2,'WaitUntilDone',true);
    else
        disp('위치 조정 끝')
    end
    
    [height,time] = readHeight(drone);
    while size(height) == [0 1]
        [height,time] = readHeight(drone);
    end
    
    sense_height = height;
    
    error_height = ref_height-sense_height;
    
    if error_height<=0.2 && error_height>=-0.2
        break
    end
    
end
```

#### - 오류 방지 코드
드론의 센서코드가 오작동하면  정상동작할때 까지 센서코드를 실행하는 코드이다.  
```matlab
while size(img) == [0 0 3]       
        pause(0.4)
        img = snapshot(cam);
    end
```

```matlab
while size(angles) ==[0 3] 
    [angles,time]= readOrientation(drone);
end
```

```matlab
if size(s)==[0 1] 
        s = struct('Centroid',[240 115]);
        pause(0.3)
    end
```

```matlab
   while size(height) == [0 1]
        [height,time] = readHeight(drone);
    end
```

## - 결론  
드론은 지적조사, 화재진압, 수송, 감시 정찰 등 사람이 접근하기 어려운 지형이나 실시간으로 모니터링이 필요한 상황에서 활용되고 있고. 그 활용 분야는 계속해서 확장되고 있다. 이처럼 여러 분야에서 드론을 활용하기 위해서는 드론의 안정적인 자율 비행이 뒷받침 되어야한다. 이번 미니드론 자율비행 경진대회를 참가하여 드론을 안정적으로 제어 하기위한 이미지 처리와 드론 자율비행 알고리즘을 직접 설계하고 드론에 적용하여 자율비행을 구현 할 수 있었다.
