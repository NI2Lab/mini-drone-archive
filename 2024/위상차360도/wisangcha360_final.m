rotate_angle=0; %색상을 링의 중앙에 맞추기 위해 드론을 회전하는 각도를 저장하는 변수
dis=0; %드론이 얼마만큼 뒤로 이동했는지 확인하는 변수
angle=0; %드론이 색상을 링의 중앙에 맞추기 위해 얼마만큼 돌았는지 저장하는 변수

% 링을 알아보기 위한 파랑색 hsv 범위 설정
blue_hue_min = 0.5;
blue_hue_max = 0.7;
blue_sat_min = 0.4;
blue_val_min = 0.2;

% 빨간색 hsv 범위 설정
red_hue_min1 = 0; 
red_hue_max1 = 0.05;
red_hue_min2 = 0.95;
red_hue_max2 = 1.0;
red_sat_min = 0.5;
red_sat_max = 0.9;
red_val_min = 0.5;
red_val_max = 0.9;

% 초록색 hsv 범위 설정
green_hue_min = 0.3;
green_hue_max = 0.55;
green_sat_min = 0.4;
green_val_min = 0.4;
green_sat_max = 0.8;
green_val_max = 0.8;

% 보라색 범위 설정
purple_hue_min = 0.65;
purple_hue_max = 0.77;
purple_sat_min = 0.4;
purple_val_min = 0.4;
purple_sat_max = 0.8;
purple_val_max = 0.8;

droneObj = ryze();
cameraObj = camera(droneObj);
preview(cameraObj);
takeoff(droneObj);
moveup(droneObj, 'Distance', 0.25, 'Speed', 1); %링을 한번에 인식하기 위해 드론 위로 이동

% 1st stage
%이미지 중앙이 드론의 위치라 생각하고 이미지 캡쳐 및 중앙점 계산
img = snapshot(cameraObj);
[height, width, ~] = size(img);
image_center = [width / 2, height / 2];

center_on_hole(droneObj, cameraObj, blue_hue_min, blue_hue_max, blue_sat_min, blue_val_min, img, image_center, dis);%드론을 링의 중앙에 맞추기 위한 함수
moveforward(droneObj, 'Distance', 1.9+dis, 'Speed', 1); %색상을 정확히 인식하고 링의 중앙에 맞추기 위해 전진

%빨강색을 찾기 위해 사진 캡쳐 및 hsv로 추출
img = snapshot(cameraObj);
hsv_img = rgb2hsv(img);
H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);
red_mask = ((H >= red_hue_min1) & (H <= red_hue_max1) | (H >= red_hue_min2) & (H <= red_hue_max2)) & (S >= red_sat_min) & (S <= red_sat_max) & (V >= red_val_min) & (V <= red_val_max);

