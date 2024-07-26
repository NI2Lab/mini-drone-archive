팀명 : 비상비상초비상
========

2024 미니드론 자율비행 경진대회 기술 워크샵

'비상비상초비상' 팀입니다.

# 목차

1. 대회 진행 전략

   ① 중심점 찾기 전략
   
   ② 중심점을 향하여 이동
   
   ③ 드론 전진
   
   ④ 색상 표시 인식
   
   ⑤ 오류 사진 검출
   
   ⑥ 현수막 정면 인식
   
2. 알고리즘 설명
   
3. 소스코드 설명


# 1. 대회 진행 전략

### 1. 중심점 찾기 전략
현수막의 원이 보이는 경우, 원이 보이지 않고 현수막의 일부만 보이는 경우 두 가지의 상황에 맞게 중점을 찾는 함수를 정의했다.

#### 1-1) 원이 보이지 않는 경우
 
<img src="https://github.com/JYJ-01/Drone/assets/167416324/01e2acef-7d31-46be-bc56-31e7f74c7d61" width="350" height="250"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/2ccf897c-2050-4319-80f1-a887008731b5" width="350" height="250"/>

>
>위 사진과 같이 현수막의 일부만 보이는 경우, 현수막의 파란 부분을 인식한 뒤 해당 부분의 중점을 추출하여 중심점 탐색
>
>(Boundary 함수 이용)

#### 1-2) 원이 보이는 경우

<img src="https://github.com/JYJ-01/Drone/assets/167416324/63c42038-a9bd-40e9-8902-3f73051fa7f5" width="350" height="250"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/52d26827-711d-4e54-bcc6-ae870bef90e8" width="350" height="250"/>

>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/71cf332d-bd5d-4a4a-83a3-74ba59a06b70" width="350" height="250"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/a212fbf8-2009-435c-b50c-2856368f3eee" width="350" height="250"/>

>
>
>위 사진과 같이 현수막의 원의 일부라도 보이는 경우, 원의 부분을 인식한 뒤 해당 부분의 중점을 추출하여 중심점 탐색
>
>(Centroid 함수 이용)

### 2. 중심점을 향하여 드론 이동

드론 카메라의 화면 중점과 찾은 중심점을 비교하여 이동할 거리 계산

<img src="https://github.com/JYJ-01/Drone/assets/167416324/63c42038-a9bd-40e9-8902-3f73051fa7f5" width="400" height="300"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/2cc1e3d6-5ea4-4b87-8769-03ad82533a1f" width="400" height="300"/>

>
>우측 하단으로 이동하는 경우

<img src="https://github.com/JYJ-01/Drone/assets/167416324/a3ea344c-3459-4cab-b835-9eca61efc70f" width="400" height="300"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/04d949d5-c981-4057-9fad-b3d65776087f" width="400" height="300"/>

>
>좌측 상단으로 이동하는 경우

### 3. 드론 전진

>2,3 단계에서는 정해진 거리를 전진한다.
>
>예외적으로 1단계, 4단계에서는 회귀분석을 통해 드론의 위치에서 현수막까지의 거리를 계산하여 이동한다.
>
>1단계에서는 드론 이륙 시 불안정하게 흔들려 이륙지점에서부터 현수막까지의 거리가 달라지는 문제점을 해결하기 위해,
>
>4단계에서는 착륙지점에 정확히 착륙하기 위해 현수막과의 거리를 파악할 필요성을 느꼈다.
>
>카메라에 인식되는 원의 직경 길이에 따른 드론과 현수막과의 거리를 회귀분석하여 원의 직경의 값을 알 때 현수막과 드론 사이의 거리를 출력하는 다항식의 계수를 구했다.
>
>회귀분석을 위해 현수막과 드론 사이의 거리를 1m~4.85m 까지 5cm 씩 움직이며 5장씩 촬영, 총 390장을 촬영하여 데이터로 사용했다
>
>촬영된 사진을 바탕으로 각 거리에 맞는 원의 직경 픽셀 값을 알 수 있었고, 해당 데이터로 회귀분석을 진행했다.
>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/e68e076c-0e4f-4d02-82d2-1907499ae7ec" width="400" height="300"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/e168c86a-272a-444c-95d2-5d87c51c0656" width="400" height="300"/>

