%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

% 드론 행동 결정 표식 HSV 임계값
thdown_red1 = [0, 0.65, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.65, 0.25];
thup_red2 = [1, 1, 1];
thdown_green = [0.25, 40/240, 80/240];         
thup_green = [0.40, 1, 1];
%thdown_green = [0.275, 0.5, 0.25];
%thup_green = [0.325, 1, 1];
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

right_cnt = 0;
left_cnt = 0;
up_cnt = 0;
down_cnt = 0;
activeForward = 1;

droneObj = ryze()
cameraObj = camera(droneObj);
takeoff(droneObj);
moveup(droneObj, 'distance', 0.4);

while(1)
    frame = snapshot(cameraObj);
    if sum(frame, 'all') == 0
        disp('frame error!');
        continue;
    end

    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv); 

    bw1 = (thdown_blue(1) < src_h) & (src_h < thup_blue(1)) & (thdown_blue(2) < src_s) & (src_s < thup_blue(2)); % 파란색 검출

    if sum(bw1, 'all') < 5000
        moveforward(droneObj, 'distance', 0.3);   %너무 멀경우 조금씩 전진
        disp('너무 멀어서 조금 전진');
    end

    sumLeftUp = sum(bw1(1:rows/2, 1:cols/2), 'all');             % 좌상단
    sumRightUp = sum(bw1(1:rows/2, cols/2:end), 'all');          % 우상단
    sumLeftDown = sum(bw1(rows/2:end, 1:cols/2), 'all');         % 좌하단    
    sumRightDown = sum(bw1(rows/2:end, cols/2:end), 'all');      % 우하단

    
    if(sumLeftUp == 0)                              % 좌상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.2);        
        moveright(droneObj, 'distance', 0.2);
        %moveback(droneObj, 'distance', 0.2);
        disp('우하단 이동');
        continue;
    elseif(sumRightUp == 0)                         % 우상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.2);       
        moveleft(droneObj, 'distance', 0.2);
        %moveback(droneObj, 'distance', 0.2);
        disp('좌하단 이동');
        continue;
    elseif(sumLeftDown == 0)                        % 좌하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.2);          
        moveright(droneObj, 'distance', 0.2);
        %moveback(droneObj, 'distance', 0.2);
        disp('우상단 이동');
        continue;
    elseif(sumRightDown == 0)                       % 우하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.2);          
        moveleft(droneObj, 'distance', 0.2);
       % moveback(droneObj, 'distance', 0.2);
        disp('좌상단 이동');
        continue;
    end

    bw2 = imfill(bw1,'holes');                  % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
    for row = 1:rows
        for col = 1:cols
            if bw1(row, col) == bw2(row, col)
                bw2(row, col) = 0;
            end
        end
    end

    if sum(bw2, 'all') > 20000
        % Detecting Center
        disp('파란색 크로마키 검출! 원 센터 좌표 구하기');
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
            
        disp('센터 좌표 확인! 카메라 좌표와 일치화 진행중');
        moveRow = center_row - camera_mid_row;
        moveCol = center_col - camera_mid_col;
            
        right_cnt = 0;
        left_cnt = 0;
        up_cnt = 0;
        down_cnt = 0;

        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
    else
        disp('뒤로 드론 이동 && 컨티뉴');
        moveback(droneObj, 'distance', 0.3);
        continue;
    end  
          
    try
        disp('드론 센터 좌표 맞추기');
        if (-100 < moveRow && moveRow < 100) && (-100 < moveCol && moveCol < 100)
            movedown(droneObj, 'distance', 0.2);
            bw2_pix_num = sum(bw2, 'all');
            if 110000 < bw2_pix_num
                disp('링 통과 중');
                moveforward(droneObj, 'distance', 1.1);
                pause(1);
                moveforward(droneObj, 'distance', 0.9);
                while 1
                    disp('왈왈');
                    frame = snapshot(cameraObj);
                    if sum(frame, 'all') == 0
                        disp('frame error!');
                        continue;
                    end

                    disp('여기까쥐1');
                    
                    src_hsv = rgb2hsv(frame);
                    src_h = src_hsv(:, :, 1);
                    src_s = src_hsv(:, :, 2);
                    src_v = src_hsv(:, :, 3);

                    disp('여기까쥐2');

                    % Image Preprocessing
                    bw_red = ((thdown_red1(1) < src_h & src_h < thup_red1(1)) & (thdown_red1(2) < src_s & src_s < thup_red1(2))) ...            % 빨간색1범위 검출
                           + ((thdown_red2(1) < src_h & src_h < thup_red2(1)) & (thdown_red2(2) < src_s & src_s < thup_red2(2)));               % 빨간색2범위 검출
                    disp('레드됨');
                    bw_purple = (thdown_purple(1) < src_h) & (src_h < thup_purple(1)) & (thdown_purple(2) < src_s) & (src_s < thup_purple(2));  % 보라색범위 검출
                    bw_green = (thdown_green(1) < src_h) & (src_h < thup_green(1)) & (thdown_green(2) < src_s) & (src_s < thup_green(2));


                    %subplot(2, 2, 1), imshow(frame);
                    %subplot(2, 2, 2), imshow(frame);
                    %subplot(2, 2, 3), imshow(bw_red);
                    %subplot(2, 2, 4), imshow(bw_purple);

                    % 빨간색 혹은 보라색 검출할 때까지 전진
                    %sum(bw_red, 'all');
                    disp('여기까쥐3');
                                                            % 프로그램 종료
                    
                    if(sum(bw_red, 'all') > 500)                       % 빨간색이 검출되면
                        disp('빨간색 검출! 우회전!');
                        turn(droneObj, deg2rad(90));                       % Turn right, 다음동작 크로마키 검출, 지난 링을 건드리지 않도록 일정거리 전진
                        moveforward(droneObj, 'distance', 1.2);
                        right_cnt = 0;
                        left_cnt = 0;
                        up_cnt = 0;
                        down_cnt = 0;
                        activeForward = 1;
                        loopBreak = 1;
                        break;
                        
                    elseif(sum(bw_green, "all")>500)
                        disp('초록색 검출! 각도 변경!')
                        turn(droneObj, deg2rad(90));
                        moveforward(droneObj, 'distance', 1.2);
                        turn(droneObj, deg2rad(45));
                        right_cnt = 0;
                        left_cnt = 0;
                        up_cnt = 0;
                        down_cnt = 0;
                        activeForward = 1;
                        loopBreak = 1;
                        break;

                    elseif (sum(bw_purple, 'all') > 1000)                          % 보라색이 검출되면
                        disp('보라색 검출! 착지!');
                        land(droneObj);                                     % Landing
                        return; 
                        
                    else
                        disp('표식 없음. 표식 찾아 드론 이동');
                        if down_cnt < 1
                            down_cnt = down_cnt + 1;
                            movedown(droneObj, 'distance', 0.2);
                            continue;
                        elseif up_cnt < 1
                            up_cnt = up_cnt + 1;
                            moveup(droneObj, 'distance', 0.4);
                            continue;
                        elseif left_cnt < 1
                            left_cnt = left_cnt + 1;
                            moveleft(droneObj, 'distance', 0.2);
                            continue;
                        elseif right_cnt < 1
                            right_cnt = right_cnt + 1;
                            moveright(droneObj, 'distance', 0.4);
                            continue;
                        else
                            moveup(droneObj, 'distance', 0.2);
                            right_cnt = 0;
                            left_cnt = 0;
                            up_cnt = 0;
                            down_cnt = 0;
                        end
                    end
                end

                if loopBreak == 1
                    loopBreak = 0;
                    continue
                end
                

            elseif (bw2_pix_num < 110000)
                disp('원에 조금씩 접근중');
                moveforward(droneObj, 'distance', 0.3);             % 맵에 따라서 1m단위로 링을 배치한다면 0.5, 아니라면 0.2 or 0.25
            end      
            
        elseif moveRow < -100
            disp('좌표 일치화 진행중, MoveUp');
            moveup(droneObj, 'Distance', 0.2)
        elseif 100 < moveRow
            disp('좌표 일치화 진행중, MoveDown');
            movedown(droneObj, 'Distance', 0.2)
        elseif moveCol < -100
            disp('좌표 일치화 진행중, MoveLeft');
            moveleft(droneObj, 'Distance', 0.2)
        elseif 100 < moveCol
            disp('좌표 일치화 진행중, MoveRight');
            moveright(droneObj, 'Distance', 0.2)
        end

        disp('원 검출 완료');
        %{
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        %}
        clear center_col;
        clear center_row;
   catch exception
        disp('원 검출 안됨 예외발생.');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame);
        subplot(2, 2, 3), imshow(bw1);
    end
    pause(1);
    
end