while 1
    if any(red_mask(:)) %빨강색을 인식할 경우
         fprintf('빨간색을 인식했습니다.\n');

        % 빨간색 사각형의 중점 찾기
        red_stats = regionprops(red_mask, 'Centroid', 'BoundingBox', 'Area');
        if ~isempty(red_stats)
            max_area = 0;
            red_centroid = [];
            red_bbox = [];
            for k = 1:numel(red_stats)
                if red_stats(k).Area > max_area
                    max_area = red_stats(k).Area;
                    red_centroid = red_stats(k).Centroid;
                    red_bbox = red_stats(k).BoundingBox;
                end
            end
            fprintf('빨간색 사각형의 중점 좌표: (%.1f, %.1f)\n', red_centroid(1), red_centroid(2));
        end

        target_x = red_centroid(1) - image_center(1); %현재 위치와 색상 중점의 차이 계산

        while abs(target_x) > 35  % x좌표가 오차범위 35픽셀이 될때까지 아래 반복
           if target_x > 0 %빨강색이 이미지 중점보다 오른쪽에 있을시 드론을 5도 회전
              turn(droneObj, deg2rad(5));
              rotate_angle=5;
              angle=angle+5;
           elseif target_x < 0 %빨강색이 이미지 중점보다 왼쪽에 있을시 드론을 -5도 회전
              turn(droneObj, deg2rad(-5));
              rotate_angle=-5;
              angle=angle-5;
           end

           % 다시 한 번 이미지를 캡처하여 빨강색의 중점 좌표 업데이트
           img = snapshot(cameraObj);
           hsv_img = rgb2hsv(img);
           H = hsv_img(:,:,1);
           S = hsv_img(:,:,2);
           V = hsv_img(:,:,3);
               
           % 빨간색 사각형의 중점 및 경계 업데이트
           red_mask = ((H >= red_hue_min1) & (H <= red_hue_max1) | (H >= red_hue_min2) & (H <= red_hue_max2)) & (S >= red_sat_min) & (S <= red_sat_max) & (V >= red_val_min) & (V <= red_val_max);
           red_stats = regionprops(red_mask, 'Centroid', 'BoundingBox', 'Area');
           if ~isempty(red_stats)
           max_area = 0;
           red_centroid = [];
           red_bbox = [];
            for k = 1:numel(red_stats)
                if red_stats(k).Area > max_area
                        max_area = red_stats(k).Area;
                        red_centroid = red_stats(k).Centroid;
                        red_bbox = red_stats(k).BoundingBox;
                end
            end
                fprintf('새로운 빨간색 사각형의 중점 좌표: (%.1f, %.1f)\n', red_centroid(1), red_centroid(2));
           end
               
            if ~isempty(red_centroid) %중점을 찾을시 거리 업데이트                            
                target_x = red_centroid(1) - image_center(1);
            else % 못 찾을시 그전의 값이 우리가 설정한 오차범위보다 약간 높다고 인식
                %이전에 회전한 각도에 따라 반대로 회전시켜 색상을 인식했을 때로 원상복구  
                if rotate_angle==5 
                    turn(droneObj, deg2rad(-5));
                    angle=angle-5;
                elseif rotate_angle==-5
                    turn(droneObj, deg2rad(5));
                    angle=angle+5;
                end
                break;
            end
        end  
    %드론을 전진후 다음단계를 위해 회전    
    moveforward(droneObj, 'Distance', 1.8, 'Speed', 1);
    turn(droneObj, deg2rad(130-angle));
    break;
    else %인식하지 못할 경우 원의 중점 기준으로 그냥 직진후 회전
      fprintf('빨간색을 인식하지 못했습니다.\n');
      moveforward(droneObj, 'Distance', 1.8, 'Speed', 1);
      turn(droneObj, deg2rad(130));
      break;
    end
end
rotate_angle=0; %각도 초기화
dis=0; %거리 초기화
angle=0;%각도 초기화

%2nd stage
%드론 전진 및 드론을 링의 중앙에 맞추고 색상을 인식하기 위해 다시 드론 전진
moveforward(droneObj, 'Distance', 2, 'Speed', 1);
img = snapshot(cameraObj);
center_on_hole(droneObj, cameraObj, blue_hue_min, blue_hue_max, blue_sat_min, blue_val_min, img, image_center, dis);
moveforward(droneObj, 'Distance', 2+dis, 'Speed', 1);

%초록색을 찾기 위해 사진 캡쳐 및 hsv로 추출
img = snapshot(cameraObj);
hsv_img = rgb2hsv(img);
H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);
green_mask = (H >= green_hue_min) & (H <= green_hue_max) & (S >= green_sat_min) & (S <= green_sat_max) & (V >= green_val_min) & (V <= green_val_max);