>
>위 사진은 4단계에서 회귀분석을 위해 진행했던 촬영과정과 회귀분석으로 원의 직경 픽셀값에 따른 현수막과의 거리를 5차 다항식으로 나타낸 사진이다.
>
>해당 과정을 1단계에서도 적용하였고 이를 통해 1, 4단계에서 드론의 위치에 따른 현수막과의 거리를 알 수 있었다.


### 4. 색상 표식 인식

>빨강,초록,보라색을 인식하는 코드를 HSV 정보를 활용하여 작성했다.
>
>색상을 검출하여 해당 표식의 중점좌표를 구한 뒤 드론의 중점과 표식의 중점이 일치하는지 확인했다.
>
>1. 빨간색 HSV 설정 
>  
<img src="https://github.com/JYJ-01/Drone/assets/167416324/093987a3-3889-44ac-9425-9f8cb0dca8a9" width="400" height="300"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/e7a6fe3a-66f8-4a54-a770-f7407c2a733a" width="400" height="300"/>

>
>2. 초록색 HSV 설정
>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/acacd4c8-5026-48c6-bf41-a04e04e4f613" width="400" height="300"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/6c7f8136-ceb5-431e-a9c4-896e84b0a7f4" width="400" height="300"/>

>
>3. 보라색 HSV 설정
>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/00e7b634-25fb-45ed-9f70-f9bb7dd4bf4f" width="400" height="300"/>
<img src="https://github.com/JYJ-01/Drone/assets/167416324/e553c595-e27b-4306-8845-ae24ded296a7" width="400" height="300"/>

>
> 대회 맵(2,3단계)에서는 색상 표식이 현수막의 중점에 위치하도록 제어해야 한다.
>
> 해당 조건을 만족시키기 위해 우선 현수막을 통해 중점제어를 한 뒤 현수막 원 너머의 표식을 인식한다.
>
> 해당 표식이 우리가 정한 중점 조건에 만족하면 표식이 현수막의 원 중앙에 있다고 판단한다.
>
> 만약 현수막을 통해 중점제어를 했지만, 표식이 우리가 정한 중점 조건에서 벗어난다면 드론을 후진한 뒤 위 과정을 반복한다.

### 5. 오류 사진 검출
>
>종종 드론이 촬영하는 사진에서 회색 모자이크 오류가 생기는 경우가 발생한다.
>
><img src="https://github.com/JYJ-01/Drone/assets/167416324/e192cd1a-9df8-4213-b621-c8a95013419a" width="400" height="500"/>
>
>
>해당 문제를 해결하기 위해 드론이 촬영하는 모든 경우에 해당 회색 오류 색상을 검출하여 오류 시 재촬영을 하도록 코드를 구성하였다.
>
>하지만 오류로 인한 회색이 아닌 주변 환경에 의해 회색이 검출될 수 있다.
>
>따라서 오류로 인한 회색 화면의 특징을 검출하여 오류로 인한 회색만 검출하도록 코드를 구성하였다.


