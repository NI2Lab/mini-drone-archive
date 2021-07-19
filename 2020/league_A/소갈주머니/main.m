droneObj = ryze()
stage = 0;
% h 임계값 설정
global min_h;   global max_h;
min_h = 0.225;  max_h = 0.405;
global dist_to_cir;
dist_to_cir = 2.45;
global move_dist;
move_dist = 0;

takeoff(droneObj);
Move(droneObj, 0.3, "up");

cameraObj = camera(droneObj);
preview(cameraObj);

[frame,ts] = snapshot(cameraObj);
[hall_frame, x, y] = loc_recog(frame);

while 1
    [frame,ts] = snapshot(cameraObj);
    [hall_frame, x, y] = loc_recog(frame);
    
    if isnan(x) || isnan(y) || x-5 < 0 || y-5 < 0
        continue;
    end
    
    if ((x >= 450) && (x <= 550)) && ((y >= 110) && (y <= 190))
        dist = dist_to_cir - move_dist;
        Move(droneObj, dist, "forward");
        stage = stage + 1;
        move_dist = 0;
        dist_to_cir = 3.2;
        force_cir_noncheck = 0;
        cir_error_cnt = 0;
        while 1
            if force_cir_noncheck == 0
                cir_num = Cir_Check(cameraObj);
            else
                force_cir_noncheck = 0;
            end
            if stage == 3 && cir_num == 2     % 파란 원
                land(droneObj);
                return;     % 종료
            elseif stage < 3 && cir_num == 1 % 빨간 원
                Rotate(droneObj, -90);
                
                [frame,ts] = snapshot(cameraObj);
                [hall_frame, x, y] = loc_recog(frame);
                
                % 링이 너무 높아 화면에 안나올 경우
                if isnan(x) || isnan(y) || x-5 < 0 || y-5 < 0
                    Move(droneObj, 0.4, "up");
                    
                    [frame,ts] = snapshot(cameraObj);
                    [hall_frame, x, y] = loc_recog(frame);                                    
                    
                    if isnan(x) || isnan(y) || x-5 < 0 || y-5 < 0
                        Move(droneObj, 0.7, "down");
                        break;
                    end
                end
                
                % 링 통과 후 90도 회전하고 드론 위치 설정
                if x < 500 && y < 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "left");
                    Move(droneObj, 0.3, "up");
                    break;
                elseif x < 500 && y > 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "left");
                    Move(droneObj, 0.3, "down");
                    break;
                elseif x > 500 && y < 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "right");
                    Move(droneObj, 0.3, "up");
                    break;
                elseif x > 500 && y > 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "right");
                    Move(droneObj, 0.3, "down");
                    break;
                end
                
            % 원이 안보일때
            elseif cir_num == 3
                loop_cnt = 0;
                while force_cir_noncheck == 0
                   loop_cnt = loop_cnt+1;
                   
                   %좌우 회전 후 없으면
                   Rotate(droneObj, 20);
                   cir_num = Cir_Check(cameraObj);
                   if loop_cnt > 1
                       if stage == 3
                           cir_num = 2;
                       elseif stage < 3
                           cir_num = 1;
                       end
                   end
                   if cir_num ~= 3
                       force_cir_noncheck = 1;
                   end
                   Rotate(droneObj, -20);       %원위치
                   
                   if force_cir_noncheck == 0
                       Rotate(droneObj, -20);
                       cir_num = Cir_Check(cameraObj);
                       if cir_num ~= 3
                           force_cir_noncheck = 1;
                       end
                       Rotate(droneObj, 20);    %원위치
                   end
                   if force_cir_noncheck == 0
                       Move(droneObj, 0.2, "up");
                       cir_num = Cir_Check(cameraObj);
                       if cir_num ~= 3
                           force_cir_noncheck = 1;
                       end
                   end
                end
            
            else
                cir_error_cnt = cir_error_cnt + 1;
                if cir_error_cnt >= 2
                    force_cir_noncheck = 1;
                    if stage == 3
                        cir_num = 2;
                    elseif stage < 3
                        cir_num = 1;
                    end
                end
            end %elseif num=3 end                    
        end     %while end
        if stage >= 3
            stage = 2;
        end
    else
        x_diff = x - 500;
        y_diff = y - 150;
        
        if y_diff > 150
            Move(droneObj, 0.4, "down");
        elseif y_diff > 30
            Move(droneObj, 0.2, "down");
        elseif y_diff < -150
            Move(droneObj, 0.4, "up");
        elseif y_diff < -30
            Move(droneObj, 0.2, "up");
        end
        
        if x_diff > 150
            Move(droneObj, 0.4, "right");
        elseif x_diff > 30
            Move(droneObj, 0.2, "right");
        elseif x_diff < -150
            Move(droneObj, 0.4, "left");
        elseif x_diff < -30
            Move(droneObj, 0.2, "left");
        end
    end
end

function [hall_frame, x, y] = loc_recog(frame)
    global min_h;
    global max_h;
    
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_green = (min_h < h) & (h < max_h);
    
    % 픽셀수가 일정 개수보다 적은 연결성분 제거
    bw = bwareaopen(detect_green, 1000);
    
    %침식
    se = strel('line', 20, 0);
    bw = imerode(bw,se);
    
    % 팽창
    bw = imdilate(bw, se);
    [width, height] = size(bw);
    
    bw(:, 1) = 1;
    bw(:, width) = 1;
    bw(1, :) = 1;
    
    bw2 = imfill(bw, 'holes');
    
    bw3 = bw2 - bw;
    hall_frame = bw3;

    [row, col] = find(bw3);
    row = sort(row);
    col = sort(col);
    y = int16(median(row));
    x = int16(median(col));
end

function rtn = Move(droneObj, dist, dir)
    % 입력되는 방향에 따라 드론을 이동
    global move_dist;
    if dir == "forward"
        moveforward(droneObj, 'Distance', dist);
        move_dist = move_dist + dist;
    elseif dir == "back"
        moveback(droneObj, 'Distance', dist);
    elseif dir == "right"
        moveright(droneObj, 'Distance', dist);
    elseif dir == "left"
        moveleft(droneObj, 'Distance', dist);
    elseif dir == "up"
        moveup(droneObj, 'Distance', dist);
    elseif dir == "down"
        movedown(droneObj, 'Distance', dist);
    end
    pause(0.5);
    rtn = "";
end

function rtn = Rotate(droneObj,ang)
    % 입력 받은 각도만큼 드론을 회전
    turn(droneObj, deg2rad(ang));
    pause(0.5);
    rtn = "";
end

function cir_num = Cir_Check(cameraObj)
    [frame,ts] = snapshot(cameraObj);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    detect_red = (0 <= h) &(h < 0.05) | (h <= 1) & (h > 0.95);
    detect_red_s = (0.6 < s) & (s <= 1);
    detect_red = detect_red & detect_red_s;

    detect_blue = (h > 0.5) & (h < 0.6);
    detect_blue_s = (0.6 < s) & (s <= 1);
    detect_blue = detect_blue & detect_blue_s;
    if nnz(detect_red) > 50
        cir_num = 1; % red
    elseif nnz(detect_blue) > 50
        cir_num = 2; % blue
    else
        cir_num = 3; % 원 인식 못할 때 (벽과 너무 가깝거나 다른 위치일 때)
    end
end
