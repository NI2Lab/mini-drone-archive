

ace = ryze() %드론지정  %최초선언후 주석처리
acecam = camera(ace); %드론 카메라사용 %최초선언후 주석처리

takeoff(ace);

% preview(acecam);   % 테스트용 테스트용 테스트용  테스트용 테스트용 테스트용


moveup(ace, 'Distance', 0.3)  %1.1m까지 상승


img_rev_blue_1 = get_img_rev_blue(acecam);  % 파란색 영역이 반전된 이미지를 얻는다
most_circle_1 = find_maxcircularity(img_rev_blue_1);  % 원형성이 가장 큰 도형 most_circle
pause(0.05);

%% 1단계 / 원이 보일때
if(most_circle_1.EquivDiameter < 350)
    moveforward(ace,'Distance',1.3);

elseif(most_circle_1.EquivDiameter < 500)
    moveforward(ace,'Distance',0.7)

end

img_red = get_img_red(acecam);  % 빨간색 이진 이미지를 얻는다
most_red = find_color_square(img_red);  % 빨간 사각형을 찾는다


% 1단계 / 빨간색 일정크기 이상으로 보일때 
while(most_red.Area < 626)  %빨간색으로부터 1.15m 이상 떨어져있으면 조금씩 전진
    to_center_LR(ace, most_red.Centroid, 0.3, 50);  % 중심맞추고(좌우이동), 중심이면 0.3m 직진

    img_red = get_img_red(acecam);  % 빨간색 이진 이미지를 얻는다
    most_red = find_color_square(img_red);  % 빨간 사각형을 찾는다
    
    pause(0.05)
end


% 1단계 / 원 통과 직전
if (most_red.Area < 807) % 빨간색으로부터 거리가 1.15 ~ 1.25m 인 경우
    moveforward(ace, 'Distance', 1.3) % 앞으로 0.7m 이동

elseif (most_red.Area < 1020) % 빨간색으로부터 거리가 1.05 ~ 1.15m 인 경우
    moveforward(ace, 'Distance', 1.15) % 앞으로 0.6m 이동

elseif (most_red.Area < 1268) % 빨간색으로부터 거리가 0.95 ~ 1.05m 인 경우
    moveforward(ace, 'Distance', 1) % 앞으로 0.5m 이동

elseif (most_red.Area < 1648) % 빨간색으로부터 거리가 0.85 ~ 0.95m 인 경우
    moveforward(ace, 'Distance', 0.7) % 앞으로 0.4m 이동

elseif (most_red.Area < 2173) % 빨간색으로부터 거리가 0.75 ~ 0.85m 인 경우
    moveforward(ace, 'Distance', 0.55) % 앞으로 0.3m 이동

elseif (most_red.Area < 2500) % 빨간색으로부터 거리가 0.65 ~ 0.75m 인 경우
    moveforward(ace, 'Distance', 0.4) % 앞으로 0.2m 이동
end

turn(ace,deg2rad(90)) % 빨간색 인식 90도 돌기
%% 2단계  / 단계별로 상승
first_find_blue = 0;

img_2rd_1_1m = get_img_rev_blue(acecam);   % 1.1m 에서 촬영
most_2rd_blue_1_1m = chase_blue_square(img_2rd_1_1m);   % 1.1m에서 파란면적  확인

if ( most_2rd_blue_1_1m.Area > 5000 )   % 파란면적을 찾았으면

    while(most_2rd_blue_1_1m.Centroid(2) < 250 || most_2rd_blue_1_1m.Centroid(2) > 350)
        img_2rd_1_1m = get_img_rev_blue(acecam);
        most_2rd_blue_1_1m = chase_blue_square(img_2rd_1_1m);
        
        to_center_UD(ace, most_2rd_blue_1_1m.Centroid, 0, 50)
    end

    first_find_blue = 1;
    disp('1.1m에서 파란면적 찾음')
end