### 6. 현수막 정면 인식
>
> 드론이 회전하는 과정에서 현수막을 정면으로 바라보지 못하는 경우가 발생할 수 있다.
>
> 따라서 드론 회전 후 다음 단계 현수막 중점 검출 전 드론이 현수막을 정면으로 바라보는지 확인할 필요성을 느꼈다.
>
> 현수막을 정면이 아닌 방향으로 바라보면 현수막 좌,우측의 세로 길이가 다르다는 특징을 이용했다.
>
> 현수막 정면은 다음과 같은 방법으로 검출한다.
>
> 1. 기울어진 방향에서 현수막을 바라본 사진을 이진화한 뒤 중점을 검출한다
>
><img src="https://github.com/JYJ-01/Drone/assets/167416324/39c90eea-418c-44ac-be30-64ae75e017c4" width="500" height="400"/>
>
> 2. 해당 중점을 사분면의 중점으로 두고 각 사분면 현수막 픽셀 중 중점과 가장 먼 픽셀의 위치를 찾는다
>
> <img src="https://github.com/JYJ-01/Drone/assets/167416324/b1133ab9-df20-43c2-95f5-52b8aa85a9b0" width="500" height="400"/>
>
> 3. 각 사분면의 픽셀은 현수막의 꼭짓점으로 검출된다. 해당 꼭짓점 좌표를 통해 현수막의 좌측,우측 세로 길이를 구한다.
>
> <img src="https://github.com/JYJ-01/Drone/assets/167416324/03401d02-399d-49ff-acaa-4f209b80c918" width="500" height="400"/>
>
> 4. 해당 길이를 비교하여 얼마나 회전할지, 어느 방향으로 회전해야 하는지 도출한다.
>
> <img src="https://github.com/JYJ-01/Drone/assets/167416324/7097bc4f-3d7f-439e-9815-2c6db7c4ab86" width="600" height="500"/>
>
> 해당 방법은 현수막 전체가 보여야 한다는 단점이 있다.
> 따라서 현수막과 너무 가깝지 않은 선에서 해당 정면을 검출하는 함수를 사용하도록 코드를 구성하였다.

# 2. 알고리즘 설명
<img src="https://github.com/JYJ-01/Drone/assets/167416324/ee9b0bf1-dabb-4b7b-894c-3c714a247e4b" width="900" height="700"/>

#### 1. 전처리 과정 : 영상 획득 및 영상 이진화 까지의 과정
> 호버링 - takeoff 함수를 이용하여 드론 이륙
> 
> 영상 수신 - snapshot 함수를 이용하여 영상 사진 수신
> 
> 이진화 - 정의한 함수 find_color 를 통해 색상에 맞는 영상 이진화
> 
> 회색 오류 검출 - 정의한 함수 find_color_gray 를 통해 드론 자체적 오류로 인해 회색 모자이크가 생기면 영상 재촬영 
> 
> 목표 중점 탐색 - 정상적으로 촬영된 이진화 사진을 토대로 목표 중점 탐색


#### 2. 목표 중점 찾기 : 이진화된 영상으로 목표 중점을 탐색 및 해당 지점으로 이동
>> 현수막의 원이 보이는가? - 원이 보이는지 안보이는지에 따라 어떤 함수를 사용할지 선택
>>
>> 원의 중점을 목표지점으로 - centroid 함수 사용
>>
>> 현수막의 중점을 목표 지점으로 - boundary 함수 사용
>
> 목표지점으로 이동 - 화면상의 중점과 함수를 통해 구한 목표중점까지의 거리를 구한 뒤 이동
>
> 목표지점과 카메라 중점이 일치하는지 - 화면상의 중점과 목표중점이 일치하는지 확인
>
> 정해진 거리 전진 및 링 통과 - 주어진 전진거리 이동


#### 3. 기타 사항
>색이 검출되는가? - 각 단계별 색상 인식 함수로 회전 각도 계산
>
>색상 중점 좌표와 화면 중앙 좌표가 근사한가? - 색상 표식이 현수막 링 중앙에 위치하는지 확인
>
>빨강,초록,보라 인식 - 각 색상이 중앙에 있다고 판단되면 단계에 맞게 전진 및 회전
>
>현수막의 좌,우측 세로변의 길이가 비슷한가? - 드론이 현수막을 정면으로 바라보도록 드론제어
>
>목표 중점 찾기 알고리즘 적용 - 드론이 정면을 바라본다면 현수막 중점 찾기 알고리즘 적용(노란색 과정)
>
>색상 중점 좌표와 화면 중앙 좌표가 근사한가? - 4단계 마지막 빨간색 색상 중점이 화면 중앙에 도달했는지 확인
>
>4단계 현수막 통과 및 착륙 - 4단계 빨강 색상이 중앙에 위치했다 판단되면 직진 및 착륙





# 3. 소스코드 설명

#### 드론 연결 및 호버링, 모든 단계에 필요한 상수값 정의

