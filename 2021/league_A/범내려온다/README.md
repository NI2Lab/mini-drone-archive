# 2021 미니드론 자율주행 경진대회 A리그 범내려온다팀!:tiger:

<br></br>
## 대회 진행 전략
![전략](https://github.com/yoonbeomjun/Aleague_bumdown/blob/master/readme/1.PNG?raw=true)
![전략](https://github.com/yoonbeomjun/Aleague_bumdown/blob/master/readme/2.PNG?raw=true)

### 
- **1. 링 구멍의 중심을 찾는 전략** :  카메라를 캡쳐하여 링을 이진화시킵니다. 이진화 영상에서 imfill함수를 사용하여 구멍을 채웁니다. 구멍을 채운 영상에서 이진화 영상을 빼서 구멍만을 추출합니다. 구멍의 중심을 찾아 Throttle제어와 Roll제어를 하여 드론과 구멍의 중심이 일치하게 제어합니다.

- **2. 구멍을 찾는 전략** : 링 구멍의 중심을 찾는 전략을 사용합니다. 구멍이 구해지지 않으면 링에 대한 중심을 통해 Throttle제어와 Roll제어를 합니다.

- **3. 링이 안보일 때 전략** : 카메라를 캡쳐하여 링을 이진화시킵니다. 픽셀이 보이지 않을때 먼저 Roll제어를 통해 좌/우로 이동하여 링을 찾습니다. 그럼에도 보이지 않을 경우 Throttle제어를 통해 하강합니다. 이때 저희 드론의 디폴트위치는 상단 가운데로 위치하게 했습니다.

- **4. 전진할 때 전략** : 카메라를 캡쳐하여 표식을 이진화 시킵니다. 표식색의 픽셀이 검출되지 않는다면 전진하고 픽셀이 검출되면 표식에 대한 중점을 구합니다. 중점이 드론과 일직선상에 있으면 전진하고 그렇지 않으면 Roll제어를 하여 일직선상에 위치하게 합니다. 전과정을 반복하다 픽셀값이 기준 이상이 되면 표식을 찾았다고 인식하여 회전 혹은 착지를 합니다.

---
<br></br>
## 알고리즘 설명
![알고리즘도](https://github.com/yoonbeomjun/Aleague_bumdown/blob/master/readme/1%EB%8B%A8%EA%B3%84.PNG?raw=true)
![알고리즘도](https://github.com/yoonbeomjun/Aleague_bumdown/blob/master/readme/2,3%EB%8B%A8%EA%B3%84.PNG?raw=true)


- **1단계**  
   -  드론 이륙

   - **이미지 전처리**
     - 텔로 드론의 영상을 받아와 [Snapshot](https://kr.mathworks.com/help/supportpkg/ryzeio/ref/snapshot.html) 함수를 이용하여 사진 영상을 가져옵니다.
     - RGB 색 공간에서 HSV 색 공간으로 변경합니다.
     - 링 및 표식을 찾기 위해 HSV 색 공간을 통하여 링의 색 및 표식의 색을 찾고 이진화를 실행합니다.
     - Throttle제어를 통해 고도를 맞춰줍니다.
  - **전진**
     1. **이미지 전처리**를 실행합니다.
     2. [regionprops](https://kr.mathworks.com/help/images/ref/regionprops.html)함수를 사용하여 중심점을 찾습니다.
     3. 이상적인 중심점과 영상의 중심점의 차이를 계산하여 X값의 차이가 40이상이면 Roll제어를 합니다.
     4. 표식의 픽셀수를 세어 기준값 이상이면 회전을 합니다.

- **2단계**
   - Pitch제어를 하여 앞으로 갑니다.  
   - 링을 위에서부터 찾기 위해 Throttle제어를 통해 상승합니다.
   
   - **링 인식**  
      1. **이미지 전처리**를 실행합니다.
      2. 픽셀수를 세어 링을 인식합니다.
      3. 인식을 못했다면 오른쪽/왼쪽/아래쪽으로 이동 후 전과정을 반복합니다.
      4. 인식을 했다면 [regionprops](https://kr.mathworks.com/help/images/ref/regionprops.html)함수를 사용하여 중심을 찾습니다.
      5. 중심을 기준으로 Throttle제어와 Roll제어를 합니다.
      6. 이미지와 imfill함수를 사용한 이미지를 빼서 구멍을 인식합니다. 인식하지 못하였다면 전과정을 반복합니다.    

   - **중심 찾기**
      1. **이미지 전처리**를 실행합니다.
      2. [regionprops](https://kr.mathworks.com/help/images/ref/regionprops.html)함수를 사용하여 구멍의 중심을 찾습니다.
      3. 중심을 기준으로 Throttle제어와 Roll제어를 하여 중심과 드론이 일직선 상에 위치하게 합니다.
     
   - **전진**

- **3단계**
   - Pitch제어를 하여 앞으로 갑니다.
   - readHeight함수를 사용하여 고도를 측정합니다.
   - 고도가 1m보다 낮으면 Throttle제어를 통해 상승합니다.
   
   - **링 인식**
   
   - **중심 찾기**
   
   - **전진**
   
   - 드론 착지
   
 

---
<br></br>
## 소스코드 설명

### 드론 및 변수 설정
```matlab
clear;
drone=ryze();
cam=camera(drone);

idealX = 480;
idealY = 200;
past_red = 0;
current_red = 0;
move = 0;
```
### 1단계
```matlab
%드론을 띄워주고 1단계 높이를 맞춤
takeoff(drone);
moveup(drone,'Distance', 0.3,'Speed',1);
moveforward(drone,'Distance', 1.3,'Speed',1);
```
   - **전진 알고리즘**
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.95<h)&(h<1.0))&((0.645<s)&(s<0.925));
    disp(sum(binary_res_red,'all'));
    if sum(binary_res_red,'all') > 100 && sum(binary_res_red,'all') < 1000
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        
        if abs(idealX - centerX) < 40
            a=1;
            disp("x좌표 맞음");
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.2,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.21,'Speed',1);
        end
        if a==0
            continue
        end
    end
        
    moveforward(drone,'Distance', 0.4,'Speed',1);
    frame=snapshot(cam);
    
    
    hsv=rgb2hsv(frame);
    h=hsv(:,:,1);
    s=hsv(:,:,2);
    
    detect_red_bin=((0.8<h)&(h<1))&((0.7<s)&(s<0.95))|((0<h)&(h<0.2))&((0.7<s)&(s<0.95));
    past_red = current_red;
    current_red = sum(detect_red_bin, 'all');
    if past_red > 0 & past_red - 50 > current_red 
        turn(drone, deg2rad(-90));
        break
    end
    if sum(detect_red_bin, 'all') >= 3000
        turn(drone, deg2rad(-90));
        break
    end
end
```
### 2단계
```matlab
%변수 
past_red = 0;
current_red = 0;
%전진 후 디폴트 위치로 이동
moveforward(drone,'Distance', 1,'Speed',1);
moveup(drone,'Distance',0.8,'Speed',1);
moveright(drone,'Distance',1.5,'Speed',1);
```
- **링 인식 알고리즘**
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    fillimg = imfill(binary_res,'holes');
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveleft(drone,'Distance',1.5,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'distance',1.5,'speed',1);
        move = 2;
    elseif move == 2
        moveright(drone,'Distance',1);
        movedown(drone,'distance',0.5);
        move = 0;
    end
end
```
- **구멍 찾기 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    if sum(result,'all') > 20000
        break
    elseif sum(fillimg,'all') < 130000 && sum(result,'all') < 20000
        frame =snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
        stats = regionprops('table',binary_res,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        
        if abs(idealX - centerX) < 40
            a=1;
            disp("x좌표 맞음");
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.3);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.2);
        end
        if abs(idealY - centerY) < 20
            b=1;
            disp("y좌표 맞음");
        elseif idealY - centerY < 0
            b=0;
            movedown(drone,'distance',0.2);
        elseif idealY - centerY > 0
            b=0;
            moveup(drone,'distance',0.3);
        end
        if a==1 && b==1
            break
        end
    end
end
```
- **중심 찾기 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    for i = 1:960
        binary_res(1,i)=1;
    end
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    subplot(2,1,2), subimage(result);
    stats = regionprops('table',result,'Centroid','MajorAxisLength','MinorAxisLength');
    for i = 1:size(stats)
        if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
            maxI=i;
            break;
        end
    end
    centerX = max(stats.Centroid(maxI,1));
    centerY = max(stats.Centroid(maxI,2));
    
    if abs(idealX - centerX) < 40
        a=1;
        disp("x좌표 맞음");
    elseif idealX - centerX < 0
        a=0;
        moveright(drone,'distance',0.3);
    elseif idealX - centerX > 0
        a=0;
        moveleft(drone,'distance',0.2);
    end
    if abs(idealY - centerY) < 20
        b=1;
        disp("y좌표 맞음");
    elseif idealY - centerY < 0
        b=0;
        movedown(drone,'distance',0.2);
    elseif idealY - centerY > 0
        b=0;
        moveup(drone,'distance',0.3);
    end
    if a==1 && b==1
        break
    end
end
```
- **전진 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.95<h)&(h<1.0))&((0.645<s)&(s<0.925));
    subplot(2,1,1), subimage(binary_res_red);
    if sum(binary_res_red,'all') > 30 && sum(binary_res_red,'all') < 1000
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        
        if abs(idealX - centerX) < 30
            a=1;
            disp("x좌표 맞음");
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.21);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.2);
        end
        if a==0
            continue
        end
    end
        
    moveforward(drone,'Distance', 0.4);
   
    past_red = current_red;
    current_red = sum(binary_res_red, 'all');
    subplot(2,1,2), subimage(binary_res_red);
    disp(sum(binary_res_red, 'all'));
    if past_red > 0 & past_red - 50 > current_red 
        turn(drone, deg2rad(-90));
        disp("빨간색 안보이지만 회전");
        break
    end
    if sum(binary_res_red, 'all') >= 1000
        turn(drone, deg2rad(-90));
        disp(readHeight(drone));
        break
    end