if ( ~first_find_blue )  % 1.1m에서 파란면적을 못찾았으면
    moveup(ace, 'Distance', 0.5);   %   1.6m로 상승
    img_2rd_1_6m = get_img_rev_blue(acecam);   % 1.6m 에서 촬영
    most_2rd_blue_1_6m = chase_blue_square(img_2rd_1_6m);   % 1.6m에서 파란면적 확인

    if ( most_2rd_blue_1_6m.Area > 5000 )   % 파란면적을 찾았으면
        
        while(most_2rd_blue_1_6m.Centroid(2) < 250 || most_2rd_blue_1_6m.Centroid(2) > 350)

            img_2rd_1_6m = get_img_rev_blue(acecam);   
            most_2rd_blue_1_6m = chase_blue_square(img_2rd_1_6m);   

            to_center_UD(ace, most_2rd_blue_1_6m.Centroid, 0, 50)

        end
        
        first_find_blue = 1; 
        disp('1.6m에서 파란면적 찾음')
    end
end


if ( ~first_find_blue )  % 1.6m에서도 파란면적을 못찾았으면
    moveup(ace, 'Distance', 0.5);   %   2.1m로 상승
    img_2rd_2_1m = get_img_rev_blue(acecam);   % 2.1m 에서 촬영
    most_2rd_blue_2_1m = chase_blue_square(img_2rd_2_1m);   % 2.1m에서 파란면적 확인

    if ( most_2rd_blue_2_1m.Area > 5000 )   % 원을 찾았으면

        while(most_2rd_blue_2_1m.Centroid(2) < 250 || most_2rd_blue_2_1m.Centroid(2) > 350)

            img_2rd_2_1m = get_img_rev_blue(acecam);   
            most_2rd_blue_2_1m = chase_blue_square(img_2rd_2_1m); 

            to_center_UD(ace, most_2rd_blue_2_1m.Centroid, 0, 50)
        end

        first_find_blue = 1; 
        disp('2.0m에서 파란면적 찾음')
    end
    disp('파란면적 못찾음')
end

%% 2단계/ 상하정렬이후/ 전진 이전

img_2rd_UDcen = get_img_rev_blue(acecam);   % 상하 정렬된 위치에서 촬영
most_2rd_blue_UDcen = chase_blue_square(img_2rd_UDcen);   % 상하 정렬된 위치에서 파란면적 중심 확인

UDcen_RR = 0;  % 파란면적 중심의 위치, 0이면 왼쪽/1이면 오른쪽
if(most_2rd_blue_UDcen.Centroid(1) > 480)
    UDcen_RR = 1;
end

%--------------------------------

moveforward(ace,'Distance',1)  % 상하 정렬됬으니 1m 앞으로 이동

pause(0.5)

img_2rd_forward = get_img_rev_blue(acecam);   % 앞으로 간 후 촬영
most_2rd_blue_forward = chase_blue_square(img_2rd_forward);   % 앞으로 간 후 파란면적 중심 확인

while(most_2rd_blue_forward.Area < 5000)  % 앞으로 갔는데 파란면적이 안보일 경우
    disp('앞으로 왔는데 파란면적 안보임')
    if( UDcen_RR == 1 )
        moveright(ace, 'Distance', 0.5)  % 뒤에서 기억했던 중심 방향으로 이동
    else
        moveleft(ace, 'Distance', 0.5)
    end

    img_2rd_forward = get_img_rev_blue(acecam);   % 중심방향으로 이동 후 촬영
    most_2rd_blue_forward = chase_blue_square(img_2rd_forward);   % 파란면적 중심 확인
end


%% 2단계 앞으로 나왔고, 파란면적을 잡은 경우

img_2rd_get = get_img_rev_blue(acecam);   % 파란 반전 이진 이미지 촬영
most_circle_2_get = find_maxcircularity(img_2rd_get);  % 원형성 판단
blue_square_2_get = chase_blue_square(img_2rd_get);  % 파란면적 판단

