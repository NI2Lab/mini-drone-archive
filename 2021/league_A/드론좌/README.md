# DroneLeft

# 🧾 드론좌 전략 🧾
+ HSV 색공간을 이용해 주변 환경 변화로 인한 오류 제거
+ 색 검출 알고리즘을 이용한 링과 표식 검출 
+ 팽창/이진화를 통한 이미지의 노이즈 제거
+ 링의 중앙값을 찾고 드론을 최대한 링의 중앙에 맞추기
+ 링의 지름을 이용한 거리 검출 알고리즘 사용

------------------------------------------------------

## ✅ 드론좌 흐름도
<img width="700" alt="flow_chart" src="https://user-images.githubusercontent.com/76803020/125616967-372305d9-25d9-470b-91ea-e47e55c9ebed.PNG">

------------------------------------------------------

## ✅ 주요 알고리즘

### 1. 링 검출
+ 링을 촬영한 frame 이미지를 이진화 시킨 후 지정한 값으로 연결성분 제거
+ 이미지 팽창을 통한 빈 공간 보충 
+ 'holes'를 인식한 이미지를 이용해 링 검출
+ 드론 카메라로 인식하는 원본 영상
+ ![KakaoTalk_20210714_213249984](https://user-images.githubusercontent.com/76803020/125622641-73706b0f-72ba-4a32-aa67-2bd821d5a828.gif)
+ 이진화하여 찾아낸 링 검출 영상
+ ![KakaoTalk_20210714_211024757](https://user-images.githubusercontent.com/76803020/125621734-82fc0255-b170-4327-b908-3f0cf985d48f.gif)


### 2. 링 중심 좌표 검출
+ 검출된 링의 행렬값을 통한 중앙값 추출
+ 드론의 카메라 프레임의 중심값과 링의 중심값의 차이를 이용해 드론의 상하좌우 위치를 조정
+ 이진화한 링 검출 영상에서 찾은 링의 중앙좌표 영상
 ![KakaoTalk_20210714_210913348](https://user-images.githubusercontent.com/76803020/125622055-42cc3019-f6a4-4584-9b52-b8f05410f7df.gif)

+ 
### 3. 링과의 거리 측정
+ 거리별로 측정한 원의 넓이를 통한 거리 측정 
 ![KakaoTalk_20210714_210034346](https://user-images.githubusercontent.com/76803020/125622755-ed83a93f-945e-4fb0-8641-6001dd701376.png)


# 4. 표식 검출
+ 두 표식의 hsv 색공간을 이용해 hsv 임계값 추출
+ 추출된 값을 이용해 표식 인식 후 다음 단계를 진행할지, 착지할지 결정
+ 빨간색 표식 추출과정
 ![KakaoTalk_20210714_211319973](https://user-images.githubusercontent.com/76803020/125621959-eb76209b-6f15-47a6-bcfc-f0795a790ae4.gif)
+ 보라색 표식 추출과정
 ![KakaoTalk_20210714_220858883](https://user-images.githubusercontent.com/76803020/125627559-810a7cc3-50fa-4ae5-bd88-fff974cad6c6.gif)


------------------------------------------------------

## ✅ 전체 소스 코드에 대한 설명

* h 임계값 설정
```matlab
global min_h;   global max_h;
global min_s;   global max_s;
min_h = 0.55;  max_h = 0.62;  % 0.55 0.62
min_s = 0.52;  max_s = 0.85;
```
* 변수 선언
```matlab
is_circle = 0; % 원 인식 여부
is_center = 0; % 원의 중앙 검출 여부
stage_pass = 0; % 링 통과 여부
mark_color = 0; % 표식의 색
remain_dist = 3; % 링까지의 거리
stage = 1; % 현재 단계
```
* 링과의 거리
```matlab
dist_05 = 0;
dist_1 = 0;
dist_15 = 0;
dist_2 = 0;
dist_3 = 0;
```
* 드론 객체 선언 후 이륙 및 카메라 제어
```matlab
droneObj = ryze();

takeoff(droneObj);
Move(droneObj, 0.3, 'up');

cameraObj = camera(droneObj);
preview(cameraObj);
```
 -----------------------------------
```matlab
while 1
    is_circle = 0;
    
    [frame,ts] = snapshot(cameraObj);

    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);

    detect_blue = (min_h < h) & (h < max_h);
    detect_blue_s = (min_s < s) & (s <= max_s);
    detect_blue = detect_blue & detect_blue_s;
``` 
* 이미지 이진화 -> 연결성분 제거 -> 팽창
```matlab
    bw = bwareaopen(detect_blue, 5000);
    
    se = strel('line', 30, 0);
    bw = imdilate(bw, se);
    [width, height] = size(bw);

    bw(:, 1) = 1;
    if bw == 1
        continue;
    end
    bw(:, width) = 1;
    bw(1, :) = 1;
```
* 링의 빈공간 보충 후 연결성분 제거
```matlab
    bw2 = imfill(bw, 'holes');
    bw3 = bw2 - bw;
    hall_frame = bw3;
    hall_frame = bwareaopen(hall_frame, 5000);
    hall_frame = imfill(hall_frame, 'holes');
    hall_frame = bwareaopen(hall_frame, 5000);
```
* 원 중앙값 추출
```matlab
    [row, col] = find(hall_frame);
    row = sort(row);
    col = sort(col);
    y = int16(median(row))
    x = int16(median(col))
   
``` 
* 검출한 링 중앙점 확인
```matlab
    c_x = x;
    c_y = y;
    
    if c_x < 11
        c_x = 11;
        is_circle = 1;
    end
    if c_y < 11
        c_y = 11;
        is_circle = 1;
    end
    for c = c_x-10:c_x+10
        for r = c_y-10:c_y+10
            hall_frame(r, c) = 0;
        end
    end

    imshow(hall_frame);
    
    if x == 0 || y == 0
        continue;
    end
```
* 드론이 중앙에 위치하도록 조정
```matlab
    %if ((x >= 450) && (x <= 550)) && ((y >= 150) && (y <= 180))
    if is_center == 0
        if ((x >= 450) && (x <= 550)) && ((y >= 130) && (y <= 200))
            is_center = 1;
        else
            x_diff = x - 500;
            y_diff = y - 150;

            if y_diff > 150
                Move(droneObj, 0.4, "down"); 
            elseif y_diff > 30
                Move(droneObj, 0.2, "down");
            elseif y_diff < -150
                Move(droneObj, 0.4, "up");
            elseif y_diff < -30
                Move(droneObj, 0.2, "up");
            end

            if x_diff > 150
                Move(droneObj, 0.4, "right");
            elseif x_diff > 30
                Move(droneObj, 0.2, "right");
            elseif x_diff < -150
                Move(droneObj, 0.4, "left");
            elseif x_diff < -30
                Move(droneObj, 0.2, "left");
            end

            continue;
        end
    end
```
* 원의 지름값 구하기
```matlab
    if ~isempty(x)
        tmp = unique(col);
        rad = nnz(tmp)
    end
```
* 단계별 거리 인식
* *  1단계에서 링의 넓이에 따른 거리 파악
```matlab
    if stage == 1
        if rad > 500
            dist_1 = dist_1 + 1
        elseif rad <= 500 && rad >= 330
            dist_2 = dist_2 + 1
        elseif rad < 330 && rad > 200
            dist_3 = dist_3 + 1
        else
            continue;
        end
```
* *  2단계에서 링의 넓이에 따른 거리 파악
```matlab
    elseif stage == 2
        if rad > 456
            dist_1 = dist_1 + 1
        elseif rad <= 456 && rad >= 281
            dist_2 = dist_2 + 1
        elseif rad < 281 && rad > 150
            dist_3 = dist_3 + 1
        else
            continue;
        end
```    
* *  3단계에서 링의 넓이에 따른 거리 파악
```matlab
    else
        if rad > 398
            dist_1 = dist_1 + 1
        elseif rad <= 398 && rad >= 200
            dist_2 = dist_2 + 1
        elseif rad < 200
            dist_3 = dist_3 + 1
        else
            continue;
        end
    end
```    
* 거리 인식이 실패할 경우 다시 측정
```matlab
    if dist_1 ~= 5 && dist_2 ~= 5 && dist_3 ~= 5
        continue;
    end
```
* 거리 판별 후 변수 초기화
```matlab
    if dist_1 == 5
        remain_dist = 1
        dist_1 = 0;
    elseif dist_2 == 5
        remain_dist = 2
        dist_2 = 0;
    else
        remain_dist = 3
        dist_3 = 0;
    end
```
* 링까지의 거리에 따른 드론 이동거리 설정
```matlab
    if remain_dist == 3
        Move(droneObj, 3.15, 'forward');
        stage_pass = 1;
    elseif remain_dist == 2
        Move(droneObj, 2.15, 'forward');
        stage_pass = 1;
    elseif remain_dist == 1
        Move(droneObj, 1.15, 'forward');
        stage_pass = 1;
    end
    stage = stage + 1; % 단계 상승
```
* 표식 인식을 위한 프레임 재설정
```matlab
    while mark_color ~= 1 && mark_color ~= 2
        if stage_pass == 1
            [frame,ts] = snapshot(cameraObj);

            hsv = rgb2hsv(frame);
            h = hsv(:,:,1);
            s = hsv(:,:,2);
 ```
 * 표식의 색 검출 -> 이진화 및 연결성분 제거
 ```matlab
            detect_red = (0 <= h) &(h < 0.05) | (h <= 1) & (h > 0.95);
            detect_red_s = (0.6 < s) & (s <= 1);
            detect_red = detect_red & detect_red_s;

            detect_purple = (h > 0.74) & (h < 0.81);
            detect_purple_s = (0.50 < s) & (s < 0.60);
            detect_purple = detect_purple & detect_purple_s;
            
            red = bwareaopen(detect_red, 700);
            purple = bwareaopen(detect_purple, 700);
 ```
 * 검출한 표식의 색에 따른 드론 제어
 ```matlab
            if nnz(red) < 50 && nnz(purple) < 50
                if stage == 1 || stage == 2
                    mark_color = 1; % red
                    Rotate(droneObj, -90);
                else
                    land(droneObj);
                end
            elseif nnz(red) > nnz(purple)
                mark_color = 1; % red
                Rotate(droneObj, -90);
            else
                mark_color = 2; % purple
                land(droneObj);
                break;
            end
        end
    end
end
```
-----------------------------------------------
* 드론 움직임 제어 함수 구현
```matlab
function rtn = Move(droneObj, dist, dir)
    % 입력되는 방향에 따라 드론을 이동
    global move_dist;
    if dir == "forward"
        moveforward(droneObj, 'Distance', dist);
        move_dist = move_dist + dist;
    elseif dir == "back"
        moveback(droneObj, 'Distance', dist);
    elseif dir == "right"
        moveright(droneObj, 'Distance', dist);
    elseif dir == "left"
        moveleft(droneObj, 'Distance', dist);
    elseif dir == "up"
        moveup(droneObj, 'Distance', dist);
    elseif dir == "down"
        movedown(droneObj, 'Distance', dist);
    end
    pause(0.5);
    rtn = "";
end
```
* 회전 함수 구현
```matlab
function rtn = Rotate(droneObj,ang)
    % 입력 받은 각도만큼 드론을 회전
    turn(droneObj, deg2rad(ang));
    pause(0.5);
    rtn = "";
end
```
