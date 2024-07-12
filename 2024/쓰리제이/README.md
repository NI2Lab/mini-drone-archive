# 2024 미니드론 자율주행 경진대회 쓰리제이 팀 코드
---
## 대회 진행 전략
<p align="center">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/472a8b51-8539-4316-8f4b-3312295932ab" >
</p>

1. 드론의 카메라가 실시간으로 이미지를 캡처합니다.

2. 먼저 이미지에서 가림막 내부 링의 중심점을 기준으로 드론의 위치를 조정합니다.
   
3. 마커 색상별 임계값을 이용해 각 단계의 마커를 탐지합니다.
  
4. 링의 중심점과 마커의 중심점 간의 오차를 계산합니다.

5. 드론이 위치를 바꿔가며 중심점이 일치할 경우 동작을 수행합니다. 

6. 이 과정을 반복하여 경로를 따라 최종 목적지에 도달합니다.

## 알고리즘 설명
### 가림막 내부 링의 중심으로 드론 이동
드론을 마커와 가림막의 중심을 안정적으로 맞추기 위해

마커를 감지하기 전에 가림막의 중심을 기준으로 드론의 위치를 조정합니다.

이 동작은 단계마다 반복적으로 이루어지기 때문에 함수로 만들어 사용했습니다.

먼저 드론의 카메라가 캡처한 이미지를 HSV 색상 공간으로 변환합니다. 

파란색 영역을 감지할 임계값으로 Canny 엣지 감지를 통해 윤곽선을 검출합니다. 

정확도를 높이기 위해 저희는 가장 큰 윤곽선 두 개를 선택해 링을 찾았습니다.

poly2mask 함수를 사용하여 윤곽선(링) 내부의 영역에 이진 마스크를 생성합니다. 

regionprops 함수의 속성 중 'Centroid'를 사용하여 중심점을 계산합니다.

중심점을 드론의 현재 위치와 비교합니다.

드론을 적절한 방향으로 이동시켜 파란색 영역의 중심으로 조정합니다.

아래 코드에서 주석을 통해 설명을 자세히 추가했습니다.

```matlab
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
                moveright(droneObj, 'distance', 0.2);
            else
                moveleft(droneObj, 'distance', 0.2);
            end
        end

        if abs(error_y) > tolerance
            if error_y > 0
                movedown(droneObj, 'distance', 0.2);
            else
                moveup(droneObj, 'distance', 0.2);
            end
        end

        % 오차가 충분히 작으면 루프 탈출
        if abs(error_x) <= tolerance && abs(error_y) <= tolerance
            break;
        end
    end
end


% 파란색 사각형 내부 원형 테두리의 중심 계산
inner_mask = poly2mask(inner_boundary(:,2), inner_boundary(:,1), size(canny_img, 1), size(canny_img, 2));
props = regionprops(inner_mask, 'Centroid'); % 이진화 마스크로 변환된 링의 중심점 계산
inner_centroid = props.Centroid; % 계산된 중심점 추출
```  


아래 이미지는 마커를 제외한 각 파란색 사각형의 내부 원형 테두리의 중심만을 검출한 이미지입니다.
<p align="center">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/611b7381-ccf2-49d4-a9cd-573238b56e2a">  
</p>

### 마커 탐지 및 조정
다음으로 마커를 탐지합니다. 링의 중심점을 찾을 때와 비슷하게 구현했습니다. 

드론이 캡처한 이미지를 HSV 색상 공간으로 변환합니다. 파란색 링 테두리의 중심점을 찾고 

각 색상마다 설정한 임계값으로 마커의 테두리를 찾습니다.

마커 내부에 이진 마스크를 생성한 후 가장 큰 객체를 추출해내면 regionprops의 'Centroid'를 사용해해 중심점을 계산합니다.

마커의 중심점과 링의 중심점의 오차를 통해 드론의 위치를 바꿔가며 중심을 맞추도록 조정합니다.

중심이 맞을 경우 다음 동작 (직진과 회전)을 수행합니다.

아래는 빨간색 마커를 찾는 코드입니다. 파란색 중심점을 찾는 방법은 중복되어 생략했습니다. 주석을 통해 코드 설명을 추가하겠습니다.

```matlab
while true
    pause(2);
    img = snapshot(cam); % 카메라로 이미지 캡처
    imshow(img);

    hsv = rgb2hsv(img); % 이미지를 HSV 색상 공간으로 변환
    h = hsv(:,:,1); 
    s = hsv(:,:,2);
    v = hsv(:,:,3); 

    
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

    error = screen_center(1) - inner_centroid(1);

    if abs(error) > 50
        if error > 0
            moveleft(droneObj,'distance',0.33)
        else
           moveright(droneObj,'distance',0.33)
        end
    end    
``` 

마커의 중심을 찾을 때까지 이전에 찾은 파란색 중심과 오차를 비교하여 드론의 위치를 조정합니다.

아래는 드론이 각 단계에서 중심점을 맞추는 과정을 figure로 출력한 이미지입니다.
<p align="center">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/cf29ac82-8138-4e6c-b31f-bb3ee888ec6b" width="700" height="450">  
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/69bb3046-582b-4d9c-92fa-5e6577f060e5" width="700" height="450">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/e2cb92f4-b314-4c2c-b9cd-87b15b1cf939" width="700" height="450">
</p>


### 2-3단계에서 문제점 발생, 해결 방법
위와 같은 방법으로 같은 방법으로 대회장 이미지 속 보라색 마커를 탐지할 때 기존의 보라색 임계값을 사용하면 노이즈로 인해 탐지하지 못했습니다.
<p align="center">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/492c8824-f8d6-48ee-8832-199c65afb414)">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/60d81a7e-cbb4-4ddc-9a67-81c93c0b8a5b">
</p>

이는 저희가 만든 경기장과 대회장의 채도, 조명 밝기 등 다양한 차이점이 원인이라고 판단했습니다. 따라서 저희는 보라색의 H,S,V을 최대값, 최소값 범위를 각각 지정하고 10장의 사진들의 마커를 가장 잘 찾아낼 때까지 계속 바꿔가며 최적의 범위를 구했습니다.

```matlab
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
```

아래 이미지는 위 HSV 범위로 대회장 보라색 마커를 탐지하여 figure로 출력한 이미지입니다.
<p align="center">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/b5829a3c-930d-45e8-878e-980ea6a03c07">
<img src="https://github.com/JJeongAA/JJ_team/assets/168095384/0c5dde05-132c-4ed0-88c7-edb7c02ee83b">
</p>