img_green_get = get_img_green(acecam);   % 초록색 이진 이미지 촬영
most_green_get = find_color_square(img_green_get);  % 초록색 사각형 잡히는지 확인
pause(0.05)

while(most_green_get.Area < 400)   % 초록색 면적이 400 미만이면 반복

    if(most_green_get.Area > 300)   % 초록색이 적당히 멀리있지만 보이면
        to_center(ace, most_green_get.Centroid, 0.2, 50);  % 중심맞추고(좌우이동), 중심이면 0.3m 직진

    elseif(most_green_get.Area > 200)   % 초록색이 멀리있지만 보이면
        to_center(ace, most_green_get.Centroid, 0.2, 50);  % 중심맞추고(좌우이동), 중심이면 0.4m 직진

    elseif ( most_circle_2_get.Circularity > 0.6 && most_circle_2_get.EquivDiameter < 700 )  % 원 찾으면
        to_center(ace, most_circle_2_get.Centroid, 0.2, 50);   % 정렬 후 전진

    else
        to_center_back(ace, blue_square_2_get.Centroid, 0.2, 50);   % 파란면적을 쫒아간다
    end

    img_2rd_get = get_img_rev_blue(acecam);   % 파란 반전 이진 이미지 촬영
    most_circle_2_get = find_maxcircularity(img_2rd_get);  % 원형성 판단
    blue_square_2_get = chase_blue_square(img_2rd_get);  % 파란면적 판단

    img_green_get = get_img_green(acecam);   % 초록색 이진 이미지 촬영
    most_green_get = find_color_square(img_green_get);  % 초록색 사각형 잡히는지 확인

    pause(0.05)
end


%% 2단계 / 초록색이 인식된 경우

img_green = get_img_green(acecam);  % 초록색 이진 이미지를 얻는다
most_green = find_color_square(img_green);  % 초록 사각형을 찾는다
pause(0.05)

% 2단계 / 초록색 일정크기 이상으로 보일때 
while(most_green.Area < 626 ) %초록색으로부터 1.25m 이상 떨어져있으면 조금씩 전진
    to_center(ace, most_green.Centroid, 0.2, 40);  % 중심맞추고(좌우이동), 중심이면 0.2m 직진

    img_green = get_img_green(acecam);  % 초록색 이진 이미지를 얻는다
    most_green = find_color_square(img_green);  % 초록 사각형을 찾는다
    
    pause(0.05)
end


% 2단계 / 원 통과 직전

if (most_green.Area < 807) % 초록색으로부터 거리가 1.15 ~ 1.25m 인 경우
    moveforward(ace,'Distance',0.8) % 앞으로 0.7m 이동

elseif (most_green.Area < 1020) % 초록색으로부터 거리가 1.05 ~ 1.15m 인 경우
    moveforward(ace,'Distance',0.7) % 앞으로 0.6m 이동

elseif (most_green.Area < 1268) % 초록색으로부터 거리가 0.95 ~ 1.05m 인 경우
    moveforward(ace,'Distance',0.6) % 앞으로 0.5m 이동

elseif (most_green.Area < 1648) % 초록색으로부터 거리가 0.85 ~ 0.95m 인 경우
    moveforward(ace,'Distance',0.5) % 앞으로 0.4m 이동

elseif (most_green.Area < 2173) % 초록색으로부터 거리가 0.75 ~ 0.85m 인 경우
    moveforward(ace,'Distance',0.4) % 앞으로 0.3m 이동

elseif (most_green.Area < 2500) % 초록색으로부터 거리가 0.65 ~ 0.75m 인 경우
    moveforward(ace,'Distance',0.3) % 앞으로 0.2m 이동
end


%% 3단계 시작
turn(ace, deg2rad(90));
moveforward(ace,'Distance',1)
turn(ace, deg2rad(45));

find_blue_3rd = 0;

img_3rd_first = get_img_rev_blue(acecam);   % 2단계 통과높이에서 촬영
most_blue_3rd_first = chase_blue_square(img_3rd_first);   % 2단계 통과높이에서 파란면적 확인

