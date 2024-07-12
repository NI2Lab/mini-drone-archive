팀명 : 꼼꼼하게 

팀원 : 박준상, 박지희

# 대회 진행 전략

경쟁 전략은 크게 세 가지 범주로 나뉩니다.

1. 원의 중심을 통과하거나 원의 중심에 근접하기
2. 드론 카메라 방향과 사각형 정면 일치시키기
3. 원 뒤의 색상 인식하기

## 1. 원의 중심을 통과하거나 근접하기 위한 전략

파란 사각형에서 잘린 원의 중심을 이진화하고 형태 계산을 통해 노이즈를 제거합니다.
그 후, 원의 중심과 카메라의 중심이 일치하는 방향으로 이동합니다.
원의 중심과 카메라의 중심이 일치하면 드론의 위치와 파란 원의 위치를 계산하여 드론이 원을 통과하거나 원 앞에 위치하도록 이동합니다.

## 2. 드론 카메라 방향과 사각형 정면 일치 전략

첫 번째 통과 후 각도가 정확히 결정되지 않았기 때문에 이에 맞추어 사용합니다.
`findbestangle` 함수로 좌우 각도를 측정하고 많은 파란 원이 감지되는 영역을 찾습니다.
`bestangle` 및 `blueposition` 함수 출력을 사용하여 사각형에 맞추기 위해 상하좌우로 이동합니다.

## 3. 원 뒤의 색상 인식 전략

실험을 통해 색상 임계값을 도출하고 빨간색, 녹색, 보라색의 범위를 설정합니다.
이를 통해 색상에 따라 회전 착륙이 가능합니다.


# 코드 전반적인 설명

1. **이륙 후 프레임을 통해 원의 중심 찾기**
2. **첫 번째 원의 중심을 찾은 후, 원까지의 거리를 계산하고 일정 거리 직진하여 통과**
3. **목표의 색상을 인식한 후 일정 각도로 회전**  함수: `check_red_color`
4. **좌우 각도를 회전하여 두 번째 원을 찾고 최적의 각도로 설정**  함수: `findbestangle`
5. **원의 중심을 찾은 후 원까지의 거리를 계산하고 일정 거리 직진하여 원에 근접**
6. **원 안의 색상을 인식한 후 일정 각도로 회전**  함수: `check_green_color`
7. **좌우 각도를 회전하여 3차원 원을 찾고 최적의 각도로 설정**  함수: `findbestangle`
8. **원의 중심을 찾은 후 원까지의 거리를 계산하고 일정 거리 직진하여 원에 근접**
9. **원 안의 색상을 인식한 후 일정 각도로 회전**  함수: `check_purple_color`
10. **좌우 각도를 회전하여 4차원 원을 찾고 최적의 각도로 설정**  함수: `findbestangle`
11. **원의 중심을 찾은 후 원까지의 거리를 계산하고 일정 거리 직진하여 원에 근접**
12. **원의 색상을 인식한 후 일정 거리를 이동하고 착륙**  함수: `land_red`

## 함수사용 

- `check_red_color`: 목표의 빨간색을 인식하고 일정 각도로 회전합니다.
- `findbestangle`: 좌우 각도를 회전하여 최적의 각도를 설정합니다.
- `check_green_color`: 원 안의 초록색을 인식하고 일정 각도로 회전합니다.
- `check_purple_color`: 원 안의 보라색을 인식하고 일정 각도로 회전합니다.
- `land_red`: 원 안의 색상을 인식한 후 착륙합니다.


# 알고리즘 및 소스코드 설명

## 빨강, 초록, 보라색 사각형을 감지하는 함수 has_red = check_red_color(cam), has_green = check_green_color(cam), has_purple = check_purple_color(cam)

### 개요
`check_red_color` 함수는 드론이 코스를 진행할 때 빨간색 사각형을 인식하기 위한 함수입니다. 이 함수는 카메라로부터 이미지를 캡처하고, 이미지에서 빨간색 픽셀을 검출하여 빨간색 사각형의 존재 여부를 확인합니다. 비슷한 방식으로 `check_green_color`와 `check_purple_color` 함수도 존재하지만, 이 설명에서는 `check_red_color` 함수만을 다룹니다.

