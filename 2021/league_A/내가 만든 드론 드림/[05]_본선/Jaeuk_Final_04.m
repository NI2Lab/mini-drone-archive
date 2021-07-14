clear()
% HSV Threshold Green
thdown_green = [0.25, 40/240, 80/240];
thup_green = [0.40, 240/240, 240/240];
% HSV Threshold Blue
thdown_blue = [0.5, 0.35, 0.25];
thup_blue = [0.75, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
takeoff(droneObj);
% v = VideoReader('test_video2.mp4');
while 1
    % HSV Convert
    disp('HSV Converting');
%     frame = readFrame(v);
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);
    
    detected_blue = (0.5 < src_h)&(src_h < 0.75) & (0.15 < src_s)&(src_s < 1) & (0.25 < src_v)&(src_v < 1);   % 파란색 검출
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
    
%     %구멍 위치를 어느정도 캠 가운데로 조정
%     while 1
%         if sum(imcrop(detected_blue, [0 0 480 720]), 'all') - sum(imcrop(detected_blue, [480 0 960 720]), 'all') > 10000
%             disp('캠 위치 왼쪽이동');
%             moveleft(droneObj, 'distance', 0.3');
%         elseif sum(imcrop(detected_blue, [480 0 960 720]), 'all') - sum(imcrop(detected_blue, [0 0 480 720]), 'all') > 10000
%             disp('캠 위치 오른쪽이동');
%             moveright(droneObj, 'distance', 0.3');
%         end
%     
%         if sum(imcrop(detected_blue, [0 0 960 360]), 'all') - sum(imcrop(detected_blue, [0 360 960 720]), 'all') > 10000
%             disp('캠 위치 위쪽이동');
%             moveup(droneObj, 'distance', 0.3');
%         elseif sum(imcrop(detected_blue, [0 360 960 720]), 'all') - sum(imcrop(detected_blue, [0 0 960 360]), 'all') > 10000
%             disp('캠 위치 아래쪽이동');
%             movedown(droneObj, 'distance', 0.3');
%         end
%     
%         if sum(detected_blue, 'all') >= 250000
%             disp('캠 위치 조정완료');
%         break;
%         end
%     end    
    
   
    if(find_cir == 1)
        disp('find_cir = 1');
        try
            bw2 = imfill(bw1,'holes');
            imshow(bw2)% 구멍을 채움
            %구멍을 채우기 전과 후를 비교하여 값이 일정하면 0, 변했으면 1로 변환
            for row = 1:rows
                for col = 1:cols
                    if bw1(row, col) == bw2(row, col)
                        bw2(row, col)=0;
                    end
                end
            end


    
    % 링의 중점과 이미지의 중점좌표를 일치화 후 전진
    
            % Detecting Center
            disp('Image Processing 2: Detect Center');
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
                
        % 현재 이미지 받아오기
%         img = snapshot(cam);
%         
%         img_hsv = rgb2hsv(img);
%         dst_h = img_hsv(:,:,1);
        ring_mid = [center_col, center_row];
%         [img_row, img_col, channels] = size(img_hsv);
        camera_mid = [camera_mid_col, camera_mid_row];
        
        disp('Image Processing 3: Camera Move to Center');
        if img_mid(2) - ring_mid(2) > 50
            disp('왼쪽으로 이동');
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - ring_mid(2) < -50
            disp('오른쪽으로 이동');
            moveright(droneObj, 'Distance', 0.2);
        end
    
        if img_mid(1) - ring_mid(1) > 50
            disp('위로 이동');
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - ring_mid(1) < -50
            disp('아래로 이동');
            movedown(droneObj, 'Distance', 0.2);
        end
    
        if img_mid(1)-ring_mid(1) < 50 && img_mid(1)-ring_mid(1)>-50 ...
                && img_mid(2)-ring_mid(2)<50 && img_mid(2)-ring_mid(2)>-50
            disp('중점 일치화 완료 후 전진');
            moveforward(droneObj, 'Distance', 1.0);
            break;
        end
    
    
    while 1
        img = snapshot(cam);
        img_hsv = rgb2hsv(img);
        dst_h = img_hsv(:,:,1);
        detected_red = (dst_h>1)+(dst_h<0.05);
    
        if sum(detected_red, 'all') >= 150000
            turn(droneObj, deg2rad(-90));
            break;
        else
            disp('빨간표식 향해 전진');
            moveforward(droneObj, 'Distance', 0.5);
        end
    end
    
    catch exception
            disp('error');
        end
    end
end
    
%     subplot(2, 2, 1), imshow(frame); hold on;
%     plot(center_col, center_row, 'r*'); hold off;
%     subplot(2, 2, 3), imshow(bw1); hold on;
%     plot(center_col, center_row, 'r*'); hold off;
%     subplot(2, 2, 4), imshow(bw2); hold on;
%     plot(center_col, center_row, 'r*'); hold off;
%     imshow(bw1);
%     imshow(bw2);
    
%     subplot(1, 2, 2), imshow(dst_hsv1)
%     plot(center_col, center_row, 'r*'); hold off;
%     subplot(2, 2, 2), imshow(gray_thres_dst); hold on;
%     plot(center_col, center_row, 'r*'); hold off;
%     subplot(2, 2, 3), imshow(dst_hsv1);
%     subplot(2, 2, 4), imshow(dst_hsv2);