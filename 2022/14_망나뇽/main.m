drone=ryze()
cam=camera(drone);

idealX = 480;
idealY = 200;
past_red = 0;
current_red = 0;
move = 0;
a=0;
b=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1단계%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
takeoff(drone);
moveup(drone,'Distance', 0.3,'Speed',1);
moveforward(drone,'Distance', 1,'Speed',1);
%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res_red = ((0.35<h)&(h<0.415))&((0.267<s)&(s<0.996))&((0.176<v)&(v<0.51));
    past_red = current_red;
    current_red = sum(binary_res_red,'all');
    
    if past_red > 0 & past_red - 500 > current_red 
        turn(drone, deg2rad(90));
        break
    end
    if sum(binary_res_red,'all') >= 2200
        turn(drone, deg2rad(90));
        break
    end
    

    moveforward(drone,'Distance', 0.5,'Speed',1);
end
%1단계 완료

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%2단계%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
past_red = 0;
current_red = 0;
a=0;
b=0;
move = 0;

moveforward(drone,'Distance', 1.25,'Speed',1);
moveup(drone,'Distance', 0.5,'Speed',1);
moveright(drone,'Distance',0.7,'Speed',1);
%링이 안보일 때 (링이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.61<h)&(h<0.66))&((0.67<s)&(s<0.85));

    fillimg = imfill(binary_res,'holes');
    %링 찾으면 탈출
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveleft(drone,'Distance',1.5,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'Distance',2,'speed',1);
        move = 2;
    elseif move == 2
        movedown(drone,'Distance',0.3,'Speed',1);
        move = 3;
    elseif move == 3
        moveright(drone,'Distance',4,'Speed',1);
        move = 0;
    end