### 과정 설명
1. **이미지 캡처**: 카메라에서 이미지를 캡처하고 이를 이중 형식(double)으로 변환합니다.
2. **빨간색 검출 이미지 초기화**: 빨간색이 검출된 이미지를 저장할 `img3` 배열을 초기화합니다.
3. **빨간색 임계값 설정**: 빨간색 픽셀을 검출하기 위한 임계값을 설정합니다.
4. **빨간색 픽셀 검출**: 설정된 임계값을 기준으로 이미지를 스캔하여 빨간색 픽셀을 검출합니다. 빨간색 픽셀이 아닌 경우 해당 픽셀을 제거하고, 빨간색 픽셀인 경우 이를 `img3`에 마킹합니다.
5. **형태학적 팽창**: 구조화 요소(strel)를 사용하여 빨간색 영역을 더 두드러지게 만듭니다.
6. **빨간색 픽셀 존재 여부 확인**: 팽창된 이미지에서 빨간색 픽셀이 존재하는지 확인합니다.
7. **결과 시각화 및 출력**: 원본 이미지와 빨간색 픽셀이 검출된 이미지를 시각화하고, 빨간색이 검출되었는지 여부를 출력합니다.

### 코드
```matlab
function has_red = check_red_color(cam)

    % 카메라에서 이미지 캡처
    frame = snapshot(cam);
    img = double(frame);
    [R, C, X] = size(img);

    % 빨간색 검출 이미지를 저장할 img3 초기화
    img3 = zeros(R, C, X);

    % 빨간색 검출을 위한 임계값
    red_threshold1 = 38;
    red_threshold2 = 10;
    green_threshold = 30;

    % 주어진 임계값으로 빨간색 픽셀 검출
    for i = 1:R
        for j = 1:C
            if img(i, j, 1) - img(i, j, 2) < red_threshold1 || ...
               img(i, j, 1) - img(i, j, 3) < red_threshold2 || ...
               img(i, j, 2) - img(i, j, 3) > green_threshold
                % 빨간색이 아닌 색상 제거
                img3(i, j, :) = 0;
            else
                % 빨간색 픽셀 마킹
                img3(i, j, 1) = 255;
                img3(i, j, 2) = 0;
                img3(i, j, 3) = 0;
            end
        end
    end

    % 빨간색 영역을 더 두드러지게 하기 위한 형태학적 팽창
    se = strel('disk', 5); % 팽창을 위한 구조화 요소
    red_channel = img3(:, :, 1);
    dilated_red = red_channel;
    for k = 1:10
        dilated_red = imdilate(dilated_red, se);
    end

    % 이미지에 빨간색 픽셀이 있는지 확인
    red_pixels_dilated = dilated_red == 255;
    has_red = any(red_pixels_dilated(:));

    % 시각화를 위한 원본 이미지와 빨간색 검출 이미지 표시
    figure;
    subplot(1, 2, 1);
    imshow(uint8(img));
    title('원본 이미지');

    subplot(1, 2, 2);
    imshow(uint8(img3));
    title('빨간색 픽셀 검출');

    % 빨간색 검출 여부 출력
    if has_red
        disp('빨간색이 검출되었습니다');
    else
        disp('빨간색이 검출되지 않았습니다');
    end
end
```



## 최적의 각도와 위치를 찾는 함수 [bestAngle, bluePosition] = findbestangle(drone, cam)

### 개요
`findbestangle` 함수는 드론이 이동 중에 회전한 후 각도가 맞지 않을 경우를 고려하여 파란색 천막이 어느 각도에서 가장 잘 보이는지를 확인하고, 드론을 그 각도로 회전시킵니다. 동시에 천막이 위쪽 또는 아래쪽에 위치하는지 파악하여 `bluePosition`에 저장하고, 이 값을 이용해 드론의 위치를 조정합니다. 최적의 각도를 찾은 후, `moveright` 또는 `moveleft` 명령을 사용하여 드론을 이동시킵니다.

### 과정 설명
1. **각도 범위 설정**: 드론이 -20도에서 20도까지 회전할 각도를 설정합니다. 이 범위 내에서 10도 간격으로 각도를 변경합니다.
2. **파란색 픽셀 합과 위치를 저장할 배열 초기화**: 각 각도별로 파란색 픽셀의 합과 수직 위치를 저장할 배열을 초기화합니다.
3. **각도 간격 계산**: 각도 간격을 계산하여 드론이 회전할 때 사용할 간격을 설정합니다.
4. **각 각도별 이미지 캡처 및 분석**:
   - 카메라로 현재 각도에서 이미지를 캡처합니다.
   - RGB 임계값을 사용하여 파란색 픽셀을 검출하고 이진 마스크를 생성합니다.
   - 형태학적 연산을 통해 마스크를 정리하고 작은 객체를 제거합니다.
   - 마스크에서 파란색 픽셀의 합과 평균 수직 위치를 계산합니다.
   - 파란색 마스크를 시각화하여 현재 각도에서의 결과를 확인합니다.
   - 다음 각도로 이동하기 위해 드론을 회전시킵니다.
