# 2023 미니 드론 자율 비행 대회
## 자 비 스

### 대회 진행 전략
완주를 하기 위한 조건은 다음과 같습니다.

#### 1. 파란링 통과 알고리즘
- 드론으로 링을 어떻게 인지할 것인가
- 만약 링을 보지 못할 때는 어떻게 할 것인가
- 링 통과 후, 드론을 어디까지 제어시킬 것인가

#### 2. 표적 인식 알고리즘
- 표적 색은 어떻게 인지할 것인가
- 색을 인식하였을 경우 드론 제어를 어떻게 할 것인가
- 불규칙적인 경로를 어떤식으로 알고리즘을 구현할 것인가

#### 3. 보라색 착륙 미션 알고리즘
- 정확한 착륙 지점에 도달하려면 어떻게 해야할 것인가

기체 비행 중 위 조건들을 만족시키며 비행을 하면 궁극적인 목표인 완주를 할 수 있을 것으로 보이며, 인식할 수 있는 색의 이미지 필터링의 값을 적절하게  조절하여 정확도를 높이고자 하였습니다.

### 알고리즘 설명
![image](https://github.com/chooo2/hey/assets/128977521/72cecc14-e099-4128-9769-2682a82d7c3f)

![image](https://github.com/chooo2/hey/assets/128977521/1f7515b5-94c1-44cd-a5ac-548d75e42a24)

 
위의 블록도는 이 대회에서 사용할 코드의 알고리즘을 나타낸 것입니다.

크게  3계로 구분지어 알고리즘을 설명 드리겠습니다.
##### 1단계
우선 이미지를 필터링하는 h, s, v값을 지정하여 이미지를 필터링 시키고, 이 이미지의 이진화를 통해 원하는 색의 픽셀합들을 정의합니다. 이때 이 픽셀들의 중점 또한 얻을 수 있습니다.

##### 2단계
파란 링의 중점을 즉, 원을 바라볼 수 있는 제어를 먼저 할 것입니다. 만일 파랑색의 픽셀합이 일정값 이상이면 파란 장애물을 매우 가까이서 마주하고 있다고 판단하여 moveback() 함수를 사용하였고, 만일 보이지 않는다면 드로 시야에서 파란 장애물이 감지되지 않았따는 것을 의미한다고 볼 수 있기에 이 경우 또한 moveback함수를 사용하였습니다.
그런 후, 드론 시야에 원을 보일 수 있도록 제어를 하고자 하였고, 원이 보일 수 있다는 것은 전방의 표적을 인식할 수 있는 위치로 드론을 제어시킨다는 의미입니다.
드론 시야의 size를 좌/우 그리고 상/하 로 구분지어 각 차이가 적절해 지는 지점으로 드론을 제어시키고자 하였습니다.
이 제어를 통해 저희는 드론을 파란 장애물의 링(원)을 통과시킬 준비를 마칠 수 있습니다.

##### 3-1 단계
이제부터는 표적을 인식하고 처리하는 알고리즘을 구현할 것입니다. 표적의 종류는 총 3가지 이며 실시간으로 이 3가지의 픽셀합을 비교할 것입니다. 비교를 하여 max값일때, 그 색을 인식하였다고 판단내릴 수 있습니다.
하지만 여기서 문제점은 2단계가 완료가 되지 않은 상황에서 3-1단계가 실행될 수 있다는 점입니다. 따라서 2단계를 완료해야만 얻을 수 있는 변수와 이 변수를 가지고 있어야만 3-1단계를 실행할 수 있는 변수를 정의하여 이러한 문제점을 해결하였습니다.

##### 3-2 단계
파란 링을 통과 시킬 준비가 끝났다면 표적의 중점을 기준으로 링을 통과시키고자 하였습니다. 만일 중심을 잘 잡고 있다면 전진을 시키고, 중심을 잘 잡고 있지 않는다면 드론시야의 중심과 표적의 중심 차이가 일정하게 유지시킬 수 있도록 표적의 중앙을 유지하는 알고리즘을 구현하여 올바른 드론 제어를 실행하고자 하였습니다.

##### 3-3 단계 
그렇다면 무작정 전진만 하게 된다면 당연히 충돌이 일어날 것이고, 공지사항의 맵 규격을 참고하여 거리를 정확히 가늠한다면 통과는 가능하겠지만, 단순한 대회 목적으로 구현하는 코드보다는 조금 더 정확도 높은 코드를 구현하고자, 거리에 따라 표적의 픽셀 합이 달라진 다는 point를 이용하였습니다. 이 점을 이용하여 일정 범위의 픽셀합이라면 3-1단계에서 인식했던 색의 미션을 수행하는 알고리즘을 실행시킬 것이고, 일정 범위보다 멀다면 전진, 일정 범위를 넘겼다면 후진한 다음, 미션을 수행하는 알고리즘을 실행시켰습니다. 여기서 후진 후, 바로 미션을 수행시키는  이유는 자칫 후진과 전진이 무한 반복이 될 수 도 있는 상황을 고려하였기 때문이고, 대회가 time attack이다 보니 움직일 수 있는 횟수 또한 제한을 걸어두었습니다.

##### 3-4 단계
인식한 색의 미션을 수행하는 알고리즘입니다.
RED : 시계방향으로 90도 회전합니다.
GREEN : 5도씩 회전하며 다음 목표인 보라색을 찾고자 할것입니다.
Purpele : 착륙을 시킵니다.

상대적으로 RED와 PULPLE의 미션은 단순합니다. 3-3단계의 거리 조절인 픽셀값을 잘 지정한다면 단순하게 구현되기 때문입니다.
문제는 초록색에서 보라색으로 넘어갈때의 보라색의 표적을 볼 수 있도록 하는 구현과 맵의 변동사항인 각도를 어떤식으로 고려해야할지가 문제가 되었습니다.

이때, 보라색을 찾는 알고리즘을 구현하였고, 최대 60도 정도까지만 시야를 확인할 수 있게 하여 5도씩 회전하며 보라색을 찾고자 하였습니다. 
여기서 경우의 수는 총 2가지 입니다. 만일 보라색을 찾았다면 3-2 단계의 코드를 응용하여 적절한 드론 이동 제어를 할 것입니다.
그리고 두번쨰 경우의 수는 보라색이 보이지 않을떄 입니다. 이는 초록색을 보고 멈추는 제어에서 보라색이 파란색 장애물에 가려져 찾을 수 없는 상황임을 말합니다. 이를 해결하고자 2단계에서 사용한 좌/우 상/하로 나누어 이동하는 제어를 넣는데, 이떄 딱 한번 이동하여 다시 보라색을 찾는 회전을 반복시킬 것입니다. 그 이유는 마지막 단계에서는 이전 단계와는 달리 표적을 가리는 장애물로 결론지었기 떄문에 구현할 수 있던 알고리즘입니다. 이 과정을 반복시켜 저희가 설정한 보라색의 일정 픽셀합의 범위 안으로 들어갈 수 있도록 드론을 제어 시킬 것입니다. 하지만 hovering 중인 드론이 착륙 지점의 상공인지 판단할 수 없다는 한계가 있었습니다.

##### 3-5 단계
그래서 보라색을 향해 전진하다 멈추는 지점을 1m가 되도록 픽셀합의 범위를 조정한 후, 드론 시야의 중앙 x값과 보라색 픽셀의 중앙 x값을 일치시킨 다면 1m 뒤에 착륙지점이 있다고 결론지을 수 있습니다. 이 과정을 통해 정확한 착륙까지 수행할 수 있는 알고리즘까지 구현을 하였습니다.


### 소스 코드 설명

아래에는 main.m 코드를 간략화한 코드입니다. 간략화한 코드와 main.m 코드는 같은 알고리즘으로 구동되고, while문을 사용해서 간략화하여 나타내었습니다.
먼저 색 범위 및 색의 교집합을 정의하여 주행에 사용할 전처리 알고리즘을 선언합니다.
그리고 파랑 장애물에 대한 코드 설명입니다.

파랑색의 픽셀합이 일정 이상일 경우, 매우 근접한 거리에 장애물이 있다고 판단, 후진을 하기로 하였습니다.
그런식으로 일정 거리를 유지한 다음, 좌/우 상/하를 imcroop함수를 사용하여 비교할 수 있도록 하여 드론의 위치를 링의 중앙을 바라볼 수 있도록 하였습니다.
이 과정을 거치면 드론을 링을 통과할 준비가 완료된 것이고, 전방의 표적을 보고 제어할 수 있도록 MODE라는 변수를 활용하여 while문을 탈출 및 들어갈 수 있도록 하였습니다.
표적의 인식은 이 경우가 마친 후, 가장 많은 픽셀합이 인식되는 색을 인식하느 것으로 하였습니다.
이 픽셀의 중심과 드론의 중심을 타이트하게 조절하여 장애물에 충돌하지 않고 링을 통과하고자 하였고, 만약 사정거리를 벗어나게 된다면 move()함수를 사용하여 1시 방향, 5시 방향, 11시 방향, 7시 방향, 아래, 위, 좌, 우로 총 8가지 경우를 구현하여 시간 단축과 사정거리를 유지할 수 있도록 하였습니다. 

중심을 이용하여 오차없는 제어를 하고자 한 것입니다.

그리고 픽셀 합을 이용하여 원하는 거리에서 전진을 멈출 수 있도록하였습니다. 드론이 특정 색을 보고 계속 전진하면 픽셀합은 증가합니다. 이를 이용하여 저희가 원하는 지점에서 정지할 수 있는 코드를 구현하였습니다.

그런 후. 각 색깔에 대한 미션을 수행하였습니다.
빨간색은 시계방향으로 90도 회전, 초록색은 보라색을 찾는 알고리즘 실행, 보라색은 착륙입니다.
다시말하자면 초록색을 제외하면 단순하게 다음 단계로 넘어갈 수 있는 간단한 제어 알고리즘을 구현한 것입니다.

그렇다면 보라색을 찾는 알고리즘은 어떤식으로 구현하였는지 설명드리겠습니다.
먼저 일정 범위(약 60도)의 회전을 분할하여 보라색을 찾는 작업을 수행하였고, 만일 찾지 못하였다면 파란색을 이용하여 드론의 위치를 약간 조정시킬 것입니다. 여기서 전 과정과 차이는 파란색을 표적이 볼 수 있는 용도가 아닌 정말 장애물로서 코드를 구현했다는 점과 파란색을 이용하여 드론의 위치 조정을 계속 반복하는것이 아닌 1~2회 정도로 제한을 한다는 점입니다.

이 과정을 반복하면 드론의 상 하 좌 우 각도 까지 보라색을 바라볼 수 있는 제어를 구현할 수 있고, 찾게되면 보라색의 중앙 x값과 드론의 중앙 x값을 맞추어 전진 후, 일정 픽셀합의 범위에 들어간 후, 후진 착륙 혹은 착륙 제어를 통하여 완주를 시킬 수 있는 코드입니다.


main() {
   
    % 이전 작업 초기화 후 선언
    clc;
    clear;
    Tello = ryze();
    cam = camera(Tello);
    takeoff(Tello); % 드론 이륙
    % 색 범위 설정
    blue_h_min=0.5; blue_h_max=0.7; blue_s_min=0.55; blue_s_max=0.82; % BLUE ring의 hsv값 설정
    red_h_min_1=0; red_h_max_1=0.05; red_h_min_2=0.92; red_h_max_2=1; red_s_min=0.5; red_s_max=1; % RED target의 hsv값 설정
    green_h_min=0.33; green_h_max=0.45; green_s_min=0.4; green_s_max=1; % GREEN target의 hsv값 설정
    purple_h_min=0.65; purple_h_max=0.8; purple_s_min=0; purple_s_max=1; % PURPLE target의 hsv값 설정
    % 초기 높이 조절
    [height,time] = readHeight(Tello);
    if (height<1.2)
        moveup(Tello,'Distance',1.2-height,'Speed',0.4)
    elseif (hegith>1.2)
        movedown(Tello,'Distance',1.2-height,'Speed',0.4)
    end
    %%
    while true % 첫 번째 while문 : 계속 해서 사용해야 하는 지역변수 대입
        MODE=0;
        target_detect=0; % target 식별하면 1이되고, 미션 수행후에 다시 0이 됨.
        red_mode = 0; % red target을 인식하면 1로 바뀌고 수행하고자함. 수행이 완료되면 다시 0이 됨.
        green_mode = 0; % green target을 인식하면 1로 바뀌고 수행하고자함. 수행이 완료되면 다시 0이 됨.
        purple_mode = 0; % purple target을 인식하면 1로 바뀌고 수행하고자함. 수행이 완료되면 다시 0이 됨.
        frame_rgb = snapshot(cam);
        target_threshold_max=17; % target 미션을 유지하는 최대 값
        target_threshold_min=17; % target 미션을 유지하는 최소 값
        % frame의 hsv 값 선언
        frame_hsv=rgb2hsv(frame_rgb);
        h=frame_hsv(:,:,1);
        s=frame_hsv(:,:,2);
        v=frame_hsv(:,:,3);
        % 컬러 마스크
        blue_mask=(blue_h_min<=h)&(h<=blue_h_max)&(blue_s_min<=s)&(s<=blue_s_max); % BLUE color filtering
        red_mask=(red_h_min_1<=h)&(h<=red_h_max_1)&(red_h_min_2<=h)&(h<=red_h_max_2)&(red_s_min<=s)&(s<=red_s_max); % RED color filtering
        green_mask=(green_h_min<=h)&(h<=green_h_max)&(green_s_min<=s)&(s<=green_s_max); % GREEN color filtering
        purple_mask=(purple_h_min<=h)&(h<=purple_h_max)&(purple_s_min<=s)&(s<=purple_s_max); % PURPLE color filtering
    % 드론 시야의 중점
        dorone_eyesight = double(zeros(size(frame_rgb)));
        for i=1:size(dorone_eyesight,1)
            for j=1:size(dorone_eyesight,2)
                dorone_eyesight(i,j)=1;
            end
        end
        dorone_eyesight_x=sum(dorone_eyesight(i,:),'all');
        dorone_eyesight_y=sum(dorone_eyesight(:,j),'all');
        center_eyesight_x=dorone_eyesight_x/2;
        center_eyesight_y=dorone_eyesight_y/2;
    %%%%% 빨 간 색 %%%%%
    frame_red = double(zeros(size(h)));
            for i=1:size(frame_red,1)
                for j=1:size(frame_red,2)
                if(frame_red==red_mask)
                    frame_red(i,j)=1;
                end
                end
            end
    % RED target 중점
    R=regionprops(frame_red,'centroid');
    centroid_red=cat(1,R.centroid);
    center_red_x=centroid_red(:,1); %r의 중앙 x값
    center_red_y=centroid_red(:,2); %r의 중앙 x값
    total_red=sum(frame_red,'all'); %r의 총 인덱스값
    % 드론 시야 중심 red target 중심의 차이
    red_target_error_x=center_red_x-center_eyesight_x;
    red_target_error_y=center_red_y-center_eyesight_y;
    %%%%%%% 초 록 색 %%%%%%
    frame_green = double(zeros(size(h)));
    for i=1:size(frame_green,1)
        for j=1:size(frame_green,2)
            if(frame_green==green_mask)
                frame_green(i,j)=1;
            end
        end
    end
    % GREEN target 중점
    g=regionprops(frame_green,'Centroid');
    centroid_green=cat(1,g.Centroid);
    center_green_x=centroid_green(:,1); % g의 중앙 x값
    center_green_y=centroid_green(:,2); % g의 중앙 y값
    total_green=sum(frame_green,'all'); % g의 총 인덱스 값 
    % 드론 시야 중심 green target 중심의 차이
    green_target_error_x=center_green_x-center_eyesight_y; 
    greent_target_error_y=center_green_y-center_eyesight_y;
    %%%%% 보 라 색 %%%%%
    frame_purple = double(zeros(size(h)));
    for i=1:size(frame_purple,1)
        for j=1:size(frame_purple,2)
            if(frame_purple==purple_mask)
                frame_purple(i,j)=1;
            end
        end
    end
    % PURPLE target의 중점
    p=regionprops(frame_purple,'Centroid');
    centroid_purple=cat(1,p.Centroid);
    center_purple_x=centroid_purple(:,1); % p의 중앙 x값
    center_purple_y=centroid_purple(:,2); % p의 중앙 y값
    total_purple=sum(frame_purple,'all'); % p의 총 인덱스 값
    % 드론 시야 중심 purple target 중심의 차이
    purple_targe_error_x=center_purple_x-center_eyesight_x;
    purple_target_error_y=center_purple_y-center_eyesight_y;
    %%%%% 파 란 색 %%%%%
    total_blue=sum(blue_mask,'all');
    %%%%% target 미션 인식 %%%%%
    if (target_detect==0)&&(total_red>total_green)&&(total_red>total_purple) % red target 인식
          disp('RED target 미션을 수행하겠습니다.')
          red_mode=1;
          target_detect=1;
    elseif (target_detect==0)&&(total_green>total_red)&&(total_green>total_purple) % green target 인식
          disp('GREEN target 미션을 수행하겠습니다.')
          green_mode=1;
          target_detect=1;
    elseif (target_detect==0)&&(total_purple>total_red)&&(total_purple>total_blue) % purple target 인식
           disp('PURPLE target 미션을 수행하겠습니다.')
           purple_mode=1;
           target_detect=1;
    end
    %%%%% 각 미션 별 값 변동 %%%%%
    if red_mode==1
        target_error_x=red_target_error_x;
        target_error_y=red_target_error_y;
        total_index=total_red;
    elseif green_mode==1
        target_error_x=green_target_error_x;
        target_error_y=greent_target_error_y;
        total_index=total_green;
    elseif purple_mode==1
        target_error_x=purple_target_error_x;
        target_error_y=purple_target_error_y;
        total_purple;
    end
    %%
    while true % 두 번째 while문 : 파랑이
        if (purple_mode==1) % 보라 target 미션 수행중에는 파랑이를 크게 신경쓰지 않습니다.
            break;
        else
            if total_blue>=200000 % 파랑이 찾는 알고리즘 넣고 다 찾게되면 break 처리
                moveback(Tello,'Distance',0.2,'Speed',0.3);
            else
                MODE=1;
            end
        end
        %%%%% 링 통과 전 좌 우 상 하 비교 %%%%%
        left=sum(imcrop(blue_mask,[0 0 480 720]),'all');    
        right=sum(imcrop(blue_mask,[480 0 960 720]),'all');
        up=sum(imcrop(blue_mask,[0 360 960 720]),'all');
        down=sum(imcrop(blue_mask,[0 0 960 360]),'all');
        compare_row=left-right;
        compare_col=up-down;
    %%%%% 링 통과 전 drone 기체 위치 조정 %%%%%
            if (MODE==1)&&(5000<=compare_col) % 아래로 조정
                movedown(Tello,'Distance',0.2,'Speed',0.5);
                disp('아래로 조정합니다.')
                MODE=1;
            elseif (MODE==1)&&(compare_col<=-5000) % 위로 조정
                moveup(Tello,'Distance',0.2,'Speed',0.5);
                disp('위로 조정합니다.')
                MODE=1;
            elseif (-5000<=compare_col)&&(compare_col<=5000)
                MODE=1;
                if (MODE==1)&&(5000<=compare_row) % 좌로 조정
                moveleft(Tello,'Distance',0.3,'Speed',0.5);
                disp('좌로 조정합니다.')
                MODE=1;
                elseif (MODE==1)&&(compare_row<=-5000) % 우로 조정
                moveright(Tello,'Distance',0.3,'Speed',0.5);
                disp('우로 조정합니다.')
                MODE=1;
                elseif(-5000<=compare_row)&&(compare_row<=5000)
                disp('링을 통과할 준비를 마쳤습니다.')
                MODE=2;
                break;
                end
            end
    end
    %%
    while true % 세 번째 while문 : 빨강이
        if (red_mode==1) % 빨강이 찾는 알고리즘 넣고 다 찾게되면 break 처리
        x = 0;
        y = 0;
          while ((x>3) || ((center_eyesight_x + 15 > center_red_x) && (center_eyesight_x -15 < center_red_x)))==0
            % 표적 출력
            if (center_eyesight_x > center_red_x) % 왼쪽으로 조정 
                moveleft(drone,'distance',0.2,'Speed',0.2);
                x=x+1;
                pause(1);
            elseif(center_eyesight_x < center_red_x) % 오른쪽으로 조정
                disp(center_eyesight_x - center_red_x)
                x=x+1;
                pause(1);
            end
          end
          fprintf('\nx축 일치\n')
          fprintf('x = %d',x)
            while ((y>3) || ((center_eyesight_y + 20 > center_red_y) && (center_eyesight_y -20 < center_red_y)))==0
                 if (center_eyesight_y < center_red_y) % 아래쪽으로 조정
                    movedown(drone,'distance',0.2,'Speed',0.1);
                    y=y+1;
                    pause(1);
              elseif(center_eyesight_y > center_red_y) % 위쪽으로 조정
                    moveup(drone,'distance',0.2,'Speed',0.1);
                    y=y+1;
                    pause(1);
                 end
            end
        else
            break;
        end
    end
    %%
    while true % 네 번째 while문 : 초록이
        third_phase=center_eyesight_x-center_purple_x;
        if (green_mode==1) % 초록이 찾는 알고리즘 넣고 다 찾게되면 break 처리
            if (third_phase<=-15)
                turn(Tello,deg2rad(5));
            elseif (15<=third_phase)
                turn(Tello,deg2rad(-5));
            elseif (-15<=third_phase) && (third_phase<=15) % 회전 각도 조정 완료
                green_mode=0; 
                target_detect=0;
                break;
            else
               turn(Tello,deg2rad(5));
            end
        else
            green_mode=0; 
            target_detect=0;
            break;
        end
    end
    %%
    while true % 다섯 번째 while문 : 보라
        if (purple_mode==1) % 보라 찾는 알고리즘 넣고 다 찾게되면 break 처리
            if (-15<=target_error_x)&&(target_error_x<=15)&&(-15<=target_error_y)&&(target_error_y<=15) % 빨강 중심과 드론 중심 맞추기 (8 경우의 수)
                if (650<=total_index)&&(total_index<=850)
                    purple_mode=2;
                    break;
                elseif (total_index<650)
                    moveforward(Tello,'Distance',0.2,'Speed',0.5);
                elseif (850<total_index)
                    moveback(Tello,'Distance',0.2,'Speed',0.5);
                    purple_mode=2;
                    break;
                end
            elseif (target_error_x<=15) % +x축 방향으로 조정
                moveright(Tello,'Distance',0.2,'Speed',0.5);
            elseif (15<=target_error_x) % -x축 방향으로 조정
                moveleft(Tello,'Distance',0.2,'Speed',0.5);
            elseif (target_error_y<=15) % +y축 방향으로 조정
                moveup(Tello,'Distance',0.2,'Speed',0.5);
            elseif (15<=target_error_y) % -y축 방향으로 조정
                moverdown(Tello,'Distance',0.2,'Speed',0.5);
            elseif (target_error_x<=-15)&&(target_error_y<=-15) % 1시 방향으로 조정
                move(Tello,[0.2 0.2 0],"Speed",0.5);
            elseif (target_error_x<=-15)&&(15<=target_error_y) % 5시 방향으로 조정 
                move(Tello,[0.2 -0.2 0],"Speed",0.5);
            elseif (15<=target_error_x)&&(15<=target_error_y) % 7시 방향으로 조정
                move(Tello,[-0.2 -0.2 0],"Speed",0.5);
            elseif (15<=target_error_x)&&(target_error_y<=-15) % 11시 방향으로 조정 
                move(Tello,[-0.2 0.2 0],"Speed",0.5);
            end
        else % 착륙 지점 상공에서 hovering 중 
            break;
        end
    end
    if purple_mode==2 % 탈출이다 ~ 끝이다 ~ !!
        break;
    end
    end
    land(Tello);
    
}

#### 팀원 소개
팀장 최남규

팀원 권오민

팀원 장민근
