
% 727 수정 2번째 직진 거리 3.5->2.5
% move up 0.4
% circle_E_R 50

%find red_objct function
function has_red = check_red_color(cam)
    % Capture an image from the camera
    frame = snapshot(cam);
    img = double(frame);
    [R, C, X] = size(img);

    % Initialize img3 to store the red-detected image
    img3 = zeros(R, C, X);

    % Thresholds for detecting red
    red_threshold1 = 38;
    red_threshold2 = 10;
    green_threshold = 30;

    % Detect red pixels with the given thresholds
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) < red_threshold1 || ...
               img(i, j, 1) - img(i, j, 3) < red_threshold2 || ...
               img(i, j, 2) - img(i, j, 3) > green_threshold
                % Eliminate colors that are not red
                img3(i, j, :) = 0;
            else
                % Mark the red pixels
                img3(i, j, 1) = 255;
                img3(i, j, 2) = 0;
                img3(i, j, 3) = 0;
            end
        end
    end

    % Morphological dilation to make the red regions more prominent
    se = strel('disk', 5); % Structuring element for dilation
    red_channel = img3(:, :, 1);
    dilated_red = red_channel;
    for k = 1:10
        dilated_red = imdilate(dilated_red, se);
    end

    % Check if there are any red pixels in the image
    red_pixels_dilated = dilated_red == 255;
    has_red = any(red_pixels_dilated(:));

    % Display the original and the red-detected image for visualization
    figure;
    subplot(1, 2, 1);
    imshow(uint8(img));
    title('Original Image');

    subplot(1, 2, 2);
    imshow(uint8(img3));
    title('Detected Red Pixels');

     if has_red
        disp('Red color detected');
    else
        disp('Red color not detected');
    end
end

function has_green = check_green_color(cam)
    % Capture an image from the camera
    frame = snapshot(cam);
    img = double(frame);
    [R, C, X] = size(img);

    % Initialize img3 to store the green-detected image
    img3 = zeros(R, C, X);

    % Thresholds for detecting green
    green_threshold1 = 20;
    green_threshold2 = 10;
    green_threshold3 = 15;

    % Detect green pixels with the given thresholds
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) > green_threshold1 || ...
               img(i, j, 1) - img(i, j, 3) > green_threshold2 || ...
               img(i, j, 2) - img(i, j, 3) < green_threshold3
                % Eliminate colors that are not green
                img3(i, j, :) = 0;
            else
                % Mark the green pixels
                img3(i, j, 1) = 0;
                img3(i, j, 2) = 255;
                img3(i, j, 3) = 0;
            end
        end
    end

    % Morphological dilation to make the green regions more prominent
    se = strel('disk', 5); % Structuring element for dilation
    green_channel = img3(:, :, 2);
    dilated_green = green_channel;
    for k = 1:10
        dilated_green = imdilate(dilated_green, se);
    end

    % Check if there are any green pixels in the image
    green_pixels_dilated = dilated_green == 255;
    has_green = any(green_pixels_dilated(:));

    % Display the original and the green-detected image for visualization
    figure;
    subplot(1, 2, 1);
    imshow(uint8(img));
    title('Original Image');

    subplot(1, 2, 2);
    imshow(uint8(img3));
    title('Detected Green Pixels');

    if has_green
        disp('Green color detected');
    else
        disp('Green color not detected');
    end
end
%find purple_objct function
function has_purple = check_purple_color(cam)
    % Capture an image from the camera
    frame = snapshot(cam);
    img = double(frame);
    [R, C, X] = size(img);

    % Initialize img3 to store the purple-detected image
    img3 = zeros(R, C, X);

    % Thresholds for detecting purple
    purple_threshold1 = 11;
    purple_threshold2 = 0;
    purple_threshold3 = 20;

    % Detect purple pixels with the given thresholds
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) < purple_threshold1 || ...
               img(i, j, 1) - img(i, j, 3) > purple_threshold2 || ...
               img(i, j, 2) - img(i, j, 3) > purple_threshold3
               
               img3(i, j, :) = 0;

            else

                img3(i, j, 1) = 120;
                img3(i, j, 2) = 50;
                img3(i, j, 3) = 120;
            end
        end
    end

    % Morphological dilation to make the purple regions more prominent
    se = strel('disk', 5); % Structuring element for dilation
    purple_channel = img3(:, :, 1); % Use the red channel as representative
    dilated_purple = purple_channel;
    for k = 1:10
        dilated_purple = imdilate(dilated_purple, se);
    end

    % Check if there are any purple pixels in the image
    purple_pixels_dilated = dilated_purple == 120;
    has_purple = any(purple_pixels_dilated(:));

    % Display the original and the purple-detected image for visualization
    figure;
    subplot(1, 2, 1);
    imshow(uint8(img));
    title('Original Image');

    subplot(1, 2, 2);
    imshow(uint8(img3));
    title('Detected Purple Pixels');

    if has_purple
        disp('Purple color detected');
    else
        disp('Purple color not detected');
    end
end