호버링 후 안정적인 중점 검출을 위해 후진과 상승을 한번 한 후 진행한다.

```java
    clear
    drone = ryze()
    cam = camera(drone);
    takeoff(drone);
    move(drone,[-0.2,0,-0.6],'speed',0.5);
    gray_error = 0;
    level = 1;
    format long
    x_rc = 480;
    e_count = 0;
    add = 0.75;
    pic_num = 1;
    pic = {};
    L_add = 0.05;
    error = 0;
    error_blue = 0;

```

#### 각 단계에 필요한 상수값 정의

각 단계마다 현수막의 직경 크기, 원의 크기에 따른 y 중점 좌표, 1,4단계 회귀분석 계수를 정의하였다.

```java
    if level == 1
        L = 0.57 + L_add;
        y_rc = 180;
        r = [12.112785246855540;-0.112318420979197;5.193367486402072e-04;-1.271369725301128e-06;1.570377189160116e-09;-7.695558755592146e-13];
        disp('Level 1 start')
    elseif level == 2
        L = 0.46 + L_add ;
        y_rc = 190;
        H = readHeight(drone);
        disp('Level 2 start')
        
    elseif level == 3
        L = 0.46;
        y_rc = 190;
        H = readHeight(drone);
        disp('Level 3 start')
        
    else
        L = 0.52;
        y_rc = 180;
        r = [14.418878808623500;-0.167167270744241;9.696092698112550e-04;-2.988626315852980e-06;4.665089042371920e-09;-2.895562197103830e-12];
        disp('Level 4 start')
    end
```

#### 오류 사진 제거

회색 모자이크 오류가 생겼을 경우 재촬영하는 코드이다.

회색 모자이크가 발생하면 항상 직사각형 모양으로 발생된다는 것을 파악했다.

따라서 회색 색상을 검출했을 때 직경을 딴 뒤 가장 큰 직경 픽셀 값이 1000을 넘어가면 회색 모자이크 오류라고 판단한다.

픽셀값 1000 조건으로 인해 오류가 아닌 일반적인 상황의 회색 색상 검출은 오류라고 판단하지 않을 것이다.

```java
    % Fail-safe for Connection Error on Image
   while 1
                snap = snapshot(cam);
                gray = Image_Fail_Safe_RGB(snap,500,120,140);
                props2 = regionprops(gray, 'MajorAxisLength');
                major = [props2.MajorAxisLength];

                if isempty(major) == 1
                    break
                elseif max(major) < 1000
                    break
                else
                    e_count = e_count + 1;
                    if e_count > 100
                        e_count = 0;
                        gray_error = gray_error + 1;
                        disp("Wifi error occured")
                        break
                    end
                end
    end
```

#### 드론이 현수막을 정면으로 바라보도록 yaw 제어

위 설명과 같이 현수막의 양쪽 세로길이의 차이가 10픽셀 이상이면 상황에 맞게 5도씩 회전하도록 코드를 구성하였다.

하지만 현수막 검출 오류로 인해 과도한 각도를 회전하게 될 수 있으므로 발생 가능성이 없는 과도한 픽셀값 차이가 발생한다면 yaw제어를 무시하고 중점을 찾도록 코드를 구성하였다.

과도한 픽셀값 기준은 70 픽셀로 구성하였다.

