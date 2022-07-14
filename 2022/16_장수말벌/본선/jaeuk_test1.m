%크로마키 임계값
thdown_blue = [0.55, 0.43, 0.25];
thup_blue = [0.75, 1, 1];

drone = ryze()
cameraObj = camera(drone);
takeoff(drone);
moveup(drone, 'distance', 0.4);

while(1)
    frame = snapshot(cameraObj);

    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);
    bw1 = (thdown_blue(1) < src_h) & (src_h < thup_blue(1)) & (thdown_blue(2) < src_s) & (src_s < thup_blue(2)); % 파란색 검출

    [rows, cols, channels] = size(src_hsv);       
    dst_hsv1 = double(zeros(size(src_hsv)));      
    dst_hsv2 = double(zeros(size(src_hsv)));

    sumUp = sum(bw1(1:rows/2, :), 'all');             % 상단 절반
    sumDown = sum(bw1(rows/2:end, :), 'all');         % 하단 절반
    sumLeft = sum(bw1(:, 1:cols/2), 'all');           % 좌측 절반
    sumRight = sum(bw1(:, cols/2:end), 'all');        % 우측 절반

    disp('여기까지됨');

    if(sumUp == 0)                                  % 상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.3);        % 하단으로 이동
    elseif(sumDown == 0)                            % 하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.3);          % 상단으로 이동 -----------------------------------------------------
    elseif(sumLeft == 0)                            % 좌측에 크로마키가 없으면
        moveright(droneObj, 'distance', 0.5);       % 우측으로 이동
    elseif(sumRight == 0)                           % 우측에 크로마키 없으면
        moveleft(droneObj, 'distance', 0.5);
    end

    for row = 1:rows
        for col = 1:cols
            if thdown_blue(1) < src_hsv(row, col, 1) && src_hsv(row, col, 1) < thup_blue(1) ...
                    && thdown_blue(2) < src_hsv(row, col, 2) && src_hsv(row, col, 2) < thup_blue(2) ...
                    && thdown_blue(3) < src_hsv(row, col, 3) && src_hsv(row, col, 3) < thup_blue(3)
                dst_hsv1(row, col, :) = [0, 0, 1];
            else
                dst_hsv2(row, col, :) = [0, 0, 1];
            end
        end
    end

    
    dst_gray = im2gray(bw1);

    %dst_gray1 = im2gray(dst_rgb1);
    canny1 = edge(bw1,'Canny');

    corners1 = pgonCorners(dst_gray, 4);       % 바깥사각형 코너 좌표 검출
    count = 0;

    %모서리 구하기 이거 고쳐야됨
    while 1
        corners1 = pgonCorners(canny1,4);
        %모서리 개수    
        for i = 1:size(corners1)
            count = count + 1;
        end
        %너무 가까울 때나 모서리가 안보일 때
        if count < 4
             a = [0 0 0 0]; % a4: 좌상 a3: 우상 a1: 좌하 a2: 우하 ㄹ위치에 있을 때
            if count == 3       % 문제3번처럼 한 구석이 안나올 때
                for i = 1:size(corners1)
                    if corners1(i,1) >= 716
                        a(1) = a(1)+1;
                        a(2) = a(2)+1;
                    end
                    if corners1(i,1) <= 4
                        a(3) = a(3)+1;
                        a(4) = a(4)+1;
                   end
                    if corners1(i,2) >= 956
                        a(2) = a(2)+1;
                        a(3) = a(3)+1;
                    end
                    if corners1(i,2) <= 4
                        a(4) = a(4)+1;
                        a(1) = a(1)+1;
                    end
                end
            end
            % roi를 할 수 있도록 순서를 재배치 하고 가장 끝쪽 값을 넣어줌
            for i = 1:4
                if a(i) == 2
                    if i == 4
                        corners1(i,2) = 4;
                        corners1(i,1) = 4;
                    else
                        for j = 4:-1:i+1
                            corners1(j,1) = corners1(j-1,1);
                            corners1(j,2) = corners1(j-1,2);
                        end
                        if i == 1 
                            corners1(i,2) = 4;
                            corners1(i,1) = 716;
                        elseif i == 2
                            corners1(i,2) = 956;
                            corners1(i,1) = 716;
                        elseif i == 3
                            corners1(i,1) = 4;
                            corners1(i,2) = 956;           
                        end
                    end
                end
            end
            % 값이 잘 나올 수 있도록 roi값을 줄여줌
            for i = 1:4
                if i == 1
                    corners1(i,1) = corners1(i,1)-4;
                    corners1(i,2) = corners1(i,2)+4;
                end
                if i == 2
                    corners1(i,1) = corners1(i,1)-4;
                    corners1(i,2) = corners1(i,2)-4;
                end  
                if i == 3
                    corners1(i,1) = corners1(i,1)+4;
                    corners1(i,2) = corners1(i,2)-4;
                end  
                if i == 4
                    corners1(i,1) = corners1(i,1)+4;
                    corners1(i,2) = corners1(i,2)+4;
                end  
            end
        else
            break;
        end
    end

    roi_x = [corners1(1, 2) + 5, corners1(2, 2) - 5, corners1(3, 2) - 5, corners1(4, 2) + 5];  % roi범위 소량 확장
    roi_y = [corners1(1, 1) - 5, corners1(2, 1) - 5, corners1(3, 1) + 5, corners1(4, 1) + 5];  % roi범위 소량 확장
    roi = roipoly(dst_gray, roi_x, roi_y);         % 코너 좌표만큼 안쪽 이미지 roi

    dst_img = dst_rgb2 .* roi;       
    dst_gray1 = rgb2gray(dst_img);

    count_pixel = 0;
    center_row = 0;
    center_col = 0;
    for row = 1:rows                                
        for col = 1:cols
            if dst_gray1(row, col) == 1          
                count_pixel = count_pixel + 1;      %검출될때마다 픽셀수 세기
                center_row = center_row + row;      %검출될때마다 가로좌표 더하기
                center_col = center_col + col;      %검출될때마다 세로좌표 더하기
            end
        end
    end

    center_row = center_row / count_pixel;
    center_col = center_col / count_pixel;
    
    answer = [center_col, center_row]          

    camera_mid_row = rows / 2;
    camera_mid_col = cols / 2;
            
    disp('Calculating Circle Center');
    moveRow = center_row - camera_mid_row;
    moveCol = center_col - camera_mid_col;
    
    subplot(2, 3, 1); imshow(frame);
    subplot(2, 3, 2); imshow(dst_rgb1);
    subplot(2, 3, 3); imshow(dst_rgb2);
    subplot(2, 3, 4); imshow(bw1);
    subplot(2, 3, 5); imshow(dst_gray); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 3, 6); imshow(frame); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    
end

%land(droneObj);