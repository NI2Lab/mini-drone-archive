%% (0) 초기 선언
clear;
drone=ryze(); % 드론 객체 선언
cam=camera(drone); % 카메라 객체 선언
preview(cam); % 드론 카메라 모니터링

%% (1) 이륙
takeoff(drone);
pause(1);

moveforward(drone, 'Distance', 0.5, 'WaitUntilDone', true);
pause(1);

%% (2) 초록색 탐색
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
    end

    % 중앙 점을 따라가는 함수
    if YgreenCenter < 325
        moveup(drone, 0.6);
        pause(1);
    elseif YgreenCenter > 395
        movedown(drone, 0.5);
        pause(1);
    else
        if XgreenCenter < 430
            moveleft(drone, 0.6);
            pause(1);
        elseif XgreenCenter > 530
            moveright(drone, 0.5);
            pause(1);
        else
            break;
        end
    end
    
    clear XgreenCenter;
    clear YgreenCenter;
end
% (3) 전진하기 전 드론을 아래로 이동시킴
movedown(drone, 'Distance', 0.4, 'WaitUntilDone', true);

% (4) 드론을 중앙에 맞췄으므로 2m 전진
moveforward(drone, 'Distance', 2);

%% (5) 빨간색 탐색
R = 1;
while 1
    frame=snapshot(cam);
    hsv=rgb2hsv(frame);
    h=hsv(:,:,1);
    detect_red=(h>0.8)+(h<0.2);

    if sum(detect_red, 'all')>=9000 % 빨간 픽셀의 개수 = 9000
        % 빨간색 검출하면 정지
        break
    else
        if mod(R, 2) == 1
            moveup(drone, 0.6);
            pause(1);
            R = R + 1;
        else
            movedown(drone, 0.5);
            pause(1);
            R = R + 1;
        end
    end
end

% (6) 왼쪽으로 90도 회전
turn(drone,deg2rad(-90));
moveforward(drone, 'Distance', 0.5);
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
    end

    % 중앙 점을 따라가는 함수
    if YgreenCenter < 330
        moveup(drone, 0.6);
        pause(1);
    elseif YgreenCenter > 390
        movedown(drone, 0.5);
        pause(1);
    else
        if XgreenCenter < 440
            moveleft(drone, 0.6);
            pause(1);
        elseif XgreenCenter > 520
            moveright(drone, 0.5);
            pause(1);
        else
            break;
        end
    end

    clear XgreenCenter;
    clear YgreenCenter;
end
% (8) 전진하기 전 드론을 아래로 이동시킴
movedown(drone, 'Distance', 0.4, 'WaitUntilDone', true);

% (9) 드론을 중앙에 맞췄으므로 2m 전진
moveforward(drone, 'Distance', 2);
    
%% (10) 두 번째 빨간색 탐색
R = 1;
while 1
    frame=snapshot(cam);
    hsv=rgb2hsv(frame);
    h=hsv(:,:,1);
    detect_red=(h>0.8)+(h<0.2);

    if sum(detect_red, 'all')>=9000 % 빨간 픽셀의 개수 = 9000
        % 빨간색 검출하면 정지
        break
    else
        if mod(R, 2) == 1
            moveup(drone, 0.6);
            pause(1);
            R = R + 1;
        else
            movedown(drone, 0.5);
            pause(1);
            R = R + 1;
        end
    end
end

% (11) 왼쪽으로 90도 회전
turn(drone,deg2rad(-90));
moveforward(drone, 'Distance', 0.7);
pause(1);

%% (13) 세 번째 초록색 탐색
while 1
    frame=snapshot(cam);
    hsv=rgb2hsv(frame);
    h=hsv(:,:,1);
    green_den=hsv(:,:,1);
    detect_green=(0.225<green_den)&(green_den<0.275);

    if sum(detect_green, 'all')>=50000 % 초록 픽셀의 개수 = 50000
        % 초록색 검출하면 정지
        break
    else
        % 초록색을 검출하지 못하면 오른쪽으로 이동
        moveright(drone, 0.5);
    end
end

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
    end

    % 중앙 점을 따라가는 함수
    if YgreenCenter < 335
        moveup(drone, 0.6);
        pause(1);
    elseif YgreenCenter > 385
        movedown(drone, 0.5);
        pause(1);
    else
        if XgreenCenter < 450
            moveleft(drone, 0.6);
            pause(1);
        elseif XgreenCenter > 510
            moveright(drone, 0.5);
            pause(1);
        else
            break;
        end
    end
end
% (14) 전진하기 전 드론을 아래로 이동시킴
movedown(drone, 'Distance', 0.4, 'WaitUntilDone', true);

% (15) 드론을 중앙에 맞췄으므로 1.9m 전진
moveforward(drone, 'Distance', 1.9);

%% (16) 파란색 탐색
while 1
    frame=snapshot(cam);
    hsv=rgb2hsv(frame);
    h=hsv(:,:,1);
    detect_blue=(0.3<h)&(h<0.7);

    if sum(detect_blue, 'all')>=3000 % 파란 픽셀의 개수 = 3000
        % 파란색 검출하면 정지
        break
    else
        % 파란색을 검출하지 못하면 상승
        moveup(drone, 0.6);
        pause(1);
        movedown(drone, 0.5);
        pause(1);
    end
end

%% (17) 착륙
land(drone);