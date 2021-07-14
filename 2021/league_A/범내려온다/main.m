clear;
drone=ryze();
cam=camera(drone);

idealX = 480;
idealY = 200;
past_red = 0;
current_red = 0;
move = 0;
a=0;
b=0;

preview(cam);

%1 level
disp("1 level");
takeoff(drone);
moveup(drone,'Distance', 0.3,'Speed',1);
moveforward(drone,'Distance', 1.5,'Speed',1);

%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.95<h)&(h<1.0))&((0.645<s)&(s<0.925));
    subplot(2,1,1), subimage(binary_res_red);
    disp(sum(binary_res_red,'all'));
    if sum(binary_res_red,'all') > 50 && sum(binary_res_red,'all') < 1000
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        disp(centerX);
        disp(centerY);
        if abs(idealX - centerX) < 40
            a=1;
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.2,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.3,'Speed',1);
        end
        if abs(idealY - centerY) < 30
            b=1;
        elseif idealY - centerY < 0 && b == 0
            movedown(drone,'distance',0.2,'Speed',1);
        elseif idealY - centerY > 0 && b == 0
            moveup(drone,'distance',0.3,'Speed',1);
        end
        if a==0 || b == 0
            continue
        end
    end

    past_red = current_red;
    current_red = sum(binary_res_red, 'all');
    if past_red > 0 & past_red - 50 > current_red 
        turn(drone, deg2rad(-90));
        break
    end
    if current_red >= 3000
        turn(drone, deg2rad(-90));
        break
    end
    
    moveforward(drone,'Distance', 0.4,'Speed',1);
end
%1단계 완료

%2단계
disp("2 level");
past_red = 0;
current_red = 0;
a=0;
b=0;
move = 0;

moveforward(drone,'Distance', 1,'Speed',1);
moveup(drone,'Distance',0.8,'Speed',1);
moveright(drone,'Distance',1.5,'Speed',1);
%링이 안보일 때 (링이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    subplot(2,1,2), subimage(binary_res);
    disp(sum(binary_res,'all'));
    fillimg = imfill(binary_res,'holes');
    %링 찾으면 탈출
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveleft(drone,'Distance',1.5,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'distance',1.5,'speed',1);
        move = 2;
    elseif move == 2
        moveright(drone,'Distance',3,'Speed',1);
        movedown(drone,'distance',0.5,'Speed',1);
        move = 0;
    end
end
%링은 보이지만 구멍이 안보일 때(구멍이 보이거나, 표식이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    binary_res_red = ((0.95<h)&(h<1.0))&((0.645<s)&(s<0.925));
    subplot(2,1,2), subimage(binary_res);
    
    %표식이 보이면 탈출
    if sum(binary_res_red,'all') > 50
        break
    end
    
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    disp(sum(result,'all'));
    %구멍이 보이면 탈출
    if sum(result,'all') > 20000
        break
    elseif sum(result,'all') < 20000
        stats = regionprops('table',binary_res,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        
        if abs(idealX - centerX) < 40
            a=1;
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.5,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.4,'Speed',1);
        end
        if abs(idealY - centerY) < 20
            b=1;
        elseif idealY - centerY < 0
            b=0;
            movedown(drone,'distance',0.3,'Speed',1);
        elseif idealY - centerY > 0
            b=0;
            moveup(drone,'distance',0.4,'Speed',1);
        end
        if a==1 && b==1
            break
        end
    end
end
%구멍의 중심 계산 후 제어(중심에 맞거나, 표식이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    binary_res_red = ((0.95<h)&(h<1.0))&((0.645<s)&(s<0.925));
    
    %표식이 보이면 탈출
    if sum(binary_res_red,'all') > 50
        break
    end
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res; 
    subplot(2,1,1), subimage(result);
    subplot(2,1,2), subimage(binary_res);
    stats = regionprops('table',result,'Centroid','MajorAxisLength','MinorAxisLength');
    for i = 1:size(stats)
        if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
            maxI=i;
            break;
        end
    end
    centerX = max(stats.Centroid(maxI,1));
    centerY = max(stats.Centroid(maxI,2));
    
    if abs(idealX - centerX) < 40
        a=1;
    elseif idealX - centerX < 0
        a=0;
        moveright(drone,'distance',0.3,'Speed',1);
    elseif idealX - centerX > 0
        a=0;
        moveleft(drone,'distance',0.2,'Speed',1);
    end
    if abs(idealY - centerY) < 20
        b=1;
    elseif idealY - centerY < 0
        b=0;
        movedown(drone,'distance',0.2,'Speed',1);
    elseif idealY - centerY > 0
        b=0;
        moveup(drone,'distance',0.3,'Speed',1);
    end
    
    if a==1 && b==1
        break
    end
end
%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.95<h)&(h<1.0))&((0.645<s)&(s<0.925));
    subplot(2,1,1), subimage(binary_res_red);
    disp(sum(binary_res_red,'all'));
    if sum(binary_res_red,'all') > 50 && sum(binary_res_red,'all') < 1000
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        disp(centerX);
        disp(centerY);
        if abs(idealX - centerX) < 40
            a=1;
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.2,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.3,'Speed',1);
        end
        if abs(idealY - centerY) < 20
            b=1;
        elseif idealY - centerY < 0 && b == 0
            movedown(drone,'distance',0.2,'Speed',1);
        elseif idealY - centerY > 0 && b == 0
            moveup(drone,'distance',0.3,'Speed',1);
        end
        if a==0 || b == 0
            continue
        end
    end

    past_red = current_red;
    current_red = sum(binary_res_red, 'all');
    if past_red > 0 & past_red - 50 > current_red 
        turn(drone, deg2rad(-90));
        break
    end
    if current_red >= 3000
        turn(drone, deg2rad(-90));
        break
    end
    
    moveforward(drone,'Distance', 0.4,'Speed',1);