while 1
    if any(green_mask(:))%초록색 인식했을 시
         fprintf('초록색을 인식했습니다.\n');

        % 초록색 사각형의 중점 찾기
        green_stats = regionprops(green_mask, 'Centroid', 'BoundingBox', 'Area');
        if ~isempty(green_stats)
            max_area = 0;
            green_centroid = [];
            green_bbox = [];
            for k = 1:numel(green_stats)
                if green_stats(k).Area > max_area
                    max_area = green_stats(k).Area;
                    green_centroid = green_stats(k).Centroid;
                    green_bbox = green_stats(k).BoundingBox;
                end
            end
            fprintf('초록색 사각형의 중점 좌표: (%.1f, %.1f)\n', green_centroid(1), green_centroid(2));
        end

        target_x = green_centroid(1) - image_center(1);%현재 위치와 색상 중점의 차이 계산

        while abs(target_x) > 35  % x좌표가 오차범위 35픽셀이 될때까지 아래 반복
           if target_x > 0 %초록색이 이미지 중점보다 오른쪽에 있을시 드론을 5도 회전
              turn(droneObj, deg2rad(5));
              rotate_angle=5;
              angle=angle+5;
           elseif target_x < 0 %초록색이 이미지 중점보다 왼쪽에 있을시 드론을 -5도 회전
              turn(droneObj, deg2rad(-5));
              rotate_angle=-5;
              angle=angle-5;
           end

           % 다시 한 번 이미지를 캡처하여 초록색 중점 좌표 업데이트
           img = snapshot(cameraObj);
           hsv_img = rgb2hsv(img);
           H = hsv_img(:,:,1);
           S = hsv_img(:,:,2);
           V = hsv_img(:,:,3);
               
           % 초록색 사각형의 중점 및 경계 업데이트
           green_mask = (H >= green_hue_min) & (H <= green_hue_max) & (S >= green_sat_min) & (S <= green_sat_max) & (V >= green_val_min) & (V <= green_val_max);
           green_stats = regionprops(green_mask, 'Centroid', 'BoundingBox', 'Area');
           if ~isempty(green_stats)
           max_area = 0;
           green_centroid = [];
           green_bbox = [];
            for k = 1:numel(green_stats)
                if green_stats(k).Area > max_area
                        max_area = green_stats(k).Area;
                        green_centroid = green_stats(k).Centroid;
                        green_bbox = green_stats(k).BoundingBox;
                end
            end
                fprintf('새로운 초록색 사각형의 중점 좌표: (%.1f, %.1f)\n', green_centroid(1), green_centroid(2));
           end
               
            if ~isempty(green_centroid)%중점을 찾을시 거리 업데이트    
                target_x = green_centroid(1) - image_center(1);
            else% 못 찾을시 그전의 값이 우리가 설정한 오차범위보다 약간 높다고 인식
                %이전에 회전한 각도에 따라 반대로 회전시켜 색상을 인식했을 때로 원상복구  
                if rotate_angle==5 
                    turn(droneObj, deg2rad(-5));
                    angle=angle-5;
                elseif rotate_angle==-5
                    turn(droneObj, deg2rad(5));
                    angle=angle+5;
                end
                break;
            end
        end  
    %드론을 전진후 다음단계를 위해 회전       
    moveforward(droneObj, 'Distance', 1.2, 'Speed', 1);
    turn(droneObj, deg2rad(-130-angle)); 
    break;
    else %초록색을 인식하지 못했을 시 아래 코드 수행
      fprintf('초록색을 인식하지 못했습니다.\n');
      %드론을 전진후 다음단계를 위해 회전       
      moveforward(droneObj, 'Distance', 1.2, 'Speed', 1);
      turn(droneObj, deg2rad(-130)); 
      break;
    end
end
rotate_angle=0;%드론각도 초기화
dis=0;%거리 초기화
angle=0;%드론각도 초기화

%3rd stage
%이미지 캡쳐후 드론을 링의 중앙에 맞추고 다시 캡쳐해서 보라색 인식
img = snapshot(cameraObj);
center_on_hole(droneObj, cameraObj, blue_hue_min, blue_hue_max, blue_sat_min, blue_val_min, img, image_center, dis);
moveforward(droneObj, 'Distance', 1.5+dis, 'Speed', 1);
img = snapshot(cameraObj);
hsv_img = rgb2hsv(img);
H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);
purple_mask = (H >= purple_hue_min) & (H <= purple_hue_max) & (S >= purple_sat_min) & (S <= purple_sat_max) & (V >= purple_val_min) & (V <= purple_val_max);