5. **최적의 각도 찾기**: 파란색 픽셀이 가장 많이 검출된 각도를 찾고, 그 각도로 드론을 회전시킵니다.
6. **결과 출력**: 최적의 각도와 파란색 위치를 출력하고 반환합니다.

### 코드
```matlab
function [bestAngle, bluePosition] = findbestangle(drone, cam)

    % 각도 범위를 -20도에서 20도로 설정
    angles = -20:10:20;
    turn(drone, deg2rad(-20));

    % 각도별로 파란색 픽셀의 합을 저장할 배열 초기화
    blueSum = zeros(1, length(angles));

    % 각도별로 파란색 픽셀의 수직 위치를 저장할 배열 초기화
    bluePositions = zeros(1, length(angles));

    % 각도 간격 계산
    interval = diff(angles(1:2));

    for i = 1:length(angles)
        try
            % 현재 각도에서 카메라로 이미지 캡처
            img = snapshot(cam);

            % RGB에서 파란색 검출을 위한 임계값 정의
            blueMin = [0, 0, 100];
            blueMax = [100, 100, 255];

            % 파란색을 기반으로 이진 마스크 생성
            blueMask = (img(:,:,1) >= blueMin(1) & img(:,:,1) <= blueMax(1)) & ...
                       (img(:,:,2) >= blueMin(2) & img(:,:,2) <= blueMax(2)) & ...
                       (img(:,:,3) >= blueMin(3) & img(:,:,3) <= blueMax(3));

            % 형태학적 연산 수행
            blueMask = imcomplement(blueMask); % 마스크 반전
            blueMask = bwareaopen(blueMask, 8000); % 작은 객체 제거
            blueMask = imcomplement(blueMask); % 마스크 다시 반전
            se = strel('disk', 9);
            blueMask = imclose(blueMask, se); % 마스크 닫기
            blueMask = bwareaopen(blueMask, 7000); % 최종 정리

            % 마스크에서 파란색 픽셀의 합 계산
            blueSum(i) = sum(blueMask(:));

            % 파란색 픽셀의 평균 수직 위치 계산
            [rows, cols] = find(blueMask);
            
            % 파란색 픽셀이 존재하는 경우
            if ~isempty(rows)
                bluePositions(i) = mean(rows) / size(blueMask, 1);
            % 파란색 픽셀이 없는 경우
            else
                bluePositions(i) = 0.5; % 파란색 픽셀이 없으면 중간으로 설정
            end

            % 파란색 마스크 표시
            figure;
            subplot(1,1,1);
            imshow(blueMask);
            title(['각도 ', num2str(angles(i)), '에서 초기 파란색 마스크']);

            % 모든 관련 값 표시
            disp(['각도: ', num2str(angles(i)), ', 파란색 합: ', num2str(blueSum(i)), ', 파란색 위치: ', num2str(bluePositions(i))]);

            % 마지막 각도가 아닌 경우 간격 각도로 드론 회전
            if i < length(angles)
                turn(drone, deg2rad(interval));
            end
            
        catch e
            % 오류 발생 시 오류 메시지 출력
            disp(['각도 ', num2str(angles(i)), '에서 오류: ', e.message]);
        end
    end
    
    % 가장 많은 파란색 픽셀이 검출된 각도 찾기
    [~, maxIndex] = max(blueSum);
    bestAngle = angles(maxIndex);
    bluePosition = bluePositions(maxIndex);   
    % 드론을 최적의 각도로 회전
    turn(drone, deg2rad(bestAngle - angles(end)));

    % 최적의 각도와 파란색 위치 표시
    disp(['최적의 각도: ', num2str(bestAngle), ', 파란색 위치: ', num2str(bluePosition)]);

end
```


## 드론 이동 함수 - track_red_object(drone, cam)

## 개요
`track_red_object` 함수는 드론이 빨간색 사각형을 찾아 해당 사각형의 중점과 카메라의 중점을 맞추어 이동하도록 하는 함수입니다. 이 함수는 마지막 링을 통과하기 전에 빨간색 사각형을 감지하고, 사각형의 중점과 카메라의 중점 좌표 차이를 이용해 드론을 상하좌우로 이동시킵니다.

## 과정 설명
1. **카메라 중심 및 초기화**
    - 카메라의 중심 좌표를 설정합니다.
    - 사각형의 중점 좌표를 저장할 변수를 초기화합니다.
    - 허용 오차 범위를 정의하고, 빨간색 중심 찾기 변수를 초기화합니다.

