clear()
% HSV Threshold Green
thdown_green = [0.25, 40/240, 80/240];
thup_green = [0.40, 240/240, 240/240];
% HSV Threshold Blue
thdown_blue = [0.5, 0.35, 0.25];        % 파란색의 임계값 범위
thup_blue = [0.75, 1, 1];               
thdown_red1 = [0, 0.5, 0.5];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.5, 0.5];
thup_red2 = [1, 1, 1];
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
takeoff(droneObj);
% v = VideoReader('test_video2.mp4');
while 1
    % HSV Convert
    %frame = readFrame(v);
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
    bw1 = (0.5 < src_h)&(src_h < 0.75) & (0.15 < src_s)&(src_s < 1) & (0.25 < src_v)&(src_v < 1);   % 파란색 검출
    
    %사분면 처리 (가운데로 대충 이동)
    left = bw1(:,1:cols/2); right = bw1(:,cols/2:end); up = bw1(1:rows/2,:); down = bw1(rows/2:end,:);
    sum_up = sum(sum(up)); sum_down = sum(sum(down)); sum_left = sum(sum(left)); sum_right = sum(sum(right));
    find_cir = 0;
    
    if(sum_up == 0)
        disp('sum_up = 0');
        movedown(droneObj, 'distance', 0.5);
    elseif(sum_down == 0)
        disp('sum_down = 0');
        moveup(droneObj, 'distance', 0.5);
    elseif(sum_left == 0)
        disp('sum_left = 0');
        moveright(droneObj, 'distance', 0.5);
    elseif(sum_right == 0)
        disp('sum_right = 0');
        moveleft(droneObj, 'distance', 0.5);
    else
        find_cir = 1;
    end
    
    if(find_cir == 1)
        disp('find_cir = 1');
        try
            bw2 = imfill(bw1,'holes');    % 구멍을 채움
            %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환 (0->검은색 1->하얀색)
            for row = 1:rows
                for col = 1:cols
                    if bw1(row, col) == bw2(row, col)
                        bw2(row, col)=0;
                    end
                end
            end
            
            if(sum(sum(bw2)) < 50)
                disp('Cannot find the circle');
                moveback(droneObj, 'distance', 0.2);
                if(sum_up > sum_down)
                   moveup(droneObj, 'distance', 0.3);
                else
                    movedown(droneObj, 'distance', 0.3);
                end
                if(sum_left > sum_right)
                   moveleft(droneObj, 'distance', 0.3);
                else
                    moveright(droneObj, 'distance', 0.3);
                end
            else
            
                % Detecting Center (중점 찾기)
                count_pixel = 0;
                center_row = 0;
                center_col = 0;
                for row = 1:rows
                    for col = 1:cols
                        if bw2(row, col) == 1
                            count_pixel = count_pixel + 1;
                            center_row = center_row + row;
                            center_col = center_col + col;    
                        end        
                    end
                end
                center_row = center_row / count_pixel;
                center_col = center_col / count_pixel;
                camera_mid_row = rows / 2;
                camera_mid_col = cols / 2;

                dif_x = camera_mid_col - center_col
                dif_y = camera_mid_row - center_row
%                 go = 0;

                if((dif_x <= -50 || dif_x >= 50) || (dif_y <= -50 || dif_y >= 50))
                    disp('중심 맞추기');
                    if dif_x <= -300
                        moveright(droneObj, 'distance', 0.3)
                    elseif dif_x <= -150
                        moveright(droneObj, 'distance', 0.25)
                    elseif dif_x <= 0
                        moveright(droneObj, 'distance', 0.2)
                    elseif dif_x <= 150
                        moveleft(droneObj, 'distance', 0.2)
                    elseif dif_x <= 300
                        moveleft(droneObj, 'distance', 0.25)
                    else
                        moveleft(droneObj, 'distance', 0.3)
                    end

                    if dif_y <= -300
                        movedown(droneObj, 'distance', 0.3)
                    elseif dif_y <= -150
                        movedown(droneObj, 'distance', 0.25)
                    elseif dif_y <= 0
                        movedown(droneObj, 'distance', 0.2)
                    elseif dif_y <= 150
                        moveup(droneObj, 'distance', 0.2)
                    elseif dif_y <= 300
                        moveup(droneObj, 'distance', 0.2)
                    else
                        moveup(droneObj, 'distance', 0.25)
                    end
                else
                    cnt = 0;
                    while(1)
                        cnt = cnt + 1;
                        frame = snapshot(cameraObj);
                        src_hsv = rgb2hsv(frame);
                        src_h = src_hsv(:,:,1);
                        src_s = src_hsv(:,:,2);
                        src_v = src_hsv(:,:,3);
                        [rows, cols, channels] = size(src_hsv);

                        bw_red = (thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)) ...
                            | (thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3)); 
                        bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));

                        subplot(1, 3, 1), imshow(frame);
                        subplot(1, 3, 2), imshow(bw_red);
                        subplot(1, 3, 3), imshow(bw_purple);

                        if(sum(bw_red, 'all') > 8000)
                            turn(droneObj, deg2rad(-90));
                    %         moveforward(droneObj, 'distance', 0.7);
                            land(droneObj)
                            break;
                        elseif(sum(bw_purple, 'all') > 8000)
                            land(droneObj);
                            return;
                        else
                            moveforward(droneObj, 'distance', 0.4);
                        end
                        
                        if (cnt > 4)
                           break; 
                        end
                    end
                end

                

                %%% 이미지 출력
                subplot(2, 2, 1), imshow(frame); hold on;
                plot(center_col, center_row, 'r*'); hold off;
                subplot(2, 2, 3), imshow(bw1); hold on;
                plot(center_col, center_row, 'r*'); hold off;
                subplot(2, 2, 4), imshow(bw2); hold on;
                plot(center_col, center_row, 'r*'); hold off;
            end

        catch exception
            disp('error');
        end
    end
    
end