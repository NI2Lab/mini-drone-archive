clc; clear;
drone = ryze();
cam = camera(drone);
takeoff(drone);     
%%
Level = 1
backCount = 0;
moveup(drone, 'Distance', 0.5, 'Speed', 1);
moveback(drone, 'Distance', 0.5, 'Speed', 1);
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 800
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);    
    ones = find(detectBlue);
    for i = 1: length(ones)
        ones_x(i) = fix(ones(i)/720);
        ones_y(i) = rem(ones(i),720) - 1;
        if ones_y(i) == -1
            ones_x(i) = ones_x(i) - 1;
            ones_y(i) = ones_y(i) + 721;
        end
        topleft(i) = ones_x(i)^2 + ones_y(i)^2; 
        bottomleft(i) = ones_x(i)^2 + (ones_y(i) - 720)^2; 
    end
    [~, topleftNum] = min(topleft.^1/2);
    [~, bottomleftNum] = min(bottomleft.^1/2);
    leftSide_x = (ones_x(bottomleftNum) + ones_x(topleftNum))/2;
    if leftSide_x > 300
        moveright(drone, 'Distance', 0.7);
        continue
    end

    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.2);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.2);
        end

    elseif boundaryNum == 2

        if ringProperty.MinorAxisLength/ringProperty.MajorAxisLength <= 0.6
            moveback(drone, 'Distance', 0.5);
            backCount = backCount + 1;
            continue
        end

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.78/ringDiameter; 
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end
        break

    else
   
        moveback(drone,'Distance', 0.5, 'Speed',1);
        backCount = backCount + 1;

    end
end
movedown(drone,'Distance', 0.4, 'Speed', 1);
moveforward(drone,'Distance', 3.0 + 0.5*backCount, 'Speed', 1);
turn(drone, deg2rad(90));
moveback(drone, 'Distance', 0.8, 'Speed', 1);
%%
Level = 2
backCount = 0;
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 800
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);    

    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.2);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.2);
        end

    elseif boundaryNum == 2

        if ringProperty.MinorAxisLength/ringProperty.MajorAxisLength <= 0.6
            moveleft(drone, 'Distance', 0.7);
            continue
        end

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.78/ringDiameter; %*
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end
        break

    else
   
        moveback(drone,'Distance', 0.5, 'Speed',1);
        backCount = backCount + 1;

    end
end
movedown(drone,'Distance', 0.4, 'Speed', 1); 
moveforward(drone,'Distance', 3.3 + 0.5*backCount, 'Speed', 1);
turn(drone, deg2rad(90));
moveback(drone, 'Distance', 0.4, 'Speed', 1);
%%
Level = 3
backCount = 0;
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 800
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);    

    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.2);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.2);
        end

    elseif boundaryNum == 2

        if ringProperty.MinorAxisLength/ringProperty.MajorAxisLength <= 0.6
            moveleft(drone, 'Distance', 0.7);
            continue
        end

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.57/ringDiameter;
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end
        break

    else
   
        moveback(drone,'Distance', 0.5, 'Speed',1);
        backCount = backCount + 1;

    end
end
movedown(drone,'Distance', 0.4, 'Speed', 1);
moveforward(drone,'Distance', 2.9 + 0.5*backCount, 'Speed', 1);
turn(drone, deg2rad(60));
%%
Level = 4
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 200
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);    

    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.3);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.3);
        end

    elseif boundaryNum == 2

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.50/ringDiameter; 
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end
        break

    else
   
        moveright(drone,'Distance', 0.2, 'Speed',1);

    end
end
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
    catch
        continue
    end
    if detectBlue_y <= 10 
        moveup(drone, 'Distance', 0.3)
    elseif detectBlue_y + detectBlue_h >= 710
        movedown(drone, 'Distance', 0.3)
    end
    break
end
turnCount = 0;
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 200
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);  
    if detectBlue_y <= 10 || detectBlue_y + detectBlue_h >= 710
        moveright(drone, 'Distance', 0.2)
        moveback(drone, 'Distance', 0.2)
        continue
    end
    if detectBlue_x + detectBlue_w >= 950 
        moveright(drone, 'Distance', 0.2)
        continue
    end
    ones = find(detectBlue);
    for i = 1: length(ones)
        ones_x(i) = fix(ones(i)/720);
        ones_y(i) = rem(ones(i),720) - 1;
        if ones_y(i) == -1
            ones_x(i) = ones_x(i) - 1;
            ones_y(i) = ones_y(i) + 721;
        end
        topleft(i) = ones_x(i)^2 + ones_y(i)^2; 
        topright(i) = (ones_x(i)-960)^2 + ones_y(i)^2; 
        bottomleft(i) = ones_x(i)^2 + (ones_y(i) - 720)^2; 
        bottomright(i) = (ones_x(i)-960)^2 + (ones_y(i) - 720)^2;
    end
    [~, topleftNum] = min(topleft.^1/2);
    [~, toprightNum] = min(topright.^1/2);
    [~, bottomleftNum] = min(bottomleft.^1/2);
    [~, bottomrightNum] = min(bottomright.^1/2);
    sideRatio = (ones_y(bottomleftNum) - ones_y(topleftNum)) - (ones_y(bottomrightNum) - ones_y(toprightNum));
    if turnCount > 30
        break
    elseif sideRatio > 10
        turn(drone, -0.05)
        turnCount = turnCount + 1;
    elseif sideRatio <= 10
        break
    end