if ( most_blue_3rd_first.Area > 5000 )   % 파란면적을 찾았으면
    
    while(most_blue_3rd_first.Centroid(2) < 250 || most_blue_3rd_first.Centroid(2) > 350)
        to_center_UD(ace, most_blue_3rd_first.Centroid, 0, 50)

        img_3rd_first = get_img_rev_blue(acecam);   % 2단계 통과높이에서 촬영
        most_blue_3rd_first = chase_blue_square(img_3rd_first);   % 2단계 통과높이에서 파란면적 확인

    end

    find_blue_3rd = 1;
    disp('2단계통과높이에서 파란면적 찾음')
end


if ( ~find_blue_3rd )  % 파란면적을 못찾았으면
    moveup(ace, 'Distance', 0.5);   %   0.5m 상승
    img_3rd_05m = get_img_rev_blue(acecam);   % +0.5m에서 촬영
    most_blue_3rd_05m = chase_blue_square(img_3rd_05m);   % +0.5m에서 파란면적 확인

    if ( most_blue_3rd_05m.Area > 5000 )   % 파란면적을 찾았으면
        
        while(most_blue_3rd_05m.Centroid(2) < 250 || most_blue_3rd_05m.Centroid(2) > 350)
            to_center_UD(ace, most_blue_3rd_05m.Centroid, 0, 50)
            
            img_3rd_05m = get_img_rev_blue(acecam);   % +0.5m에서 촬영
            most_blue_3rd_05m = chase_blue_square(img_3rd_05m);   % +0.5m에서 파란면적 확인

        end

        find_blue_3rd = 1; 
        disp('+0.5m에서 파란면적 찾음')
    end
end


if ( ~find_blue_3rd )  % +0.5m에서도 파란면적을 못찾았으면
    moveup(ace, 'Distance', 0.5);   %   +1m로 상승
    img_3rd_10m = get_img_rev_blue(acecam);   % +1m 에서 촬영
    most_blue_3rd_10m = chase_blue_square(img_3rd_10m);   % 2.1m에서 파란면적 확인

    if ( most_blue_3rd_10m.Area > 5000 )   % 원을 찾았으면

        while(most_blue_3rd_10m.Centroid(2) < 250 || most_blue_3rd_10m.Centroid(2) > 350)
            to_center_UD(ace, most_blue_3rd_10m.Centroid, 0, 50)
        
            img_3rd_10m = get_img_rev_blue(acecam);   % +1m 에서 촬영
            most_blue_3rd_10m = chase_blue_square(img_3rd_10m);   % 2.1m에서 파란면적 확인
        end
        
        find_blue_3rd = 1; 
        disp('+1.0m에서 파란면적 찾음')
    end
end

if ( ~find_blue_3rd )  % +1m에서도 파란면적을 못찾았으면
    movedown(ace, 'Distance', 1.5);   %   -0.5m로 하강
    img_3rd_15m = get_img_rev_blue(acecam);   % +1m 에서 촬영
    most_blue_3rd_15m = chase_blue_square(img_3rd_15m);   % 2.1m에서 파란면적 확인

    if ( most_blue_3rd_15m.Area > 5000 )   % 원을 찾았으면

        while(most_blue_3rd_15m.Centroid(2) < 250 || most_blue_3rd_15m.Centroid(2) > 350)

            to_center_UD(ace, most_blue_3rd_15m.Centroid, 0, 50)
        
            img_3rd_15m = get_img_rev_blue(acecam);   % +1m 에서 촬영
            most_blue_3rd_15m = chase_blue_square(img_3rd_15m);   % 2.1m에서 파란면적 확인
        end

        disp('-0.5m에서 파란면적 찾음')
        find_blue_3rd = 1; 
    end
    disp('파란면적 못찾음')
end


%% 3단계/ 상하정렬이후/ 전진 이전