```java
    if level == 4
        while 1
            % Snapshot with Fail-safe code
            while 1
                snap = snapshot(cam);
                gray = Image_Fail_Safe_RGB(snap,500,120,140);
                props2 = regionprops(gray, 'MajorAxisLength');
                major = [props2.MajorAxisLength];

                if isempty(major) == 1
                    break
                elseif max(major) < 1000
                    break
                else
                    e_count = e_count + 1;
                    if e_count > 100
                        e_count = 0;
                        gray_error = gray_error + 1;
                        disp("Wifi error occured")
                        break
                    end
                end
            end
            
            % Image Processing for Obstacles
            blue = find_color(snap,1500,0.55,0.7,0.5);
            BWa = ~blue;
            BWa = bwareaopen(BWa,1500);
            Diameter = [];

            % Find Diameter
            try
                [~,point_yaw] = diameter_chase(BWa,120,700);
                x_yaw = point_yaw(1);
                y_yaw = point_yaw(2);
            catch
                disp("Fail to find diameter - yaw control")
                break 
            end
            
            % Detect Side Line
            invBWa = bwareafilt(~BWa,1);
            BWa = ~invBWa;
            try
            [pixel_diff,n,tt1,tt2,tt3,tt4] = Yaw_Control(BWa,x_yaw,y_yaw);
            catch
                break 
            end
            

            % Plot
            pic{pic_num} = snap;
            subplot(5,5,pic_num)
            imshow(BWa)
            hold on
            title('Yaw')
            plot(tt1(1)+x_yaw,tt1(2)+y_yaw,'r.',tt2(1)+x_yaw,tt2(2)+y_yaw,'r.',tt3(1)+x_yaw,tt3(2)+y_yaw,'r.',tt4(1)+x_yaw,tt4(2)+y_yaw,'r.','MarkerSize',10)
            fprintf("yaw_control : pixel_diff =  %d deg \n", pixel_diff)
            hold off
            
            % Yaw Control
            if (pixel_diff >= 10) && (pixel_diff <= 70)
                if n == 1
                    turn(drone,deg2rad(5));
                else
                    turn(drone,deg2rad(-5));
                end
            elseif pixel_diff > 70
                break
            else
                pic_num = pic_num + 1;
                break
            end
            pic_num = pic_num + 1;
        end
        moveforward(drone,'distance',1.15,'speed',1);
        pause(0.5);
    end
```


#### 중점 찾기

>##### 원이 보이는 경우 diameter_chase 함수 사용
>
>##### 원이 보이지 않는 경우 line_chase 함수 사용

원이 보이는 경우 사용자 정의 함수 diameter_chase 를 이용하여 중점 목표를 탐색한다.

만약 원이 보이지 않는다면 isempty(Diameter) == 1 해당 구문에 걸리게 되고, 

사용자 정의 함수 line_chase를 이용하여 목표 지점을 탐색한다.

```java
      % Image Processing for Obstacles
    while 1
       
        blue = find_color(snap,800,0.55,0.7,0.4);
        blue =  bwareaopen(blue,900);
        BWa = ~blue;
        BWa = bwareaopen(BWa,900);
        Diameter = [];
        
        % Find Centroid : 1) Centorid chase 2) Box chase
        try
            [Diameter,Centroid] = diameter_chase(BWa,120,600);
        catch
        end
        if isempty(Diameter) == 1
            try
                [Boundary,Point] = line_chase(blue,800);
            catch
                B = 0;
                break
            end
            Centroid(1) = Point(1);
            Centroid(2) = Point(2);
            Diameter = 0;
        end
        x_mc = Centroid(1);
        y_mc = Centroid(2);
```

#### 중점 이동 거리 계산 

1. 원이 검출되지 않았을 때 (if Diameter == 0) 목표 중점과 화면 중점과의 픽셀 차이가 240 이상이라면 0.4m 이동, 180 이상이라면 0.3 이동, 그 외에는 0.2m 이동하라고 구성하였다.

원이 보이지 않는 상황이기 때문에 크게 움직이도록 0.4m까지 이동거리를 설정하였다.

2. 원이 검출되었을 때 (else) 목표 중점과 화면 중점의 픽셀 차를 구한 뒤 원의 직경 픽셀로 나누었다.

해당 값을 실제 원의 직경 길이로 곱하면 실제로 이동해야 하는 길이가 나오게 된다.

해당 값이 0.2m 이상이라면 해당 값을 반올림하여 이동, 0.1~0.2m 사이라면 0.2m 이동, 0.1m 이하라면 중점이라고 인식한다.

원이 보이는 상황에서는 크게 움직일 필요가 없으므로 0.2m 부근에서 이동하도록 구성하였다.