while 1
    if any(purple_mask(:)) %보라색 인식시
         fprintf('보라색을 인식했습니다.\n');

        % 보라색 사각형의 중점 찾기
        purple_stats = regionprops(purple_mask, 'Centroid', 'BoundingBox', 'Area');
        if ~isempty(purple_stats)
            max_area = 0;
            purple_centroid = [];
            purple_bbox = [];
            for k = 1:numel(purple_stats)
                if purple_stats(k).Area > max_area
                    max_area = purple_stats(k).Area;
                    purple_centroid = purple_stats(k).Centroid;
                    purple_bbox = purple_stats(k).BoundingBox;
                end
            end
            fprintf('보라색 사각형의 중점 좌표: (%.1f, %.1f)\n', purple_centroid(1), purple_centroid(2));
        end

        target_x = purple_centroid(1) - image_center(1);%현재 위치와 색상 중점의 차이 계산

        while abs(target_x) > 35  % x좌표가 오차범위 35픽셀이 될때까지 아래 반복
           if target_x > 0 %보라색이 이미지 중점보다 오른쪽에 있을시 드론을 5도 회전
              turn(droneObj, deg2rad(5));
              rotate_angle=5;
              angle=angle+5;
           elseif target_x < 0 %보라색이 이미지 중점보다 왼쪽에 있을시 드론을 -5도 회전
              turn(droneObj, deg2rad(-5));
              rotate_angle=-5;
              angle=angle-5;
           end

           % 다시 한 번 이미지를 캡처하여 보라색 중점 좌표 업데이트
           img = snapshot(cameraObj);
           hsv_img = rgb2hsv(img);
           H = hsv_img(:,:,1);
           S = hsv_img(:,:,2);
           V = hsv_img(:,:,3);
               
           % 보라색 사각형의 중점 및 경계 업데이트
           purple_mask = (H >= purple_hue_min) & (H <= purple_hue_max) & (S >= purple_sat_min) & (S <= purple_sat_max) & (V >= purple_val_min) & (V <= purple_val_max);
           purple_stats = regionprops(purple_mask, 'Centroid', 'BoundingBox', 'Area');
           if ~isempty(purple_stats)
           max_area = 0;
           purple_centroid = [];
           purple_bbox = [];
            for k = 1:numel(purple_stats)
                if purple_stats(k).Area > max_area
                        max_area = purple_stats(k).Area;
                        purple_centroid = purple_stats(k).Centroid;
                        purple_bbox = purple_stats(k).BoundingBox;
                end
            end
                fprintf('새로운 보라색 사각형의 중점 좌표: (%.1f, %.1f)\n', purple_centroid(1), purple_centroid(2));
           end
               
            if ~isempty(purple_centroid)%중점을 찾을시 거리 업데이트    
                target_x = purple_centroid(1) - image_center(1);
            else% 못 찾을시 그전의 값이 우리가 설정한 오차범위보다 약간 높다고 인식
                %이전에 회전한 각도에 따라 반대로 회전시켜 색상을 인식했을 때로 원상복구  
                if rotate_angle==5
                    turn(droneObj, deg2rad(-5));
                    angle=angle-5;
                elseif rotate_angle==-5
                    turn(droneObj, deg2rad(5));
                    angle=angle+5;
                end
                break;
            end
        end 
    %드론을 전진후 다음단계를 위해 회전   
    moveforward(droneObj, 'Distance', 1.7, 'Speed', 1);
    turn(droneObj, deg2rad(215-angle)); 
    break;

    else %보라색을 인식하지 못할 경우 아래 코드 수행
      fprintf('보라색을 인식하지 못했습니다.\n');
      %드론을 전진후 다음단계를 위해 회전   
      moveforward(droneObj, 'Distance', 1.7, 'Speed', 1);
      turn(droneObj, deg2rad(215)); 
      break;
    end
end
rotate_angle=0;%각도 초기화
dis=0; %길이 초기화

%last stage
%이미지 캡쳐후 드론을 링의 중앙에 위치시킨후 빨강색 인식을 위해 전진
moveforward(droneObj, 'Distance', 1, 'Speed', 1);
img = snapshot(cameraObj);
center_on_hole(droneObj, cameraObj, blue_hue_min, blue_hue_max, blue_sat_min, blue_val_min, img, image_center, dis);
moveforward(droneObj, 'Distance', 2+dis, 'Speed', 1);

%이미지 캡쳐후 hsv로 빨강색 추출
img = snapshot(cameraObj);
hsv_img = rgb2hsv(img);
H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);
red_mask = ((H >= red_hue_min1) & (H <= red_hue_max1) | (H >= red_hue_min2) & (H <= red_hue_max2)) & (S >= red_sat_min) & (S <= red_sat_max) & (V >= red_val_min) & (V <= red_val_max);

