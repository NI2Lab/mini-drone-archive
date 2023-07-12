clear;

drone=ryze("Tello")
takeoff(drone)

moveup(drone, "Distance",0.5)
pause(0.5)
moveback(drone, "Distance",0.3)
cam = camera(drone);

x = 0;
y = 0;

stage_nnz = [180000, 150000, 130000, 100000]
i = 1

%%%%%%%%%%%% 링 통과 %%%%%%%%%%%%
while 1
    hall_frame=detect_ring(cam);
    [x, y] = detect_center(hall_frame)

    while Move(drone,x,y)
        pause(0.1);
        hall_frame=detect_ring(cam);
        [x, y] = detect_center(hall_frame);
    end
    
    while 1
        hall_frame=detect_ring(cam);
        if nnz(hall_frame) > stage_nnz(i)
    
            %%%%%%%%%%%%% 색 탐지 %%%%%%%%%%%%%%
            [img,ts] = snapshot(cam);
            if detect_col(img) == 1 %% 빨강
                moveforward(drone, "Distance", 1.8, "Speed",1);
                pause(1);
                turn(drone, deg2rad(90));
                break;
            elseif detect_col(img) == 2  %% 초록
                moveforward(drone, "Distance", 1.8, "Speed",1);
                pause(1);
                turn(drone, deg2rad(60));
                hall_frame=detect_ring(cam);
                [x, y] = detect_center(hall_frame);
                while angle(drone, x)
                    pause(0.1);
                    hall_frame=detect_ring(cam);
                    [x, y] = detect_center(hall_frame);
                end
                break;
            elseif detect_col(img) == 3  %% 보라
                land(drone)
                clear drone
                return
            end
        else
            [x, y] = detect_center(hall_frame); %시간확인용
            Move(drone,x,y);
            moveforward(drone, "Distance", 0.2, "Speed",0.7); 
        end
    end
    i = i+1;

end

function hall_frame = detect_ring(cam)
    
    [img,ts] = snapshot(cam);

    th_down = 0.5;    % 파란색의 최소 임계값
    th_up = 0.7;      % 파란색의 최대 임계값
    
    hsv_img = rgb2hsv(img);     % hsv로 바꾸기
    h = hsv_img(:,:,1);         % h만 따로 뽑기
    
    detect = (th_down < h)&(th_up> h); %초록색 부분 찾기
    bw = bwareaopen(detect, 5000);
    
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
end

function [x, y] = detect_center(hall_frame)
    [row, col] = find(hall_frame);
    row = sort(row);
    col = sort(col);
    
    y = int16(median(row));
    x = int16(median(col));
end

function rtn = Move(drone,x,y)
    x_center = 640;
    y_center = 230;
    x_dist = abs(x-x_center)/1280;
    y_dist = abs(y-y_center)/720;
    spare = 90;
    if x_dist < 0.2
        x_dist = 0.2;
         
    end
    if y_dist < 0.2
        y_dist = 0.2;
         
    end
    if (((y >= y_center-spare) && (y <= y_center+spare)) && ((x >= x_center-spare) && (x <= x_center+spare))) %중앙
        rtn = 0;
    else
        if     x > x_center+spare
              moveright(drone,'Distance', x_dist);
        elseif x < x_center-spare
              moveleft(drone,'Distance', x_dist);
        end
        if     y < y_center-spare
              moveup(drone,'Distance',y_dist);
        elseif y > y_center+spare
              movedown(drone,'Distance',y_dist);
        end
        rtn = 1;
    end
    
    
end

function rtn = abs(num)
    if(num>=0)
        rtn = num;
    else
        rtn = -num;
    end
end

function color = detect_col(img)
    hsv_img = rgb2hsv(img);     % hsv로 바꾸기
    h = hsv_img(:,:,1);         % h만 따로 뽑
    s = hsv_img(:,:,2);

    detect_r = (0.9 <= h)|(0.03> h);
    detect_red_s = (0.55 < s) & (s <= 1);
    detect_red = detect_r & detect_red_s;
    detect_red = bwareaopen(detect_red, 300);
    nnz_r = nnz(detect_red);

    detect_g = (0.25 < h)&(0.4> h);
    detect_green_s = (0.2 < s) & (s <= 0.6);
    detect_green = detect_g & detect_green_s;
    detect_green = bwareaopen(detect_green, 300);
    nnz_g = nnz(detect_green);
    
    detect_p = (0.7 < h)&(0.82> h);
    detect_purple_s = (0.11 < s) & (s < 1);
    detect_purple = detect_p & detect_purple_s;
    detect_purple = bwareaopen(detect_purple, 300);
    nnz_p = nnz(detect_purple);

    if (nnz_r > nnz_g)
        if(nnz_r > nnz_p)
            color = 1;
        else
            color = 3;
        end
    else
        if(nnz_g > nnz_p)
            color = 2;
        else
            color = 3;
        end
    end
end

function an = angle(drone, x)
    if (x>=450) & (x<=510)
        an = 0;
    elseif (x<450)
        turn(drone, deg2rad(-5));
        an = 1;
    elseif (x>510)
        turn(drone, deg2rad(5));
        an = 1;
    end
end
