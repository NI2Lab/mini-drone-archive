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

    % Image Preprocessing
    bw1 = double(zeros(size(src_hsv)));
    bw1 = (0.5 < src_h)&(src_h < 0.75) & (0.15 < src_s)&(src_s < 1) & (0.25 < src_v)&(src_v < 1);   % 파란색 검출
    
    % Move To Center
    sumUp = sum(sum(bw1(1:rows/2, :)));             % 상단 절반
    sumDown = sum(sum(bw1(rows/2:end, :)));         % 하단 절반
    sumLeft = sum(sum(bw1(:, 1:cols/2)));           % 좌측 절반
    sumRight = sum(sum(bw1(:, cols/2:end)));        % 우측 절반
    
    if(sumUp == 0)                                  % 상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.2);        % 하단으로 이동
    elseif(sumDown == 0)                            % 하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.2);          % 상단으로 이동
    elseif(sumLeft == 0)                            % 좌측에 크로마키가 없으면
        moveright(droneObj, 'distance', 0.2);       % 우측으로 이동
    elseif(sumRight == 0)                           % 우측에 크로마키 없으면
        moveleft(droneObj, 'distance', 0.2);        % 좌측으로 이동
    else                                            % 4개의 사분면 모두에 크로마키가 존재하면 원 검출
        bw2 = imfill(bw1,'holes');      % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
        % 구멍을 채우기 전후를 비교, 원이 아닌부분 0(검은색), 원 부분 1(흰색)
        for row = 1:rows
            for col = 1:cols
                if bw1(row, col) == bw2(row, col)
                    bw2(row, col) = 0;
                end
            end
        end
        
        if sum(sum(bw2)) > 100
            % Detecting Center
            disp('Image Processing 2: Detecting Center');
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
            disp('Move to Center Caculating');
            moveRow = center_row - camera_mid_row;
            moveCol = center_col - camera_mid_col;
            if not(-40< moveRow && moveRow < 40) || not(-40< moveCol && moveCol < 40)
                movedown(droneObj, 'distance', 0.4);
                moveforward(droneObj, 'distance', 2);
                land(droneObj);
                break;
            end
            
        else
            disp('Move To Cromakey');
            if(sumUp > sumDown)                         % 상단 크로마키 > 하단 크로마키
               moveup(droneObj, 'distance', 0.2);       % 상단으로 이동
            else                                        % 상단 크로마키 < 하단 크로마키
                movedown(droneObj, 'distance', 0.2);    % 하단으로 이동
            end
            
            if(sumLeft > sumRight)                      % 좌측 크로마키 > 우측 크로마키
               moveleft(droneObj, 'distance', 0.2);     % 좌측으로 이동
            else                                        % 좌측 크로마키 < 우측 크로마키
                moveright(droneObj, 'distance', 0.2);   % 우측으로 이동
            end
        end     
    end
    
   try
        subplot(2, 2, 1), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
   catch exception
        disp('There is no Circle Center Coordinates');
        subplot(1, 2, 1), imshow(frame);
        subplot(1, 2, 2), imshow(bw1);
   end
%     imshow(bw1);
%     imshow(bw2);
    
%     subplot(1, 2, 2), imshow(dst_hsv1)
%     plot(center_col, center_row, 'r*'); hold off;
%     subplot(2, 2, 2), imshow(gray_thres_dst); hold on;
%     plot(center_col, center_row, 'r*'); hold off;
%     subplot(2, 2, 3), imshow(dst_hsv1);
%     subplot(2, 2, 4), imshow(dst_hsv2);
end