while 1
    if any(red_mask(:)) %빨강색 인식시
         fprintf('빨간색을 인식했습니다.\n');

        % 빨간색 사각형의 중점 찾기
        red_stats = regionprops(red_mask, 'Centroid', 'BoundingBox', 'Area');
        if ~isempty(red_stats)
            max_area = 0;
            red_centroid = [];
            red_bbox = [];
            for k = 1:numel(red_stats)
                if red_stats(k).Area > max_area
                    max_area = red_stats(k).Area;
                    red_centroid = red_stats(k).Centroid;
                    red_bbox = red_stats(k).BoundingBox;
                end
            end
            fprintf('빨간색 사각형의 중점 좌표: (%.1f, %.1f)\n', red_centroid(1), red_centroid(2));
        end

        target_x = red_centroid(1) - image_center(1);%현재 위치와 색상 중점의 차이 계산

        while abs(target_x) > 35  % x좌표가 오차범위 35픽셀이 될때까지 아래 반복
           if target_x > 0 %빨강색이 이미지 중점보다 오른쪽에 있을시 드론을 5도 회전
              turn(droneObj, deg2rad(5));
              rotate_angle=5;
           elseif target_x < 0 %빨강색이 이미지 중점보다 왼쪽에 있을시 드론을 -5도 회전
              turn(droneObj, deg2rad(-5));
              rotate_angle=-5;
           end

           % 다시 한 번 이미지를 캡처하여 빨강색 중점 좌표 업데이트
           img = snapshot(cameraObj);
           hsv_img = rgb2hsv(img);
           H = hsv_img(:,:,1);
           S = hsv_img(:,:,2);
           V = hsv_img(:,:,3);
               
           % 빨간색 사각형의 중점 및 경계 업데이트
           red_mask = ((H >= red_hue_min1) & (H <= red_hue_max1) | (H >= red_hue_min2) & (H <= red_hue_max2)) & (S >= red_sat_min) & (S <= red_sat_max) & (V >= red_val_min) & (V <= red_val_max);
           red_stats = regionprops(red_mask, 'Centroid', 'BoundingBox', 'Area');
           if ~isempty(red_stats)
           max_area = 0;
           red_centroid = [];
           red_bbox = [];
            for k = 1:numel(red_stats)
                if red_stats(k).Area > max_area
                        max_area = red_stats(k).Area;
                        red_centroid = red_stats(k).Centroid;
                        red_bbox = red_stats(k).BoundingBox;
                end
            end
                fprintf('새로운 빨간색 사각형의 중점 좌표: (%.1f, %.1f)\n', red_centroid(1), red_centroid(2));
           end
               
            if ~isempty(red_centroid)%중점을 찾을시 거리 업데이트    
                target_x = red_centroid(1) - image_center(1);
            else% 못 찾을시 그전의 값이 우리가 설정한 오차범위보다 약간 높다고 인식
                %이전에 회전한 각도에 따라 반대로 회전시켜 색상을 인식했을 때로 원상복구  
                if rotate_angle==5
                    turn(droneObj, deg2rad(-5));
                elseif rotate_angle==-5
                    turn(droneObj, deg2rad(5));
                end
                break;
            end
        end  
    %드론을 전진후 착륙
    moveforward(droneObj, 'Distance', 1.55, 'Speed', 1);
    land(droneObj);
    closePreview(cameraObj);
    break;
  else
      fprintf('빨간색을 인식하지 못했습니다.\n');
      %드론을 전진후 착륙
      moveforward(droneObj, 'Distance', 1.55, 'Speed', 1);
      land(droneObj);
      closePreview(cameraObj);
      break;
    end
end