```java
     % Calculate the distance to Centroid
        if Diameter == 0
            d_x = x_mc - x_rc;
            d_y = y_mc - y_rc;
            if abs(d_x) > 240
                move_d_x = 0.4;
            else
                move_d_x = 0.2;
            end
            if abs(d_y) > 180
                move_d_y = 0.3;
            else
                move_d_y = 0.2;
            end
        else
            if Diameter < 200
                m_Diameter = 200;
            else
                m_Diameter = Diameter;
            end
            d_x = L * (x_mc - x_rc)/m_Diameter;
            d_y = L * (y_mc - y_rc)/m_Diameter;

            if (abs(d_x) > 0.1)&&(abs(d_x) < 0.2)
                move_d_x = 0.2;
            else
                move_d_x = round(abs(d_x),1);
            end
            if (abs(d_y) > 0.1)&&(abs(d_y) < 0.2)
                move_d_y = 0.2;
            else
                move_d_y = round(abs(d_y),1);
            end
        end
        x = sign(d_x);
        y = sign(d_y);
```

#### 중점 이동

move 함수를 이용하여 목표중점까지 대각선으로 이동하도록 구성하였다.

```java
    % Move to Centroid based on Calculated values
        if (move_d_x > 0.1) && ( move_d_y > 0.1)
            if (x == 1) && (y == 1)
                move(drone,[0,move_d_x,move_d_y]);
            elseif (x == 1) && (y == -1)
                move(drone,[0,move_d_x,-move_d_y]);
            elseif (x == -1) && (y == -1)
                move(drone,[0,-move_d_x,-move_d_y]);
            elseif (x == -1) && (y == 1)
                move(drone,[0,-move_d_x,move_d_y]);
            end
        elseif (move_d_x > 0.1) && (move_d_y <= 0.1)
            if x == 1
                moveright(drone,'distance',move_d_x,'speed',0.6)
            elseif x == -1
                moveleft(drone,'distance',move_d_x,'speed',0.6)
            end
        elseif (move_d_y > 0.1) && (move_d_x <= 0.1)
            if y == 1
                movedown(drone,'distance',move_d_y,'speed',0.6)
            elseif y == -1
                moveup(drone,'distance',move_d_y,'speed',0.6)
            end
        else
            x = 0;
            y = 0;
            break
        end
    end
```


#### 색 인식 및 표식 중점 확인

각 단계별로 HSV 값을 이용해 색상을 검출한다

색상을 검출한 뒤 해당 색상의 중점을 검출하고, 해당 중점을 화면상의 중점과 비교한다.

두 값의 차이가 기준보다 크다면 드론을 후진한 뒤 재정렬하여 위 과정을 반복한다.

해당 과정을 통해 색상 표식이 현수막 원 안에 위치하도록 만들 수 있었다.

```java
    % Check the color point - red
        red = find_color(snap,70,0.001,0.05,0.4);
        try
            [~,point_red] = diameter_chase(red,10,300);
            x_mc_red = point_red(1);
            y_mc_red = point_red(2);
            e_red = (abs(x_mc_red - 480) + abs(y_mc_red - 360));
            if e_red < 600
                subplot(5,5,pic_num)
                imshow(red)
                pic_num = pic_num +1;
            else
                moveback(drone,'Distance',0.3);
            end
        catch
            disp("Fail to find the color - red")
        end

    % Check the color point - green
        green = find_color(snap,100,0.38,0.47,0.4);
        try
            [~,point_green] = diameter_chase(green,10,700);
            x_mc_green = point_green(1);
            y_mc_green = point_green(2);
            e_green = (abs(x_mc_green - 480) + abs(y_mc_green - 360));
            if e_green < 600
                subplot(5,5,pic_num)
                imshow(green)
                pic_num = pic_num +1;
            else
                moveback(drone,'Distance',0.3);
            end
        catch
            disp("Fail to find the color - green")
        end

    purple = find_color(snap,100,0.65,0.79,0.05);
        try
            [~,point_purple] = diameter_chase(purple,10,200);
            x_mc_purple = point_purple(1);
            y_mc_purple = point_purple(2);
            e_purple = (abs(x_mc_purple - 480) + abs(y_mc_purple - 360));
            if e_purple < 600
                subplot(5,5,pic_num)
                imshow(purple)
                pic_num = pic_num +1;
            else
                moveback(drone,'Distance',0.3);
            end
        catch
            disp("Fail to find the color - purple")
        end
```

