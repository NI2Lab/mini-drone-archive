clear()
% HSV Threshold Green
thdown_green = [0.25, 40/240, 80/240];
thup_green = [0.40, 240/240, 240/240];
% HSV Threshold Blue
thdown_blue = [0.5, 0.35, 0.25];
thup_blue = [0.75, 1, 1];

% HSV Threshold Red
thdown_red1 = [0, 0.25, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.25, 0.25];
thup_red2 = [1, 1, 1];

% HSV Threshold Purple
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
takeoff(droneObj);
% v = VideoReader('test_video2.mp4');
while 1
    % HSV Convert
    disp('----------------- HSV Converting --------------------');
%     frame = readFrame(v);
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
    try
        bw1 = (0.5 < src_h)&(src_h < 0.75) & (0.15 < src_s)&(src_s < 1) & (0.25 < src_v)&(src_v < 1);   % 파란색 검출
    catch
        bw1 = double(zeros(size(src_hsv)));
    end
    
    % Move To Center
    sumUp = sum(sum(bw1(1:rows/2, :)));             % 상단 절반
    sumDown = sum(sum(bw1(rows/2:end, :)));         % 하단 절반
    sumLeft = sum(sum(bw1(:, 1:cols/2)));           % 좌측 절반
    sumRight = sum(sum(bw1(:, cols/2:end)));        % 우측 절반
    
    if(sumUp == 0)                                  % 상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.2);        % 하단으로 이동
    elseif(sumDown == 0)                            % 하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.2);          % 상단으로 이동
    elseif(sumLeft == 0)                            % 좌측에 크로마키가 없으면
        moveright(droneObj, 'distance', 0.2);       % 우측으로 이동
    elseif(sumRight == 0)                           % 우측에 크로마키 없으면
        moveleft(droneObj, 'distance', 0.2);        % 좌측으로 이동
    else                                            % 4개의 사분면 모두에 크로마키가 존재하면 원 검출
        bw2 = imfill(bw1,'holes');      % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
        % 구멍을 채우기 전후를 비교, 원이 아닌부분 0(검은색), 원 부분 1(흰색)
        for row = 1:rows
            for col = 1:cols
                if bw1(row, col) == bw2(row, col)
                    bw2(row, col) = 0;
                end
            end
        end
        
        if sum(sum(bw2)) > 100
            % Detecting Center
            disp('Image Processing 2: Detecting Center');
            count_pixel = 0;
            center_row = 0;
            center_col = 0;
            for row = 1:rows
                for col = 1:cols
                    if bw2(row, col) == 1
                        count_pixel = count_pixel + 1;
                        center_row = center_row + row;
                        center_col = center_col + col;    
                    end        
                end
            end
            center_row = center_row / count_pixel;
            center_col = center_col / count_pixel;
            camera_mid_row = rows / 2;
            camera_mid_col = cols / 2;
            
            disp('Calculating Circle Center');
            moveRow = center_row - camera_mid_row;
            moveCol = center_col - camera_mid_col;            
        else
            disp('Move Cromakey To Center');
            if(sumUp > sumDown)                         % 상단 크로마키 > 하단 크로마키
                moveup(droneObj, 'distance', 0.2);       % 상단으로 이동
            else                                        % 상단 크로마키 < 하단 크로마키
                movedown(droneObj, 'distance', 0.2);    % 하단으로 이동
            end
            if(sumLeft > sumRight)                      % 좌측 크로마키 > 우측 크로마키
                moveleft(droneObj, 'distance', 0.2);     % 좌측으로 이동
            else                                        % 좌측 크로마키 < 우측 크로마키
                moveright(droneObj, 'distance', 0.2);   % 우측으로 이동
            end
        end     
    end
    
    try
        disp('Move Drone Very Carefully!!!');
        if (-40< moveRow && moveRow < 40) && (-40< moveCol && moveCol < 40)
            movedown(droneObj, 'distance', 0.3);
            moveforward(droneObj, 'distance', 1);                   % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
            % Image Preprocessing
            while 1
                frame = snapshot(cameraObj);
                src_hsv = rgb2hsv(frame);
                src_h = src_hsv(:,:,1);
                src_s = src_hsv(:,:,2);
                src_v = src_hsv(:,:,3);
                bw_red = (((thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)))) ...% 빨간색1 검출
                        + (((thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3))));      % 빨간색2 검출
                bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));   % 보라색 검출

                % 빨간색 혹은 보라색 검출할 때까지 전진
                if (sum(bw_red, 'all') > 8000)                          % 빨간색이 검출되면
                    disp('RED Color Detected!!! Drone Turn Left');
                    turn(droneObj, deg2rad(-90));                       % Turn Left, 다음동작 크로마키 검출, 지난 링을 건드리지 않도록 일정거리 전진
                    moveforward(droneObj, 'distance', 1.25);            % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
                    break;
                elseif(sum(bw_purple, 'all') > 8000)                    % 보라색이 검출되면
                    disp('Purple Color Detected!!! Drone Landing');
                    land(droneObj);                                     % Landing
                    return;                                             % 프로그램 종료
                else
                    % if문 넣어서 링의 크기 측정 후 일정 픽셀이상이면 상수거리 이동
                    disp('Circle Coordinate Detected!!! Drone Move Forward');
                    moveforward(droneObj, 'distance', 0.4);
                end
            end
        elseif moveRow < -40
            disp('MoveUp');
            moveup(droneObj, 'Distance', 0.2)
        elseif 40 < moveRow
            disp('MoveDown');
            movedown(droneObj, 'Distance', 0.2)
        elseif moveCol < -40
            disp('MoveLeft');
            moveleft(droneObj, 'Distance', 0.2)
        elseif 40 < moveCol
            disp('MoveRight');
            moveright(droneObj, 'Distance', 0.2)
        end

        disp('There is Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        clear center_col;
        clear center_row;
   catch exception
        disp('There is no Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame);
        subplot(2, 2, 3), imshow(bw1);
%         subplot(2, 2, 4), imshow(bw2);
    end
    pause(1);
end