img_3rd_UDcen = get_img_rev_blue(acecam);   % 상하 정렬된 위치에서 촬영
most_3rd_blue_UDcen = chase_blue_square(img_3rd_UDcen);   % 상하 정렬된 위치에서 파란면적 중심 확인

UDcen_RRR = 0;  % 파란면적 중심의 위치, 0이면 왼쪽/1이면 오른쪽
if(most_3rd_blue_UDcen.Centroid(1) > 480)
    UDcen_RRR = 1;
end

%--------------------------------

moveforward(ace,'Distance',0.3)  % 상하 정렬됬으니 1m 앞으로 이동

pause(0.5)

img_3rd_forward = get_img_rev_blue(acecam);   % 앞으로 간 후 촬영
most_3rd_blue_forward = chase_blue_square(img_3rd_forward);   % 앞으로 간 후 파란면적 중심 확인

while(most_3rd_blue_forward.Area < 4000)  % 앞으로 갔는데 파란면적이 안보일 경우
    disp('앞으로 왔는데 파란면적 안보임')
    if( UDcen_RRR == 1 )
        moveright(ace, 'Distance', 0.5)  % 뒤에서 기억했던 중심 방향으로 이동
    else
        moveleft(ace, 'Distance', 0.5)
    end

    img_3rd_forward = get_img_rev_blue(acecam);   % 중심방향으로 이동 후 촬영
    most_3rd_blue_forward = chase_blue_square(img_3rd_forward);   % 파란면적 중심 확인
end

%% 3단계 앞으로 나왔고, 파란면적을 잡은 경우

img_3rd_get = get_img_rev_blue(acecam);   % 파란 반전 이진 이미지 촬영
most_circle_3_get = find_maxcircularity(img_3rd_get);  % 원형성 판단
blue_square_3_get = chase_blue_square(img_3rd_get);  % 파란면적 판단

img_purple_get = get_img_purple(acecam);   % 보라색 이진 이미지 촬영
most_purple_get = find_color_square(img_purple_get);  % 보라색 사각형 잡히는지 확인
pause(0.05)

while(most_purple_get.Area < 400)   % 보라색 면적이 400 미만이면 반복

    if(most_purple_get.Area > 300)   % 보라색이 적당히 멀리있지만 보이면
        to_center(ace, most_purple_get.Centroid, 0.2, 50);  % 중심맞추고(좌우이동), 중심이면 0.3m 직진

    elseif(most_purple_get.Area > 200)   % 보라색이 멀리있지만 보이면
        to_center(ace, most_purple_get.Centroid, 0.2, 50);  % 중심맞추고(좌우이동), 중심이면 0.4m 직진

    elseif ( most_circle_3_get.Circularity > 0.6 && most_circle_3_get.EquivDiameter < 700 )  % 원 찾으면
        to_center(ace, most_circle_3_get.Centroid, 0.2, 50);   % 정렬 후 전진

    else
        to_center_back(ace, blue_square_3_get.Centroid, 0.2, 50);   % 파란면적을 쫒아간다
    end

    img_3rd_get = get_img_rev_blue(acecam);   % 파란 반전 이진 이미지 촬영
    most_circle_3_get = find_maxcircularity(img_3rd_get);  % 원형성 판단
    blue_square_3_get = chase_blue_square(img_3rd_get);  % 파란면적 판단

    img_purple_get = get_img_green(acecam);   % 보라색 이진 이미지 촬영
    most_purple_get = find_color_square(img_purple_get);  % 보라색 사각형 잡히는지 확인

    pause(0.05)
end


%% 3단계, 보라색이 인식된 경우

img_purple2 = get_img_purple(acecam);  % 초록색 이진 이미지를 얻는다
most_purple = find_color_square(img_purple2);  % 초록 사각형을 찾는다
pause(0.05)