end
while 1
    img = snapshot(cam);
    hsv = rgb2hsv(img); h = hsv(:,:,1); s = hsv(:,:,2); v = hsv(:,:,3);
    blue = ((0.568 < h)&(h < 0.658))&(0.3 < s)&(0.96 > v);
    detectBlue = bwareafilt(blue, 1);
    cannybinaryImg = edge(detectBlue, 'canny', 0.5, 10); 
    cannyfill = imfill(cannybinaryImg, 4, "holes");
    ring = bwareafilt(cannyfill, 1);
    try
        detectBlueProperty = regionprops(detectBlue,'Image','BoundingBox','MajorAxisLength','MinorAxisLength');
        detectBlue_x = detectBlueProperty.BoundingBox(1);
        detectBlue_y = detectBlueProperty.BoundingBox(2);
        detectBlue_w = detectBlueProperty.BoundingBox(3); 
        detectBlue_h = detectBlueProperty.BoundingBox(4);
        ringProperty = regionprops(ring,'Image','MajorAxisLength','MinorAxisLength');
    catch
        continue
    end
    boundary = bwboundaries(detectBlue);
    boundaryCell = cellfun(@length, boundary);
    i = 0;
    while 1
        i = i + 1;
        try
            if boundaryCell(i) < 200
                boundary(i) = [];
                boundaryCell(i) = [];
                i = i - 1;
            end
        catch
            break 
        end
    end
    boundaryNum = length(boundary);    

    if boundaryNum == 1

        if detectBlue_x <= 10
            moveleft(drone,'Distance', 0.3);
        elseif detectBlue_x + detectBlue_w >= 950
            moveright(drone,'Distance', 0.3);
        end
        if detectBlue_y <= 10 
            moveup(drone,'Distance', 0.3);
        elseif detectBlue_y + detectBlue_h >= 710
            movedown(drone,'Distance', 0.3);
        end

    elseif boundaryNum == 2

        [~, num] = min(boundaryCell);
        ringMat = cell2mat(boundary(num));
        ringDiameter = (max(ringMat(:,1)) - min(ringMat(:,1)) + max(ringMat(:,2)) - min(ringMat(:,2)))/2;
        regCo = 0.50/ringDiameter; 
        ringCenter_x = mean(ringMat(:,2)); ringCenter_y = mean(ringMat(:,1));
        dx = ringCenter_x - 480;    
        if dx < 0
            command_x = 'L';
        elseif dx > 0
            command_x = 'R';
        end
        actual_dx = abs(dx)*regCo;
        command_dx = round(actual_dx, 1);
        if command_dx <= 0.1
            command_x = 'S';
        end
        dy = ringCenter_y - 360;
        if dy < 0
            command_y = 'U';
        elseif dy > 0
            command_y = 'D';
        end
        actual_dy = abs(dy)*regCo;
        command_dy = round(actual_dy, 1);
        if command_dy <= 0.1
            command_y = 'S';
        end
        if command_x == 'L'
            moveleft(drone, 'Distance', command_dx);
        elseif command_x == 'R'
            moveright(drone, 'Distance', command_dx);
        elseif command_x == 'S'
            disp('');
        end
        if command_y == 'U'
            moveup(drone, 'Distance', command_dy);
        elseif command_y == 'D'
            movedown(drone, 'Distance', command_dy);
        elseif command_y == 'S'
            disp('');
        end
        realDistance = polyval([1.326476927048637e-10 -2.260626850551402e-07 1.504186358212177e-04 -0.048674850178656 7.580227872959118],ringDiameter);
        distance = (ceil(realDistance*10))/10;
        if distance == 1.9
            moveforward(drone,'Distance', 0.2);
            continue
        elseif distance > 2.0
            moveforward(drone,'Distance', distance - 1.8);
            continue
        elseif distance < 1.2
            moveback(drone,'Distance', 1.8 - distance)
            continue
        else
            moveforward(drone,'Distance', distance - 1);
            break
        end

    else
   
        moveback(drone,'Distance', 0.2, 'Speed',1);

    end
end
land(drone)
