%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

drone = ryze()
cameraObj = camera(drone);
takeoff(drone);
moveup(drone, 'distance', 0.4);

while(1)
    frame = snapshot(cameraObj);

    frame_hsv = rgb2hsv(frame);

    [rows, cols, channels] = size(frame_hsv);

    dst_h = frame_hsv(:, :, 1);
    dst_s = frame_hsv(:, :, 2);
    dst_v = frame_hsv(:, :, 3);

    dst_hsv1 = double(zeros(size(dst_h)));       
    dst_hsv2 = double(zeros(size(dst_h)));

    for row = 1:rows
        for col = 1:cols
           if thdown_blue(1) < dst_h(row, col) && dst_h(row, col) < thup_blue(1) ...
               && thdown_blue(2) < dst_s(row, col) && dst_s(row, col) < thup_blue(2) ...
               && thdown_blue(3) < dst_v(row, col) && dst_v(row, col) < thup_blue(3)
               dst_hsv1(row, col) = 1;
            else
                dst_hsv2(row, col) = 1;
            end
        end
    end

<<<<<<< HEAD
=======
    %{
    %상하좌우 맞추기
    while 1
        %좌우 부터
        lcnt = 0;
        rcnt = 0;
        ucnt = 0;
        dcnt = 0;
        for row = 1:rows                                
            for col = 1:cols
                if dst_hsv1(row, col) == 1
                     %좌
                    if row < 360
                        lcnt = lcnt + 1;
                    %우
                    else
                        rcnt = rcnt + 1;
                    end        
                end
            end
        end
        %상하
        for row = 1:rows                                
            for col = 1:cols
                if dst_hsv1(row, col) == 1
                    %상
                    if row < 480
                        ucnt = ucnt + 1;
                    %하
                    else
                        dcnt = dcnt + 1;
                    end        
                end     
            end
        end
        if (lcnt - rcnt) > 3000
            moveleft(drone, 'distance', 0.2);
        elseif (rcnt - lcnt) > 3000
            moveright(drone, 'distance', 0.2);
        elseif (ucnt - dcnt) > 3000
            moveup(drone, 'distance', 0.2);
        elseif (dcnt - ucnt) > 3000
            movedown(drone, 'distance', 0.2);
        else
            break;
        end
    end
    %}

    dst_rgb1 = hsv2rgb(dst_hsv1);
    dst_rgb2 = hsv2rgb(dst_hsv2);

>>>>>>> e4e9eea1af4a4e80e83cdb31726b770e34637ef5
    dst_gray1 = im2gray(dst_hsv1);
    canny1 = edge(dst_gray1,'Canny');

    count = 0;
    corners1 = pgonCorners(canny1,4);
    %모서리 개수    
    for i = 1:size(corners1)
        count = count + 1;
    end
    
    roi_x = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];  % roi범위 소량 확장
    roi_y = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];  % roi범위 소량 확장
    roi = roipoly(dst_gray1, roi_x, roi_y);         % 코너 좌표만큼 안쪽 이미지 roi

    dst_img = dst_hsv2 .* roi;       
    dst_gray = im2gray(dst_img);

    count_pixel = 0;
    center_row = 0;
    center_col = 0;
    for row = 1:rows                                
        for col = 1:cols
            if dst_gray(row, col) == 1          
                count_pixel = count_pixel + 1;      %검출될때마다 픽셀수 세기
                center_row = center_row + row;      %검출될때마다 가로좌표 더하기
                center_col = center_col + col;      %검출될때마다 세로좌표 더하기
            end
        end
    end

    center_row = center_row / count_pixel;
    center_col = center_col / count_pixel;

    answer = [center_col, center_row];          % 센터좌표 검출

    if abs(center_row -rows/2) < 300 && abs(center_col - cols/2)
        moveforward(drone,'distance', 0.5)
    end
    
    
    subplot(2, 3, 1); imshow(frame);
    subplot(2, 3, 2); imshow(dst_rgb1);
    subplot(2, 3, 3); imshow(dst_rgb2);
    subplot(2, 3, 4); imshow(dst_img);
    subplot(2, 3, 5); imshow(dst_gray); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 3, 6); imshow(frame); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    
end

%land(droneObj);