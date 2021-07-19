# Aleague_INHACONTROL616

2020 미니드론 자율비행 경진대회를 위한 A리그 INHACONTROL616 팀의 GitHub Repository입니다.

대회 미션 수행에 필요한 MATLAB® 코드가 업로드 되어 있으며, 본 README.md 파일에는 우리 팀의 대회 진행 전략, 알고리즘 및 소스 코드의 설명에 대한 내용이 담겨 있습니다.

![pic1](https://user-images.githubusercontent.com/60594155/87503582-962f3f80-c69f-11ea-8f7e-e6e8cff9d315.jpg)



## Run My Code: How-to
1. MATLAB 설치. (above version R2020a)
2. MATLAB Add-On 설치; Image Processing Toobox, MATLAB Support Package for Ryze Tello Drones.
3. 본 Repo에서 제공되는 MATLAB 코드(.m file) 를 매트랩이 참조하는 경로에 위치시킨 후 매트랩에서 Ryze Tello Drone 연결 및 코드 실행.

## 대회 진행 전략

우리 팀의 대회 진행 계획은 다섯 부분으로 나뉘어 있으며, 다음과 같습니다.

1. MATLAB을 사용한 드론의 제어 연습.
2. 맵 구성.
3. 알고리즘 계획 및 MATLAB 코드 작성.
4. MATLAB 코드를 바탕으로 실제 Ryze Tello 드론에 적용 및 미션 수행 연습.



### 1. MATLAB을 사용한 드론의 제어 연습
  
  대회 주최 측에서 제공하는 온라인 워크샵 수업 내용을 바탕으로, MATLAB Support Package for Ryze Tello Drones을 이용하여 드론을 전후좌우, 상하로 동작시켜 보았으며, 이 과정을 통해 얻은 제어 경험 및 기술을 바탕으로 향후 미션에서 드론을 자율적으로 비행할 수 있도록 합니다.
  
### 2. 맵의 구성

  드론의 자율비행을 위한 맵은 주최측에서 사전에 공지한 규격대로 시트지를 가지고 제작하였습니다.
  
  다음은 규격에 따라 제작한 맵의 사진입니다.
  
![map1](https://user-images.githubusercontent.com/60594155/87538779-c7c3fd00-c6d7-11ea-8fc7-c2614d0e8b9e.jpeg)
![map2](https://user-images.githubusercontent.com/60594155/87538790-cb578400-c6d7-11ea-89ee-f75fae17e2a9.jpeg)
![map3](https://user-images.githubusercontent.com/60594155/87538795-cd214780-c6d7-11ea-844a-837fd51c0472.jpeg)
![map4](https://user-images.githubusercontent.com/60594155/87538803-ceeb0b00-c6d7-11ea-8108-0e3f9af14c85.jpeg)

### 3. 알고리즘 계획 및 MATLAB 코드 작성

  하단의 '알고리즘 설명', '소스 코드 설명' 탭에서 기술합니다.
  
### 4. MATLAB 코드를 바탕으로 실제 Ryze Tello 드론에 적용 및 미션 수행 연습


  



  
  


## 알고리즘 설명

1. 드론 이륙 및 안정된 자세를 위한 1초 대기.
2. 첫 번째 초록색 링의 탐색 및 통과를 위한 중점 찾기.
3. 중점을 찾아 통과.
4. 회전을 뜻하는 빨간 원을 인식 후 첫 번째 회전. (반시계방향 90º).
5. 두 번째 초록색 링의 탐색 및 통과를 위한 중점 찾기.
6. 중점을 찾아 통과.
7. 두 번째 빨간 원 인식 후 두 번째 회전. (반시계방향 90º)
8. 세 번째 초록색 링의 탐색 및 통과를 위한 중점 찾기.
9. 중점을 찾아 통과.
10. 착지를 뜻하는 파란 원을 인식 후 착지.


## 소스 코드 설명

다음은 우리 팀이 대회 미션 수행을 위해 작성한 MATLAB 코드입니다.

    %% (0) 초기 변수 선언
    clear;
    clc;
    aa=ryze(); % 드론 객체 선언
    cam=camera(aa); % 카메라 객체 선언
    preview(cam); % 드론 카메라 모니터링

    %% (1) 이륙
    takeoff(aa);
    pause(1); % 안정화를 위해 1초 대기
    disp("takeoff");
    moveforward(aa, 'Distance', 0.3, 'WaitUntilDone', true);
    pause(1); % 안정화를 위해 1초 대기

    %% (2) 초록색 탐색
    while 1
    % 초록색 박스 안의 중앙 점을 출력하는 함수
    frame=snapshot(cam);
    hsv=rgb2hsv(frame);
    green_den=hsv(:,:,1);
    detect_green=(0.225<green_den)&(green_den<0.275); % green의 범위 : Hue값 기준 0.225 ~ 0.275
    [row, col] = find(detect_green);
    if ~isempty(row) && ~isempty(col)
        XgreenCenter = round(mean(col));
        YgreenCenter = round(mean(row));
         subplot(1,2,1); imshow(frame);
         hold on 
         plot(XgreenCenter,YgreenCenter,'ro','MarkerSize',10,'MarkerFaceColor','r')
         hold off
         subplot(1,2,2); imshow(detect_green);
         hold on;
         plot(XgreenCenter,YgreenCenter,'r*','MarkerSize',10,'MarkerFaceColor','r')
         drawnow;
         hold off
    end

    %% 중앙 점을 따라가는 함수

    if YgreenCenter < 325
        moveup(aa, 0.6);
        pause(1);
        disp("moveup");
    elseif YgreenCenter > 395
        movedown(aa, 0.5);
        pause(1);
        disp("movedown");
    else
        if XgreenCenter < 430
            moveleft(aa, 0.5);
            pause(1);
            disp("moveleft");
        elseif XgreenCenter > 530
            moveright(aa, 0.5);
            pause(1);
            disp("moveright");
        else
            break;
        end
    end
    
    clear XgreenCenter;
    clear YgreenCenter;
    end
    % (3) 전진하기 전 드론을 아래로 이동시킴
    movedown(aa, 'Distance', 0.4, 'WaitUntilDone', true);
    disp("gothrough");

    % (4) 드론을 중앙에 맞췄으므로 2.2m 전진
    moveforward(aa, 'Distance', 2);

    %% (5) 빨간색 탐색
    while 1
        frame=snapshot(cam);
        hsv=rgb2hsv(frame);
        h=hsv(:,:,1);
        detect_red=(h>1)+(h<0.05); % 빨간색으 hue값 : ~ 0.05, 1 ~

        if sum(detect_red, 'all')>=13000 % 빨간 픽셀의 개수 = 13000 이상일 시 빨간 색 표시 검출로 판단.
            % 빨간색 검출하면 정지
            break
        else
            % 빨간색을 검출하지 못하면 상승
            moveup(aa, 0.5);
            disp("up");
        end
    end

    % (6) 왼쪽으로 90도 회전
    turn(aa,deg2rad(-90));
    disp("turn");
    moveforward(aa, 'Distance', 0.5);
    pause(1);

    %% (7) 두 번째 초록색 탐색
    while 1
        % 초록색 박스 안의 중앙 점을 출력하는 함수
        frame=snapshot(cam);
        hsv=rgb2hsv(frame);
        green_den=hsv(:,:,1);
        detect_green=(0.225<green_den)&(green_den<0.275);
        [row, col] = find(detect_green);
        if ~isempty(row) && ~isempty(col)
            XgreenCenter = round(mean(col));
            YgreenCenter = round(mean(row));
             subplot(1,2,1); imshow(frame);
             hold on 
             plot(XgreenCenter,YgreenCenter,'ro','MarkerSize',10,'MarkerFaceColor','r')
             hold off
             subplot(1,2,2); imshow(detect_green);
             hold on;
             plot(XgreenCenter,YgreenCenter,'r*','MarkerSize',10,'MarkerFaceColor','r')
             drawnow;
             hold off
        end


        % 중앙 점을 따라가는 함수

        if YgreenCenter < 325
            moveup(aa, 0.5);
            pause(1);
            disp("moveup");
        elseif YgreenCenter > 395
            movedown(aa, 0.5);
            pause(1);
            disp("movedown");
        else
            if XgreenCenter < 430
                moveleft(aa, 0.5);
                pause(1);
                disp("moveleft");
            elseif XgreenCenter > 530
                moveright(aa, 0.5);
                pause(1);
                disp("moveright");
            else
                break;
            end
        end
    
        clear XgreenCenter;
        clear YgreenCenter;
    end
    % (8) 전진하기 전 드론을 아래로 이동시킴
    movedown(aa, 'Distance', 0.3, 'WaitUntilDone', true);
    disp("gothrough");

    % (9) 드론을 중앙에 맞췄으므로 2.1m 전진
    moveforward(aa, 'Distance', 2.1);
    
    %% (10) 두 번째 빨간색 탐색
    while 1
       frame=snapshot(cam);
       hsv=rgb2hsv(frame);
       h=hsv(:,:,1);
       detect_red=(h>1)+(h<0.05);

        if sum(detect_red, 'all')>=13000
            % 빨간색 검출하면 정지
            break
        else
            % 빨간색을 검출하지 못하면 상승
            moveup(aa, 0.5);
            disp("up");
        end
    end

    % (11) 왼쪽으로 90도 회전
    turn(aa,deg2rad(-90));
    disp("turn");
    moveforward(aa, 'Distance', 0.5);
    pause(1);

    % (13) 세 번째 초록색 탐색
    while 1
        % 초록색 박스 안의 중앙 점을 출력하는 함수
       frame=snapshot(cam);
        hsv=rgb2hsv(frame);
        green_den=hsv(:,:,1);
        detect_green=(0.225<green_den)&(green_den<0.275);
        [row, col] = find(detect_green);
        if ~isempty(row) && ~isempty(col)
            XgreenCenter = round(mean(col));
            YgreenCenter = round(mean(row));
            subplot(1,2,1); imshow(frame);
            hold on 
            plot(XgreenCenter,YgreenCenter,'ro','MarkerSize',10,'MarkerFaceColor','r')
            hold off
            subplot(1,2,2); imshow(detect_green);
            hold on;
            plot(XgreenCenter,YgreenCenter,'r*','MarkerSize',10,'MarkerFaceColor','r')
            drawnow;
            hold off
        end


        % 중앙 점을 따라가는 함수

        if YgreenCenter < 325
            moveup(aa, 0.6);
            pause(1);
            disp("moveup");
        elseif YgreenCenter > 395
            movedown(aa, 0.5);
            pause(1);
            disp("movedown");
        else
            if XgreenCenter < 430
                moveleft(aa, 0.6);
                pause(1);
                disp("moveleft");
            elseif XgreenCenter > 530
                moveright(aa, 0.5);
                pause(1);
                disp("moveright");
            else
                break;
            end
        end
    
        clear XgreenCenter;
        clear YgreenCenter;
    end
    
    
    % (14) 전진하기 전 드론을 아래로 이동시킴
    movedown(aa, 'Distance', 0.4, 'WaitUntilDone', true);
    disp("gothrough");

    % (15) 드론을 중앙에 맞췄으므로 2m 전진
    moveforward(aa, 'Distance', 2);

    % (16) 파란색 탐색
    while 1
        frame=snapshot(cam);
        hsv=rgb2hsv(frame);
        h=hsv(:,:,1);
        detect_blue=(0.55<h)&(h<0.6); % 파란색으 hue값 : 0.55 ~ 0.6

        if sum(detect_blue, 'all')>=15000 % 파란 픽셀의 개수 = 15000
            break % 파란색 검출하면 정지
        else
            moveup(aa, 0.5); % 파란색을 검출하지 못하면 상승
            disp("up");
        end
    end

    % (17) 착륙
    land(aa);
    disp("land");
