clear()
% HSV Threshold Blue
thdown_blue = [0.5, 0.25, 0.25];
thup_blue = [0.75, 1, 1];

% HSV Threshold Red
thdown_red1 = [0, 0.25, 0.25];
thup_red1 = [0.025, 1, 1];
thdown_red2 = [0.975, 0.25, 0.25];
thup_red2 = [1, 1, 1];

% HSV Threshold Purple
thdown_purple = [0.725, 0.25, 0.25];
thup_purple = [0.85, 1, 1];

droneObj = ryze();
cameraObj = camera(droneObj);
takeoff(droneObj);
moveup(droneObj, 'distance', 0.5);
while 1
    % HSV Convert
    disp('----------------- HSV Converting --------------------');
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
    try
        bw1 = (0.5 < src_h) & (src_h < 0.75); % 파란색 검출 
    catch
        bw1 = double(zeros(size(src_hsv)));
    end
    
    try
        bw2 = imfill(bw1,'holes');      % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
        % 구멍을 채우기 전후를 비교, 원이 아닌부분 0(검은색), 원 부분 1(흰색)
        for row = 1:rows
            for col = 1:cols
                if bw1(row, col) == bw2(row, col)
                    bw2(row, col) = 0;
                end
            end
        end
    catch
        bw2 = double(zeros(size(src_hsv)));
    end
    
    % Move To Center
    sumStandard = (sum(bw2, 'all') / 2) + 3000;
    sumUp = sum(bw2(1:rows/2, :), 'all');             % 상단 절반
    sumDown = sum(bw2(rows/2:end, :), 'all');         % 하단 절반
    sumLeft = sum(bw2(:, 1:cols/2), 'all');           % 좌측 절반
    sumRight = sum(bw2(:, cols/2:end), 'all');        % 우측 절반
    
    if(sumUp < sumStandard)                                  % 상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.2);        % 하단으로 이동
    elseif(sumDown < sumStandard)                            % 하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.2);          % 상단으로 이동
    elseif(sumLeft < sumStandard)                            % 좌측에 크로마키가 없으면
        moveright(droneObj, 'distance', 0.2);       % 우측으로 이동
    elseif(sumRight < sumStandard)                           % 우측에 크로마키 없으면
        moveleft(droneObj, 'distance', 0.2);        % 좌측으로 이동
    else                                            % 4개의 사분면 모두에 크로마키가 존재하면 원 검출
        % Image Preprocessing
        bw_red = (((thdown_red1(1) < src_h)&(src_h < thup_red1(1)) & (thdown_red1(2) < src_s)&(src_s < thup_red1(2)) & (thdown_red1(3) < src_v)&(src_v < thup_red1(3)))) ...% 빨간색1 검출
                + (((thdown_red2(1) < src_h)&(src_h < thup_red2(1)) & (thdown_red2(2) < src_s)&(src_s < thup_red2(2)) & (thdown_red2(3) < src_v)&(src_v < thup_red2(3))));      % 빨간색2 검출
        bw_purple = (thdown_purple(1) < src_h)&(src_h < thup_purple(1)) & (thdown_purple(2) < src_s)&(src_s < thup_purple(2)) & (thdown_purple(3) < src_v)&(src_v < thup_purple(3));   % 보라색 검출

        % 빨간색 혹은 보라색 검출할 때까지 전진
        if (sum(bw_red, 'all') > 8000)                          % 빨간색이 검출되면
            disp('RED Color Detected!!! Drone Turn Left');
            turn(droneObj, deg2rad(-90));                       % Turn Left, 다음동작 크로마키 검출, 지난 링을 건드리지 않도록 일정거리 전진
            moveforward(droneObj, 'distance', 1.25);            % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
            break;
        elseif(sum(bw_purple, 'all') > 8000)                    % 보라색이 검출되면
            disp('Purple Color Detected!!! Drone Landing');
            land(droneObj);                                     % Landing
            return;                                             % 프로그램 종료
        else
            disp('No Color Detected!!! Drone Move Forward!!');
            moveforward(droneObj, 'distance', 0.5);            % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
        end
    end
               
    subplot(2, 2, 1), imshow(frame);
    subplot(2, 2, 3), imshow(bw1);
    subplot(2, 2, 4), imshow(bw2);               
end