% 3단계 / 보라색 일정크기 이상으로 보일때 
while(most_purple.Area < 626)  %보라색으로부터 1.15m 이상 떨어져있으면 조금씩 전진
    to_center(ace, most_purple.Centroid, 0.2, 40);  % 중심맞추고(좌우이동), 중심이면 0.2m 직진

    img_purple2 = get_img_purple(acecam);  % 보라색 이진 이미지를 얻는다
    most_purple = find_color_square(img_purple2);  % 보라 사각형을 찾는다
    
    pause(0.05)
end

movedown(ace,'Distance',0.4)

% 3단계 / 원 통과 직전
if (most_purple.Area < 807) % 보라색으로부터 거리가 1.15 ~ 1.25m 인 경우
    moveforward(ace,'Distance',0.8) % 앞으로 0.7m 이동

elseif (most_purple.Area < 1020) % 보라색으로부터 거리가 1.05 ~ 1.15m 인 경우
    moveforward(ace,'Distance',0.7) % 앞으로 0.6m 이동

elseif (most_purple.Area < 1268) % 보라색으로부터 거리가 0.95 ~ 1.05m 인 경우
    moveforward(ace,'Distance',0.6) % 앞으로 0.5m 이동

elseif (most_purple.Area < 1648) % 보라색으로부터 거리가 0.85 ~ 0.95m 인 경우
    moveforward(ace,'Distance',0.5) % 앞으로 0.4m 이동

elseif (most_purple.Area < 2173) % 보라색으로부터 거리가 0.75 ~ 0.85m 인 경우
    moveforward(ace,'Distance',0.4) % 앞으로 0.3m 이동

elseif (most_purple.Area < 2500) % 보라색으로부터 거리가 0.65 ~ 0.75m 인 경우
    moveforward(ace,'Distance',0.3) % 앞으로 0.2m 이동
end

land(ace) % 보라색 인식, 착륙

%% 함수 선언(3단계)
function [img_purple] = get_img_purple(acecam) % 빨간 이진 이미지 촬영

take_img = snapshot(acecam);
pause(0.1)

if(size(take_img,1) ~= 720)   % 이미지 촬영을 불러올 때 에러가 생기는 경우
    pause(0.5)
    take_img = snapshot(acecam);
    pause(0.5)
end

img_hsv = rgb2hsv(take_img);

h = img_hsv(:, :, 1);
s = img_hsv(:, :, 2);
v = img_hsv(:, :, 3);

img_purple = ((h>0.95)|(h<0.05))&(s>0.4)&(v>0.1)&(v<0.9); % 빨간색 인식
% % img_purple = (h>0.725)&(h<0.825)&(s>0.3)&(v>0.1)&(v<0.9); % 보라색 인식


end


%% 함수 선언(2단계)
function [most_blue_square] = chase_blue_square(binary_img)
    blue_img = imcomplement(binary_img);
    % 반전 이미지(파랑이 0)인 이미지를 받아오므로, 비반전 이미지(파랑이 1)인 이미지로 변환
    
    shapes = regionprops(blue_img, 'Area', 'Centroid');

    if(isempty(shapes))  % 도형이 없으면 0 반환
        most_blue_square = struct('Area', 0, 'Centroid', [0 0]);
        return
    end

    size_s = size(shapes, 1);

    Area_matrix = zeros(size_s, 1);  % 구조체를 배열로 바꾸기 위함

    for i_s = 1 : size_s
        Area_matrix(i_s) = shapes(i_s).Area;
    end

    erase = Area_matrix > 1000;  % 면적이 1000보다 큰 것만 남기고 지우기
    blue_square = erase .* Area_matrix;  % 면적이 1000보다 큰 것들의 원형성

    [~, index] = max(blue_square);
    
    most_blue_square = shapes(index);
end

function [img_green] = get_img_green(acecam) % 초록 이진 이미지 촬영

take_img = snapshot(acecam);
pause(0.1)
   
if(size(take_img,1) ~= 720)   % 이미지 촬영을 불러올 때 에러가 생기는 경우
    pause(0.5)
    take_img = snapshot(acecam);
    pause(0.5)
end

