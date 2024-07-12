clear tello cameraObj; % 객체 초기화

% Tello 드론과의 연결 설정
tello = ryze();
cameraObj = camera(tello);

% 드론 이륙
takeoff(tello);

% 허용 오차 설정
tolerance = 30;

% 옵션 구조체 정의
options = struct();
options.Camera = cameraObj;  % 카메라 객체
options.Tolerance = tolerance;  % 허용 오차

% 첫 번째 링 통과 (타깃: 빨강)
passThroughRing(tello, options, 57/2, 1);

% 첫 번째 링을 통과한 후 방향 전환 및 이동
turn(tello, deg2rad(130));
pause(1);

moveforward(tello, 'Distance', 3, 'Speed', 0.8);
pause(1);

% 두 번째 링 통과 (타깃: 초록)
passThroughRing(tello, options, 46/2, 2);

% 두 번째 링을 통과한 후 방향 전환 및 이동
turn(tello, deg2rad(-130));
pause(1);

% 세 번째 링 통과 (타깃: 보라)
passThroughRing(tello, options, 46/2, 2);

% 세 번째 링을 통과한 후 방향 전환 및 이동
turn(tello, deg2rad(215));
pause(1);

% 네 번째 링 통과 (타깃: 빨강)
passThroughRing(tello, options, 52/2, 3);

% 드론 착륙
land(tello);