% Define the findbestangle function
function bestAngle = findbestangle(drone, cam)

    % Set angle range from -10 degrees to 10 degrees
    angles = -20:10:20;
    turn(drone, deg2rad(-20));

    % Initialize an array to store the sum of blue pixels by angle.
    blueSum = zeros(1, length(angles));

    % Calculate the angular spacing.
    interval = diff(angles(1:2));

    for i = 1:length(angles)
        try
            % Take a snapshot of the camera at the current angle.
            img = snapshot(cam);

            % Define thresholds for blue color detection in RGB
            blueMin = [0, 0, 100];
            blueMax = [100, 100, 255];

            % Create a binary mask based on blue color
            blueMask = (img(:,:,1) >= blueMin(1) & img(:,:,1) <= blueMax(1)) & ...
                       (img(:,:,2) >= blueMin(2) & img(:,:,2) <= blueMax(2)) & ...
                       (img(:,:,3) >= blueMin(3) & img(:,:,3) <= blueMax(3));

            % Perform morphological operations
            blueMask = imcomplement(blueMask); % Invert mask
            blueMask = bwareaopen(blueMask, 8000); % Remove small objects
            blueMask = imcomplement(blueMask); % Re-invert mask
            se = strel('disk', 9);
            blueMask = imclose(blueMask, se); % Close mask
            blueMask = bwareaopen(blueMask, 7000); % Final clean-up

            % Calculate the sum of blue pixels in the mask
            blueSum(i) = sum(blueMask(:));

            % Calculate the average vertical position of blue pixels
            [rows, cols] = find(blueMask);

            % Display the blue mask
            figure;
            subplot(1,1,1);
            imshow(blueMask);
            title(['Initial blue mask at angle ', num2str(angles(i))]);

            % Display all relevant values
            disp(['Angle: ', num2str(angles(i)), ', BlueSum: ', num2str(blueSum(i))]);

            % Rotate the drone by the interval angle if not the last angle
            if i < length(angles)
                turn(drone, deg2rad(interval));
            end
            
        catch e
            % If an error occurs, output an error message
            disp(['Error at angle ', num2str(angles(i)), ': ', e.message]);
        end
    end
    
    % Find the angle at which most blue pixels are detected
    [~, maxIndex] = max(blueSum);
    bestAngle = angles(maxIndex); 
    % Rotate the drone to the optimal angle
    turn(drone, deg2rad(bestAngle - angles(end)));

  
    % Display final best angle and blue position
    disp(['Best Angle: ', num2str(bestAngle)]);

end

