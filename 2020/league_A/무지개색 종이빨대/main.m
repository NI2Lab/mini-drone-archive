% 드론 객체 생성
droneObj = ryze()
cam = camera(droneObj);

% 이륙 & 높이 맞추기 위해 상승
takeoff(droneObj);
moveup(droneObj, 'Distance', 0.6);

preview(cam);
% 이미지 캡쳐하여 중앙 좌표 계산
img = snapshot(cam);

img_size = size(img);
img_mid = [img_size(1)/2, img_size(2)/2];

% page1 - first square through
while 1
    hole_mid = FindHoleMid(img);
    
    disp(img_mid);
    disp(hole_mid);
    disp("===========================================");
    % 2m거리에서 green 픽셀 수 13~14만
    
%     hsv = rgb2hsv(img);
%     h = hsv(:, :, 1);
%     detect_green = (0.25 < h) & (h < 0.355);
%     
%     sum_g = sum(detect_green, 'all');
%     disp(sum_g);
%     disp("===========================================");
    % green 픽셀 수로 전후 거리 조절
%      if sum_g > 145000
%          moveback(droneObj, 'Distance', 0.2);
%      elseif sum_g < 125000
%          moveforward(droneObj, 'Distance', 0.2);
%      end

    if img_mid(2) - hole_mid(2) > 50
        moveleft(droneObj, 'Distance', 0.2);
    elseif img_mid(2) - hole_mid(2) < -50
        moveright(droneObj, 'Distance', 0.2);
    elseif img_mid(1) - hole_mid(1) > 35
        moveup(droneObj, 'Distance', 0.2);
    elseif img_mid(1) - hole_mid(1) < -35
        movedown(droneObj, 'Distance', 0.2);
    else
        movedown(droneObj, 'Distance', 0.5);
        moveforward(droneObj, 'Distance', 2.5, 'Speed', 0.6); %첫번째 앞으로 이동 2.5미터
        pause(1);
        break;
    end

    img = snapshot(cam);
end

% page2 - first turn red dot
turn(droneObj, deg2rad(-90));
pause(1);
moveforward(droneObj, 'Distance', 1); %두번째 앞으로 이동 1미터


% page3 - second square through
while 1
    img = snapshot(cam);
    hole_mid = FindHoleMid(img);
    
    disp(img_mid);
    disp(hole_mid);
    disp("===========================================");
    
    if isnan(hole_mid)
        median = GreenTracking(img);
        row_median = median(1);
        col_median = median(2);
        
        if img_mid(2) - col_median > 35
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - col_median < -35
            moveright(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median > 35
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median < -35
            movedown(droneObj, 'Distance', 0.2);
        else
            movedown(droneObj, 'Distance', 0.4);
            moveforward(droneObj, 'Distance', 2.0);
            break;
        end
    else
        if img_mid(2) - hole_mid(2) > 35
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - hole_mid(2) < -35
            moveright(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - hole_mid(1) > 35
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - hole_mid(1) < -35
            movedown(droneObj, 'Distance', 0.2);
        else
            movedown(droneObj, 'Distance', 0.4);
            moveforward(droneObj, 'Distance', 2); % 두번째 앞으로 이동 1미터 + 2미터 = 3미터
            break;
        end
    end
end


% page4 - second red dot detect
turn(droneObj, deg2rad(-90));
pause(1);
moveforward(droneObj, 'Distance', 1); %세번째 앞으로 이동 1미터

[height, time] = readHeight(droneObj)
        
if height >= 0.8
    movedown(droneObj, 'Distance', 0.4);
else
    moveup(droneObj, 'Distance', 0.6);
end
    

pause(1);
moveleft(droneObj, 'Distance', 0.9);
flag1 = 0;

% page5 - search green color
while 1 
    img = snapshot(cam);
    pause(1);
    
    hsv = rgb2hsv(img);
    h = hsv(:,:,1);
    detect_green = (0.25 < h) & (h < 0.355);
    disp(sum(detect_green, 'all'));
    disp("===========================================");
    
    if sum(detect_green, 'all') >= 40000
        % green color detected
        break;
    else
        % right 카운트 //
        % if flag1 > 5 // 대회 때 사용 코드
        if flag1 > 5
            moveup(droneObj, 'Distance', 0.5); 
            moveleft(droneObj, 'Distance', 1.8);
            flag1 = 0;
        else
            moveright(droneObj, 'Distance', 0.3);
            flag1 = flag1 + 1;
        end
    end 
end

% page6 - last square through
while 1
    img = snapshot(cam);
    
    hole_mid = FindHoleMid(img);
    
    disp(img_mid);
    disp(hole_mid);
    disp("===========================================");
    
    if isnan(hole_mid)
        median = GreenTracking(img);
        row_median = median(1);
        col_median = median(2);
        
        if img_mid(2) - col_median > 35
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - col_median < -35
            moveright(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median > 35
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median < -35
            movedown(droneObj, 'Distance', 0.2);
        else
            movedown(droneObj, 'Distance', 0.4);
            moveforward(droneObj, 'Distance', 2.0);
            break;
        end
    else
        if img_mid(2) - hole_mid(2) > 35
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - hole_mid(2) < -35
            moveright(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - hole_mid(1) > 35
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - hole_mid(1) < -35
            movedown(droneObj, 'Distance', 0.2);
        else
            movedown(droneObj, 'Distance', 0.4);
            moveforward(droneObj, 'Distance', 2); %세번째 앞으로 이동 1미터 + 2미터 = 3미터
            break;
        end
    end
end

% page7 - blue dot detect 
pause(1);
land(droneObj);


% function 1
function ans = FindHoleMid(img)
    %figure, imshow(img)
    hsv = rgb2hsv(img);
    h = hsv(:, :, 1);
    h(1,:) = 0.35;
    h(:,1) = 0.35;
    h(:, 960) = 0.35;
    
    %detect_green = (0.275 < h) & (h < 0.355);
    detect_green = (0.25 < h) & (h < 0.355);
    bw = detect_green;
    
    disp(sum(detect_green, 'all'));
    se = strel('line',11,90);
    bw = imdilate(bw,se);
    bw = imdilate(bw,se);
    bw = imerode(bw,se);
    bw = imerode(bw,se);
    
    bw = bwareaopen(detect_green, 1000);
    %figure, imshow(bw)
   
    bw2 = imfill(bw, 'holes');
    
    bw3 = bw2 - bw;
    %figure, imshow(bw2)
    
    bw4 = bwareaopen(bw3, 1000);
    imshow(bw4);
    [row, col] = find(bw4);
    
    row = unique(row);
    col = unique(col);

    row_size = size(row, 1);
    col_size = size(col, 1);
    
    row_median = sum(row)/row_size;
    col_median = sum(col)/col_size;
    
    ans = [round(row_median), round(col_median)];
end

% function 2
function ans = GreenTracking(img)
    hsv = rgb2hsv(img);
    h = hsv(:, :, 1);
    detect_green = (0.25 < h) & (h < 0.355);

    bw = detect_green;
    se = strel('line',11,90);
    bw = imdilate(bw,se);
    bw = imdilate(bw,se);
    bw = imerode(bw,se);
    bw = imerode(bw,se);
    bw = bwareaopen(detect_green, 1000);

    bw2 = imfill(bw, 'holes');

    [row, col] = find(bw2);

    row = unique(row);
    col = unique(col);

    row_size = size(row, 1);
    col_size = size(col, 1);

    row_median = round(sum(row)/row_size);
    col_median = round(sum(col)/col_size);
    
    ans = [row_median col_median];
end