2. **이미지 캡처 및 처리**
    - 드론의 카메라를 사용하여 이미지를 캡처합니다.
    - 캡처한 이미지를 처리하기 위해 이중 정밀도로 변환합니다.
    - 빨간색을 감지하기 위한 임계값을 설정합니다.

3. **빨간색 감지 및 이진화**
    - 각 픽셀을 순회하며 설정한 RGB 임계값에 따라 빨간색을 감지합니다.
    - 감지된 빨간색 영역을 마킹하고, 나머지 영역은 검정색으로 설정합니다.

4. **형태학적 팽창**
    - 빨간색 영역을 더욱 두드러지게 만들기 위해 형태학적 팽창을 수행합니다.
    - 팽창된 빨간색 픽셀을 원본 이미지에 오버레이합니다.

5. **중점 계산**
    - 팽창된 빨간색 픽셀의 중점을 계산합니다.
    - 중점이 감지되지 않으면 NaN으로 설정합니다.

6. **중점 좌표와 카메라 중심 좌표의 차이 계산**
    - 중점 좌표와 카메라 중심 좌표 간의 차이를 계산합니다.
    - 차이를 기반으로 드론을 상하좌우로 이동시킵니다.

## 코드

```matlab
function track_red_object(drone, cam)
    camera_center = [480, 220]; % 카메라의 중심 좌표
    centroid = zeros(size(camera_center)); % 사각형의 중점 좌표를 저장할 변수
    error_range = 50; % 허용 오차 범위 (픽셀 단위)
    camera_center_in_red = 0; % 빨간색 중심 찾기 변수 초기화

    while ~camera_center_in_red
        frame = snapshot(cam);
        img = double(frame);
        [R, C, X] = size(img);

        % 빨간색을 감지한 이미지를 저장하기 위한 img3 초기화
        img2 = zeros(size(img)); % img2를 사용할 수 있도록 사전 할당
        img3 = zeros(R, C, X);

        % 빨간색을 감지하기 위한 임계값 설정
        red_threshold1 = 38;
        red_threshold2 = 10;
        green_threshold = 30;

        for i = 1:R
            for j = 1:C
                if img(i, j, 1) - img(i, j, 2) < red_threshold1 || img(i, j, 1) - img(i, j, 3) < red_threshold2 || img(i, j, 2) - img(i, j, 3) > green_threshold
                    % 빨간색이 아닌 색 제거
                    img3(i, j, :) = 0;
                else
                    % 빨간색 픽셀 마킹
                    img3(i, j, 1) = 255;
                    img3(i, j, 2) = 0;
                    img3(i, j, 3) = 0;
                end
            end
        end

        % 빨간색 영역을 더욱 두드러지게 만들기 위한 형태학적 팽창
        se = strel('disk', 5); % 팽창을 위한 구조적 요소
        red_channel = img3(:, :, 1);
        dilated_red = red_channel;
        for k = 1:10
            dilated_red = imdilate(dilated_red, se);
        end

        % 팽창된 빨간색 픽셀을 원본 이미지에 오버레이
        img4 = img3;
        img4(:, :, 1) = dilated_red;

        % 팽창된 빨간색 픽셀의 중점 계산
        red_pixels_dilated = img4(:, :, 1) == 255;
        [y, x] = find(red_pixels_dilated);

        if ~isempty(x) && ~isempty(y)
            centroid = [mean(x), mean(y)];
        else
            centroid = [NaN, NaN]; % 빨간색 픽셀이 감지되지 않으면 중점을 NaN으로 설정
        end

        % 카메라 프레임의 중심 정의
        camera_center = [480, 220];

        % 중점 좌표와 카메라 중심 좌표의 차이 계산
        Distance = centroid - camera_center;

        % 원본, 빨간색 감지 및 팽창된 이미지에 중점 표시
        figure;
        subplot(1, 3, 1);
        imshow(uint8(img));
        title('원본 이미지');
        hold on;
        if ~isnan(centroid(1))
            plot(centroid(1), centroid(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        plot(camera_center(1), camera_center(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        hold off;

        subplot(1, 3, 2);
        imshow(uint8(img3));
        title('감지된 빨간 픽셀');
        hold on;
        if ~isnan(centroid(1))
            plot(centroid(1), centroid(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        plot(camera_center(1), camera_center(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        hold off;

        subplot(1, 3, 3);
        imshow(uint8(img4));
        title('팽창된 빨간 픽셀');
        hold on;
        if ~isnan(centroid(1))
            plot(centroid(1), centroid(2), 'g+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        plot(camera_center(1), camera_center(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
        hold off;

        % 드론 제어 로직
        if ~isnan(centroid)
            if Distance(1) > 0 && abs(Distance(1)) > error_range && Distance(2) < error_range
                disp("드론을 오른쪽으로 이동 중");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1.5);
            elseif Distance(1) < 0 && abs(Distance(1)) > error_range && Distance(2) < error_range
                disp("드론을 왼쪽으로 이동 중");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1.5);
            elseif abs(Distance(1)) < error_range && Distance(2) > 0 && abs(Distance(2)) > error_range
                disp("드론을 아래로 이동 중");
                movedown(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1.5);
            elseif abs(Distance(1)) < error_range && Distance(2) < 0 && abs(Distance(2)) > error_range
                disp("드론을 위로 이동 중");
                moveup(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1.5);
            elseif Distance(1) > 0 && abs(Distance(1)) > error_range
                disp("오른쪽으로 이동 중");
                moveright(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1.5);
            elseif Distance(1) < 0 && abs(Distance(1)) > error_range
                disp("왼쪽으로 이동 중");
                moveleft(drone, 'Distance', 0.2, 'Speed', 0.5);
                pause(1.5);
            elseif red_pixels_dilated(round(camera_center(2)), round(camera_center(1)));
                disp("중심 찾기");
                camera_center_in_red = 1; % 종료 조건: find_colorcenter를 1로 설정하여 루프 종료
            end
        else
            disp("빨간 물체가 감지되지 않았습니다");
            disp("0.2m 뒤로 이동 중");
            moveback(drone, 'Distance', 0.2, 'Speed', 1);
        end
    end

    % 루프 종료 후 실행될 추가 코드
    disp("중심이 발견되어

 루프를 종료합니다.");
end
```


