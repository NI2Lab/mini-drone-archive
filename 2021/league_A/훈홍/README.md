# drone
# Strategy
 2021 미니드론경진대회 전략으로 1단계에서는 빠른 시간내에 통과를 목적으로 하며, 2단계와 3단계에서는 정확성을 중시하며 통과를 최우선 순위로 하고, 빠른 시간은 두번째 우선순위로 삼는다. 또한 우리팀은 정확성과 속도의 향상을 위해서 image processing toolbox에서 제공되는 여러 함수들을 활용하여서 이미지 처리를 수행하였다. (중점 찾기, 장애물과 드론 사이의 거리 구하기)  또한 장애물까지의 거리를 측정할 때 거리에 따른 1,2,3단계별로 링의 직경을 여러번 측정하여 드론이 현재 위치에서 링을 통과하기 위한 거리(Input)를 계산하여 정확성을 높였다.
# Algorithm
> 1. 드론 객체 선언 및 takeoff

> 2. 링의 구멍을 이미지 처리하여 구멍을 찾아낸다. 구멍에서 많이 벗어난 경우 상하 좌우로 이동한다.

> 3. 이미지 속에서 링의 중점을 구하고 상하좌우로 조금씩 이동하여 드론을 중점에 맞춘다.

> 4. 링의 구멍의 장축을 측정하여 드론과의 거리를 계산한 뒤 링을 통과킨다. 
> (드론과 장애물까지의 거리에 따라 링의 장축의 길이가 달라지므로 이를 이용하여 거리를 측정하였다.)

> 5. 표식을 인식하여 빨간색이면 회전, 보라색이면 착지를 한다

> 6. 착지하기 전까지 **2**단계로 돌아가 반복한다



# Source Code
Source Code를 알고리즘 단계별로 기술하였다. 모든 Source Code가 아닌 핵심점인 부분에 대해서만 정리하였으며, 상세한 설명은 초록색 글씨로 표기하였다.

1. 변수 설정 및 takeoff
```matlab
%초기화
clear,clc ;

%변수 설정
drone=ryze();   
cam=camera(drone);
originCenter=[480 170; 480 170; 480 170]; 
count=0;
max=0;
none=0;
takeoff(drone);
```
2. 구멍 찾기

