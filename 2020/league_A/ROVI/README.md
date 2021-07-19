### 2020 제 51회 대한전기학회 학술대회 미니드론 자율비행 경진대회

---
### 팀 소개

>+ __한국교통대학교 기계공학전공__
>+ __A 리그 ROVI 팀__
>+ __팀장 : 장원보__
>+ __팀원 : 이유진, 변승재__
>+ __지도교수 : 황면중 교수__

---

### 목차
>1. 대회소개
>2. 시스템 구조
>3. 대회 진행 전략
>4. 알고리즘
>5. 소스코드 설명
>6. 모의 비행
>7. 결론 및 향후 계획

---

### 대회소개
>- 미니드론으로 3개의 사각 링을 자율 비행으로 통과하여 단계별 미션을 수행하는 대회.
>- MATLAB 소프트웨어를 기반으로 드론 자율 비행 제어 시스템을 설계를 목적으로 함.

__[드론 대회 경기장]__
 

![드론 경기장 사진_1](https://user-images.githubusercontent.com/47821444/87562208-ade6e200-c6f8-11ea-89bb-a1c15a70ad5a.png)

---
![드론_경기장_사진_3](https://user-images.githubusercontent.com/47821444/87562415-f8685e80-c6f8-11ea-9009-9273c0658661.jpg)

![드론_경기장_사진_4](https://user-images.githubusercontent.com/47821444/87562420-f900f500-c6f8-11ea-8a85-7a204d99070d.jpg)

![드론_경기장_사진_2](https://user-images.githubusercontent.com/47821444/87562422-f9998b80-c6f8-11ea-9503-f0664e0470d9.jpg)

단계별 Cut-off Time이 존재하며 아래와 같음.

| 1단계	| 2단계	|3단계|
|:---|---:|:---:|
| 60 sec | 90 sec | 150 sec|

---


### 시스템구조

- PC-드론 간 원격제어를 하며,  MATLAB 프로그램으로 자율 비행 제어 시스템을 설계함.

![드론 시스템 구조](https://user-images.githubusercontent.com/47821444/87562328-d7a00900-c6f8-11ea-9433-8c162aea64ac.png)

---

### 대회 전략
>+  드론에 부착된 전면 카메라로 입력받은 사진 데이터를 영상처리하고, 드론이 사각 링의 중>심 위치를 파악하며, 링 뒤에 있는 빨간색 & 파란색 원형 표식의 중심 위치와 면적을 파악하여 드론이 링 통과하는 것을 목표로 함.
>
> + 영상처리를 이용한 방법을 사용할 경우 조명에 따라 원하는 픽셀 데이터가 많이 달라지기 때문에, 입력받은 사진 데이터 색  채널이 RGB 채널 보다 조명에 강한 HSV 색 채널 변환하여 이진화로 주변 환경의 영향에도 일관된 데이터를 받을 수 있게 함.
>
>+ 드론의 비행 계획은 비행 중인 드론이 사각 링의 중심을 찾고,  링 뒤의 표식의 위치로 드론이 움직이는 방향을 결정하며, 표식의 면적을 통해 드론 간 거리를 파악함.
>
>+ 1단계 사각 링은 위치 및 크기의 정보를 알고 있으며, 1단계에 소요되는 시간을 단축시키기 위해 드론이 이륙 위치에서 링의 중심부에 비행한 후, 1단계 사각 링 뒤에 있는 빨간 표식의 위치와 거리를 파악하여 링을 통과하게 함.
>
>+ 2단계와 3단계는 같은 로직이며, 사각 링의 중심을 찾고, 링 뒤의 표식의 위치와 면적을 통해 드론 간 거리를 파악하여 각 단계의 링을 통과함.
>
>+ 링 통과 후 표식의 색에 따라 서로 다른 비행을 취하게 함.
 

---

>알고리즘은  __영상처리(Image Processing)__ 와 __비행계획 (Flight Planning)__ 으로 나눌 수 있음.

---
#### 영상처리(Image Processing)
>드론에서 입력받은 이미지 데이터(RGB data, 행 720 x 열 960 pixel)를 HSV 채널로 변환하고, 특정 색 __(링 색깔, 빨간색, 파란색 표식)__ 에 대해서 임계값을 설정하여, 이진화를 진행함. 
>
>픽셀 값이 '0' 과 '1'로 나타난 이진화 데이터에서 값이 '1' 인 픽셀의 행과 열의 총 위치의 평균 값으로 중심 좌표를 추출함.
>
>이진화 데이터에서 값이 '1'인 픽셀 개수를 파악하여 드론과 빨간색 및 파란색 표식까지의 거리를 파악함.
>
>드론이 주변의 불필요한 이미지 데이터를 인식하지 않기 위해 이미지에서 좌우 10% (1~96, 769~960 pixel) 만큼 열을 제거함.
>
>드론 카메라로 입력받은 이미지 데이터의 노이즈를 제거하기 위해 2차원 중앙값 필터를 적용하였음.
 >

---
#### 비행 계획 (Flight Planning)
비행 계획은 __1단계,  2~3단계, 특정 표식에 의한 비행(action)__ 으로 구성됨.

>__<1단계>__
__1.__ 이륙하여 호버링을 함.
__2.__ 앞으로 1.3m 이동 후 0.4m 위로 상승함.
__3.__ 링 뒤에 있는 빨간 표식 찾기. (센터링 맞추기, 상, 하, 좌, 우 이동)
__4.__ 드론과 빨간 표식 간 거리에 맞게 드론 전진 이동
>
>
>__<2~3단계>__
__1.__ 사각 링의 중심점 찾기 (센터링 맞추기, 상,하,좌,우 이동)
__2.__ 앞으로 0.5m 이동 
__3.__ 링 뒤에 있는 빨간색 & 파란색 표식 찾기. (센터링 맞추기, 상, 하, 좌,우 이동)
__4.__ 드론과  빨간색 & 파란색 표식 간 거리에 맞게 드론 전진 이동
>
>
>__<특정 표식에 의한 비행>__
>__빨간 표식인 경우__
>__4-1.__ 빨간 표식 앞에서 90도 반시계 방향으로 회전
>__4-2.__ 0.7m 앞으로 이동 후 0.3m 우측 이동
>__파란 표식인 경우__
> __4-1.__ 착륙
 >
 ---
### 알고리즘
미니드론 비행계획 알고리즘 순서도는 아래와 같음.

__[영상처리 알고리즘]__
<center><img src ="https://user-images.githubusercontent.com/47821444/87576411-4fc3fa00-c70c-11ea-9aaf-7035a60917e4.png"></center>


__[1단계 비행계획 알고리즘]__
<center><img src ="https://user-images.githubusercontent.com/47821444/87576416-53f01780-c70c-11ea-9511-3bd5260c3222.png"></center>

__[2~3단계 비행계획 알고리즘]__
<center><img src ="https://user-images.githubusercontent.com/47821444/87576422-56527180-c70c-11ea-8e47-0ac10ecada67.png"></center>


___
### 소스코드
드론을 실행시키는 `main.m` 파일과 이를 이용한 `영상처리 및 비행 경로 계획 알고리즘 함수` (`dot_tracking.m`, `ring_tracking.m`)로 구성되어 있음.

---
__`main.m`__

드론 원격 제어 환경 설정
```
t = ryze();
c = camera(t);
takeoff(t)
pause(1)
```
1단계 통과를 위한 사전 이동
```
moveforward(t,'Distance', 1.3)
moveup(t,'Distance',0.4)
```
사용자 정의 함수에 사용되는 변수 지정.
```
%%% 공통 변수
timer = 0;
function_switch = 0;

%%% ring_tracking 변수
ring_lost_count = 0;
side_lean = 0;

%%% dot_tracking 변수
dot_lost_count = 0;
process = 1;
```
드론의 자율비행 구동
```
while(function_switch <= 1)
	if function_switch == 0
		try
			[timer, function_switch, dot_lost_count, process] = dot_tracking(t,c, timer, function_switch, dot_lost_count, process);
		end
	elseif function_switch == 1
		try
			[timer, function_switch, side_lean, ring_lost_count] = ring_tracking(t, c, timer, function_switch, side_lean, ring_lost_count);
		end
	end
	pause(0.5)
end
```
__영상처리 및 비행경로계획 알고리즘 함수__
__`dot_tracking.m`__
표식에 대해서 센터링 및 거리 파악 후 드론 비행 알고리즘.

표식과 드론의 위치를 맞추기 위한 Offset 지정 및 function에 필요한 변수 지정
```
offset = 100;
timer_limit = 3;
```
입력 받은 이미지 데이터를 색 변환후 빨간색과 파란색에 대해 각각 이진화, 중앙값 필터 이미지 처리
```
img = snapshot(c);
img_hsv = rgb2hsv(img);
land_hsv = rgb2hsv(0,65,135);
turn_hsv = rgb2hsv(150,50,50);
blue_binary = zeros(720,960);
red_binary = zeros(720,960);
for i = 1:720
    for j = 1:960
        if abs(img_hsv(i,j,1) - land_hsv(1,1,1)) <= 0.05 && abs(img_hsv(i,j,2) - land_hsv(1,1,2)) <= 0.25
            blue_binary(i,j) = 1;
        else
            blue_binary(i,j) = 0;
        end
        if abs(img_hsv(i,j,1) - turn_hsv(1,1,1)) <= 0.05 && abs(img_hsv(i,j,2) - turn_hsv(1,1,2)) <= 0.25
            red_binary(i,j) = 1;
        else
            red_binary(i,j) = 0;
        end
    end
end

blue_binary = medfilt2(blue_binary);
red_binary = medfilt2(red_binary);
```
각 색의 면적 추출.
```
blue_area = sum(blue_binary,'all');
red_area = sum(red_binary,'all');
```
__`Process.1`__
특정 색 픽셀 개수(면적)가 적은 경우
드론이 주위를 반시계 방향으로 이동하며 표식을 찾는 비행 로직

<center><img src="https://user-images.githubusercontent.com/47821444/87582879-04164e00-c716-11ea-9cc2-1be4be72724c.png" width="50%" height="50%"></center>




```
if process == 1
    if red_area < 15 && blue_area < 15
        if dot_lost_count == 0
            moveup(t,'Distance', 0.3)
            dot_lost_count = 1;
        elseif dot_lost_count == 1
            moveleft(t,'Distance',0.3)
            dot_lost_count = 2;
        elseif dot_lost_count == 2
            movedown(t,'Distance', 0.3)
            dot_lost_count = 3;
        elseif dot_lost_count == 3
            movedown(t,'Distance',0.3)
            dot_lost_count = 4;
        elseif dot_lost_count == 4
            moverigth(t,'Distance',0.3)
            dot_lost_count = 5;
        elseif dot_lost_count == 5
            moveright(t,'Distance',0.3)
            dot_lost_count = 6;
        elseif dot_lost_count == 6
            moveup(t,'Distance',0.3)
            dot_lost_count = 7;
        elseif dot_lost_count == 7
            moveup(t,'Distance',0.3)
            dot_lost_count = 8;
        elseif dot_lost_count == 8
            moveleft(t,'Distance',0.3)
            dot_lost_count = 1;
        end
```
특정 색 픽셀 개수(면적)이 충족한 경우
빨간색과 파란색 중 더 많이 검출된 표식의 색을 특정하며 드론이 특정 색의 표식의 중심 위치를 파악하여 이동함
표식의 중심 위치로 이동하여 __timer__ 를 통해 3회간 위치가 충족됬는지 확인하면 __`Process.2`__ 로 전환
```        
    else
        if red_area >= blue_area
            [row, col] = find(red_binary);
            yc = round(mean(row));
            xc = round(mean(col));
            rowOffset = round(720/2.8) - yc;
            colOffset = (768/2) - xc;
            
            if timer < timer_limit
                if(colOffset < -offset)
                    timer = 0;
                    moveright(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end                    
                elseif(colOffset  > offset)
                    timer = 0;
                    moveleft(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end                   
                elseif(rowOffset > offset)
                    timer = 0;
                    moveup(t, 'Distance', 0.2)                    
                elseif(rowOffset < -offset)
                    timer = 0;
                    movedown(t, 'Distance', 0.2)                    
                else
                    timer = timer + 1;
                end
            else
                process = 2;
            end            
        else            
            [row, col] = find(blue_binary);
            yc = round(mean(row));
            xc = round(mean(col));
            rowOffset = round(720/2.8) - yc;
            colOffset = (768/2) - xc;            
            if timer < timer_limit
                if(colOffset < -offset)
                    timer = 0;
                    moveright(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end                    
                elseif(colOffset  > offset)
                    timer = 0;
                    moveleft(t, 'Distance', 0.2)
                    if(rowOffset > offset)
                        moveup(t, 'Distance', 0.2)
                    elseif(rowOffset < -offset)
                        movedown(t, 'Distance', 0.2)
                    end                    
                elseif(rowOffset > offset)
                    timer = 0;
                    moveup(t, 'Distance', 0.2)                    
                elseif(rowOffset < -offset)
                    timer = 0;
                    movedown(t, 'Distance', 0.2)
                else
                    timer = timer + 1;
                end
            else
                process = 2;
                timer = 0;
            end
        end
    end
```
__`Process.2`__
더 많이 검출된 표식의 색상을 면적에 따라 구분하여 정면 이동량을 구하고 이동
빨간색의 경우 정면 이동 후 회전-정면 이동-우측 이동 순으로 이동하여 다음 단계의 사전 이동하며 `ring_tracking.m` 함수로 전환
파란색의 경우 정면 이동 후 착지
```
elseif process == 2
    if blue_area > red_area
        if blue_area < 25
            moveforward(t,'Distance',2.3)
        elseif blue_area < 35
            moveforward(t,'Distance',2.1)
        elseif blue_area < 50
            moveforward(t,'Distance',1.9)
        elseif blue_area < 60
            moveforward(t,'Distance',1.7)
        elseif blue_area < 70
            moveforward(t,'Distance',1.5)
        elseif blue_area < 85
            moveforward(t,'Distance',1.3)
        elseif blue_area < 125
            moveforward(t,'Distance',1.1)
        elseif blue_area < 240
            moveforward(t,'Distance',0.9)
        elseif blue_area < 290
            moveforward(t,'Distance',0.7)
        else
            moveforward(t,'Distance',0.5)
        end
        
        land(t)
    else
        if red_area < 25
            moveforward(t,'Distance',2.3)
        elseif red_area < 35
            moveforward(t,'Distance',2.1)
        elseif red_area < 50
            moveforward(t,'Distance',1.9)
        elseif red_area < 60
            moveforward(t,'Distance',1.7)
        elseif red_area < 70
            moveforward(t,'Distance',1.5)
        elseif red_area < 85
            moveforward(t,'Distance',1.3)
        elseif red_area < 125
            moveforward(t,'Distance',1.1)
        elseif red_area < 240
            moveforward(t,'Distance',0.9)
        elseif red_area < 290
            moveforward(t,'Distance',0.7)
        else
            moveforward(t,'Distance',0.5)
        end
        
        function_switch = 1;
        process = 1;
        timer = 0;
        turn(t,deg2rad(-90));
        pause(1)
        moveforward(t,'Distance',0.7)
        pause(1)
        moveright(t,'Distance',0.3)
    end
end
```
__`ring_tracking.m`__
링에 대해서 센터링 및 일정 거리 비행 알고리즘.

링과 드론의 위치를 맞추기 위한 Offset 지정 및 function에 필요한 변수 지정
```
offset = 50;
timer_limit = 3;
```
입력 받은 이미지 데이터를 색 변환후 링의 색(초록색)에 대해 이진화, 중앙값 필터 이미지 처리
처리된 영상에서 검출된 픽셀의 위치 추출
```
img = snapshot(c);
size_img = size(img);

if size_img(3) == 3
    hsv_ring = rgb2hsv(85,140,55);
    hsv_img = rgb2hsv(img);
    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    
    ring_binary = zeros(720,768);
    
    for i = 1:720
        for j = 97:1:864
            if abs(h(i,j) - hsv_ring(1)) < 0.05 && abs(s(i,j) - hsv_ring(2)) < 0.2
                ring_binary(i,j-96) = 1;
            else
                ring_binary(i,j-96) = 0;
            end
        end
    end
    
    ring_binary = medfilt2(ring_binary);
    [row, col] = find(ring_binary);
```
링의 색에 해당하는 픽셀 개수(면적)가 적은 경우
드론이 주위의 일정 범위를 이동하며 링을 찾는 비행 로직 
```
if(length(row) < 100 || length(col) < 100)
        if ring_lost_count == 0
            ring_lost_count = 1;
            movedown(t,'Distance',0.3)
        elseif ring_lost_count == 1
            ring_lost_count = 2;
            moveup(t,'Distance',0.6)
        elseif ring_lost_count == 2
            ring_lost_count = 3;
            moveright(t,'Distance',0.5)
        elseif ring_lost_count == 3
            ring_lost_count = 4;
            moveleft(t,'Distance',1)
        elseif ring_lost_count == 4
            ring_lost_count = 5;
            movedown(t,'Distance',0.6)
        elseif ring_lost_count == 5
            ring_lost_count = 6;
            moveright(t,'Distance',1)
        else
            ring_lost_count = 0;
            moveleft(t,'Distance',0.5)
            moveup(t,'Distance',0.3)
        end
```
링의 색에 해당하는 픽셀 개수(면적)가 충족된 경우
링의 중심 위치를 파악하여 이동함
표식의 중심 위치로 이동하여 __timer__ 를 통해 3회간 위치가 충족됬는지 확인하면 정면으로 일정거리 이동 후 __`dot_tracking.m`__ 함수로 전환
```
else
        ring_lost_count = 0;
        yc = round(mean(row));
        xc = round(mean(col));
        rowOffset = round(720/4) - yc;
        colOffset = (768/2) - xc;
        
        
        if timer < timer_limit
            if(colOffset < -offset)
                timer = 0;
                moveright(t, 'Distance', 0.2)
                if(rowOffset > offset)
                    moveup(t, 'Distance', 0.2)
                elseif(rowOffset < -offset)
                    movedown(t, 'Distance', 0.2)
                end
                
            elseif(colOffset  > offset)
                timer = 0;
                moveleft(t, 'Distance', 0.2)
                if(rowOffset > offset)
                    moveup(t, 'Distance', 0.2)
                elseif(rowOffset < -offset)
                    movedown(t, 'Distance', 0.2)
                end
                
            elseif(rowOffset > offset)
                timer = 0;
                moveup(t, 'Distance', 0.2)
                
            elseif(rowOffset < -offset)
                timer = 0;
                movedown(t, 'Distance', 0.2)
                
            elseif sum(ring_binary(:,453:504),'all')/52 >= 720*0.5
                if side_lean < 3
                    if sum(ring_binary(:,1),'all') > sum(ring_binary(:,768),'all')
                        timer = 0;
                        side_lean = side_lean + 1;
                        moveleft(t,'Distance',0.3)
                        
                    else
                        timer = 0;
                        side_lean = side_lean + 1;
                        moveright(t,'Distance',0.3)
                    end
                    
                else
                    if sum(ring_binary(1,:),'all') > sum(ring_binary(720,:),'all')
                        side_lean = 0;
                        moveup(t,'Distance',0.2)
                    else
                        side_lean = 0;
                        movedown(t,'Distance',0.2)
                    end
                end
            else
                timer = timer + 1;
            end
        else
            function_switch = 0;
            timer = 0;
            moveforward(t,'Distance',0.5)
        end
    end
end
```
___
### 모의 비행 

<center><img src="https://user-images.githubusercontent.com/47821444/87576248-070c4100-c70c-11ea-925f-0b3f27a0026a.gif">x8배속</center>


__[구간 별 소요되는 시간]__
| 1단계	| 2단계	|3단계|
|:---|---:|:---:|
| 31 sec |  48 sec | 76 sec|


___

### 결론 및 향후 계획
>- 드론의 전면 카메라에서 취득한 이미지 데이터로 사각 링 장애물 및 원형 표식을 검출하였으며, 드론이 특정 물체의 위치를 따라 트래킹 하는 알고리즘을 적용하여 링 통과 및 표식에 맞는 드론 비행을 수행함.
>- 대회 환경과 비슷하게 장애물을 구성하여 모의실험을 진행하였지만, 드론이 조명에 따라 영상처리 결과 데이터와 주변 환경과 지형지물로 인해 결과값이 달라졌으며, 실제 대회 현장에서도 제안한 드론 자율 비행 알고리즘 수행 결과가 다소 차이 있을 것으로 보임.
>-  향후 다양한 경우에 따른 드론 자율 비행 테스트를 진행하며, 구간별 소요 시간을 단축시킬 계획임.

