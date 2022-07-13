%clc; clear;
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
            if abs(height-1) > 0.2
                disp('높이 조절 중');
                if height < 1
                    moveup(drone,'distance',1-height, 'speed', 1);
                    moveforward(drone, 'distance', 1, 'speed', 1);
                    break;
                else
                    movedown(drone,'distance',height-1, 'speed', 1);
                    moveforward(drone, 'distance', 1, 'speed', 1);
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
            bounding_screen = regionprops(blue_screen, 'BoundingBox', 'Area');
            bounding_area = 0;
            for j = 1:length(bounding_screen)
                if bounding_area <= bounding_screen(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    bounding_area = bounding_screen(j).Area;
                    x1 = round(bounding_screen(j).BoundingBox(1));
                    x2 = round(bounding_screen(j).BoundingBox(3)) + x1;
                    y1 = round(bounding_screen(j).BoundingBox(2));
                    y2 = round(bounding_screen(j).BoundingBox(4)) + y1;
                end
            end
            
            circle = imfill(blue_screen,'holes'); %빈 공간 채우기

            for x=1:size(blue_screen,1)
                for y=1:size(blue_screen,2)
                    if blue_screen(x,y)==circle(x,y)
                        circle(x,y)=0;  %동일한 부분을 0으로 처리함으로써 원만 추출 0 - 검은색
                    end
                end
            end
            
            blue_screen(y1:y2, x1:x2) = 1;
            
           
            
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
                    disp('Circle Detection : 기동 횟수 초과에 따른 직진 및 초기화');
                    moveback(drone, 'distance', 0.3, 'speed', 1);
                    count = 0;

                else
                    %미션 3에서 원 탐색을 위하여 3도씩 회전하면서 탐색 시행
                    if mission == 3
                        disp('5도 회전');
                        turn(drone, deg2rad(5));
                        count = count + 1;
                    end

                    %화면에 표시된 blue_screen의 좌우값 차이를 이용
                    if diff_lr > 25000
                        disp('왼쪽으로 0.3m 만큼 이동');
                        moveleft(drone,'distance',0.3,'speed',1);
                        count = count + 1;

                    elseif diff_lr < -25000
                        disp('오른쪽으로 0.3m 만큼 이동');
                        moveright(drone,'distance',0.3,'speed',1);
                        count = count + 1;
                    end

                    %화면에 표시된 blue_screen의 상하값 차이를 이용
                    if diff_ud > 20000
                        disp('위쪽으로 0.2m 만큼 이동');
                        moveup(drone,'distance',0.2,'speed',1);
                        count = count + 1;

                    elseif diff_ud < -10000
                        disp('아래쪽으로 0.2m 만큼 이동');
                        movedown(drone,'distance',0.2,'speed',1);
                        count = count + 1;
                    else
                        disp('카운트 +1');
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
%             point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
%             point = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
            point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);

        elseif mission == 3
            point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
%             point = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
%             point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);
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
            if (420 <= round(circle_center(1)) && 540 >= round(circle_center(1))) && (180 <= round(circle_center(2)) && 340 >= round(circle_center(2)))

                if circle_area >= 80000
                    disp('Circle Detection : 충분한 크기의 원 탐색 완료, 8만넘김, 다운시로 전진할거임.');
                    moveforward(drone, 'distance', 0.7, 'speed', 1);
                    break;

                else
                    disp('Circle Detection : 중심은 맞앗고 원크기 작아서 원으로 접근 중');
                    moveforward(drone, 'distance', 0.7, 'speed', 1);
                end

            elseif 420 > round(circle_center(1))
                disp('Circle Detection : 자세 제어를 위해 좌측으로 이동');
                moveleft(drone, 'distance', 0.3, 'speed', 1);

            elseif 540 < round(circle_center(1))
                disp('Circle Detection : 자세 제어를 위해 우측으로 이동');
                moveright(drone, 'distance', 0.3, 'speed', 1);

            elseif 180 > round(circle_center(2))
                disp('Circle Detection : 자세 제어를 위해 위로 이동');
                moveup(drone, 'distance', 0.2, 'speed', 1);

            elseif 340 < round(circle_center(2))
                disp('Circle Detection : 자세 제어를 위해 아래로 이동');
                movedown(drone, 'distance', 0.2, 'speed', 1);
            end
        
        else
            if mission == 3
                turn(drone, deg2rad(5));
                %moveleft(drone, 'distance', 0.2, 'speed', 1);
            end
            disp('으엑 보이던 원이 안보여!! 전진');
            moveback(drone, 'distance', 0.2, 'speed', 1);
            
        end
    end

        
    
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
%             point = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
%             point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);

        elseif mission == 2
