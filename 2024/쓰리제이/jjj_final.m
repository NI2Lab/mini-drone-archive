clear all;
clc;



% 드론 객체 생성 및 카메라 설정
droneObj = ryze();
cam = camera(droneObj);

% 드론 카메라 중점과 파란색 원의 중점 위치 조정 
function moveDroneToBlueCenter(droneObj, cam)
    % 드론 카메라의 중심 좌표
    center = [480, 180];
    
    % 이동 허용 오차
    tolerance = 36;

    while true
        % 이미지 캡처
        pause(2);
        img = snapshot(cam);
        imshow(img);

        % 이미지를 HSV 색상 공간으로 변환
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        % 파란색 영역의 중심점 찾기
        % 파란색 임계값 설정
        blue_threshold = (h > 0.55) & (h < 0.75) & (s > 0.4) & (v > 0.2);

        % Canny 엣지 감지
        canny_img = edge(blue_threshold, 'canny');

        % 윤곽선 검출
        [B, L] = bwboundaries(canny_img, 'noholes');

        % 윤곽선 크기 기준으로 정렬
        boundary_sizes = cellfun(@(x) size(x, 1), B);
        [~, sorted_indices] = sort(boundary_sizes, 'descend');

        % 가장 큰 두 개의 윤곽선 선택
        if length(sorted_indices) > 1
            outer_boundary = B{sorted_indices(1)};
            inner_boundary = B{sorted_indices(2)};
        else
            error('파란색 테두리를 찾을 수 없습니다.');
        end

        % 파란색 테두리의 중심 계산
        inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
        props = regionprops(inner_mask, 'Centroid');
        inner_centroid = props.Centroid;

        % 결과 이미지 표시
        figure;
        imshow(img);
        hold on;
        plot(center(1), center(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2); % 드론 중심점
        plot(inner_centroid(1), inner_centroid(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2); % 파란색 영역 중심점
        title('드론 초점과 파란색 영역의 중심점');
        hold off;

        % 중심점 조정
        % 현재 중심점 간의 오차 계산
        error_x = inner_centroid(1) - center(1);
        error_y = inner_centroid(2) - center(2);

        % 오차를 기준으로 드론 이동
        if abs(error_x) > tolerance
            if error_x > 0
                moveright(droneObj, 'distance', 0.25);
            else
                moveleft(droneObj, 'distance', 0.25);
            end
        end

        if abs(error_y) > tolerance
            if error_y > 0
                movedown(droneObj, 'distance', 0.25);
            else
                moveup(droneObj, 'distance', 0.25);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= tolerance && abs(error_y) <= tolerance
            break;
        end
    end
end


try
    % 드론 이륙
    takeoff(droneObj);
    moveup(droneObj, 'distance', 0.4,'Speed',1);
    moveback(droneObj,'distance', 1,'Speed',1); 

    % 1번째 링
    while true
        % 이미지 캡처
        img = snapshot(cam);
        imshow(img);
        [height, width, ~] = size(img);
        screen_center = [width / 2, height / 2];
        
        % 이미지를 HSV 색상 공간으로 변환
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        %% 파란색 테두리의 중심점 찾기
        % 파란색 임계값 설정
        blue_threshold = (h > 0.55) & (h < 0.75) & (s > 0.4) & (v > 0.2);

        % Canny 엣지 감지
        canny_img = edge(blue_threshold, 'canny');

        % 윤곽선 검출
        [B, L] = bwboundaries(canny_img, 'noholes');
    
        % 윤곽선 크기 기준으로 정렬
        boundary_sizes = cellfun(@(x) size(x, 1), B);
        [~, sorted_indices] = sort(boundary_sizes, 'descend');

        % 가장 큰 두 개의 윤곽선 선택
        if length(sorted_indices) > 1
            outer_boundary = B{sorted_indices(1)};
            inner_boundary = B{sorted_indices(2)};
        else
            error('파란색 테두리를 찾을 수 없습니다.');
        end
    
        % 파란색 테두리의 중심 계산
        inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
        props = regionprops(inner_mask, 'Centroid');

        % 중심점이 없는 경우 처리
        if isempty(props)
            error('파란색 테두리의 중심점을 찾을 수 없습니다.');
        end
        
        inner_centroid = props.Centroid;

        %% 빨간색 마커의 중심점 찾기
        % 빨간색 임계값 설정 (두 영역으로 나뉨: 빨간색은 H값이 0 부근과 1 부근에 분포)
        red_threshold1 = (h > 0.95) & (h <= 1) & (s > 0.5) & (v > 0.2);
        red_threshold2 = (h >= 0) & (h < 0.05) & (s > 0.5) & (v > 0.2);
        red_threshold = red_threshold1 | red_threshold2;

        % 마스크를 바이너리 이미지로 변환
        red_mask = uint8(red_threshold);

        % 레이블링하여 객체 추출
        [labeledImage, numberOfObjects] = bwlabel(red_mask);
        props = regionprops(labeledImage, 'Centroid');

        % 객체가 없을 경우 오류 처리
        if numberOfObjects == 0
            % screen_center와 inner_centorid 비교
            if screen_center(1) < inner_centroid(1)
                moveright(droneObj, 'distance', 0.3,'Speed',1);
            else
                moveleft(droneObj, 'distance', 0.3,'Speed',1);
            end
            
            % 빨간 마커를 다시 찾기 시도
            %pause(1);
            img = snapshot(cam);
            hsv = rgb2hsv(img);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            red_threshold1 = (h > 0.95) & (h <= 1) & (s > 0.5) & (v > 0.2);
            red_threshold2 = (h >= 0) & (h < 0.05) & (s > 0.5) & (v > 0.2);
            red_threshold = red_threshold1 | red_threshold2;
            red_mask = uint8(red_threshold);
            [labeledImage, numberOfObjects] = bwlabel(red_mask);
            props = regionprops(labeledImage, 'Centroid');
            
            if numberOfObjects == 0
                % 빨간 마커를 여전히 찾을 수 없으면 착륙
                land(droneObj);
                error('빨간색 마커를 찾을 수 없습니다.');
            end
        end

        % 가장 큰 객체의 중심점 찾기
        allCentroids = cat(1, props.Centroid);
        area = regionprops(labeledImage, 'Area');
        allAreas = cat(1, area.Area);
        [~, idx] = max(allAreas); % 가장 큰 객체의 인덱스

        red_centroid = allCentroids(idx, :);

        figure;
        imshow(img);
        hold on;
        plot(red_centroid(1), red_centroid(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2); % 빨간색 마커 중심점
        plot(inner_centroid(1), inner_centroid(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2); % 파란색 영역 중심점
        plot(screen_center(1),screen_center(2),'gx', 'MarkerSize', 10, 'LineWidth', 2);
        title('빨간색 마커와 파란색 영역의 중심점');
        hold off;

        %% 중심점 조정
        % 현재 중심점 간의 오차 계산
        error_x = red_centroid(1) - inner_centroid(1);
        error_y = red_centroid(2) - inner_centroid(2);
     
        % 오차를 기준으로 드론 이동
        if abs(error_x) > 20
            if error_x > 0
                moveleft(droneObj, 'distance', 0.2,'Speed',1);
            else
                moveright(droneObj, 'distance', 0.2,'Speed',1);
            end
        end

        if abs(error_y) > 25
            if error_y > 0
                moveup(droneObj, 'distance', 0.2,'Speed',1);
            else
                movedown(droneObj, 'distance', 0.22,'Speed',1);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= 20 && abs(error_y) <= 25
            break;
        end 
    end

    error = screen_center(1) - red_centroid(1);

    if abs(error) > 50
        if error > 0
            %moveleft(droneObj,'distance',0.33)
            turn(droneObj,deg2rad(-8));
        else
          % moveright(droneObj,'distance',0.33)
           turn(droneObj,deg2rad(8));
        end
    end
    
    
    % 링을 통과하는 직선 이동
    moveforward(droneObj, 'distance', 4.4,'Speed',1);
    turn(droneObj,deg2rad(130));
    moveforward(droneObj,'Distance',2.0);
    moveleft(droneObj,'Distance',0.5);
    turn(droneObj,deg2rad(18));

    % 2번째 링
    while true
        pause(1);
        img = snapshot(cam);
        imshow(img);

        % 이미지를 HSV 색상 공간으로 변환
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);


        %% 파란색 영역의 중심점 찾기
        % 파란색 임계값 설정
        blue_threshold = (h > 0.55) & (h < 0.75) & (s > 0.4)&(v>0.2);

        % Canny 엣지 감지
        canny_img = edge(blue_threshold, 'canny');

        % 윤곽선 검출
        [B, L] = bwboundaries(canny_img, 'noholes');
    
        % 윤곽선 크기 기준으로 정렬
        boundary_sizes = cellfun(@(x) size(x, 1), B);
        [~, sorted_indices] = sort(boundary_sizes, 'descend');

        % 가장 큰 두 개의 윤곽선 선택
        if length(sorted_indices) > 1
            outer_boundary = B{sorted_indices(1)};
            inner_boundary = B{sorted_indices(2)};
        else
            error('파란색 테두리를 찾을 수 없습니다.');
        end

        % 파란색 테두리의 중심 계산
        inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
        props = regionprops(inner_mask, 'Centroid');
        inner_centroid = props.Centroid;


        %% 초록색 마커의 중심점 찾기
        % 초록색 임계값 설정 (두 영역으로 나뉨: 빨간색은 H값이 0 부근과 1 부근에 분포)
        green_threshold = (0.25 < h) & (h < 0.4) & (s > 0.3) & (v > 0.3);
       
        % 마스크를 바이너리 이미지로 변환
        green_mask = uint8(green_threshold);

        % 레이블링하여 객체 추출
        [labeledImage, numberOfObjects] = bwlabel(green_mask);
        props = regionprops(labeledImage, 'Centroid');

        % 객체가 없을 경우 오류 처리
        if numberOfObjects == 0
            error('초록색 마커를 찾을 수 없습니다.');
        end

        % 가장 큰 객체의 중심점 찾기
        allCentroids = cat(1, props.Centroid);
        area = regionprops(labeledImage, 'Area');
        allAreas = cat(1, area.Area);
        [~, idx] = max(allAreas); % 가장 큰 객체의 인덱스

        green_centroid = allCentroids(idx, :);

        figure;
        imshow(img);
        hold on;
        plot(green_centroid(1), green_centroid(2), 'gx', 'MarkerSize', 10, 'LineWidth', 2); % 초록색 마커 중심점
        plot(inner_centroid(1), inner_centroid(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2); % 파란색 영역 중심점
        title('초록색 마커와 파란색 영역의 중심점');
        hold off;

        %% 중심점 조정
        % 현재 중심점 간의 오차 계산
        error_x = green_centroid(1) - inner_centroid(1);
        error_y = green_centroid(2) - inner_centroid(2);
     

        % 오차를 기준으로 드론 이동
        if abs(error_x) > 20
            if error_x > 0
                moveright(droneObj, 'distance', 0.20,'Speed',1);
            else
                moveleft(droneObj, 'distance', 0.20,'Speed',1);
            end
        end

        if abs(error_y) > 25
            if error_y > 0
                moveup(droneObj, 'distance', 0.20,'Speed',1);
            else
                movedown(droneObj, 'distance', 0.20,'Speed',1);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= 20 && abs(error_y) <= 25
            break;
        end 

    end

    error = screen_center(1) - green_centroid(1);

    if abs(error) > 50
        if error > 0
            turn(droneObj,deg2rad(-7));
        else
           turn(droneObj,deg2rad(7));
        end
    end
    %moveright(droneObj,'Distance',0.3);
    moveforward(droneObj, 'distance', 2.3,'Speed',1);
    
   

    %원래 포워드 4.4
    %moveforward(droneObj, 'distance', 0.8);
    turn(droneObj,deg2rad(-140));
    moveforward(droneObj,'Distance',0.4);
    moveleft(droneObj,'Distance',0.5);
    moveDroneToBlueCenter(droneObj, cam)
    
    %3번째링

    while true
        img = snapshot(cam);
        imshow(img);
        [height, width, ~] = size(img);
        screen_center = [width / 2, height / 2];
        % 이미지를 HSV 색상 공간으로 변환
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        % 보라색 HSV 범위 설정 (범위를 더 정밀하게 조정)
        hue_min = 0.67;  % 보라색 Hue의 최소값
        hue_max = 0.75;  % 보라색 Hue의 최대값
        sat_min = 0.4;   % 보라색 Saturation의 최소값
        sat_max = 1.0;   % 보라색 Saturation의 최대값
        val_min = 0.2;   % 보라색 Value의 최소값
        val_max = 1.0;   % 보라색 Value의 최대값 

        %% 보라색 마커의 중심점 찾기
        % 보라색 임계값 설정 
         % 보라색 마커 검출
        purple_threshold = (h >= hue_min) & (h <= hue_max) & (s >= sat_min) & (s <= sat_max) & (v >= val_min) & (v <= val_max);
       
        % 마스크를 바이너리 이미지로 변환
        purple_mask = uint8(purple_threshold);

        % 레이블링하여 객체 추출
        [labeledImage, numberOfObjects] = bwlabel(purple_mask);
        props = regionprops(labeledImage, 'Centroid');

        % 객체가 없을 경우 오류 처리
        if numberOfObjects == 0
            error('보라색 마커를 찾을 수 없습니다.');
            continue;
        end

        % 가장 큰 객체의 중심점 찾기
        allCentroids = cat(1, props.Centroid);
        area = regionprops(labeledImage, 'Area');
        allAreas = cat(1, area.Area);
        [~, idx] = max(allAreas); % 가장 큰 객체의 인덱스

        purple_centroid = allCentroids(idx, :);

        %% 파란색 영역의 중심점 찾기
        % 파란색 임계값 설정
        blue_threshold = (h > 0.55) & (h < 0.75) & (s > 0.4) & (v > 0.2);

        % Canny 엣지 감지
        canny_img = edge(blue_threshold, 'canny');

        % 윤곽선 검출
        [B, L] = bwboundaries(canny_img, 'noholes');
    
        % 윤곽선 크기 기준으로 정렬
        boundary_sizes = cellfun(@(x) size(x, 1), B);
        [~, sorted_indices] = sort(boundary_sizes, 'descend');

        % 가장 큰 두 개의 윤곽선 선택
        if length(sorted_indices) > 1
            outer_boundary = B{sorted_indices(1)};
            inner_boundary = B{sorted_indices(2)};
        else
            error('파란색 테두리를 찾을 수 없습니다.');
        end

        % 파란색 테두리의 중심 계산
        inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
        props = regionprops(inner_mask, 'Centroid');
        inner_centroid = props.Centroid;

        figure;
        imshow(img);
        hold on;
        plot(purple_centroid(1), purple_centroid(2), 'mx', 'MarkerSize', 10, 'LineWidth', 2); % 보라색 마커 중심점
        plot(inner_centroid(1), inner_centroid(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2); % 파란색 영역 중심점
        title('보라색 마커와 파란색 영역의 중심점');
        hold off;

       error_x = purple_centroid(1) - inner_centroid(1);
       error_y = purple_centroid(2) - inner_centroid(2);
     

        % 오차를 기준으로 드론 이동

        if abs(error_x) > 20
            if error_x >  0
                moveleft(droneObj, 'distance', 0.2);
            else 
                moveright(droneObj, 'distance', 0.2);
            end       
        end

     
        if abs(error_y) > 25
            if error_y > 0
                moveup(droneObj, 'distance', 0.2);
            else
                movedown(droneObj, 'distance', 0.2);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= 20 && abs(error_y) <= 25
            break;
        end 
    end

     error = screen_center(1) - purple_centroid(1);

    if abs(error) > 50
        if error > 0
            turn(droneObj,deg2rad(-9))
        else
           turn(droneObj,deg2rad(9))
        end
    end

    moveforward(droneObj,'Distance',2.0,'Speed',1);
    turn(droneObj, deg2rad(230));
    moveleft(droneObj, 'distance', 1.3,'Speed',1);
    moveforward(droneObj,'Distance',0.2,'Speed',1);
    pause(1);
    moveup(droneObj,'Distance',0.4);
    moveDroneToBlueCenter(droneObj, cam);


   % 4번째링
    while true
        % 이미지 캡처
        pause(1);
        img = snapshot(cam);
        imshow(img);
        [height, width, ~] = size(img);
        screen_center = [width / 2, height / 2];
        
        % 이미지를 HSV 색상 공간으로 변환
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        %% 파란색 테두리의 중심점 찾기
        % 파란색 임계값 설정
        blue_threshold = (h > 0.55) & (h < 0.75) & (s > 0.4) & (v > 0.2);

        % Canny 엣지 감지
        canny_img = edge(blue_threshold, 'canny');

        % 윤곽선 검출
        [B, L] = bwboundaries(canny_img, 'noholes');
    
        % 윤곽선 크기 기준으로 정렬
        boundary_sizes = cellfun(@(x) size(x, 1), B);
        [~, sorted_indices] = sort(boundary_sizes, 'descend');

        % 가장 큰 두 개의 윤곽선 선택
        if length(sorted_indices) > 1
            outer_boundary = B{sorted_indices(1)};
            inner_boundary = B{sorted_indices(2)};
        else
            error('파란색 테두리를 찾을 수 없습니다.');
        end
    
        % 파란색 테두리의 중심 계산
        inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
        props = regionprops(inner_mask, 'Centroid');

        % 중심점이 없는 경우 처리
        if isempty(props)
            error('파란색 테두리의 중심점을 찾을 수 없습니다.');
        end
        
        inner_centroid = props.Centroid;

        %% 빨간색 마커의 중심점 찾기
        % 빨간색 임계값 설정 (두 영역으로 나뉨: 빨간색은 H값이 0 부근과 1 부근에 분포)
        red_threshold1 = (h > 0.95) & (h <= 1) & (s > 0.5) & (v > 0.2);
        red_threshold2 = (h >= 0) & (h < 0.05) & (s > 0.5) & (v > 0.2);
        red_threshold = red_threshold1 | red_threshold2;

        % 마스크를 바이너리 이미지로 변환
        red_mask = uint8(red_threshold);

        % 레이블링하여 객체 추출
        [labeledImage, numberOfObjects] = bwlabel(red_mask);
        props = regionprops(labeledImage, 'Centroid');

        % 객체가 없을 경우 오류 처리
        if numberOfObjects == 0
            % screen_center와 inner_centorid 비교
            if screen_center(1) < inner_centroid(1)
                moveright(droneObj, 'distance', 0.3,'Speed',1);
            else
                moveleft(droneObj, 'distance', 0.3,'Speed',1);
            end
            
            % 빨간 마커를 다시 찾기 시도
            %pause(1);
            img = snapshot(cam);
            hsv = rgb2hsv(img);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            red_threshold1 = (h > 0.95) & (h <= 1) & (s > 0.5) & (v > 0.2);
            red_threshold2 = (h >= 0) & (h < 0.05) & (s > 0.5) & (v > 0.2);
            red_threshold = red_threshold1 | red_threshold2;
            red_mask = uint8(red_threshold);
            [labeledImage, numberOfObjects] = bwlabel(red_mask);
            props = regionprops(labeledImage, 'Centroid');
            
            if numberOfObjects == 0
                % 빨간 마커를 여전히 찾을 수 없으면 착륙
                land(droneObj);
                error('빨간색 마커를 찾을 수 없습니다.');
            end
        end

        % 가장 큰 객체의 중심점 찾기
        allCentroids = cat(1, props.Centroid);
        area = regionprops(labeledImage, 'Area');
        allAreas = cat(1, area.Area);
        [~, idx] = max(allAreas); % 가장 큰 객체의 인덱스

        red_centroid = allCentroids(idx, :);

        figure;
        imshow(img);
        hold on;
        plot(red_centroid(1), red_centroid(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2); % 빨간색 마커 중심점
        plot(inner_centroid(1), inner_centroid(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2); % 파란색 영역 중심점
        plot(screen_center(1),screen_center(2),'gx', 'MarkerSize', 10, 'LineWidth', 2);
        title('빨간색 마커와 파란색 영역의 중심점');
        hold off;

        %% 중심점 조정
        % 현재 중심점 간의 오차 계산
        error_x = red_centroid(1) - inner_centroid(1);
        error_y = red_centroid(2) - inner_centroid(2);
     
        % 오차를 기준으로 드론 이동
        if abs(error_x) > 20
            if error_x > 0
                moveleft(droneObj, 'distance', 0.2,'Speed',1);
            else
                moveright(droneObj, 'distance', 0.2,'Speed',1);
            end
        end

        if abs(error_y) > 25
            if error_y > 0
                moveup(droneObj, 'distance', 0.2,'Speed',1);
            else
                movedown(droneObj, 'distance', 0.22,'Speed',1);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= 20 && abs(error_y) <= 25
            break;
        end 
    end

    error = screen_center(1) - red_centroid(1);

    if abs(error) > 50
        if error > 0     
            turn(droneObj,deg2rad(-15));
        else
           turn(droneObj,deg2rad(15));
        end
    end

    moveforward(droneObj, 'distance',0.5);

    while true
        % 이미지 캡처
        pause(1);
        img = snapshot(cam);
        imshow(img);
        [height, width, ~] = size(img);
        screen_center = [width / 2, height / 2];
        
        % 이미지를 HSV 색상 공간으로 변환
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        %% 파란색 테두리의 중심점 찾기
        % 파란색 임계값 설정
        blue_threshold = (h > 0.55) & (h < 0.75) & (s > 0.4) & (v > 0.2);

        % Canny 엣지 감지
        canny_img = edge(blue_threshold, 'canny');

        % 윤곽선 검출
        [B, L] = bwboundaries(canny_img, 'noholes');
    
        % 윤곽선 크기 기준으로 정렬
        boundary_sizes = cellfun(@(x) size(x, 1), B);
        [~, sorted_indices] = sort(boundary_sizes, 'descend');

        % 가장 큰 두 개의 윤곽선 선택
        if length(sorted_indices) > 1
            outer_boundary = B{sorted_indices(1)};
            inner_boundary = B{sorted_indices(2)};
        else
            error('파란색 테두리를 찾을 수 없습니다.');
        end
    
        % 파란색 테두리의 중심 계산
        inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
        props = regionprops(inner_mask, 'Centroid');

        % 중심점이 없는 경우 처리
        if isempty(props)
            error('파란색 테두리의 중심점을 찾을 수 없습니다.');
        end
        
        inner_centroid = props.Centroid;

        %% 빨간색 마커의 중심점 찾기
        % 빨간색 임계값 설정 (두 영역으로 나뉨: 빨간색은 H값이 0 부근과 1 부근에 분포)
        red_threshold1 = (h > 0.95) & (h <= 1) & (s > 0.5) & (v > 0.2);
        red_threshold2 = (h >= 0) & (h < 0.05) & (s > 0.5) & (v > 0.2);
        red_threshold = red_threshold1 | red_threshold2;

        % 마스크를 바이너리 이미지로 변환
        red_mask = uint8(red_threshold);

        % 레이블링하여 객체 추출
        [labeledImage, numberOfObjects] = bwlabel(red_mask);
        props = regionprops(labeledImage, 'Centroid');

        % 객체가 없을 경우 오류 처리
        if numberOfObjects == 0
            % screen_center와 inner_centorid 비교
            if screen_center(1) < inner_centroid(1)
                moveright(droneObj, 'distance', 0.3,'Speed',1);
            else
                moveleft(droneObj, 'distance', 0.3,'Speed',1);
            end
            
            % 빨간 마커를 다시 찾기 시도
            %pause(1);
            img = snapshot(cam);
            hsv = rgb2hsv(img);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
            v = hsv(:,:,3);
            red_threshold1 = (h > 0.95) & (h <= 1) & (s > 0.5) & (v > 0.2);
            red_threshold2 = (h >= 0) & (h < 0.05) & (s > 0.5) & (v > 0.2);
            red_threshold = red_threshold1 | red_threshold2;
            red_mask = uint8(red_threshold);
            [labeledImage, numberOfObjects] = bwlabel(red_mask);
            props = regionprops(labeledImage, 'Centroid');
            
            if numberOfObjects == 0
                % 빨간 마커를 여전히 찾을 수 없으면 착륙
                land(droneObj);
                error('빨간색 마커를 찾을 수 없습니다.');
            end
        end

        % 가장 큰 객체의 중심점 찾기
        allCentroids = cat(1, props.Centroid);
        area = regionprops(labeledImage, 'Area');
        allAreas = cat(1, area.Area);
        [~, idx] = max(allAreas); % 가장 큰 객체의 인덱스

        red_centroid = allCentroids(idx, :);

        figure;
        imshow(img);
        hold on;
        plot(red_centroid(1), red_centroid(2), 'rx', 'MarkerSize', 10, 'LineWidth', 2); % 빨간색 마커 중심점
        plot(inner_centroid(1), inner_centroid(2), 'bx', 'MarkerSize', 10, 'LineWidth', 2); % 파란색 영역 중심점
        plot(screen_center(1),screen_center(2),'gx', 'MarkerSize', 10, 'LineWidth', 2);
        title('빨간색 마커와 파란색 영역의 중심점');
        hold off;

        %% 중심점 조정
        % 현재 중심점 간의 오차 계산
        error_x = red_centroid(1) - inner_centroid(1);
        error_y = red_centroid(2) - inner_centroid(2);
     
        % 오차를 기준으로 드론 이동
        if abs(error_x) > 20
            if error_x > 0
                moveleft(droneObj, 'distance', 0.2,'Speed',1);
            else
                moveright(droneObj, 'distance', 0.2,'Speed',1);
            end
        end

        if abs(error_y) > 25
            if error_y > 0
                moveup(droneObj, 'distance', 0.2,'Speed',1);
            else
                movedown(droneObj, 'distance', 0.22,'Speed',1);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= 20 && abs(error_y) <= 25
            break;
        end 
    end

    error = screen_center(1) - red_centroid(1);

    if abs(error) > 50
        if error > 0     
            turn(droneObj,deg2rad(-15));
        else
           turn(droneObj,deg2rad(15));
        end
    end

    moveforward(droneObj, 'distance',2.5);
    land(droneObj);


catch ME
    % 오류가 발생하면 드론 착륙
    land(droneObj);
    rethrow(ME);
 
end