## 드론 착륙 함수 - Land_red(drone, cam)

## 개요
`land_red` 함수는 드론이 20cm 지름의 원에 정확하게 착륙할 수 있도록 도와주는 함수입니다. 이 함수는 빨간 사각형을 찾고, 그 사각형의 넓이를 계산하여 적정 거리만큼 이동 후 착륙합니다.

## 과정 설명
1. **이미지 캡처 및 처리**
    - 드론의 카메라를 사용하여 이미지를 캡처합니다.
    - 캡처한 이미지를 처리하기 위해 이중 정밀도로 변환합니다.
    - 빨간색을 감지하기 위한 임계값을 설정합니다.

2. **빨간색 감지**
    - 각 픽셀을 순회하며 설정한 RGB 임계값에 따라 빨간색을 감지합니다.
    - 감지된 빨간색 영역을 마킹하고, 나머지 영역은 검정색으로 설정합니다.

3. **이진 이미지 처리**
    - 감지된 빨간색 영역을 이진 이미지로 변환합니다.
    - 이진 이미지를 보완하여 추가 처리를 준비합니다.
    - 작은 객체를 제거하여 노이즈를 줄입니다.
    - 모폴로지 연산을 사용하여 빨간색 영역 내의 간격을 채웁니다.

4. **거리 계산**
    - 감지된 빨간색 객체 중 가장 큰 객체를 찾아 넓이를 계산합니다.
    - 넓이를 기반으로 사각형까지의 거리를 선형 회귀식을 사용하여 계산합니다. (`distance = -0.0005 * area + 3.1304 + 0.2`)

5. **드론 제어**
    - 드론을 감지된 빨간 사각형에서 0.75m 앞까지 이동시킵니다.
    - 원하는 위치에 도달한 후 착륙을 수행합니다.

## 코드

```matlab
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
                    % 빨강 아니면 검정
                    img3(i, j, :) = 0;
                else
                    % 빨간색 빨강 마킹
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
            continue; % 빨강 못 찾으면 반복 다시 실행
        end

        % 가장 큰 개체 찾기 -> 사각형일 가능성 높음
        largestArea = -inf;
        largestObject = stats(1);
        for k = 1:length(stats)
            if stats(k).Area > largestArea
                largestArea = stats(k).Area;
                largestObject = stats(k);
            end
        end
        area = largestObject.Area;

        distance = -0.0005 * area + 3.1304 + 0.2;

        % 드론 제어 -> 사각형에서 0.75m 앞으로 이동해 착륙
        desiredDistance = 0.75;
        if distance > desiredDistance
            disp(['move forward ', round(distance - desiredDistance, 1)])
            moveforward(drone, 'Distance', round(distance - desiredDistance, 1), 'Speed', 0.5);
            movedown(drone, 'Distance', 0.7, 'Speed', 0.5);
            land(drone);
            find_land = 1;
        elseif distance < desiredDistance
            moveback(drone, 'Distance', 0.2, 'Speed', 0.5);
        end
    end
end
```