%             point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
%             point = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
            point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);

        elseif mission == 3
%             point = (pur_h_min<h) & (h<pur_h_max) & (pur_s_min<s) & (s<=pur_s_max);
            point = (gre_h_min<h) & (h<gre_h_max) & (gre_s_min<s) & (s<=gre_s_max);
%             point = ((red_h_min1<h) & (h<red_h_max1) | (red_h_min2<h) & (h<red_h_max2)) & (red_s_min<s) & (s<=red_s_max);
        end
            
            point_detect_area = regionprops(point, 'Centroid', 'Area');
            point_area = 0;
            for j = 1:length(point_detect_area)
                if point_area <= point_detect_area(j).Area %가장 큰 영역 추출을 위하여 Area를 이용한 처리
                    point_area = point_detect_area(j).Area;
                    point_center = point_detect_area(j).Centroid;
                end
            end
            
            
            if sum(point, 'all') >= 50
                detection = true;
                if sum(point, 'all') > 2000
                    if mission == 1
                        disp('Marker Detection : 미션 1 표식 감지');
                        turn(drone, deg2rad(90));
                        disp('돌고전진');
                        moveforward(drone, 'distance', 0.6, 'speed', 1);
                        break;
                        
                    elseif mission == 2
                        disp('Marker Detection : 미션 2 표식 감지');
                        turn(drone, deg2rad(90));
                        moveforward(drone, 'distance', 1, 'speed', 1);
                        turn(drone, deg2rad(30));
                        moveleft(drone, 'distance', 0.3, 'speed', 1);
                        break;
                        
                    elseif mission == 3
                        disp('미션 3 표식 감지');
                        moveforward(drone, 'distance', 0.2, 'speed', 1);
                        disp('미션 종료');
                        land(drone);
                        
                        break;
                    end
                    
                    
                elseif 50 < sum(point, 'all') && sum(point, 'all') < 1200
                    if point_center(1) < 320
                        disp('Marker Detection : 좌측으로 이동');
                        moveleft(drone, 'distance', 0.2, 'speed', 1);
                        
                    elseif point_center(1) > 640
                        disp('Marker Detection : 우측으로 이동');
                        moveright(drone, 'distance', 0.2, 'speed', 1);
                        
                    elseif point_center(2) > 360
                        disp('Marker Detection : 아래로 이동');
                        movedown(drone, 'distance', 0.2, 'speed', 1);
                        
                        
                    elseif 320 <= point_center(1) && point_center(1) <= 640 && point_center(2) <= 360
                        disp('Marker Detection : 전진');
                        moveforward(drone, 'distance', 0.5, 'speed', 1);
                        
                    else
                        disp('Marker Detection : 후진');
                        moveback(drone, 'distance', 0.3, 'speed', 1);
                        
                    end
                         
                elseif 1200 <= sum(point, 'all') && sum(point, 'all') <= 2000
                    disp('Marker Detection : 전진');
                    moveforward(drone, 'distance', 0.3, 'speed', 1);  
                    
                end
                
            else
                if mission == 1 || mission == 2
                    disp('마커 100 미만이라서 무한 직진');
                    moveforward(drone, 'distance', 0.3, 'speed', 1);

                elseif mission == 3
                    turn(drone, deg2rad(5));
                    disp('턴턴턴');
                    moveleft(drone, 'distance', 0.2, 'speed', 1);
                    moveforward(drone, 'distance', 0.2, 'speed', 1);
                end
                
              
            end
    end
end