#### 단계별 전진, 회귀분석 전진

1,4단계는 각각 구한 회귀분석 계수를 통해 전진한다.

회귀분석을 통해 현수막까지의 거리를 파악할 수 있기 때문에 호버링 시 흔들리는 문제, 착륙지점에 정확히 착륙해야 하는 문제 등을 해결할 수 있을 것이다.

2,3단계는 2단계로 나누어 전진한다.

첫번째 전진 후 중점을 정렬한 뒤 두번째 전진을 하도록 구성하였다.

```java
        % Move forward - level 1
        offset = 0.1;
        distance_1 = r(1) + r(2).*Diameter+r(3).*Diameter.^2 + r(4).*Diameter.^3 + r(5).*Diameter.^4 + r(6).*Diameter.^5 + offset;
        move_d_f = distance_1 + 1.8;
        if move_d_f > 3.65
            move_d_f = 3.65;
        elseif move_d_f < 3.45
            move_d_f = 3.45;
        end
        fprintf("Level 1, Move Forward - %d m \n", move_d_f)
        moveforward(drone,'distance',move_d_f,'speed',1);
        turn(drone,deg2rad(130));
        move(drone,[3.1,0,-0.3],'Speed',1);
        pause(0.5);
        level = level + 1;

        % Move forward - level 2
        fprintf("Level 2, Move Forward - %d m \n", 1.8)
        moveforward(drone,'distance',1.8,'speed',1);
        turn(drone,deg2rad(-130));
        move(drone,[0.7,0,-0.3],'Speed',1);
        pause(0.5);
        level = level + 1;

        % Move forward - level 3
        fprintf("Level 3, Move Forward - %d m \n", 1.7)
        moveforward(drone,'distance',1.7,'speed',1);
        turn(drone,deg2rad(215));
        level = level + 1;

        % Move forward - level 4
        distance = r(1) + r(2).*Diameter+r(3).*Diameter.^2 + r(4).*Diameter.^3 + r(5).*Diameter.^4 + r(6).*Diameter.^5;
        move_d_forward = round(distance,1);
        fprintf("Move Forward - %d m \n",move_d_forward + add)
        moveforward(drone, 'distance', move_d_forward + add,'speed',1);
        land(drone);
```

### 사용자 정의 함수

* diameter_chase

```java
    function [Diameter,Centroid] = diameter_chase(BWa,remove,max)
    % 1. 흰색 배경의 중점을 모두 찾음
    % 2. 흰색 뭉텅이 중에 원의 형식을 크게 멋어나는 부분을 지움(diameter로 파악)
    % 3. 원의 형식을 벗어나는 index를 찾아 그와 맞는 index의 중점을 지움
    % 4. 현수막의 중심원의 중점만 남게 됨

    props = regionprops(BWa,'Centroid', 'MajorAxisLength', 'MinorAxisLength');
    points = [props.Centroid];
    major = [props.MajorAxisLength];
    minor = [props.MinorAxisLength];
    [diameters] = (major+minor)/2;
    i = 0;
    while 1
    try
        i = i + 1;
        if major(i)/minor(i) > 4
            major(i) = [];
            minor(i) = [];
            points(2*i-1) = [];
            points(2*i-1) =[];
            diameters(i) = [];
            i = i - 1;
        end
    catch
        break
    end
    end
    i = 0;
    while 1
    i = i + 1;
    try
        if diameters(i) < remove
            points(2*i-1) = [];
            points(2*i-1) =[];
            diameters(i) = [];
            i = i - 1;
        end
    catch
        break
    end
    end
    D = diameters';
    P = points;

    for k = 1:length(P)/2
    Center(k,1) = P(1,2*k-1);
    Center(k,2) = P(1,2*k);
    end
    [Diameter,num] = min(D);
    Centroid = Center(num,:);
    if Diameter > max
    Diameter = [];
    Centroid = [];
    end
    end
```

  * line_chase