function track_red_object(drone, cam)
    camera_center = [480, 230]; % Used to advance when the centroid value is adjacent to the next value
    centroid = zeros(size(camera_center)); % Variable to read the center coordinates of the circle
    error_range = 50;        % Define acceptable error range (in pixels)
    camera_center_in_red = 0; % Initialize find_colorcenter to 0

    while ~camera_center_in_red
        frame = snapshot(cam);
        img = double(frame);
        [R, C, X] = size(img);

        % Initialize img3 to store the red-detected image
        img2 = zeros(size(img));         % Preallocate img2 for use
        img3 = zeros(R, C, X);

        % Thresholds for detecting red
        red_threshold1 = 38;
        red_threshold2 = 10;
        green_threshold = 30;

        for i = 1:R
            for j = 1:C
                if img(i, j, 1) - img(i, j, 2) < red_threshold1 || img(i, j, 1) - img(i, j, 3) < red_threshold2 || img(i, j, 2) - img(i, j, 3) > green_threshold
                    % Eliminate colors that are not red
                    img3(i, j, :) = 0;
                else
                    % Mark the red pixels
                    img3(i, j, 1) = 255;
                    img3(i, j, 2) = 0;
                    img3(i, j, 3) = 0;
                end
            end
        end

      
        % Morphological dilation to make the red regions more prominent
        se = strel('disk', 5); % Structuring element for dilation
        red_channel = img3(:, :, 1);
        dilated_red = red_channel;
        for k = 1:10
            dilated_red = imdilate(dilated_red, se);
        end

        % Overlay the dilated red pixels back to the image
        img4 = img3;
        img4(:, :, 1) = dilated_red;

        % Calculate the centroid of the dilated red pixels
        red_pixels_dilated = img4(:, :, 1) == 255;
        [y, x] = find(red_pixels_dilated);

        if ~isempty(x) && ~isempty(y)
            centroid = [mean(x), mean(y)];
        else
            centroid = [NaN, NaN]; % If no red pixels are detected, set centroid to NaN
        end

        % Define the center of the camera frame
        camera_center = [480, 230];

      

        % Calculate the difference between centroid and camera center
        Distance = centroid - camera_center;

        % Display the original, red-detected, and dilated images with centroid
        figure;
        subplot(1, 3, 1);
        imshow(uint8(img));
        title('Original Image');
        hold on;
        if ~isnan(centroid(1))
            plot(centroid(1), centroid(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        plot(camera_center(1), camera_center(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        hold off;

        subplot(1, 3, 2);
        imshow(uint8(img3));
        title('Detected Red Pixels');
        hold on;
        if ~isnan(centroid(1))
            plot(centroid(1), centroid(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        plot(camera_center(1), camera_center(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        hold off;

        subplot(1, 3, 3);
        imshow(uint8(img4));
        title('Dilated Red Pixels');
        hold on;
        if ~isnan(centroid(1))
            plot(centroid(1), centroid(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        plot(camera_center(1), camera_center(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        hold off;


        % Drone control logic
        if ~isnan(centroid)
            if Distance(1) > 0 && abs(Distance(1)) > error_range && Distance(2) < error_range
                disp("Moving the drone right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1);
            elseif Distance(1) < 0 && abs(Distance(1)) > error_range && Distance(2) < error_range
                disp("Moving the drone left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1);
            elseif abs(Distance(1)) < error_range && Distance(2) > 0 && abs(Distance(2)) > error_range
                disp("Moving the drone down");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1);
            elseif abs(Distance(1)) < error_range && Distance(2) < 0 && abs(Distance(2)) > error_range
                disp("Moving the drone up");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1);
            elseif Distance(1) > 0 && abs(Distance(1)) > error_range
                disp("Moving right");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1);
            elseif Distance(1) < 0 && abs(Distance(1)) > error_range
                disp("Moving left");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1);
            elseif red_pixels_dilated(round(camera_center(2)), round(camera_center(1)));
                disp("findcenter");
                camera_center_in_red = 1; % Termination condition: set find_colorcenter to 1 to exit the loop
            end
        else
            disp("No red object detected");
            disp("MOVE BACK 0.2m");
            moveback(drone, 'Distance', 0.2, 'Speed', 0.5);
            % Add your drone control code to search for red object or hover
        end
    end

    % The loop exits here once the center of the red object is found
    disp("Center found, exiting loop.");
    % Add any additional code to execute after finding the center
end

function land_red(drone, cam)
    find_land = 0;
    while (~find_land)
        % 이미지 캡처
        frame = snapshot(cam);
        img = double(frame);

        [R, C, ~] = size(img);
        img3 = zeros(size(img));

        red_threshold1 = 38;
        red_threshold2 = 10;
        green_threshold = 30;
        % 빨간색 탐지
        for i = 1:R
            for j = 1:C
                if img(i, j, 1) - img(i, j, 2) < red_threshold1 || img(i, j, 1) - img(i, j, 3) < red_threshold2 || img(i, j, 2) - img(i, j, 3) > green_threshold
                    % Eliminate colors that are not red
                    img3(i, j, :) = 0;
                else
                    % Mark the red pixels
                    img3(i, j, 1) = 255;
                    img3(i, j, 2) = 0;
                    img3(i, j, 3) = 0;
                end
            end
        end

        red_rectangle = img3 / 255;
        red_rectangle_gray = rgb2gray(red_rectangle);
        red_rectangle_bi = imbinarize(red_rectangle_gray);

        bi2 = imcomplement(red_rectangle_bi);
        bw = bwareaopen(bi2, 200);
        bw = imcomplement(bw);

        disk_frame = strel('disk', 9);
        bw2 = imclose(bw, disk_frame);
        bw3 = bwareaopen(bw2, 100);

        % 사각형의 넓이를 이용한 거리 계산
        stats = regionprops(bw3, 'BoundingBox', 'Area');
        if isempty(stats)
            continue; % No objects detected, continue to the next iteration
        end

        % Find the largest object by area
        largestArea = -inf;
        largestObject = stats(1);
        for k = 1:length(stats)
            if stats(k).Area > largestArea
                largestArea = stats(k).Area;
                largestObject = stats(k);
            end
        end
        area = largestObject.Area;

        distance = -0.0005 * area + 3.1304+0.1;

        % 드론 제어
        desiredDistance = 0.75;
        if distance > desiredDistance
            disp(['move forward ', round(distance - desiredDistance, 1)])
            moveforward(drone, 'Distance', round(distance - desiredDistance, 1), 'Speed', 1);
            movedown(drone, 'Distance', 0.7, 'Speed', 1);
            land(drone);
            find_land = 1;
        elseif distance < desiredDistance
            moveback(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%testcode
clear

stage_pixel=0;      % 각 색의 픽셀값을 읽어오는 변수
count_forward =0;   % 전진한 횟수를 세주는 변수

area_meas=0;        % 각 스테이지 별 원의 면적

center_place=[480,190]; % centroid의 값이 다음 값과 인접할 때 전진시키기 위해 사용 기존 
centroid=zeros(size(center_place)); % 원의 중심 좌표를 읽어오는 변수

drone=ryze()      % 드론 객체 drone 선언
cam=camera(drone);  % 드론 객체 drone의 카메라 객체 cam 선언5
takeoff(drone);
moveup(drone,'Distance',0.4,'Speed',0.4);
while stage_pixel<200
frame=snapshot(cam);
img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [Row, Col, X]=size(img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img2=zeros(size(img));         % img2 변수를 사용하기 위해 사전할당을 통해 처리
    img3=zeros(size(img));         % img3 변수를 사용하기 위해 사전할당을 통해 처리

    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    % img(i,j,1)= RED, img(i,j,2)= GREEN, img(i,j,3)= BLUE
    for N =1:Row %1~R
        for j=1:Col %1~C
            % 파란색 링 색깔을 인식하기 위한 조건
            if img(N,j,1) - img(N,j,2) > -5 || img(N,j,1) - img(N,j,3) > -5|| img(N,j,2) - img(N,j,3) > -40 
                % 해당 조건충족시 해당 이미지 흰색으로 변경
                img2(N,j,1) = 255;  
                img2(N,j,2) = 255;
                img2(N,j,3) = 255;

            else
                % 조건 불충족시 이미지 검정으로 변경
                img2(N,j,:) = 0;
                img2(N,j,2) = 0;
                img2(N,j,3) = 0;
            end

        end
    end

    circle_ring = img2 / 255;  %[0~255] 에서 [0~1]범위로
    circle_ringtoGray = rgb2gray(circle_ring); % RGB to GRAY

    % Binarize and get complement
    circle_ring_bi = imbinarize(circle_ringtoGray);
    bi2 = imcomplement(circle_ring_bi);



    % Remove small objects and get complement
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);


    % Create structural element and close the image
    disk_frame = strel('disk', 9); %반지름 9인 disk
    bw2 = imclose(bw, disk_frame); 

    % Remove small objects again
    bw3 = bwareaopen(bw2, 7000);

    % Extract boundaries
    [K, L] = bwboundaries(bw3, 'noholes'); % K 경계 좌표 L은 레이블된 이미지

    % figure 1에 작업을 완료한 bw3를 그리고, 축을 표시한 다음 덧붙일 수 있도록 설계
    figure(1),imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 plot
    for N = 1:length(K)
        boundary = K{N};
        plot(boundary(:,2),boundary(:,1),'w','LineWidth',2);
    end

    % 원의 중심 표시
    plot(center_place(1), center_place(2), 'g+', 'MarkerSize', 15, 'LineWidth', 2);
    text(center_place(1) + 5, center_place(2), 'Center', 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');

     % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    state = regionprops(L,'Area','Centroid');

    % 원이라고 판단하는 기준 수치 threshold 값을 0.5로 설정
    threshold = 0.5;

    % 경계 처리
    for N = 1:length(K)
        boundary = K{N};

        % 둘레 계산
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));

        % 면적 계산
        area = state(N).Area;

        % 둥근 정도(metric) 계산
        metric = 4*pi*area/perimeter^2;

        % 결과표시
        metric_string = sprintf('%2.2f',metric);
        
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            % area_meas=state(N).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = state(N).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1), centroid(2), 'r.', 'MarkerSize', 20);  % centroid plotted in figure 1 with a red dot

            % 중점좌표 출력 및 포인트
            % disp(['Area: ', num2str(area_meas)]);
            disp(['Centroid: (', num2str(centroid(1)), ', ', num2str(centroid(2)), ')']);
            text(centroid(1) + 5, centroid(2), sprintf('(%.1f, %.1f)', centroid(1), centroid(2)), 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
            
            % MajorAxisLength와 MinorAxisLength의 평균을 NCircle_r에 저장
            NCircle_r = sqrt(area / pi);
            disp(['NCircle_r: ', num2str(NCircle_r)]);
        end
        % text함수를 통해 시각화 
        text(boundary(1,2)-30,boundary(1,1)+13,metric_string,'Color','r',...
            'FontSize',20,'FontWeight','bold')

    end
    % 3-1) 원의 중심 찾기 알고리즘
    Distance=centroid-center_place;  % 현재 원의 위치에서 기준이 되는 중점의 위치의 차이를 Dis로 저장
    disp(['Distance X: ', num2str(Distance(1))]);
    disp(['Distance Y: ', num2str(Distance(2))]);
    circle_E_R=50;
    % case 1
    if(abs(Distance(1))<circle_E_R && abs(Distance(2))<circle_E_R)    % x 좌표 차이, y 좌표 차이가 circle_error_range보다 작을 경우 앞으로 전진
        disp("Moving the drone forward");
       
        % 전진 거리를 출력
        disp(['Forward Distance: 3.2 meters']);   %%%%%%%%%%%%%%%%% 수정
        detected = check_red_color(cam);

        moveforward(drone, 'Distance', 3.2, 'Speed', 0.7);
        count_forward = 1;
        % 거리에 따른 원의 반지름으로 계산하고, 그에 따른 전진 거리를 설정
        % 그 거리를 이동하고, 이동한 횟수를 1회로 설정

  
        % case 2
    elseif(abs(Distance(1))>circle_E_R && Distance(2)>0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone down");
        movedown(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

    elseif(abs(Distance(1))<circle_E_R && Distance(2)>0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone down");
        movedown(drone,'Distance',0.2,'Speed',0.5);
        pause(1);
    
        % case 3
    elseif(abs(Distance(1))<circle_E_R && Distance(2)<0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone up");
        moveup(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

    elseif(abs(Distance(1))>circle_E_R && Distance(2)<0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone up");
        moveup(drone,'Distance',0.2,'Speed',0.5);
        pause(1);


        % case 4
    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 5
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 6
    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R)
        disp("Moving right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 7
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R)
        disp("Moving left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % 나머지 경우 처리
    else
        disp("Hovering");

        frame=snapshot(cam);
        img = double(frame);
        [R, C, X]=size(img);        

        for i =1:R
            for j=1:C
            if img(i,j,1) - img(i,j,2) <38 || img(i,j,1) - img(i,j,3) <10 || img(i,j,2)-img(i,j,3)>30  % 빨간색이 아닌 색들을 없애기 위한 조건

                    img3(i,j,1) = 0;
                    img3(i,j,2) = 0;
                    img3(i,j,3) = 0;

                else

                    img3(i,j,1) = 255;
                    img3(i,j,2) = 0;
                    img3(i,j,3) = 0;
                    stage_pixel=stage_pixel+1;

                end
            end
        end
    end
    % 전진한 횟수가 1회인 경우 해당 while loop를 빠져나오도록 설정
    if (stage_pixel<200 && count_forward==1)
        break;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 빨간색 인식 후 130도 회전 후 직진
turn(drone, deg2rad(130)); % Rotate the drone 130 degrees to the right




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause(1);
moveforward(drone, 'Distance',3.5,'Speed', 0.7);% 일정거리 이동   %%%%% 수정
bestAngle = findbestangle(drone, cam);
% Move the drone based on the best angle
if bestAngle > 0
    moveright(drone, 'Distance', 0.3, 'Speed', 0.5);
elseif bestAngle < 0
    moveleft(drone, 'Distance', 0.3, 'Speed', 0.5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stage_pixel=0;      % 각 색의 픽셀값을 읽어오는 변수
count_forward =0;   % 전진한 횟수를 세주는 변수

while stage_pixel<200
frame=snapshot(cam);
img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [Row, Col, X]=size(img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img2=zeros(size(img));         % img2 변수를 사용하기 위해 사전할당을 통해 처리
    img3=zeros(size(img));         % img3 변수를 사용하기 위해 사전할당을 통해 처리

    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    % img(i,j,1)= RED, img(i,j,2)= GREEN, img(i,j,3)= BLUE
    for N =1:Row %1~R
        for j=1:Col %1~C
            % 파란색 링 색깔을 인식하기 위한 조건
            if img(N,j,1) - img(N,j,2) > -5 || img(N,j,1) - img(N,j,3) > -5|| img(N,j,2) - img(N,j,3) > -40 
                % 해당 조건충족시 해당 이미지 흰색으로 변경
                img2(N,j,1) = 255;  
                img2(N,j,2) = 255;
                img2(N,j,3) = 255;

            else
                % 조건 불충족시 이미지 검정으로 변경
                img2(N,j,:) = 0;
                img2(N,j,2) = 0;
                img2(N,j,3) = 0;
            end

        end
    end

    circle_ring = img2 / 255;  %[0~255] 에서 [0~1]범위로
    circle_ringtoGray = rgb2gray(circle_ring); % RGB to GRAY

    % Binarize and get complement
    circle_ring_bi = imbinarize(circle_ringtoGray);
    bi2 = imcomplement(circle_ring_bi);



    % Remove small objects and get complement
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);


    % Create structural element and close the image
    disk_frame = strel('disk', 9); %반지름 9인 disk
    bw2 = imclose(bw, disk_frame); 

    % Remove small objects again
    bw3 = bwareaopen(bw2, 7000);

    % Extract boundaries
    [K, L] = bwboundaries(bw3, 'noholes'); % K 경계 좌표 L은 레이블된 이미지

    % figure 1에 작업을 완료한 bw3를 그리고, 축을 표시한 다음 덧붙일 수 있도록 설계
    figure(1),imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 plot
    for N = 1:length(K)
        boundary = K{N};
        plot(boundary(:,2),boundary(:,1),'w','LineWidth',2);
    end
    
     % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    state = regionprops(L,'Area','Centroid');

    % 원이라고 판단하는 기준 수치 threshold 값을 0.6로 설정
    threshold = 0.6;

    % 경계 처리
    for N = 1:length(K)
        boundary = K{N};

        % 둘레 계산
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));

        % 면적 계산
        area = state(N).Area;

        % 둥근 정도(metric) 계산
        metric = 4*pi*area/perimeter^2;

        % 결과표시
        metric_string = sprintf('%2.2f',metric);
        
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            area_meas=state(N).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = state(N).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1), centroid(2), 'r.', 'MarkerSize', 20);  % centroid plotted in figure 1 with a red dot

            % 중점좌표 출력 및 포인트
            disp(['Area: ', num2str(area_meas)]);
            disp(['Centroid: (', num2str(centroid(1)), ', ', num2str(centroid(2)), ')']);
            text(centroid(1) + 5, centroid(2), sprintf('(%.1f, %.1f)', centroid(1), centroid(2)), 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
            
            % MajorAxisLength와 MinorAxisLength의 평균을 NCircle_r에 저장
            NCircle_r = sqrt(area / pi);
            disp(['NCircle_r: ', num2str(NCircle_r)]);
        end
        % text함수를 통해 시각화 
        text(boundary(1,2)-30,boundary(1,1)+13,metric_string,'Color','r',...
            'FontSize',20,'FontWeight','bold')

    end
    % 3-1) 원의 중심 찾기 알고리즘
    Distance=centroid-center_place;  % 현재 원의 위치에서 기준이 되는 중점의 위치의 차이를 Dis로 저장
    circle_E_R=48;
    % case 1
    if(abs(Distance(1))<circle_E_R && abs(Distance(2))<circle_E_R)    % x 좌표 차이, y 좌표 차이가 circle_error_range보다 작을 경우 앞으로 전진
        
        disp("Moving the drone forward"); 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Half_Circle_size = 0.23; % 2차 링 크기 
        Circle_r = Half_Circle_size * NCircle_r;
        nDistance = (51.5) * (Circle_r ^ (-0.954));
        dist = round(nDistance, 2)-1.2;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % 전진 거리를 출력
        disp(['Forward Distance: ', num2str(dist), ' meters']);

        moveforward(drone, 'Distance', dist, 'Speed', 1);
        count_forward = 1;
        % 거리에 따른 원의 반지름으로 계산하고, 그에 따른 전진 거리를 설정
        % 그 거리를 이동하고, 이동한 횟수를 1회로 설정

   
        % case 2
    elseif(abs(Distance(1))<circle_E_R && Distance(2)>0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone down");
        movedown(drone,'Distance',0.2,'Speed',0.5);
        pause(1);
    
        % case 3
    elseif(abs(Distance(1))<circle_E_R && Distance(2)<0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone up");
        moveup(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 4

    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 5
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 6
    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R)
        disp("Moving right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 7
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R)
        disp("Moving left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % 나머지 경우 처리
    else
        disp("Hovering");

        frame=snapshot(cam);
        img = double(frame);
        [R, C, X]=size(img);        

        for i =1:R
            for j=1:C
            if img(i,j,1) - img(i,j,2) <20 || img(i,j,1) - img(i,j,3) <10 || img(i,j,2)-img(i,j,3)>15  % 초록색이 아닌 색들을 없애기 위한 조건

                    img3(i,j,1) = 0;
                    img3(i,j,2) = 0;
                    img3(i,j,3) = 0;

                else

                    img3(i,j,1) = 0;
                    img3(i,j,2) = 255;
                    img3(i,j,3) = 0;
                    stage_pixel=stage_pixel+1;

                end
            end
        end
    end
    % 전진한 횟수가 1회인 경우 해당 while loop를 빠져나오도록 설정
    if (stage_pixel<200 && count_forward==1)
        break;
    end
end

detected = check_green_color(cam);
if detected
    disp('Green color detected. Taking appropriate action.');
else
    disp('Green color not detected. Searching for green color.');
end

turn(drone, deg2rad(-120)); % Rotate the drone 110 degrees to the right
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
moveforward(drone,'Distance',1.3,'Speed',1);
stage_pixel=0;      % 각 색의 픽셀값을 읽어오는 변수
count_forward =0;   % 전진한 횟수를 세주는 변수

bestAngle = findbestangle(drone, cam);


while stage_pixel<200
frame=snapshot(cam);
img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [Row, Col, X]=size(img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img2=zeros(size(img));         % img2 변수를 사용하기 위해 사전할당을 통해 처리
    img3=zeros(size(img));         % img3 변수를 사용하기 위해 사전할당을 통해 처리

    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    % img(i,j,1)= RED, img(i,j,2)= GREEN, img(i,j,3)= BLUE
    for N =1:Row %1~R
        for j=1:Col %1~C
            % 파란색 링 색깔을 인식하기 위한 조건
            if img(N,j,1) - img(N,j,2) > -5 || img(N,j,1) - img(N,j,3) > -5|| img(N,j,2) - img(N,j,3) > -40 
                % 해당 조건충족시 해당 이미지 흰색으로 변경
                img2(N,j,1) = 255;  
                img2(N,j,2) = 255;
                img2(N,j,3) = 255;

            else
                % 조건 불충족시 이미지 검정으로 변경
                img2(N,j,:) = 0;
                img2(N,j,2) = 0;
                img2(N,j,3) = 0;
            end

        end
    end

    circle_ring = img2 / 255;  %[0~255] 에서 [0~1]범위로
    circle_ringtoGray = rgb2gray(circle_ring); % RGB to GRAY

    % Binarize and get complement
    circle_ring_bi = imbinarize(circle_ringtoGray);
    bi2 = imcomplement(circle_ring_bi);



    % Remove small objects and get complement
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);


    % Create structural element and close the image
    disk_frame = strel('disk', 9); %반지름 9인 disk
    bw2 = imclose(bw, disk_frame); 

    % Remove small objects again
    bw3 = bwareaopen(bw2, 7000);

    % Extract boundaries
    [K, L] = bwboundaries(bw3, 'noholes'); % K 경계 좌표 L은 레이블된 이미지

    % figure 1에 작업을 완료한 bw3를 그리고, 축을 표시한 다음 덧붙일 수 있도록 설계
    figure(1),imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 plot
    for N = 1:length(K)
        boundary = K{N};
        plot(boundary(:,2),boundary(:,1),'w','LineWidth',2);
    end
    
     % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    state = regionprops(L,'Area','Centroid');

    % 원이라고 판단하는 기준 수치 threshold 값을 0.6로 설정
    threshold = 0.6;

    % 경계 처리
    for N = 1:length(K)
        boundary = K{N};

        % 둘레 계산
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));

        % 면적 계산
        area = state(N).Area;

        % 둥근 정도(metric) 계산
        metric = 4*pi*area/perimeter^2;

        % 결과표시
        metric_string = sprintf('%2.2f',metric);
        
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            area_meas=state(N).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = state(N).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1), centroid(2), 'r.', 'MarkerSize', 20);  % centroid plotted in figure 1 with a red dot

            % 중점좌표 출력 및 포인트
            disp(['Area: ', num2str(area_meas)]);
            disp(['Centroid: (', num2str(centroid(1)), ', ', num2str(centroid(2)), ')']);
            text(centroid(1) + 5, centroid(2), sprintf('(%.1f, %.1f)', centroid(1), centroid(2)), 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
            
            % MajorAxisLength와 MinorAxisLength의 평균을 NCircle_r에 저장
            NCircle_r = sqrt(area / pi);
            disp(['NCircle_r: ', num2str(NCircle_r)]);
        end
        % text함수를 통해 시각화 
        text(boundary(1,2)-30,boundary(1,1)+13,metric_string,'Color','r',...
            'FontSize',20,'FontWeight','bold')

    end
    % 3-1) 원의 중심 찾기 알고리즘
    Distance=centroid-center_place;  % 현재 원의 위치에서 기준이 되는 중점의 위치의 차이를 Dis로 저장
    circle_E_R=40+10;
    % case 1
    if(abs(Distance(1))<circle_E_R && abs(Distance(2))<circle_E_R)    % x 좌표 차이, y 좌표 차이가 circle_error_range보다 작을 경우 앞으로 전진
        
        disp("Moving the drone forward"); 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Half_Circle_size = 0.23; % 3차 링 크기 
        Circle_r = Half_Circle_size * NCircle_r;
        nDistance = (51.5) * (Circle_r ^ (-0.954));
        dist = round(nDistance, 2) -1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % 전진 거리를 출력
        disp(['Forward Distance: ', num2str(dist), ' meters']);

        moveforward(drone, 'Distance', dist, 'Speed', 0.7);
        count_forward = 1;
        % 거리에 따른 원의 반지름으로 계산하고, 그에 따른 전진 거리를 설정
        % 그 거리를 이동하고, 이동한 횟수를 1회로 설정

    

        % case 2
    elseif(abs(Distance(1))<circle_E_R && Distance(2)>0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone down");
        movedown(drone,'Distance',0.2,'Speed',0.5);
        pause(1);
    
        % case 3
    elseif(abs(Distance(1))<circle_E_R && Distance(2)<0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone up");
        moveup(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 4

    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 5
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);


        % case 6
    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R)
        disp("Moving right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 7
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R)
        disp("Moving left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % 나머지 경우 처리
    else
        disp("Hovering");

        frame=snapshot(cam);
        img = double(frame);
        [R, C, X]=size(img);        

        for i =1:R
            for j=1:C
            if img(i,j,1) - img(i,j,2) <20 || img(i,j,1) - img(i,j,3) <10 || img(i,j,2)-img(i,j,3)>15  % 초록색이 아닌 색들을 없애기 위한 조건

                    img3(i,j,1) = 0;
                    img3(i,j,2) = 0;
                    img3(i,j,3) = 0;

                else

                    img3(i,j,1) = 120;
                    img3(i,j,2) = 50;
                    img3(i,j,3) = 200;
                    stage_pixel=stage_pixel+1;

                end
            end
        end
    end
    % 전진한 횟수가 1회인 경우 해당 while loop를 빠져나오도록 설정
    if (stage_pixel<200 && count_forward==1)
        break;
    end
end


detected = check_purple_color(cam);

if detected
    disp('purple color detected. Taking appropriate action.');
else
    disp('purple color not detected. Searching for purple color.');
end

turn(drone, deg2rad(215)); % Rotate the drone 215 degrees to the right


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CASE4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

moveforward(drone,'Distance',1.5,'speed',1);
bestAngle = findbestangle(drone, cam);
% Move the drone based on the best angle
if bestAngle > 0
    moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
elseif bestAngle < 0
    moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
end



stage_pixel=0;      % 각 색의 픽셀값을 읽어오는 변수
count_forward =0;   % 전진한 횟수를 세주는 변수


while stage_pixel<200
frame=snapshot(cam);
img = double(frame);    % frame의 값들을 double형으로 바꿔준 뒤, img 변수에 저장
    [Row, Col, X]=size(img);    % img 변수의 크기(행, 열, 색의 3차원 배열)을 각각 R, C, X에 저장
    img2=zeros(size(img));         % img2 변수를 사용하기 위해 사전할당을 통해 처리
    img3=zeros(size(img));         % img3 변수를 사용하기 위해 사전할당을 통해 처리

    % 행, 열에 값을 대입해주는 것이기에 이중 for문을 통해 조건에 따라 다른 값들을 img2에 대입
    % img(i,j,1)= RED, img(i,j,2)= GREEN, img(i,j,3)= BLUE
    for N =1:Row %1~R
        for j=1:Col %1~C
            % 파란색 링 색깔을 인식하기 위한 조건
            if img(N,j,1) - img(N,j,2) > -5 || img(N,j,1) - img(N,j,3) > -5|| img(N,j,2) - img(N,j,3) > -40 
                % 해당 조건충족시 해당 이미지 흰색으로 변경
                img2(N,j,1) = 255;  
                img2(N,j,2) = 255;
                img2(N,j,3) = 255;

            else
                % 조건 불충족시 이미지 검정으로 변경
                img2(N,j,:) = 0;
                img2(N,j,2) = 0;
                img2(N,j,3) = 0;
            end

        end
    end

    circle_ring = img2 / 255;  %[0~255] 에서 [0~1]범위로
    circle_ringtoGray = rgb2gray(circle_ring); % RGB to GRAY

    % Binarize and get complement
    circle_ring_bi = imbinarize(circle_ringtoGray);
    bi2 = imcomplement(circle_ring_bi);



    % Remove small objects and get complement
    bw = bwareaopen(bi2, 8000);
    bw = imcomplement(bw);


    % Create structural element and close the image
    disk_frame = strel('disk', 9); %반지름 9인 disk
    bw2 = imclose(bw, disk_frame); 

    % Remove small objects again
    bw3 = bwareaopen(bw2, 7000);

    % Extract boundaries
    [K, L] = bwboundaries(bw3, 'noholes'); % K 경계 좌표 L은 레이블된 이미지

    % figure 1에 작업을 완료한 bw3를 그리고, 축을 표시한 다음 덧붙일 수 있도록 설계
    figure(1),imshow(bw3);
    axis on
    hold on

    % 원의 경계를 하얀색 선으로 plot
    for N = 1:length(K)
        boundary = K{N};
        plot(boundary(:,2),boundary(:,1),'w','LineWidth',2);
    end
    
     % 그려진 각 영역의 Area(면적)과 Centroid(중점) 정보를 저장하는 stats 선언
    state = regionprops(L,'Area','Centroid');

    % 원이라고 판단하는 기준 수치 threshold 값을 0.6로 설정
    threshold = 0.6;

    % 경계 처리
    for N = 1:length(K)
        boundary = K{N};

        % 둘레 계산
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2)));

        % 면적 계산
        area = state(N).Area;

        % 둥근 정도(metric) 계산
        metric = 4*pi*area/perimeter^2;

        % 결과표시
        metric_string = sprintf('%2.2f',metric);
        
        % 기준 수치인 threshold보다 클 경우 아래의 명령을 수행
        if metric > threshold
            area_meas=state(N).Area;        % 해당 영역의 면적을 area_meas에 저장
            centroid = state(N).Centroid;   % 해당 영역의 중점을 centroid에 저장
            plot(centroid(1), centroid(2), 'r.', 'MarkerSize', 20);  % centroid plotted in figure 1 with a red dot

            % 중점좌표 출력 및 포인트
            disp(['Area: ', num2str(area_meas)]);
            disp(['Centroid: (', num2str(centroid(1)), ', ', num2str(centroid(2)), ')']);
            text(centroid(1) + 5, centroid(2), sprintf('(%.1f, %.1f)', centroid(1), centroid(2)), 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
            
            % MajorAxisLength와 MinorAxisLength의 평균을 NCircle_r에 저장
            NCircle_r = sqrt(area / pi);
            disp(['NCircle_r: ', num2str(NCircle_r)]);
        end
        % text함수를 통해 시각화 
        text(boundary(1,2)-30,boundary(1,1)+13,metric_string,'Color','r',...
            'FontSize',20,'FontWeight','bold')

    end
    % 3-1) 원의 중심 찾기 알고리즘
    Distance=centroid-center_place;  % 현재 원의 위치에서 기준이 되는 중점의 위치의 차이를 Dis로 저장
    circle_E_R=43+10;
    % case 1
    if(abs(Distance(1))<circle_E_R && abs(Distance(2))<circle_E_R)    % x 좌표 차이, y 좌표 차이가 circle_error_range보다 작을 경우 앞으로 전진
        
          disp("Moving the drone forward"); 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Half_Circle_size = 0.26; % 4차 링 크기 
        Circle_r = Half_Circle_size * NCircle_r;
        nDistance = (51.5) * (Circle_r ^ (-0.954));
        dist = round(nDistance, 2)-0.7;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % 전진 거리를 출력
        disp(['Forward Distance: ', num2str(dist), ' meters']);
        moveforward(drone, 'Distance', dist, 'Speed', 1);
        count_forward = 1;
        % 거리에 따른 원의 반지름으로 계산하고, 그에 따른 전진 거리를 설정
        % 그 거리를 이동하고, 이동한 횟수를 1회로 설정
  
        % case 2
    elseif(abs(Distance(1))<circle_E_R && Distance(2)>0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone down");
        movedown(drone,'Distance',0.2,'Speed',0.5);
        pause(1);
    
        % case 3
    elseif(abs(Distance(1))<circle_E_R && Distance(2)<0 && abs(Distance(2))>circle_E_R)
        disp("Moving the drone up");
        moveup(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 4
    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 5
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R && Distance(2)<circle_E_R)
        disp("Moving the drone left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 6
    elseif(Distance(1)>0 && abs(Distance(1))>circle_E_R)
        disp("Moving right");
        moveright(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % case 7
    elseif(Distance(1)<0 && abs(Distance(1))>circle_E_R)
        disp("Moving left");
        moveleft(drone,'Distance',0.2,'Speed',0.5);
        pause(1);

        % 나머지 경우 처리
    else
        disp("Hovering");

        frame=snapshot(cam);
        img = double(frame);
        [R, C, X]=size(img);        

        for i =1:R
            for j=1:C
            if img(i,j,1) - img(i,j,2) <38 || img(i,j,1) - img(i,j,3) <10 || img(i,j,2)-img(i,j,3)>30  % 빨간색이 아닌 색들을 없애기 위한 조건

                    img3(i,j,1) = 0;
                    img3(i,j,2) = 0;
                    img3(i,j,3) = 0;

                else

                    img3(i,j,1) = 255;
                    img3(i,j,2) = 0;
                    img3(i,j,3) = 0;
                    stage_pixel=stage_pixel+1;

                end
            end
        end
    end
    % 전진한 횟수가 1회인 경우 해당 while loop를 빠져나오도록 설정
    if (stage_pixel<200 && count_forward==1)
        break;
    end
end

track_red_object(drone, cam);

land_red(drone,cam);