end
```
### 3단계
- **링 찾기 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    fillimg = imfill(binary_res,'holes');
    disp(sum(fillimg,'all'));
    if sum(fillimg,'all') > 50000
        break
    end
    if move == 0
        moveright(drone,'Distance',0.2);
        move = 1;
    elseif move == 1
        moveleft(drone,'distance',1.5);
        move = 2;
    elseif move == 2
        moveright(drone,'Distance',0.75);
        movedown(drone,'distance',0.5);
        move = 0;
    end
end
```
- **구멍 찾기 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    if sum(result,'all') > 20000
        
        break
    elseif sum(fillimg,'all') < 130000 && sum(result,'all') < 20000
        frame =snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
        stats = regionprops('table',binary_res,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        
        if abs(idealX - centerX) < 40
            a=1;
            disp("x좌표 맞음");
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.3);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.2);
        end
        if abs(idealY - centerY) < 20
            b=1;
            disp("y좌표 맞음");
        elseif idealY - centerY < 0
            b=0;
            movedown(drone,'distance',0.2);
        elseif idealY - centerY > 0
            b=0;
            moveup(drone,'distance',0.3);
        end
        if a==1 && b==1
            break
        end
    end
end
```
- **중점 찾기 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    subplot(2,1,2), subimage(result);
    stats = regionprops('table',result,'Centroid','MajorAxisLength','MinorAxisLength');
    for i = 1:size(stats)
        if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
            maxI=i;
            break;
        end
    end
    centerX = max(stats.Centroid(maxI,1));
    centerY = max(stats.Centroid(maxI,2));
    
    if abs(idealX - centerX) < 40
        a=1;
        disp("x좌표 맞음");
    elseif idealX - centerX < 0
        a=0;
        moveright(drone,'distance',0.3);
    elseif idealX - centerX > 0
        a=0;
        moveleft(drone,'distance',0.2);
    end
    if abs(idealY - centerY) < 20
        b=1;
        disp("y좌표 맞음");
    elseif idealY - centerY < 0
        b=0;
        movedown(drone,'distance',0.2);
    elseif idealY - centerY > 0
        b=0;
        moveup(drone,'distance',0.3);
    end
    if a==1 && b==1
        break
    end
end
```
- **전진 알고리즘** 
```matlab
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res_p = ((0.835<h)&(h<0.915))&((0.435<s)&(s<0.725));
    subplot(2,1,1), subimage(binary_res_p);
    if sum(binary_res_p,'all') > 30 && sum(binary_res_p,'all') < 1000
        stats = regionprops('table',binary_res_p,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        
        if abs(idealX - centerX) < 30
            a=1;
            disp("x좌표 맞음");
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.2);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.2);
        end
        if a==0
            continue
        end
    end
        
    moveforward(drone,'Distance', 0.4);
   
    past_y = current_y;
    current_y = sum(binary_res_p, 'all');
    subplot(2,1,2), subimage(binary_res_p);
    disp(sum(binary_res_p, 'all'));
    if past_red > 0 & past_red - 50 > current_red 
        turn(drone, deg2rad(-90));
        disp("노란색 안보이지만 회전");
        break
    end
    if sum(binary_res_p, 'all') >= 1000
        disp(readHeight(drone));
        break
    end
end
land(drone);
```