```java
     function [Boundary,Point] = line_chase(BWa,remove)
     % 1. 원이 보이지 않을 때 사용(원이 잘려서 원의 형식으로 보이지 않거나 너무 가깝거나 멀어서 회귀분석자료 범위를 벗어날 때 사용)
     % 2. 현수막의 경계를 딴 뒤에 해당 경계의 중점을 찾아 이동
     % 3. 원이 보이지 않는 상황이라는 가정이기 때문에 큼직큼직하게 이동
     % 4. 너무 가까워서 바운더리로 이동거리를 측정하는 경우 직진명령어로 이동하지 못함. 해당 부분은 수정 요함
     Boundary = bwboundaries(BWa);
     C = cellfun(@length,Boundary);
     i = 0;
     while 1
     i = i + 1;
     try
        if C(i) < remove
            Boundary(i) = [];
            C(i) = [];
            i = i - 1;
        end
     catch
        break
     end
     end
     for j = 1:length(Boundary)
     Bn = Boundary(j);
     B_mat = cell2mat(Bn);
     M(j) = length(B_mat);
     end
     [~, num] = min(M);
     M2 = cell2mat(Boundary(num));
     center_x = mean(M2(:,2));
     center_y = mean(M2(:,1));
     Point = [center_x,center_y];
     end
```

* Image_Fail_Safe

```java
    function color = Image_Fail_Safe(snap,remove,real_min,real_max,s_value)

    hsv = rgb2hsv(snap);
    s = hsv(:,:,2);
    real = hsv(:,:,3);
    color = zeros(720,960);
    try
    for i = 1: 720
        for j = 1:960
            if (s(i, j) < s_value)  && (real(i,j) > real_min) && (real(i,j) < real_max)
                color(i, j) = 1;
            end
        end
    end
    color = bwareaopen(color,remove);
    color_inv = bwareaopen(~color,remove);
    color = ~color_inv;
    catch
    end
    end
```

* find_color

```java
    function color = find_color(snap,remove,min,max,s_value)

    hsv = rgb2hsv(snap);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    color = zeros(720,960);
    try
    for i = 1: 720
        for j = 1:960
            if (h(i, j)> min) && (h(i, j) < max) && (s(i,j) > s_value)
                color(i, j) = 1;
            end
        end
    end
    color = bwareaopen(color,remove);
    catch
    end
    end
```


* Yaw_Control

```java
        function [a,b] = Yaw_Control(BWa,x_mc,y_mc)

        %b=1 --> CW
        %b=0 --> CCW
        
        tt = bwperim(~BWa);
        
        [y2,x2] = find(tt);
        
        xx2 = x2 - x_mc;
        yy2 = y2 - y_mc;
        
        A = [xx2,yy2];
        
        area1 = A(A(:,1) > 0 & A(:,2) > 0, :);
        area2 = A(A(:,1) < 0 & A(:,2) > 0, :);
        area3 = A(A(:,1) < 0 & A(:,2) < 0, :);
        area4 = A(A(:,1) > 0 & A(:,2) < 0, :);
        testarea1 = ((area1(:,1)).^2) + ((area1(:,2)).^2);
        [~,maxnum1] = max(testarea1);
        fin1 = area1(maxnum1,:);
        
        testarea2 = ((area2(:,1)).^2) + ((area2(:,2)).^2);
        [~,maxnum2] = max(testarea2);
        fin2 = area2(maxnum2,:);
        
        testarea3 = ((area3(:,1)).^2) + ((area3(:,2)).^2);
        [~,maxnum3] = max(testarea3);
        fin3 = area3(maxnum3,:);
        
        testarea4 = ((area4(:,1)).^2) + ((area4(:,2)).^2);
        [~,maxnum4] = max(testarea4);
        fin4 = area4(maxnum4,:);
        
        left = fin2(2) - fin3(2);
        right = fin1(2) - fin4(2);
        
        a = abs(right - left);


        if right > left
            b = 1;
        else
            b = 0;
        end
        
        end
```
