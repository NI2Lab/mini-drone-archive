
# 2022 미니드론 자율주행 경진대회 망나뇽팀🐲


## ✔️대회 진행 전략 
* **링의 중심 찾기**

![image](https://user-images.githubusercontent.com/93758371/178394444-e2c6f7db-ae30-46a8-9db3-93070a2aea6b.png)

> 1. 카메라 캡쳐한 후 링 이진화   
> 2. 이진화 영상의 링을 채우기 위해 imfill함수 사용
> 3. 링을 채운 영상에 이진화 영상을 빼서 링만을 추출   
> 4. 구멍의 중심을 찾아 Throttle제어와 Roll제어를 하여 드론과 구멍의 중심이 일치하게 제어   

   

* **구멍 찾기**

![image](https://user-images.githubusercontent.com/93758371/178394729-dd38655e-ed23-4b55-813f-03e257af79c9.png)


> 1. 카메라 캡처를 통한 링 이진화
> 2. 구멍의 중심 찾는 코드 사용
> 3. 구멍이 구해지지 않으면 링에 대한 중심을 통해 Throttle제어와 Roll제어 실행
 
* **링이 보이지 않을 경우**
 
 ![image](https://user-images.githubusercontent.com/93758371/178409083-d329a624-0a9b-479e-903c-a812b6823125.png)

> 1. 카메라 캡처를 통한 링 이진화
> 2. 픽셀이 보이지 않을 때, Roll제어를 통한 링 탐색
> 3. 그럼에도 보이지 않을 때, Throttle제어를 통한 링 탐색

* **전진할 때**

![image](https://user-images.githubusercontent.com/93758371/178395700-dfa67d23-8208-4090-bb84-0cde0abcd73d.png)

> 1. 카메라 캡쳐를 통한 표식 이진화 
> 2. 표식색의 픽셀 미검출시 전진픽셀 검출시 표식에 대한 중점 추출
> 3. 중점과 드론이 일직선상에 있으면 전진, 그렇지 않으면 일직선상에 위치하게 하기 위해 Roll 제어
> 4. 과정 반복 후 픽셀 값이 기준 이상이 되면 표식 발견으로 인식
> 5. 회전 혹은 착지


## ✔️알고리즘 설명

![image](https://user-images.githubusercontent.com/93758371/178422453-de833562-c8a5-4418-b617-76d6dce9ca1e.png)

![image](https://user-images.githubusercontent.com/93758371/178430144-de063fe7-3220-45f5-bdf4-65efde872c74.png)

**1. 드론 연결 및 이륙**
   
> [ryze]함수와 [takeoff]함수를 사용해 드론 연결 후 이륙

**2. 전처리**

> 드론의 영상을 가져오기 위해 [snapshot]함수를 사용
> RGB 색 공간에서 HSV 색 공간으로 변경(파란색, 빨간색, 초록색, 보라색)   
> 링 및 표식을 찾기 위해 이진화 실행   

**3. 링 중점 좌표 계산 및 드론 위치 제어**

> 중점 좌표로 드론의 현재 위치 판단
> 링이 왼쪽에 있는 지 오른쪽에 있는지 판단하기 위해 반으로 나누어 각각 픽셀수를 더해 링의 중앙에 드론이 위치하도록 상하좌우 제어
> 중점 좌표 찾기위해 [regionprops]함수를 사용

**4. 직진 및 표식 확인**

> 드론의 위치가 중앙에 위치한다고 판단되면 표식을 인식할 수 있도록 Pitch제어를 통한 직진


**5. 표식과의 거리 판단**

> 입력 영상에서 표식 색상의 픽셀 개수를 통해 표식과 드론간의 거리 판단   
> 링 통과 전 표식의 중점을 재탐색하고 그 중점을 기준으로 드론의 상하좌우 제어 후, 직진해 링 통과


**6. 회전 및 착륙**

> 링 통과 후, 표식 색에 맞춰 각각 회전 및 드론 착륙






## ✔️소스 코드 설명

* **드론 및 변수 설정**
```
clear;
clc;
drone=ryze();
cam=camera(drone);

idealX = 480;
idealY = 200;
past_red = 0;
current_red = 0;
move = 0;
a=0;
b=0;   
```

* **드론 이륙 및 1단계 높이 설정**
```
takeoff(drone);
moveup(drone,'Distance', 0.3,'Speed',1);
moveforward(drone,'Distance', 0.8,'Speed',1);
```

* **1단계**
```
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.611<h)&(h<0.75))&((0.494<s)&(s<0.894));

    fillimg = imfill(binary_res,'holes');
    %링 찾으면 탈출
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveleft(drone,'Distance',0.5,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'distance',0.5,'speed',1);
        move = 2;
    elseif move == 2
        movedown(drone,'distance',0.5,'Speed',1);
        move = 3;
    elseif move == 3
        moveright(drone,'Distance',0.5,'Speed',1);
        move = 0;
    end
end
%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.950<h)&(h<=1.000))&((0.700<s)&(s<=1.000))|((0.000<=h)&(h<0.05))&((0.700<s)&(s<=1.000));
    past_red = current_red;
    current_red = sum(binary_res_red,'all');
    
    if past_red > 0 & past_red - 500 > current_red 
        turn(drone, deg2rad(90));
        break
    end
    if sum(binary_res_red,'all') >= 2200
        turn(drone, deg2rad(90));
        break
    end
    

    moveforward(drone,'Distance', 0.5,'Speed',1);
```

* **2단계 변수 재설정 및 위치 조정**
```
past_red = 0;
current_red = 0;
a=0;
b=0;
move = 0;

moveforward(drone,'Distance', 1.25,'Speed',1);
moveup(drone,'Distance', 0.2,'Speed',1);
moveright(drone,'Distance',1.5,'Speed',1);
```

* **3단계 변수 재설정 및 조정**
```
past_red = 0;
current_red = 0;
a=0;
b=0;
move = 0;

moveforward(drone,'Distance', 1,'Speed',1);
turn(drone, deg2rad(45));
```

* **링이 안보일 때(링이 보이면 통과)**
```
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.611<h)&(h<0.75))&((0.494<s)&(s<0.894));

    fillimg = imfill(binary_res,'holes');
    %링 찾으면 탈출
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveleft(drone,'Distance',2,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'Distance',2,'speed',1);
        move = 2;
    elseif move == 2
        movedown(drone,'Distance',0.3,'Speed',1);
        move = 3;
    elseif move == 3
        moveright(drone,'Distance',4,'Speed',1);
        move = 0;
    end
end
```

* **링이 보이거나 표식이 보이면 통과**
```
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res = ((0.611<h)&(h<0.75))&((0.494<s)&(s<0.894));
    binary_res_red = ((0.222<h)&(h<0.506))&((0.172<s)&(s<0.816))&((0.118<v)&(v<0.580));
    stats = regionprops('table',binary_res_red,'Area');
    %표식이 보이면 탈출
    for i = 1:size(stats)
        if stats.Area(i)==max(stats.Area)
            maxI=i;
            break;
        end
    end
    
    try
    if stats.Area(maxI) > 300
        break
    end
    catch error
    end
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    if sum(binary_res,'all')> 500000
        moveup(drone,'distance',0.3,'speed',1);
        moveback(drone,'distance',1,'speed',1);
    end
     %이 보이면 탈출
    if sum(result,'all') > 20000
        break
    elseif sum(result,'all') < 20000
        stats = regionprops('table',binary_res,'Centroid','MajorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        try
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        
        if abs(idealX - centerX) < 40
            a=1;
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.5,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.4,'Speed',1);
        end
        if abs(idealY - centerY) < 20
            b=1;
        elseif idealY - centerY < 0
            b=0;
            movedown(drone,'distance',0.3,'Speed',1);
        elseif idealY - centerY > 0
            b=0;
            moveup(drone,'distance',0.4,'Speed',1);
        end   
        catch error
            moveback(drone,'distance',0.5,'speed',1);
        end
        if a==1 && b==1
            break
        end
    end
end
```

* **링의 중심 계산 후 제어**
```
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res = ((0.611<h)&(h<0.75))&((0.494<s)&(s<0.894));
    binary_res_red = ((0.222<h)&(h<0.506))&((0.172<s)&(s<0.816))&((0.118<v)&(v<0.580));
    stats = regionprops('table',binary_res_red,'Area');
    
    %표식이 보이면 탈출
    for i = 1:size(stats)
        if stats.Area(i)==max(stats.Area)
            maxI=i;
            break;
        end
    end
    try
    if stats.Area(maxI) > 300
        break
    end
    catch error
    end

    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res; 
    if sum(result,'all') < 20000
        moveback(drone,'distance',1,'speed',1);
        continue
    end
    stats = regionprops('table',result,'Centroid','MajorAxisLength','MinorAxisLength');
    for i = 1:size(stats)
        if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
            maxI=i;
            break;
        end
    end
    
    % 채우는 코드
    centerX = max(stats.Centroid(maxI,1));
    centerY = max(stats.Centroid(maxI,2));
    
    if abs(idealX - centerX) < 40
        a=1;
    elseif idealX - centerX < 0
        a=0;
        moveright(drone,'distance',0.3,'Speed',1);
    elseif idealX - centerX > 0
        a=0;
        moveleft(drone,'distance',0.2,'Speed',1);
    end
    if abs(idealY - centerY) < 20
        b=1;
    elseif idealY - centerY < 0
        b=0;
        movedown(drone,'distance',0.2,'Speed',1);
    elseif idealY - centerY > 0
        b=0;
        moveup(drone,'distance',0.3,'Speed',1);
    end
    
    if a==1 && b==1
        moveforward(drone,'distance',0.5,'speed',1);
        break
    end
end
```
* **전진**
```
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res_red = ((0.222<h)&(h<0.506))&((0.172<s)&(s<0.816))&((0.118<v)&(v<0.580));
    past_red = current_red;
    current_red = sum(binary_res_red,'all');
    
    if past_red > 0 & past_red - 500 > current_red 
        turn(drone, deg2rad(90));
        break
    end

    if sum(binary_res_red,'all') >= 2300
        turn(drone, deg2rad(90));
        break
    end
    if sum(binary_res_red,'all') > 100
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength','Area');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        if stats.Area(maxI) > 150
            centerX = max(stats.Centroid(maxI,1));
            centerY = max(stats.Centroid(maxI,2));
            if abs(idealX - centerX) < 50
                a=1;
            elseif idealX - centerX < 0
                a=0;
                moveright(drone,'distance',0.2,'Speed',1);
            elseif idealX - centerX > 0
                a=0;
                moveleft(drone,'distance',0.3,'Speed',1);
            end
            if abs(idealY - centerY) < 30
                b=1;
            elseif idealY - centerY < 0 && b == 0
                movedown(drone,'distance',0.2,'Speed',1);
            elseif idealY - centerY > 0 && b == 0
                moveup(drone,'distance',0.3,'Speed',1);
            end
            if a==0 || b == 0
                continue
            end
        end
    end
     moveforward(drone,'Distance', 0.6,'Speed',1);
end
```