img_hsv = rgb2hsv(take_img);

h = img_hsv(:, :, 1);
s = img_hsv(:, :, 2);
v = img_hsv(:, :, 3);

% img_green = (h>0.275)&(h<0.365)&(s>0.4)&(v>0.1)&(v<0.9); % 초록색 인식 %%원본원본원본원본원본원본원본원본원본원본원본원본원본원본원본
% img_green = (h>0.616)&(h<0.716)&(s>0.4)&(v>0.1)&(v<0.9);  % 파란색 인식
img_green = (h>0.72)&(h<0.83)&(s>0.4)&(v>0.1)&(v<0.9); % 보라색 인식


end

function to_center_UD(ace, cent, dis, min_offset)  % 상하 중심정렬

    if(cent == 0)
        disp('Error : Cent missing(to_center_UD)')
    end

    offset_UD = 300 - cent(2);  % 차이값, 위쪽이면 양수/아래쪽이면 음수

    if offset_UD < (-min_offset)  % 중심이 아래쪽에 위치한 경우
        movedown(ace,'Distance', 0.2)
    elseif offset_UD > min_offset  % 중심이 위쪽에 위치한 경우
        moveup(ace,'Distance', 0.2)
    elseif dis ~= 0
        moveforward(ace, 'Distance', dis)
    end

end

function to_center(ace, cent, dis, min_offset)  %  상하좌우 중심정렬

    if(cent == 0)
        disp('Error : Cent missing(to_center)')
    end
    
    offset_LR = cent(1) - 480;  % 차이값, 왼쪽이면 음수/오른쪽이면 양수
    offset_UD = 360 - cent(2);  % 차이값, 위쪽이면 양수/아래쪽이면 음수
    
    UD_cen = 0;

    if offset_UD < (-min_offset)  % 중심이 아래쪽에 위치한 경우
        movedown(ace,'Distance', 0.2)
    elseif offset_UD > min_offset  % 중심이 위쪽에 위치한 경우
        moveup(ace,'Distance', 0.2)
    else
        UD_cen = 1;     
    end

    if offset_LR < (-min_offset)  % 중심이 왼쪽에 위치한 경우
        moveleft(ace,'Distance', 0.2)
    elseif offset_LR > min_offset  % 중심이 오른쪽에 위치한 경우
        moveright(ace,'Distance', 0.2)
    elseif ( UD_cen == 1 && dis ~= 0 )
        moveforward(ace, 'Distance', dis)
    end

end


function to_center_back(ace, cent, dis, min_offset)  %  상하좌우 중심정렬

    if(cent == 0)
        disp('Error : Cent missing(to_center)')
    end
    
    offset_LR = cent(1) - 480;  % 차이값, 왼쪽이면 음수/오른쪽이면 양수
    offset_UD = 360 - cent(2);  % 차이값, 위쪽이면 양수/아래쪽이면 음수
    
    UD_cen = 0;

    if offset_UD < (-min_offset)  % 중심이 아래쪽에 위치한 경우
        movedown(ace,'Distance', 0.2)
    elseif offset_UD > min_offset  % 중심이 위쪽에 위치한 경우
        moveup(ace,'Distance', 0.2)
    else
        UD_cen = 1;     
    end

    if offset_LR < (-min_offset)  % 중심이 왼쪽에 위치한 경우
        moveleft(ace,'Distance', 0.2)
    elseif offset_LR > min_offset  % 중심이 오른쪽에 위치한 경우
        moveright(ace,'Distance', 0.2)
    elseif ( UD_cen == 1 && dis ~= 0 )
        moveback(ace, 'Distance', dis)
    end

end