end
%링은 보이지만 구멍이 안보일 때(구멍이 보이거나, 표식이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res = ((0.61<h)&(h<0.66))&((0.67<s)&(s<0.85));
    binary_res_red = ((0.403<h)&(h<0.776))&((0.225<s)&(s<0.625))&((0.26<v)&(v<0.617));
    stats = regionprops('table',binary_res_red,'Area');
    %표식이 보이면 탈출
    for i = 1:size(stats)
        if stats.Area(i)==max(stats.Area)
            maxI=i;
            break;
        end
    end
    
    try
    if stats.Area(maxI) > 300
        break
    end
    catch error
    end
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
    if sum(binary_res,'all')> 500000
        moveup(drone,'distance',0.3,'speed',1);
        moveback(drone,'distance',0.5,'speed',1);
    end
        
    %구멍이 보이면 탈출
    if sum(result,'all') > 20000
        break
    elseif sum(result,'all') < 20000
        stats = regionprops('table',binary_res,'Centroid','MajorAxisLength');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        try
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
        catch error
            moveback(drone,'distance',0.5,'speed',1);
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
    v = hsv(:,:,3);
    binary_res = ((0.61<h)&(h<0.66))&((0.67<s)&(s<0.85));
    binary_res_red = ((0.403<h)&(h<0.776))&((0.225<s)&(s<0.625))&((0.26<v)&(v<0.617));
    stats = regionprops('table',binary_res_red,'Area');
    
    %표식이 보이면 탈출
    for i = 1:size(stats)
        if stats.Area(i)==max(stats.Area)
            maxI=i;
            break;
        end
    end
    try
    if stats.Area(maxI) > 300
        break
    end
    catch error
    end
    
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res; 
    if sum(result,'all') < 20000
        moveback(drone,'distance',0.5,'speed',1);
        continue
    end
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
        moveforward(drone,'distance',1,'speed',1);
        break
    end
end
%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    v = hsv(:,:,3);
    binary_res_red = ((0.403<h)&(h<0.776))&((0.225<s)&(s<0.625))&((0.26<v)&(v<0.617));
    past_red = current_red;
    current_red = sum(binary_res_red,'all');
    
    if past_red > 0 & past_red - 500 > current_red 
        turn(drone, deg2rad(90));
        break
    end

    if sum(binary_res_red,'all') >= 3000
        turn(drone, deg2rad(90));
        break
    end
    if sum(binary_res_red,'all') > 150
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength','Area');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        if stats.Area(maxI) > 150
            centerX = max(stats.Centroid(maxI,1));
            centerY = max(stats.Centroid(maxI,2));
            if abs(idealX - centerX) < 50
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
    end
     moveforward(drone,'Distance', 0.5,'Speed',1);
end
%2단계 끝

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%3단계%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
past_red = 0;
current_red = 0;
a=0;
b=0;
move = 0;

moveforward(drone,'Distance', 1,'Speed',1);
turn(drone, deg2rad(45));
% if readHeight(drone) < 1
%     moveup(drone,'Distance',1,'Speed',1);
% end

%링이 안보일 때 (링이 보이면 탈출)

%링이 안보일 때 (링이 보이면 탈출)
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res = ((0.61<h)&(h<0.66))&((0.67<s)&(s<0.85));

    fillimg = imfill(binary_res,'holes');
    %링 찾으면 탈출
    if sum(fillimg,'all') > 30000
        break
    end
    if move == 0
        moveright(drone,'Distance',1.5,'speed',1);
        move = 1;
    elseif move == 1
        moveleft(drone,'distance',3,'speed',1);
        move = 2;
    elseif move == 2
        moveright(drone,'Distance',1.5,'Speed',1);
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
    binary_res = ((0.61<h)&(h<0.66))&((0.67<s)&(s<0.85));
    binary_res_red = ((0.99<h)&(h<=1.000))&((0.795<s)&(s<1.000))|((0.000<=h)&(h<0.06))&((0.795<s)&(s<1.000));
    stats = regionprops('table',binary_res_red,'Area');
    if sum(binary_res,'all')> 500000
        moveback(drone,'distance',0.5,'speed',1);
    end
    %표식이 보이면 탈출
    for i = 1:size(stats)
        if stats.Area(i)==max(stats.Area)
            maxI=i;
            break;
        end
    end
    try
    if stats.Area(maxI) > 300
        break
    end
    catch error
    end
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res;
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
        try
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
            moveup(drone,'distance',0.5,'Speed',1);
        end
        catch error
            moveback(drone,'distance',0.5,'speed',1);
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
    binary_res = ((0.61<h)&(h<0.66))&((0.67<s)&(s<0.85));
    binary_res_red = ((0.99<h)&(h<=1.000))&((0.795<s)&(s<1.000))|((0.000<=h)&(h<0.06))&((0.795<s)&(s<1.000));
    stats = regionprops('table',binary_res_red,'Area');
    
    %표식이 보이면 탈출
    for i = 1:size(stats)
        if stats.Area(i)==max(stats.Area)
            maxI=i;
            break;
        end
    end
    try
    if stats.Area(maxI) > 300
        break
    end
    catch error
    end
    
    %이미지 채우기
    fillimg = imfill(binary_res,'holes');
    result = fillimg - binary_res; 
    if sum(result,'all') < 5000
        moveup(drone,'distance',0.3,'speed',1);
        moveback(drone,'distance',0.5,'speed',1);
        continue
    end
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
        moveforward(drone,'distance',1,'speed',1);
        break
    end
end
%표식 보이면 전진
while 1
    frame =snapshot(cam);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    binary_res_red = ((0.99<h)&(h<=1.000))&((0.795<s)&(s<1.000))|((0.000<=h)&(h<0.06))&((0.795<s)&(s<1.000));

    past_red = current_red;
    current_red = sum(binary_res_red,'all');
    
%     if past_red > 0 & past_red - 500 > current_red 
%         break
%     end

    if sum(binary_res_red,'all') >= 2800
        break
    end
    if sum(binary_res_red,'all') > 100
        stats = regionprops('table',binary_res_red,'Centroid','MajorAxisLength','MinorAxisLength','Area');
        for i = 1:size(stats)
            if stats.MajorAxisLength(i)==max(stats.MajorAxisLength)
                maxI=i;
                break;
            end
        end
        if stats.Area(maxI) > 100
            centerX = max(stats.Centroid(maxI,1));
            centerY = max(stats.Centroid(maxI,2));
            if abs(idealX - centerX) < 50
                a=1;
            elseif idealX - centerX < 0
                a=0;
                moveright(drone,'distance',0.2,'Speed',1);
            elseif idealX - centerX > 0
                a=0;
                moveleft(drone,'distance',0.25,'Speed',1);
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
    end
     moveforward(drone,'Distance',0.5,'Speed',1);
end
land(drone);
