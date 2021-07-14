clear;

global min_h;   global max_h;
global min_s;   global max_s;
min_h = 0.55;  max_h = 0.62;
min_s = 0.52;  max_s = 0.85;

stage = 1;

dist_cal = 0;

is_ring_detect = 0;
move_left = 0;

is_fin = 0;

is_circle = 0;
is_center = 0;

stage_pass = 0;

mark_color = 0;

dist_1 = 0;
dist_2 = 0;
dist_3 = 0;

remain_dist = 0;

droneObj = ryze();

takeoff(droneObj);
Move(droneObj, 0.3, 'up');

cameraObj = camera(droneObj);
preview(cameraObj);

while 1
    is_circle = 0;
    
    [hall_frame, x, y, col] = detect_ring(cameraObj);

    imshow(hall_frame);
    
    if x == 0 || y == 0
        if stage == 1
            continue;
        else
            is_ring_detect = is_ring_detect + 1
            if is_ring_detect == 10
                if move_left == 0
                    Move(droneObj, 1, 'left');
                    move_left = 1;
                    is_ring_detect = 0;
                    continue;
                else
                    Move(droneObj, 2, 'right');
                end
            end
            continue;
        end
    end
    
    if is_center == 0
        is_center = detect_center(droneObj, x, y);
        continue;
    end
    
    if ~isempty(x)
        tmp = unique(col);
        rad = nnz(tmp);
    end
    
    [dist_1, dist_2, dist_3, flag] = dist_meas(stage, rad, dist_1, dist_2, dist_3);
    
    if flag == 0
        continue;
    end
    
    if dist_1 ~= 5 && dist_2 ~= 5 && dist_3 ~= 5
        continue;
    end
    
    if dist_1 == 5
        remain_dist = 1
        dist_1 = 0;
    elseif dist_2 == 5
        remain_dist = 2
        dist_2 = 0;
    else
        remain_dist = 3
        dist_3 = 0;
    end
    
    
    if remain_dist == 3
        Move(droneObj, 3.15 - dist_cal, 'forward');
        stage_pass = 1;
    elseif remain_dist == 2
        Move(droneObj, 2.15 - dist_cal, 'forward');
        stage_pass = 1;
    elseif remain_dist == 1
        Move(droneObj, 1.15 - dist_cal, 'forward');
        stage_pass = 1;
    end
    
    
    while mark_color ~= 1 && mark_color ~= 2
        if stage_pass == 1
            [mark_color, is_fin] = detect_mark(cameraObj, droneObj, stage);
        end
    end
    
    stage = stage + 1
    if stage ~= 1
        dist_cal = 0.25
    end
    
    is_center = 0;
    
    stage_pass = 0;
    mark_color = 0;
    
    flag = 0;
    
    if is_fin == 1
        break;
    end
end


function rtn = Move(droneObj, dist, dir)
    if dir == "forward"
        moveforward(droneObj, 'Distance', dist);
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
    turn(droneObj, deg2rad(ang));
    pause(0.5);
    rtn = "";
end


function [hall_frame, x, y, col] = detect_ring(cameraObj)
    global min_h;    global max_h;
    global min_s;    global max_s;

    [frame, ts] = snapshot(cameraObj);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);

    detect_blue = (min_h < h) & (h < max_h);
    detect_blue_s = (min_s < s) & (s <= max_s);
    detect_blue = detect_blue & detect_blue_s;

    bw = bwareaopen(detect_blue, 5000);

    se = strel('line', 30, 0);
    bw = imdilate(bw, se);
    [width, height] = size(bw);

    bw(:, 1) = 1;
    if bw == 1
        hall_frame = 0;
        return;
    end
    bw(:, width) = 1;
    bw(1, :) = 1;

    bw2 = imfill(bw, 'holes');
    bw3 = bw2 - bw;
    
    hall_frame = bw3;
    hall_frame = bwareaopen(hall_frame, 5000);
    hall_frame = imfill(hall_frame, 'holes');
    hall_frame = bwareaopen(hall_frame, 5000);

    [row, col] = find(hall_frame);
    row = sort(row);
    col = sort(col);
    
    y = int16(median(row));
    x = int16(median(col));
    
    imshow(hall_frame);
end


function is_center = detect_center(droneObj, x, y)
    if ((x >= 450) && (x <= 550)) && ((y >= 130) && (y <= 200))
        is_center = 1;
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
        
        is_center = 0;
    end
end


function [dist_1, dist_2, dist_3, flag] = dist_meas(stage, rad, dist_1, dist_2, dist_3)
    flag = 1;
    
    if stage == 1
        rad_1 = 500;
        rad_2 = 330;
        rad_3 = 200;
    elseif stage == 2
        rad_1 = 456;
        rad_2 = 281;
        rad_3 = 150;
    else
        rad_1 = 398;
        rad_2 = 200;
        rad_3 = 50;
    end

    if rad > rad_1
        dist_1 = dist_1 + 1;
    elseif rad <= rad_1 && rad >= rad_2
        dist_2 = dist_2 + 1;
    elseif rad < rad_2 && rad > rad_3
        dist_3 = dist_3 + 1;
    else
        flag = 0;
    end
end


function [mark_color, is_fin] = detect_mark(cameraObj, droneObj, stage)
    [frame, ts] = snapshot(cameraObj);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);

    detect_red = (0 <= h) & (h < 0.05) | (h <= 1) & (h > 0.95);
    detect_red_s = (0.6 < s) & (s <= 1);
    detect_red = detect_red & detect_red_s;
    red = bwareaopen(detect_red, 700);

    detect_purple = (h > 0.74) & (h < 0.81);
    detect_purple_s = (0.60 < s) & (s < 0.80);    % 0.50 ~ 0.60
    detect_purple = detect_purple & detect_purple_s;
    purple = bwareaopen(detect_purple, 700);

    if nnz(red) < 50 && nnz(purple) < 50
       if stage == 1 || stage == 2
           mark_color = 1;
           Rotate(droneObj, -90);
           Move(droneObj, 1.2, 'forward');
           is_fin = 0;
       else
           mark_color = 2;
           land(droneObj);
           is_fin = 1;
       end
    elseif nnz(red) > nnz(purple)
       mark_color = 1;
       Rotate(droneObj, -90);
       Move(droneObj, 1.2, 'forward');
       is_fin = 0;
    else
       mark_color = 2;
       land(droneObj);
       is_fin = 1;
    end
end