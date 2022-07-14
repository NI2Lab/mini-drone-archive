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
    while (1)
        %좌우 부터
        lcnt = 0;
        rcnt = 0;
        ucnt = 0;
        dcnt = 0;
        for row = 1:rows
            for col = 1:cols
                if dst_hsv1(row,col) == 1
                    %상
                    if row < 360
                        ucnt = ucnt + 1;
                    %하
                    else
                        dcnt = dcnt + 1;
                    end
                    %좌
                    if col < 480
                        lcnt = lcnt + 1;
                    %우
                    else
                        rcnt = rcnt + 1;
                    end
                end
            end
        end

        disp("상:" + ucnt)
        disp("하:" + dcnt)
        disp("좌:" + lcnt)
        disp("우:" + rcnt)
        if (ucnt == 0 && dcnt == 0 && leftcnt == 0 && rightcnt == 0)
            disp("검출되지 않아 뒤로 보냄")
            moveback(drone,'Distance',0.2,'Speed',0.7);
        end
        if (lcnt - rcnt) > 5000
            disp("오른쪽 움직임")
            moveright(drone, 'Distance', 0.2,'Speed',0.7);
        end
        if (rcnt - lcnt) > 5000
            disp("왼쪽 움직임")
            moveleft(drone, 'Distance', 0.2,'Speed',0.7);
        end
        if (ucnt - dcnt) > 5000
            disp("아래쪽 움직임")
            movedown(drone, 'Distance', 0.2,'Speed',0.7);
        end
        if (dcnt - ucnt) > 5000
            disp("위쪽 움직임")
            moveup(drone, 'Distance', 0.2,'Speed',0.7);
        end
        if (abs(lcnt - rcnt) <= 5000 && abs(ucnt - dcnt) <= 5000)
            moveforward (drone,'Distance', 0.3,'Speed',0.7);
            upcount = 0;
            downcount = 0;
            leftcount = 0;
            rightcount = 0;
            disp("모서리 부분에 파란색이 검출되는지 확인")
            for row = 1:rows
                if (cols == 2)
                    if (dst_hsv1 == 1)
                        leftcount = leftcount + 1;
                    end
                end
                if (cols == 958)
                    if (dst_hsv2 == 1)
                        rightcount = rightcount + 1;
                    end
                end
            end
            
            for col = 1:cols
                if (rows == 2)
                    if (dst_hsv1 == 1)
                        upcount = upcount + 1;
                    end
                end
                if (rows == 718)
                    if (dst_hsv2 == 1)
                        downcount = downcount + 1;
                    end
                end
            end
                
            if (upcount == 710 && downcount == 710 && leftcount == 950 && rightcount == 950)
                count_pixel = 0;
                center_row = 0;
                center_col = 0;
                for row = 1:rows
                    for col = 1:cols
                        if dst_hsv2(row, col) == 1          
                            count_pixel = count_pixel + 1;      %검출될때마다 픽셀수 세기
                            center_row = center_row + row;      %검출될때마다 가로좌표 더하기
                            center_col = center_col + col;      %검출될때마다 세로좌표 더하기
                        end
                    end
                end
                center_row = center_row / count_pixel;
                center_col = center_col / count_pixel;

                answer = [center_col, center_row];

                if (abs(center_row -rows/2) < 1000 && abs(center_col - cols/2) < 1000)
                    moveforward(drone,'Distance', 1);
                end
            elseif ((upcount ~= 0 && downcount ~= 0 && leftcount ~= 0 && rightcount ~= 0))
                moveback(drone,'Distance', 0.2,'Speed',0.7);
            end
        end
    end
    
    %{
    subplot(2, 3, 1); imshow(frame);
    subplot(2, 3, 2); imshow(dst_rgb1);
    subplot(2, 3, 3); imshow(dst_rgb2);
    subplot(2, 3, 4); imshow(dst_img);
    subplot(2, 3, 5); imshow(dst_gray); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    subplot(2, 3, 6); imshow(frame); hold on;
    plot(center_col, center_row, 'r*'); hold off;
    %}
end

%land(droneObj);