end
%2단계 끝

%3단계 시작
disp("3 level");
past_red = 0;
current_red = 0;
a=0;
b=0;
move = 0;

moveforward(drone,'Distance', 1.2,'Speed',1);
if readHeight(drone) < 1
    moveup(drone,'Distance',1,'Speed',1);
end

%링이 안보일 때 (링이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    subplot(2,1,2), subimage(binary_res);
    disp(sum(binary_res,'all'));
    fillimg = imfill(binary_res,'holes');
    %링 찾으면 탈출
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveleft(drone,'Distance',1.5,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'distance',1.5,'speed',1);
        move = 2;
    elseif move == 2
        moveright(drone,'Distance',3,'Speed',1);
        movedown(drone,'distance',0.5,'Speed',1);
        move = 0;
    end
end
%링은 보이지만 구멍이 안보일 때(구멍이 보이거나, 표식이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    binary_res_red = ((0.835<h)&(h<0.915))&((0.435<s)&(s<0.725));
    subplot(2,1,2), subimage(binary_res);
    
    %표식이 보이면 탈출
    if sum(binary_res_red,'all') > 50
        break
    end
    
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    disp(sum(result,'all'));
    %구멍이 보이면 탈출
    if sum(result,'all') > 20000
        break
    elseif sum(result,'all') < 20000
        stats = regionprops('table',binary_res,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        
        if abs(idealX - centerX) < 40
            a=1;
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.5,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.4,'Speed',1);
        end
        if abs(idealY - centerY) < 20
            b=1;
        elseif idealY - centerY < 0
            b=0;
            movedown(drone,'distance',0.3,'Speed',1);
        elseif idealY - centerY > 0
            b=0;
            moveup(drone,'distance',0.4,'Speed',1);
        end
        if a==1 && b==1
            break
        end
    end
end
%구멍의 중심 계산 후 제어(중심에 맞거나, 표식이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.615<h)&(h<0.685))&((0.43<s)&(s<0.85));
    binary_res_red = ((0.835<h)&(h<0.915))&((0.435<s)&(s<0.725));
    
    %표식이 보이면 탈출
    if sum(binary_res_red,'all') > 50
        break
    end
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res; 
    subplot(2,1,1), subimage(result);
    subplot(2,1,2), subimage(binary_res);
    stats = regionprops('table',result,'Centroid','MajorAxisLength','MinorAxisLength');
    for i = 1:size(stats)
        if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
            maxI=i;
            break;
        end
    end
    centerX = max(stats.Centroid(maxI,1));
    centerY = max(stats.Centroid(maxI,2));
    
    if abs(idealX - centerX) < 40
        a=1;
    elseif idealX - centerX < 0
        a=0;
        moveright(drone,'distance',0.3,'Speed',1);
    elseif idealX - centerX > 0
        a=0;
        moveleft(drone,'distance',0.2,'Speed',1);
    end
    if abs(idealY - centerY) < 20
        b=1;
    elseif idealY - centerY < 0
        b=0;
        movedown(drone,'distance',0.2,'Speed',1);
    elseif idealY - centerY > 0
        b=0;
        moveup(drone,'distance',0.3,'Speed',1);
    end
    
    if a==1 && b==1
        break
    end
end
%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.835<h)&(h<0.915))&((0.435<s)&(s<0.725));
    subplot(2,1,1), subimage(binary_res_red);
    disp(sum(binary_res_red,'all'));
    if sum(binary_res_red,'all') > 50 && sum(binary_res_red,'all') < 1000
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        centerX = max(stats.Centroid(maxI,1));
        centerY = max(stats.Centroid(maxI,2));
        disp(centerX);
        disp(centerY);
        if abs(idealX - centerX) < 40
            a=1;
        elseif idealX - centerX < 0
            a=0;
            moveright(drone,'distance',0.2,'Speed',1);
        elseif idealX - centerX > 0
            a=0;
            moveleft(drone,'distance',0.3,'Speed',1);
        end
        if abs(idealY - centerY) < 20
            b=1;
        elseif idealY - centerY < 0 && b == 0
            movedown(drone,'distance',0.2,'Speed',1);
        elseif idealY - centerY > 0 && b == 0
            moveup(drone,'distance',0.3,'Speed',1);
        end
        if a==0 || b == 0
            continue
        end
    end

    past_red = current_red;
    current_red = sum(binary_res_red, 'all');
    if past_red > 0 & past_red - 50 > current_red 
        land(drone);
        break
    end
    if current_red >= 3000
        land(drone);
        break
    end
    
    moveforward(drone,'Distance', 0.4,'Speed',1);
end