```matlab
while(1)
    %파란색에 대한 HSV값 설정 및 이진화
    frame=snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blue=(0.55<h)&(h<0.7)&(0.5<s)&(s<=1);
    
    %첫 행을 1로 변환
    blue(1,:)=1;

    %마지막 행을 1로 변환
    blue(720,:)=1;
        
    %구멍을 채움
    bw2 = imfill(blue,'holes');

    %구멍을 채우기 전후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
    for x=1:720
        for y=1:960
            if blue(x,y)==bw2(x,y)
                bw2(x,y)=0;
            end
        end
    end

    %변환한 이미지의 픽셀 수가 1000이상이면 구멍을 인식했다고 파악
    %1000이하이면 상승하여 전 과정을 다시 반복
    if sum(bw2,'all')>1000
        break;
    
    else
        %화면의 좌우를 비교
        if sum(imcrop(blue,[0 0 480 720]),'all')-sum(imcrop(blue,[480 0 960 720]),'all')>10000
            moveleft(drone,'distance',0.5,'speed',1);
        elseif sum(imcrop(blue,[480 0 960 720]),'all')-sum(imcrop(blue,[0 0 480 720]),'all')>10000
            moveright(drone,'distance',0.5,'speed',1);
            end
        if sum(imcrop(blue,[0 0 960 360]),'all')-sum(imcrop(blue,[0 360 960 720]),'all')>10000
            moveup(drone,'distance',0.4,'speed',1);
        elseif sum(imcrop(blue,[0 360 960 720]),'all')-sum(imcrop(blue,[0 0 960 360]),'all')>10000
            movedown(drone,'distance',0.4,'speed',1);
        end
        
        if sum(blue,'all')<10000
            if none==0
                moveup(drone,'distance',0.3,'speed',1);
                moveleft(drone,'distance',0.3,'speed',1);
                none=none+1;
            elseif none==1
                moveright(drone,'distance',1,'speed',1);
            end
        end
    end
end
```
3. 장애물의 중점 찾기
```matlab
while 1
    %초록색에 대한 HSV값 설정 및 이진화
    frame=snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blue=(0.55<h)&(h<0.8)&(0.5<s)&(s<=1);
    
    %첫 행을 1로 변환
    blue(1,:)=1;

    %마지막 행을 1로 변환
    blue(720,:)=1;
    
    %구멍을 채움
    bw2 = imfill(blue,'holes');
    
    %구멍을 채우기 전후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
    for x=1:720
        for y=1:960
            if blue(x,y)==bw2(x,y)
                bw2(x,y)=0;
            end
        end
    end
    
    %이미지에서 인식된 곳들의 중점과 보조축의 크기를 구함
    stats = regionprops('table',bw2, 'Centroid', 'MinorAxisLength');
    z=stats.MinorAxisLength;
    max=0;
    y=stats.Centroid;
    
    %보조축의 크기가 가장 큰 곳의 중점을 가져옴
    for i=1:size(stats)
        if z(i,1)>=max
            max=z(i,1);
            firstCenter(1,1)=round(y(i,1));
            firstCenter(1,2)=round(y(i,2));
        end
    end
    clearvars max
        
    %측정된 중점과 이상 중점을 비교하여 이동
    if firstCenter(1,1)-originCenter(level,1)>=40
        moveright(drone,'Distance',0.3,'speed',1);
    elseif firstCenter(1,1)-originCenter(level,1)<=-40
        moveleft(drone,'Distance',0.2,'speed',1);
    end
    
    if firstCenter(1,2)-originCenter(level,2)>=30
        movedown(drone,'Distance',0.3,'speed',1);
    
    elseif firstCenter(1,2)-originCenter(level,2)<=-30
        moveup(drone,'Distance',0.2,'speed',1);
    end
    
    %오차범위 내에 있으면 반복문 탈출
    if firstCenter(1,2)-originCenter(level,2)<30 && firstCenter(1,2)-originCenter(level,2)>-30 && firstCenter(1,1)-originCenter(level,1)<40 && firstCenter(1,1)-originCenter(level,1)>-40
        break;
    end
end
```
4. 장애물까지의 거리 측정 및 이동
```matlab
%이미지에서 인식된 곳들의 장축의 길이의 최댓값을 구함
stats = regionprops('table', bw2, 'MajorAxisLength');
long_rad = max(stats.MajorAxisLength);

%2단게에서 long_rad의 값에 따라서 거리 추정 및 이동
if long_rad > 530
    moveforward(drone, 'distance', 1.4, 'speed', 1);
    disp('측정 거리 = 1m');
    disp('이동거리 = 1.4m');
    long_rad
    ...
    %1m에서 3m까지 0.3m 간격으로 elseif문을 설정
    %조건에 따라 맞는 거리만큼 이동
```
5. 빨간색 점 및 보라색 점 찾은 후 회전 혹은 착지
```matlab
%빨간색 점을 찾은 후 회전
while 1
    frame = snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    
    red= ((0.95<h)&(h<1)|(0<h)&(h<0.05))&(0.6<s)&(s<=1);
    sum(red,'all')

    if sum(red,'all')>3000
        turn(drone,deg2rad(-90))
        break;
    
    else
        moveback(drone,'distance',0.2)
    end
end
        
%보라색 점을 찾은 후 착지
 while 1
    %보라색에 대한 HSV값 설정 및 이진화
    frame=snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    blue= (0.55<h)&(h<0.8)&(0.8<s)&(s<=1);
    
    %보라색의 픽셀이 300이 넘으면 90도 회전
    if sum(blue,'all')>300   
        land(drone);
        break;
        
    else
        moveback(drone,'distance',0.2)
    end
end    
```
