2022 미니드론 경진대회 18-DroneBoy 팀
====
이 글은 [2022 미니드론 경진대회](http://mini-drone.co.kr/view_notice?post_id=16481977576163440691612387)에 참가한
18-DroneBoy 팀의 대회준비 과정을 기록한 결과물이다.

----
🎈 준비
====
코드설명에 들어가기 앞서 준비된 하드웨어적 요소들을 살펴보자.  
* 사용기체  
DJI Tello 미니드론을 이용하였다.

![tello](https://user-images.githubusercontent.com/102723228/178655561-3c8f5806-bc1b-486a-b8db-ebadbc10210b.png)
<img src="![tello](https://user-images.githubusercontent.com/102723228/178655561-3c8f5806-bc1b-486a-b8db-ebadbc10210b.png)">



* 환경구축  
작성된 코드를 적용해보기 위한 환경이 필요했다. [주어진 맵의 규격과 고려사항](http://mini-drone.co.kr/view_notice?post_id=16566445069343700497480829)을 토대로 최대한 대회환경과 유사하게 구성하였다.
장소는 학교 강의실을 빌렸고, 필요한 물품은 구매하여 세팅하였다.

![hong](https://user-images.githubusercontent.com/102723228/178643254-b4e66851-ecc6-4fc4-9793-32a0e628670b.jpg)
<img src="![hong](https://user-images.githubusercontent.com/102723228/178643466-71bf2aaf-c2a5-4618-a451-1859624eac76.jpg)">
![KakaoTalk_20220713_174139855_01](https://user-images.githubusercontent.com/102723228/178691157-db95d935-a87a-45d0-85ee-3e0597e30f8d.jpg)
<img src="![KakaoTalk_20220713_174139855_01](https://user-images.githubusercontent.com/102723228/178691157-db95d935-a87a-45d0-85ee-3e0597e30f8d.jpg)">


🎈 대회진행전략
====

2022 미니드론 경진대회에서 우리 팀의 전략은 빠른시간 내에 불규칙적인 장애물을 통과하는 것이 목적이다. 이를 위해 matlab에서 제공하는 image processing toolbox를 사용하여  rgb2hsv, imcrop, regionprops 함수 등으로 이미지 처리를 수행하였다. 

전체적인 과정으로 우선 takeoff 이후 카메라 전방에 있는 천막 내 x,y 직경을 측정하여 구멍을 만든다. 다음으로는 만들어낸 구멍을 이용하여 화면상 특정한 위치에 존재하도록 드론을 제어한다. 이후에 가까워졌다고 인식하면 구멍 너머의 표식을 인식하여 통과하고 회전임무를 수행한다. 

코드를 구현하기 위한 공간을 마련하기 위해 필요한 장비(천막, 봉) 구매와 강의실을 대여하여 환경을 구축하였다. 주어진 작업환경에서 코딩 후 즉시 적용해가며 이상적인 값과 실제 적용한 값과의 오차를 줄여나갔다. 




🎈 알고리즘 설명
====
1. 기기의 객체 선언 및 takeoff 진행한다.
2. 파란색 천막 인식 및 구멍을 이미지 처리한 후 드론 카메라에 표시되는 구멍의 위치에 따라 드론이 전진과 동시에 상하좌우로 제어한다.
3. 구멍에 충분히 가까워졌다고 판단되면 구멍을 이용한 제어는 멈추고 이후의 표식을 인식한다. 
4. 인식한 표식까지 전진한 후, 회전 임무를 수행한다. (2단계에서 2-3번을 반복진행)

* 전체적인 알고리즘 진행과정  

![image](https://user-images.githubusercontent.com/102723228/178747877-fcfcfaeb-a0a3-43b5-b3a0-c08d92a91fa4.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178747917-946ea54e-9268-43e1-8956-d269f9ecd91a.png)">

5. 3단계에서 장애물 앞으로 이동한 후 표식을 정면으로 인식하기 위해 Yaw 기동을 진행한다.  
* Yaw 기동을 하지 않을 시  

![image](https://user-images.githubusercontent.com/102723228/178748806-26703589-4542-49f2-a58e-3de0df25e08d.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178748806-26703589-4542-49f2-a58e-3de0df25e08d.png)">  

드론이 정면에 있지 않아, 표식을 정확히 인식할 수 없다.

* Yaw 기동 진행 시  

![image](https://user-images.githubusercontent.com/102723228/178749527-418580cb-87ab-4367-ac2f-3b6c52f00282.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178749555-b5d74f89-2b4b-49e1-808f-16ffccc5cdf2.png)">  

드론이 장애물과 평행하게 만들어 구멍통과 이후 표식을 인식하여 다음 임무를 수행하도록 한다.  

6. Yaw 기동이 끝난 드론이 카메라 화면을 4분면으로 나누어 각 사분면에 들어오는 blue screen 픽셀 값을 이용하여 Drone을 제어  
* 이론과정  

![image](https://user-images.githubusercontent.com/102723228/178752299-95c6673c-a4d8-4993-a064-faa66b2b0d97.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178752299-95c6673c-a4d8-4993-a064-faa66b2b0d97.png)">  


* 화면을 사분면으로 나누고 각 사분면으로 들어오는 blue screen data를 이진화시켜 상하좌우 드론 방향을 제어  

![image](https://user-images.githubusercontent.com/102723228/178752569-e03c3da7-fbe0-468b-aef8-47e6f4ff50bf.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178752569-e03c3da7-fbe0-468b-aef8-47e6f4ff50bf.png)">  

* 예시 1)  
![image](https://user-images.githubusercontent.com/102723228/178753224-809d906d-38ec-4834-b136-0930d6bfd71a.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178753239-3431cad4-e5a7-47f7-825a-d899c2c31099.png)">  

* 예시 2)  
![image](https://user-images.githubusercontent.com/102723228/178753293-a9a1bdec-31df-44f9-ab24-030d592a6ff8.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178753324-fa542fef-55f9-4cdc-9c72-b490ec1013b2.png)">  

* 예시 3)  
![image](https://user-images.githubusercontent.com/102723228/178753513-2029dd37-45f8-4603-92b1-96d488978383.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178753469-7f22d1a0-3af7-4e6c-9cb3-61d6edc20704.png)">  

* 예시 4)  
![image](https://user-images.githubusercontent.com/102723228/178753646-299c1a34-ee60-4b16-8d25-4cf71293b3db.png)
<img src="![image](https://user-images.githubusercontent.com/102723228/178753662-102424d9-74a7-4bd7-8900-35ab8eaaf3c7.png)">  


🎈 소스코드 설명
====
소스코드는 앞서 설명한 알고리즘에 따라 순차적으로 작성하였다. 더 상세한 설명은 각 코드별 주석에서 확인할 수 있다.

----
1. 기기의 객체 선언 및 takeoff
<pre>
clc; clear;
detection = false;
%% 변수 선언
count = 0;

%HSV 값 설정
blu_h_min = 0.55; blu_h_max = 0.7; blu_s_min = 0.5; blu_s_max = 0.9;
red_h_min1 = 0; red_h_max1 = 0.05; red_h_min2 = 0.95; red_h_max2 = 1; red_s_min = 0.8; red_s_max = 1;
gre_h_min = 0.34; gre_h_max = 0.45; gre_s_min = 0.4; gre_s_max = 1;
pur_h_min = 0.7; pur_h_max = 0.85; pur_s_min = 0.5; pur_s_max = 1;

%% 객체 선언  
drone = ryze(); %드론 객체 선언
cam = camera(drone); %카메라 객체 선언

%% Main 함수
takeoff(drone);
</pre>
-------------
2. 구멍 이미지 및 구멍 위치에 따라 일정한 시간간격으로 전진하는 드론을 상하좌우로 제어
<pre>
for mission = 1:3
    if mission == 1
        disp('미션 1 수행중');
    
    elseif mission == 2
        disp('미션 2 수행중');
        
    elseif mission == 3
        disp('미션 3 수행중');  
    end
 
    %% BLUE SCREEN 확인 함수(Blue Screen Detection)
    while 1
        if mission == 1
            [height, ] = readHeight(drone); %드론 현재 높이 받아오기
            if abs(height-0.9) > 0.2
                disp('높이 조절 중');
                if height < 0.9
                    moveup(drone,'distance',0.9-height)
                    break;
                else
                    movedown(drone,'distance',height-0.9)
                    break;
                end
            end
       
        
        else
            %이미지 처리(RGB->HSV)
            frame = snapshot(cam);
            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);

            blue_screen = (blu_h_min<h)&(h<blu_h_max)&(blu_s_min<s)&(s<blu_s_max); %파랑색 검출
            circle = imfill(blue_screen,'holes'); %빈 공간 채우기

            for x=1:size(blue_screen,1)
                for y=1:size(blue_screen,2)
                    if blue_screen(x,y)==circle(x,y)
                        circle(x,y)=0;  %동일한 부분을 0으로 처리함으로써 원만 추출
                    end
                end
            end

            %Hole 식별 시
            if sum(circle,'all') > 10000
                disp('hole 탐색 완료! 이제 원 보고 제어할거임' );
                count = 0;
                break;

            %Hole 미식별 시
            else
                %화면의 좌우, 상하를 비교(imcrop함수를 이용하여 특정 영역 추출)
                diff_lr = sum(imcrop(blue_screen,[0 0 480 720]),'all') - sum(imcrop(blue_screen,[480 0 480 720]),'all');
                diff_ud = sum(imcrop(blue_screen,[0 0 960 360]),'all') - sum(imcrop(blue_screen,[0 360 960 360]),'all');

                if count == 7
                    moveback(drone, 'distance', 0.4, 'speed', 0.5);
                    disp('Circle Detection : 기동 횟수 초과에 따른 직진 및 초기화');
                    count = 0;

                else
                    %미션 3에서 원 탐색을 위하여 3도씩 회전하면서 탐색 시행
                    if mission == 3
                        turn(drone, deg2rad(3));
                        disp('3도 회전');
                        count = count + 1;
                    end

                    %화면에 표시된 blue_screen의 좌우값 차이를 이용
                    if diff_lr > 30000
                        moveleft(drone,'distance',0.3,'speed',0.5);
                        disp('왼쪽으로 0.3m 만큼 이동');
                        count = count + 1;

                    elseif diff_lr < -30000
                        moveright(drone,'distance',0.3,'speed',0.5);
                        disp('오른쪽으로 0.3m 만큼 이동');
                        count = count + 1;
                    end

                    %화면에 표시된 blue_screen의 상하값 차이를 이용
                    if diff_ud > 12000
                        moveup(drone,'distance',0.2,'speed',0.5);
                        disp('위쪽으로 0.2m 만큼 이동');
                        count = count + 1;

                    elseif diff_ud < -12000
                        movedown(drone,'distance',0.2,'speed',0.5);
                        disp('아래쪽으로 0.2m 만큼 이동');
                        count = count + 1;
                    end
                end
            end
        end
    end
    
    %% 원 통과 함수(Circle Detection)
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        blue_screen = (blu_h_min<h)&(h<blu_h_max)&(blu_s_min<s)&(s<blu_s_max); %파랑색 검출
        fill_screen = imfill(blue_screen,'holes'); %빈공간 채우기
        circle = fill_screen;

        for x=1:size(blue_screen,1)
            for y=1:size(blue_screen,2)
                if blue_screen(x,y)==circle(x,y)
                    circle(x,y)=0;  %동일한 부분을 0으로 처리함으로써 원만 추출
                end
            end
        end

        circle_detect_area = regionprops(circle,'Centroid','Area');
        circle_area = 0;

        for j = 1:length(circle_detect_area)
                if circle_area <= circle_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    circle_area = circle_detect_area(j).Area;
                    circle_center = circle_detect_area(j).Centroid; %가장 큰 영역의 중앙 좌표값 측정
                end
        end
        
        
         if mission == 1 %원 통과 후 점 찾기
            break;

        elseif mission == 2
            point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);

        elseif mission == 3
            point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
        end
        
        point_detect_area = regionprops(point, 'Centroid', 'Area');
        point_area = 0;
        for j = 1:length(point_detect_area)
            if point_area <= point_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                point_area = point_detect_area(j).Area;
                point_center = point_detect_area(j).Centroid;
            end
        end

        if circle_area >= 10000
            if (420 <= round(circle_center(1)) && 540 >= round(circle_center(1))) && (200 <= round(circle_center(2)) && 360 >= round(circle_center(2)))

                if circle_area >= 80000
                    disp('Circle Detection : 충분한 크기의 원 탐색 완료, 8만넘김, 다운시로 전진할거임.');
                    moveforward(drone, 'distance', 0.5);
                    break;

                else
                    moveforward(drone, 'distance', 0.7, 'speed', 1);
                    disp('Circle Detection : 중심은 맞앗고 원크기 작아서 원으로 접근 중');
                end

            elseif 420 > round(circle_center(1))
                moveleft(drone, 'distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 좌측으로 이동');

            elseif 540 < round(circle_center(1))
                moveright(drone, 'distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 우측으로 이동');

            elseif 200 > round(circle_center(2))
                moveup(drone, 'distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 위로 이동');

            elseif 360 < round(circle_center(2))
                movedown(drone, 'distance', 0.2, 'speed', 0.5);
                disp('Circle Detection : 자세 제어를 위해 아래로 이동');
            end
        
        else
            moveback(drone, 'distance', 0.3, 'speed', 0.5);
            disp('으엑 보이던 원이 안보여!! 뒤로가');
        end
    end
</pre>

----
3. 표식 이미지 처리 & 인식 및 회전임무 수행
<pre>
  %% 표식 찾기 함수
    while 1
        %이미지 처리(RGB->HSV)
        frame = snapshot(cam);
        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
 
        if mission == 1 %원 통과 후 점 찾기
            point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
        elseif mission == 2
            point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);

        elseif mission == 3
            point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
        end
            point_detect_area = regionprops(point, 'Centroid', 'Area');
            point_area = 0;
            for j = 1:length(point_detect_area)
                if point_area <= point_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    point_area = point_detect_area(j).Area;
                    point_center = point_detect_area(j).Centroid;
                end
            end
            
            
            if sum(point, 'all') >= 200
                detection = true;
                if sum(point, 'all') > 2000
                    if mission == 1
                        disp('Marker Detection : 미션 1 표식 감지');
                        turn(drone, deg2rad(90));
                        moveforward(drone, 'distance', 0.4);
                        break;
                        
                    elseif mission == 2
                        disp('Marker Detection : 미션 2 표식 감지');
                        turn(drone, deg2rad(90));
                        moveforward(drone, 'distance', 1, 'speed', 1);
                        turn(drone, deg2rad(30));
                        moveleft(drone, 'distance', 0.3, 'speed', 1);
                        moveback(drone, 'distance', 0.4, 'speed', 0.5);
                        break;
                        
                    elseif mission == 3
                        disp('미션 3 표식 감지');
                        land(drone);
                        disp('미션 종료');
                        break;
                    end
                    
                    
                elseif 200 < sum(point, 'all') && sum(point, 'all') < 1200
                    if point_center(1) < 280
                        moveleft(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 좌측으로 이동');
                    elseif point_center(1) > 680
                        moveright(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 우측으로 이동');
                    elseif point_center(2) > 360
                        movedown(drone, 'distance', 0.22, 'speed', 0.5);
                        disp('Marker Detection : 아래로 이동');
                        
                    elseif 280 <= point_center(1) && point_center(1) <= 680 && point_center(2) <= 360
                        moveforward(drone, 'distance', 0.5, 'speed', 1);
                        disp('Marker Detection : 전진');
                    else
                        moveback(drone, 'distance', 0.3, 'speed', 1);
                        disp('Marker Detection : 후진');

                    end
                         
                elseif 1200 <= sum(point, 'all') && sum(point, 'all') <= 2000
                    moveforward(drone, 'distance', 0.5, 'speed', 1);  
                    disp('Marker Detection : 전진');
                    
                end
                
            elseif sum(point, 'all') < 100 && detection == true
                moveback(drone, 'distance', 0.2, 'speed', 1);
                disp('인식됏다가 갑자기 안돼 뒤로갈게~~');
                detection = false;
                
            else
                moveforward(drone, 'distance', 0.3);
                disp('마커 300 미만이라서 무한 직진');
                
              
            end
    end
end
</pre>
----
