droneObj = ryze()
cameraObj = camera(droneObj);

takeoff(droneObj);
moveup(droneObj, 'Distance', 0.3);

%1단계 원 중점 찾기
while true
    frame = snapshot(cameraObj);
    hsv_img = rgb2hsv(frame);
    subplot(2,2,1), subimage(frame);

    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    threshold = (0.575 < h) & (h < 0.675);
    threshold_s = (0.675 < s) & (s < 0.75);
    ring_ = threshold & threshold_s;
    subplot(2,2,2), subimage(ring_);
    bw =ring_;
    bw = bwareaopen(bw, 3000);
    bw2 = imfill(bw, 'holes');

    bw2 = bwareaopen(bw2, 1500);
    subplot(2,2,3), subimage(bw2);

    canny_img= edge(bw2,'canny');
    subplot(2,2,4), subimage(canny_img);
    hold on
    [w, h] = find(canny_img);
    w = unique(w);
    h = unique(h);
    
    size_w = size(w,1);
    size_h = size(h,1);
    
    mid1 = sum(w)/size_w; %y좌표
    mid2 = sum(h)/size_h; %x좌표

    ans = [mid2, mid1];
    disp(ans);
    plot(mid2,mid1,'yp');
    
    x=480-mid2;
    y=360-mid1;
    
    if (460>mid2 || mid2>500)||(340>mid1 || mid1>380) 
        if x>0
            moveright(droneObj, 'Distance', 0.2);
        elseif x<0
            moveleft(droneObj, 'Distance', 0.2);
        end
        if y>0
            movedown(droneObj, 'Distance', 0.2);
        elseif y<0
            moveup(droneObj, 'Distance', 0.2);
        end
    else
        moveforward(droneObj, 'Distance', 1);
        break;
    end
end

% 마크 인식 90도 회전
while true
    green_frame = snapshot(cameraObj);
    hsv_img = rgb2hsv(green_frame);
    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    threshold = (0.375 < h) & (h < 0.425);
    threshold_s = (0.6 < s) & (s < 0.675);
    green_ = threshold & threshold_s;
    detect_green = bwareaopen(green_, 500);

    canny_img= edge(detect_green,'canny');
    [w, h] = find(canny_img);
    y1 = max(w) - min(w);
    x1 = max(h) - min(h);
    s = times(y1, x1);
    
    if s <= 1000    
        moveforward(droneObj, 'Distance', 0.3);
    else
        moveforward(droneObj, 'Distance', 0.2);
        turn(droneObj,deg2rad(90));
        moveforward(droneObj, 'Distance', 1.5);
        break;
    end
end

%2단계 원 중점 찾기
while true
    frame = snapshot(cameraObj);
    hsv_img = rgb2hsv(frame);
    subplot(2,2,1), subimage(frame);

    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    threshold = (0.575 < h) & (h < 0.675);
    threshold_s = (0.675 < s) & (s < 0.75);
    ring_ = threshold & threshold_s;
    subplot(2,2,2), subimage(ring_);
    bw =ring_;
    bw = bwareaopen(bw, 3000);
    bw2 = imfill(bw, 'holes');

    bw2 = bwareaopen(bw2, 1500);
    subplot(2,2,3), subimage(bw2);

    canny_img= edge(bw2,'canny');
    subplot(2,2,4), subimage(canny_img);
    hold on
    [w, h] = find(canny_img);
    w = unique(w);
    h = unique(h);
    
    size_w = size(w,1);
    size_h = size(h,1);
    
    mid1 = sum(w)/size_w; %y좌표
    mid2 = sum(h)/size_h; %x좌표

    ans = [mid2, mid1];
    disp(ans);
    plot(mid2,mid1,'yp');
    
    x=480-mid2;
    y=360-mid1;
    
    if (460>mid2 || mid2>500)||(340>mid1 || mid1>380) 
        if x>0
            moveright(droneObj, 'Distance', 0.2);
        elseif x<0
            moveleft(droneObj, 'Distance', 0.2);
        end
        if y>0
            movedown(droneObj, 'Distance', 0.2);
        elseif y<0
            moveup(droneObj, 'Distance', 0.2);
        end
    else
        moveforward(droneObj, 'Distance', 1);
        break;
    end
end

% 마크 인식 90도 회전
while true
    purple_frame = snapshot(cameraObj);
    hsv_img = rgb2hsv(purple_frame);
    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    threshold = (0.675 < h) & (h < 0.775);
    threshold_s = (0.7 < s) & (s < 0.75);
    purple_ = threshold & threshold_s;
    detect_purple = bwareaopen(purple_, 500);

    canny_img= edge(detect_purple,'canny');
    [w, h] = find(canny_img);
    y1 = max(w) - min(w);
    x1 = max(h) - min(h);
    s = times(y1, x1);
    
    if s <= 1000    
        moveforward(droneObj, 'Distance', 0.3);
    else
        moveforward(droneObj, 'Distance', 0.2);
        turn(droneObj,deg2rad(90));
        moveforward(droneObj, 'Distance', 1);
        break;
    end
end

turn(droneObj,deg2rad(45));
moveforward(droneObj, 'Distance', 0.5);

%3단계 원 중점 찾기
while true
    frame = snapshot(cameraObj);
    hsv_img = rgb2hsv(frame);
    subplot(2,2,1), subimage(frame);

    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    threshold = (0.575 < h) & (h < 0.675);
    threshold_s = (0.675 < s) & (s < 0.75);
    ring_ = threshold & threshold_s;
    subplot(2,2,2), subimage(ring_);
    bw =ring_;
    bw = bwareaopen(bw, 3000);
    bw2 = imfill(bw, 'holes');

    bw2 = bwareaopen(bw2, 1500);
    subplot(2,2,3), subimage(bw2);

    canny_img= edge(bw2,'canny');
    subplot(2,2,4), subimage(canny_img);
    hold on
    [w, h] = find(canny_img);
    w = unique(w);
    h = unique(h);
    
    size_w = size(w,1);
    size_h = size(h,1);
    
    mid1 = sum(w)/size_w; %y좌표
    mid2 = sum(h)/size_h; %x좌표

    ans = [mid2, mid1];
    disp(ans);
    plot(mid2,mid1,'yp');
    
    x=480-mid2;
    y=360-mid1;
    
    if (460>mid2 || mid2>500)||(340>mid1 || mid1>380) 
        if x>0
            moveright(droneObj, 'Distance', 0.2);
        elseif x<0
            moveleft(droneObj, 'Distance', 0.2);
        end
        if y>0
            movedown(droneObj, 'Distance', 0.2);
        elseif y<0
            moveup(droneObj, 'Distance', 0.2);
        end
    else
        moveforward(droneObj, 'Distance', 1);
        break;
    end
end

% 마크 인식 90도 회전
while true
    red_frame = snapshot(cameraObj);
    hsv_img = rgb2hsv(red_frame);
    h = hsv_img(:,:,1);
    s = hsv_img(:,:,2);
    threshold = (0 <= h) & (h < 0.05) | (h <= 1) & (h > 0.95);
    threshold_s = (0.6 < s) & (s <= 1);
    red_ = threshold & threshold_s;
    detect_red = bwareaopen(red_, 500);

    canny_img= edge(detect_red,'canny');
    [w, h] = find(canny_img);
    y1 = max(w) - min(w);
    x1 = max(h) - min(h);
    s = times(y1, x1);
    
    if s <= 1000    
        moveforward(droneObj, 'Distance', 0.3);
    else
        moveforward(droneObj, 'Distance', 0.2);
        break;
    end
end

land(droneObj);