%% 함수 선언(1단계)
function [most_color] = find_color_square(color_img)
    
    shapes = regionprops(color_img, 'Area', 'Centroid');

    if(isempty(shapes))  % 도형이 없으면 0 반환
        most_color = struct('Area', 0, 'Centroid', [0 0]);
        return
    end

    size_s = size(shapes, 1);

    Area_matrix = zeros(size_s, 1);  % 구조체를 배열로 바꾸기 위함

    for i_s = 1 : size_s
        Area_matrix(i_s) = shapes(i_s).Area;
    end

    erase = (Area_matrix > 50) & (Area_matrix < 7000);  % 면적이 50 ~ 7000 인 것만 남기고 지우기
    big_Area = erase .* Area_matrix;  

    [~, area_index] = max(big_Area);
    
    most_color = shapes(area_index);  % 가장 면적이 큰 도형 추출
end

function [img_red] = get_img_red(acecam) % 빨간 이진 이미지 촬영

take_img = snapshot(acecam);
pause(0.1)

if(size(take_img,1) ~= 720)   % 이미지 촬영을 불러올 때 에러가 생기는 경우
    pause(0.5)
    take_img = snapshot(acecam);
    pause(0.5)
end

img_hsv = rgb2hsv(take_img);

h = img_hsv(:, :, 1);
s = img_hsv(:, :, 2);
v = img_hsv(:, :, 3);

% img_red = ((h>0.95)|(h<0.05))&(s>0.4)&(v>0.2)&(v<0.9); % 빨간색 인식
img_red = (h>0.28)&(h<0.39)&(s>0.4)&(v>0.1)&(v<0.9); % 초록색 인식


end

function to_center_LR(ace, cent, dis, min_offset)  % 1단계 원 쫒기

    if(cent == 0)
        disp('Error : Cent missing(to_center_LR)')
    end

    offset_LR = cent(1) - 480;  % 차이값, 왼쪽이면 음수/오른쪽이면 양수

    if offset_LR < (-min_offset)  % 중심이 왼쪽에 위치한 경우
        moveleft(ace,'Distance', 0.2)
    elseif offset_LR > min_offset  % 중심이 오른쪽에 위치한 경우
        moveright(ace,'Distance', 0.2)
    elseif dis ~= 0
        moveforward(ace, 'Distance', dis)
    end

end

function [most_circle] = find_maxcircularity(binary_image)
    shapes = regionprops(binary_image, 'Area', 'Centroid', 'Circularity', 'EquivDiameter');

    if(isempty(shapes))  % 도형이 없으면 0 반환
        most_circle = struct('Area', 0, 'Centroid', [0 0], 'Circularity', 0, 'EquivDiameter', 0);
        return
    end

    size_s = size(shapes, 1);

    Area_matrix = zeros(size_s, 1);  % 구조체를 배열로 바꾸기 위함
    Circularity_matrix = zeros(size_s, 1);

    for i_s = 1 : size_s
        Area_matrix(i_s) = shapes(i_s).Area;
        Circularity_matrix(i_s) = shapes(i_s).Circularity;
    end

    erase = Area_matrix > 4000;  % 면적이 4000보다 큰 것만 남기고 지우기
    shape_Circularity = erase .* Circularity_matrix;  % 면적이 4000보다 큰 것들의 원형성

    [~, cir_index] = max(shape_Circularity);
    
    most_circle = shapes(cir_index);
end

function [img_rev_blue] = get_img_rev_blue(acecam) % 파란반전이미지 촬영

take_img = snapshot(acecam);
pause(0.1)

if(size(take_img,1) ~= 720)   % 이미지 촬영을 불러올 때 에러가 생기는 경우
    pause(0.5)
    take_img = snapshot(acecam);
    pause(0.5)
end

img_hsv = rgb2hsv(take_img);

h = img_hsv(:, :, 1);
s = img_hsv(:, :, 2);
v = img_hsv(:, :, 3);

img_blue = (h>0.61)&(h<0.72)&(s>0.4)&(v>0.1)&(v<0.9);  % 파란색 인식

% img_blue = (h>0.4)&(h<0.5)&(s>0.4)&(v>0.05)&(v<0.9); %%%%%%%% 우드락 초록색 인식

img_rev_blue = imcomplement(img_blue);

end