function passThroughRing(tello, options, real_radius, ring_number)
    match_count = 0; % 링과 타깃의 좌표가 일치한 횟수를 추적
    move_speed = 0.8; % 드론의 이동 속도
    tolerance = 30;
    
    figure(1); % 이미지 창 생성
    hold on;

    while match_count < 1
        move_attempts = 0; % 회전 시도 횟수
        circleMaskDefined = false; % circleMask가 정의되었는지 여부
        while ~circleMaskDefined
            % 드론 카메라로부터 이미지 캡처
            img_rgb = snapshot(options.Camera);
            frame = img_rgb; % 이미지를 직접 사용하도록 수정

            % 3. 파란색 필터링
            hsvFrame = rgb2hsv(frame);
            blueLower = [0.5, 0.3, 0.2]; % 적절한 값으로 조정
            blueUpper = [0.7, 1, 1];     % 적절한 값으로 조정
            blueMask = (hsvFrame(:,:,1) >= blueLower(1) & hsvFrame(:,:,1) <= blueUpper(1)) & ...
                       (hsvFrame(:,:,2) >= blueLower(2) & hsvFrame(:,:,2) <= blueUpper(2)) & ...
                       (hsvFrame(:,:,3) >= blueLower(3) & hsvFrame(:,:,3) <= blueUpper(3));
            stats = regionprops(blueMask, 'BoundingBox', 'Area');

            if ~isempty(stats) % 파란색 영역이 있는 경우에만 처리
                [~, idx] = max([stats.Area]);
                largestBbox = stats(idx).BoundingBox;
                [rows, cols, ~] = size(blueMask);
                xStart = round(largestBbox(1));
                yStart = round(largestBbox(2));
                xEnd = min(round(largestBbox(1) + largestBbox(3)), cols);
                yEnd = min(round(largestBbox(2) + largestBbox(4)), rows);
                rectMask = false(size(blueMask));
                rectMask(yStart:yEnd, xStart:xEnd) = true;
                nonBlueInsideBlueRectMask = rectMask & ~blueMask;

                grayFrame = rgb2gray(frame);
                grayFrame(~nonBlueInsideBlueRectMask) = 0;
                [centers, radii] = imfindcircles(grayFrame, [20 50], 'ObjectPolarity', 'bright', 'Sensitivity', 0.9);
                props = regionprops(nonBlueInsideBlueRectMask, 'Centroid', 'EquivDiameter', 'Circularity');
                circularRegions = props([props.Circularity] > 0.7);

                ring_center_x = [];
                ring_center_y = [];
                resultFrame = frame;
                resultFrame = insertShape(resultFrame, 'Rectangle', largestBbox, 'Color', 'red', 'LineWidth', 3);
                
                if ~isempty(circularRegions)
                    [~, maxIdx] = max([circularRegions.EquivDiameter]);
                    largestCircle = circularRegions(maxIdx);
                    centroid = largestCircle.Centroid;
                    radius = largestCircle.EquivDiameter / 2;
                    resultFrame = insertShape(resultFrame, 'Circle', [centroid, radius], 'Color', 'green', 'LineWidth', 3);
                    ring_center_x = centroid(1);
                    ring_center_y = centroid(2);
                    resultFrame = insertText(resultFrame, centroid, sprintf('(%0.2f, %0.2f)', centroid(1), centroid(2)), 'BoxColor', 'black', 'TextColor', 'black', 'FontSize', 10, 'BoxOpacity', 0.6);
                    resultFrame = insertShape(resultFrame, 'Line', [centroid(1)-10, centroid(2), centroid(1)+10, centroid(2)], 'Color', 'black', 'LineWidth', 2);
                    resultFrame = insertShape(resultFrame, 'Line', [centroid(1), centroid(2)-10, centroid(1), centroid(2)+10], 'Color', 'black', 'LineWidth', 2);

                    [rows, cols, ~] = size(frame);
                    [X, Y] = meshgrid(1:cols, 1:rows);
                    circleMask = ((X - centroid(1)).^2 + (Y - centroid(2)).^2) <= radius^2;

                    if ~isempty(circleMask)
                        circleMaskDefined = true; % circleMask가 정의되었음을 표시
                    end

                    for c = 1:3
                        channel = resultFrame(:,:,c);
                        channel(~circleMask) = 255;
                        resultFrame(:,:,c) = channel;
                    end
                end
            end
        end

        % 11. 색상 타깃 인식 (빨강, 초록, 보라)
        % 색상 범위 정의 (RGB)
        colorRanges = struct(...
            'red',   struct('Lower', [140, 0, 0], 'Upper', [255, 100, 100]), ...
            'green', struct('Lower', [0, 100, 0], 'Upper', [80, 255, 100]), ...
            'magenta', struct('Lower', [85, 0, 110], 'Upper', [120, 105, 255])); % 파란색 및 보라색을 모두 포함

        colors = fieldnames(colorRanges);
        detectedColor = '';
        target_center_x = [];
        target_center_y = [];

        for i = 1:numel(colors)
            color = colors{i};
            colorLower = colorRanges.(color).Lower;
            colorUpper = colorRanges.(color).Upper;
        
            % 색상 마스크 생성
            colorMask = (frame(:,:,1) >= colorLower(1) & frame(:,:,1) <= colorUpper(1)) & ...
                        (frame(:,:,2) >= colorLower(2) & frame(:,:,2) <= colorUpper(2)) & ...
                        (frame(:,:,3) >= colorLower(3) & frame(:,:,3) <= colorUpper(3)) & ...
                        circleMask;
        
            % 색상 영역 경계 상자 구하기
            colorStats = regionprops(colorMask, 'BoundingBox', 'Area', 'Centroid');
        
            % 가장 큰 색상 사각형 찾기
            if ~isempty(colorStats)
                [~, colorIdx] = max([colorStats.Area]);
                largestColorBbox = colorStats(colorIdx).BoundingBox;
            
                % 색상 영역 주위에 사각형 그리기
                resultFrame = insertShape(resultFrame, 'Rectangle', largestColorBbox, 'Color', color, 'LineWidth', 3);
            
                % 감지된 색상 저장
                detectedColor = color;

                % 색상 타깃의 중심 좌표 설정
                target_center_x = colorStats(colorIdx).Centroid(1);
                target_center_y = colorStats(colorIdx).Centroid(2);

                break;
            end
        end
        % 결과 이미지 표시
        figure(1);
        imshow(resultFrame);
        title('Detected Color Target');

        img_center_x = size(img_rgb, 2) / 2;
        img_center_y = size(img_rgb, 1) / 2;

        [ring_distance, pixel_destance] = for_freedrone(ring_number, radius, real_radius);

        % 감지된 색상 출력
        disp(['Detected Color: ', detectedColor]);

        % 원본 이미지 및 흑백 처리된 이미지 표시
        figure(2);
        subplot(1, 2, 1);
        imshow(img_rgb);
        title('Original Image');
        hold on;
        if ~isempty(ring_center_x)
            plot(ring_center_x, ring_center_y, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
            text(ring_center_x, ring_center_y, sprintf('Ring\nX: %.3f\nY: %.3f', ring_center_x, ring_center_y), 'Color', 'red', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
        if ~isempty(target_center_x)
            plot(target_center_x, target_center_y, 'g+', 'MarkerSize', 15, 'LineWidth', 2);
            text(target_center_x, target_center_y, sprintf('Target\nX: %.3f\nY: %.3f', target_center_x, target_center_y), 'Color', 'green', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
        hold off;

        subplot(1, 2, 2);
        imshow(blueMask);
        title('Processed Image');
        hold on;
        plot(img_center_x, img_center_y, 'b+', 'MarkerSize', 15, 'LineWidth', 2);
        text(img_center_x, img_center_y, sprintf('Img\nX: %.3f\nY: %.3f', img_center_x, img_center_y), 'Color', 'blue', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        if ~isempty(ring_center_x)
            plot(ring_center_x, ring_center_y, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
            text(ring_center_x, ring_center_y, sprintf('Ring\nX: %.3f\nY: %.3f', ring_center_x, ring_center_y), 'Color', 'red', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
        if ~isempty(target_center_x)
            plot(target_center_x, target_center_y, 'g+', 'MarkerSize', 15, 'LineWidth', 2);
            text(target_center_x, target_center_y, sprintf('Target\nX: %.3f\nY: %.3f', target_center_x, target_center_y), 'Color', 'green', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
        hold off;

        % 링의 중심 좌표와 색상 타깃의 좌표가 일치할 경우
        if ~isempty(ring_center_x) && ~isempty(target_center_x) && abs(ring_center_x - target_center_x) <= options.Tolerance && abs(ring_center_y - target_center_y) <= options.Tolerance
            match_count = match_count + 1;
            x=ring_center_x-img_center_x;

            theta=atan(x/pixel_destance);
            disp(['Detected theta: ', sprintf('%.3f', theta)]);

            turn(tello, theta);

            if strcmp(detectedColor, 'red')
                if(ring_number==1)
                    moveforward(tello, 'Distance', ring_distance+1.45, 'Speed', move_speed);
                elseif(ring_number==3)
                    moveforward(tello, 'Distance', ring_distance+0.75, 'Speed', move_speed);
                end
            else
                moveforward(tello, 'Distance', ring_distance-0.55, 'Speed', move_speed);
            end

        else % 위치 조정 함수 호출
            if ~isempty(ring_center_x) && ~isempty(target_center_x)
                % 드론이 중심 좌표에서 벗어난 경우 위치 보정
                if ring_center_x < target_center_x - tolerance
                    % 드론을 왼쪽으로 이동
                    moveleft(tello, 'Distance', 0.2, 'Speed', move_speed);
                    pause(0.2);
                elseif ring_center_x > target_center_x + tolerance
                    % 드론을 오른쪽으로 이동
                    moveright(tello, 'Distance', 0.2, 'Speed', move_speed);
                    pause(0.2);
                end
                if ring_center_y < target_center_y - tolerance
                    % 드론을 위로 이동
                    moveup(tello, 'Distance', 0.2, 'Speed', move_speed);
                    pause(0.2);
                elseif ring_center_y > target_center_y + tolerance
                    % 드론을 아래로 이동
                    movedown(tello, 'Distance', 0.2, 'Speed', move_speed);
                    pause(0.2);
                end
             else
                % 링 중심이 감지되지 않은 경우 움직인 시도
                if move_attempts == 0
                    moveleft(tello, 'Distance', 0.2, 'Speed', move_speed);
                    pause(0.2);
                    move_attempts = move_attempts + 1;
                elseif move_attempts == 1
                    moveright(tello, 'Distance', 0.4, 'Speed', move_speed);
                    pause(0.2);
                    move_attempts = move_attempts + 1;
                end
            end
        end

        % 링의 중심이 없으면 다시 확인
        pause(0.5);
    end

    hold off;
end

function [ring_distance, pixel_destance] = for_freedrone(ring_number, radius, real_radius)
    if(ring_number==1)
        ring_distance=1.8*156.448/radius;
        pixel_destance = radius * ring_distance * 100 / real_radius;
    elseif(ring_number==2)
        ring_distance=1.8*123.265/radius;
        pixel_destance = radius * ring_distance * 100 / real_radius;
    elseif(ring_number==3)
        ring_distance=1.8*137.345/radius;
        pixel_destance = radius * ring_distance * 100 / real_radius;
    end
    disp(['Detected distance: ', sprintf('%.3f', ring_distance)]);
end