% 드론을 링의 중심으로 이동시키는 함수 정의
function center_on_hole(droneObj, cameraObj, hue_min, hue_max, sat_min, val_min, img, image_center, dis)
    %링의 파랑색을 hsv로 추출하여 중점 찾기
    hsv_img = rgb2hsv(img);
    H = hsv_img(:,:,1);
    S = hsv_img(:,:,2);
    V = hsv_img(:,:,3);
    color_mask = (H >= hue_min) & (H <= hue_max) & (S >= sat_min) & (V >= val_min);
    [B, L, N, A] = bwboundaries(color_mask);
    max_area = 0;
    max_centroid = [];

    for k = 1:N
        if (nnz(A(:,k)) > 0)
            boundary = B{k};
            for l = find(A(:,k))'
                hole_stats = regionprops(L == l, 'Centroid', 'Area');
                centroid = hole_stats.Centroid;
                area = hole_stats.Area;

                if area > max_area
                    max_area = area;
                    max_centroid = centroid;
                end
            end
        end
    end

    if ~isempty(max_centroid) % 중점을 찾을시
        
        target_y = max_centroid(2) - image_center(2); % 링의 중점과 드론의 위치의 y좌표 차이 계산

        while abs(target_y) > 190 %실제 드론이 카메라를 통해 보는 방향은 약간 아래를 향하고 있으므로 범위를 이와 같이 설정
            if target_y > 170 %170이상일 경우 드론을 아래로 이동
                movedown(droneObj, 'Distance', 0.2, 'Speed', 1);
            elseif target_y < 170 %이하일 경우 드론을 위로 이동
                moveup(droneObj, 'Distance', 0.2, 'Speed', 1);
            end

            %다시 이미지를 캡쳐하여 파랑색을 hsv로 추출후 링의 중앙 찾기
            img = snapshot(cameraObj);
            hsv_img = rgb2hsv(img);
            H = hsv_img(:,:,1);
            S = hsv_img(:,:,2);
            V = hsv_img(:,:,3);
            color_mask = (H >= hue_min) & (H <= hue_max) & (S >= sat_min) & (V >= val_min);
            [B, L, N, A] = bwboundaries(color_mask);
            max_area = 0;
            max_centroid = [];

            for k = 1:N
                if (nnz(A(:,k)) > 0)
                    boundary = B{k};
                    for l = find(A(:,k))'
                        hole_stats = regionprops(L == l, 'Centroid', 'Area');
                        centroid = hole_stats.Centroid;
                        area = hole_stats.Area;

                        if area > max_area
                            max_area = area;
                            max_centroid = centroid;
                        end
                    end
                end
            end

            if ~isempty(max_centroid)%찾았을시 거리계산
                target_y = max_centroid(2) - image_center(2);
            else %중점을 찾지 못했을 때 링을 제대로 인식하기 위해 뒤로 이동
                moveback(droneObj,'Distance',0.2, 'Speed', 1);
                fprintf('구멍의 중점을 찾지 못했습니다.\n');
                dis=dis+0.2;
            end
        end

        target_x = max_centroid(1) - image_center(1); %y좌표 계산 끝나면 x좌표 계산

        while abs(target_x) > 40 %오차범위 40픽셀 안으로 들어올때까지 아래 반복
            if target_x > 0 %링의 중앙이 드론의 위치보다 앞에 있을 시 드론을 오른쪽으로 이동
                moveright(droneObj, 'Distance', 0.2, 'Speed', 1);
            elseif target_x < 0 %링의 중앙이 드론의 위치보다 뒤에 있을시 드론을 왼쪽으로 이동 
                moveleft(droneObj, 'Distance', 0.2, 'Speed', 1);
            end

            %다시 한번 링의 중앙을 계산하기 위해 이미지 캡쳐후 hsv로 파랑색 추출
            img = snapshot(cameraObj);
            hsv_img = rgb2hsv(img);
            H = hsv_img(:,:,1);
            S = hsv_img(:,:,2);
            V = hsv_img(:,:,3);
            color_mask = (H >= hue_min) & (H <= hue_max) & (S >= sat_min) & (V >= val_min);
            [B, L, N, A] = bwboundaries(color_mask);
            max_area = 0;
            max_centroid = [];

            for k = 1:N
                if (nnz(A(:,k)) > 0)
                    boundary = B{k};
                    for l = find(A(:,k))'
                        hole_stats = regionprops(L == l, 'Centroid', 'Area');
                        centroid = hole_stats.Centroid;
                        area = hole_stats.Area;

                        if area > max_area
                            max_area = area;
                            max_centroid = centroid;
                        end
                    end
                end
            end

            if ~isempty(max_centroid) %링의 중앙을 찾았을 시 거리계산
                target_x = max_centroid(1) - image_center(1);              
            else %못찾을시 링을 확인하기 위해 뒤로 드론 이동 
                moveback(droneObj,'Distance',0.2, 'Speed', 1);
                fprintf('구멍의 중점을 찾지 못했습니다.\n');
                dis=dis+0.2;
            end
        end
    else
        fprintf('구멍의 중점을 찾지 못했습니다.\n');
    end
end