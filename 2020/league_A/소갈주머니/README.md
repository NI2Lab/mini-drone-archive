# 소갈주머니
------------------------------------------------------
## 2020 미니드론 자율비행 경진대회
------------------------------------------------------
### [✔ 대회 진행 전략] 

* 여러가지 상황에 대한 변수를 가장 최우선적으로 고려함
* 1차 2차 시도에 대한 각각 코드 준비
* HSV값으로 색 인식
* 홀의 일부만 잡혀 인식하지 못하는 상황을 대비해 링의 테두리를 만들어 완벽하게 인식한 뒤 링 통과
* 침식과 팽창을 사용한 노이즈 제거
* 링 중앙점 인식 정확도를 높임
------------------------------------------------------
### [✔ 알고리즘 설명]
![미니드론알고리즘](https://user-images.githubusercontent.com/61452782/87249449-1b490780-c49a-11ea-8aa9-996f42cff3ce.jpg)
------------------------------------------------------
1. 이륙             
2. 링의 중앙점에 드론이 **위치 해 있는지 인식**
* 링의 중앙점에 드론이 위치 해 있을 경우
  + **다음 단계**
* 링의 중앙점에 드론이 위치하지 않을 경우
  + 상하좌우 조정        
3. 드론이 링의 중앙점에 위치하고 직진비행 할 수 있는 최적 거리인지 판단(링을 통과하여 무리 없이 비행할 수 있는지)
* 드론이 링의 중앙점에 위치하지 않고 최적 거리 밖에 있다면 **전진** 하여 드론이 링의 중앙점에 위치하고 최적 거리로 오도록 유도 -> 2번 알고리즘으로 되돌아감
4. 최적 거리내에 드론이 있다면 **링 통과**
5. 링 통과 후 표식의 색상 인식
* **파란색일 경우**
  + 착륙   
* **빨간색일 경우**
  + 좌로 90도 회전
  + 좌회전 후 링의 홀을 인식하고 홀의 중앙값 저장 후 **전진**    
  + 저장한 중앙값에 따라 상하좌우 이동
7. 드론이 착륙하지 않았을 경우 2번 알고리즘으로 되돌아감 

------------------------------------------------------
### [✔ 소스코드 설명] 
----------------------------------------------------
* 변수 선언 및 임계값 설정
```
droneObj = ryze()

global min_h;   global max_h;
min_h = 0.225;  max_h = 0.405;
```
* disttocir - movedist만큼 전진해서 링통과
```
global dist_to_cir;
dist_to_cir = 2.45;
global move_dist;
move_dist = 0;
```

* 이륙
```
takeoff(droneObj);
Move(droneObj, 0.3, "up");
```

* 텔로 카메라 프레임 수신
```
cameraObj = camera(droneObj);
preview(cameraObj);
[frame,ts] = snapshot(cameraObj);
```

* 링 홀의 중앙 좌표값 검출
```
[hall_frame, x, y] = loc_recog(frame);
while 1
    [frame,ts] = snapshot(cameraObj);
    [hall_frame, x, y] = loc_recog(frame)
```

* 링의 중앙값 인식 안될 시 재인식
```
   if isnan(x) || isnan(y) || x-5 < 0 || y-5 < 0
        continue;
    end
```
* 드론이 링의 중앙 범위에 위치할 때 표식까지 남은 거리만큼 전진
```
    if ((x >= 450) && (x <= 550)) && ((y >= 110) && (y <= 190))
        dist = dist_to_cir - move_dist;
        Move(droneObj, dist, "forward");
        move_dist = 0;
        dist_to_cir = 3.2;
        force_cir_noncheck = 0;
```

* 이전에 표식 검출 하지 않았을 경우 표식 검출
```
        while 1
            if force_cir_noncheck == 0
                cir_num = Cir_Check(cameraObj);
            else
                force_cir_noncheck = 0;
            end
```

* 파란색 표식 검출 됐을 경우 착륙
```
            if cir_num == 2     % 파란 원
                land(droneObj);
                return;
```

* 빨간색 표식 검출 됐을 경우 좌로 90도 회전 후 링 인식
```
            elseif cir_num == 1 % 빨간 원
                Rotate(droneObj, -90); 
                
                [frame,ts] = snapshot(cameraObj);
                [hall_frame, x, y] = loc_recog(frame);
```

* 링이 너무 높아 화면에 나오지 않을 경우 상승하여 링 재인식
```
                if isnan(x) || isnan(y) || x-5 < 0 || y-5 < 0
                    Move(droneObj, 0.4, "up");
                    
                    [frame,ts] = snapshot(cameraObj);
                    [hall_frame, x, y] = loc_recog(frame);
```
* 상승시에도 링 검출 실패할 경우 하강하여 재인식
```
                    if isnan(x) || isnan(y) || x-5 < 0 || y-5 < 0
                        Move(droneObj, 0.7, "down");
                        break;
                    end
                end
```

* 인식한 링의 중앙 좌표에 따라 이동
```
                if x < 500 && y < 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "left");
                    Move(droneObj, 0.3, "up");
                    break;
                elseif x < 500 && y > 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "left");
                    Move(droneObj, 0.3, "down");
                    break;
                elseif x > 500 && y < 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "right");
                    Move(droneObj, 0.3, "up");
                    break;
                elseif x > 500 && y > 150
                    Move(droneObj, 1.1, "forward");
                    Move(droneObj, 0.3, "right");
                    Move(droneObj, 0.3, "down");
                    break;
                end
```
* 표식(원) 검출 실패 시
```
            elseif cir_num == 3
                while force_cir_noncheck == 0
```
* 표식 (원) 검출 실패시
  + 우, 좌, 상 반복하여 인식하여 검출 되었을 때, force 변수에 1을 저장하여 표식을 인식하지 못하도록 함
```
                   Rotate(droneObj, 20);
                   cir_num = Cir_Check(cameraObj);
                   if cir_num ~= 3
                       force_cir_noncheck = 1;
                   end
                   
                   Rotate(droneObj, -20);       %원위치
                   
                   if force_cir_noncheck == 0
                       Rotate(droneObj, -20);
                       cir_num = Cir_Check(cameraObj);
                       if cir_num ~= 3
                           force_cir_noncheck = 1;
                       end
                       Rotate(droneObj, 20);    %원위치
                   end
                   if force_cir_noncheck == 0
                       Move(droneObj, 0.2, "up");
                       cir_num = Cir_Check(cameraObj);
                       if cir_num ~= 3
                           force_cir_noncheck = 1;
                       end
                   end
                end
            end
        end
```

* 드론이 전진하기 위한 좌표 범위와 인식한 링의 중앙 좌표차에 따라 이동
```
    else
        x_diff = x - 500;
        y_diff = y - 150;

        if y_diff > 30
            Move(droneObj, 0.2, "down");
        elseif y_diff < -30
            Move(droneObj, 0.2, "up");
        end
        
        if x_diff > 30
            Move(droneObj, 0.2, "right");
        elseif x_diff < -30
            Move(droneObj, 0.2, "left");
        end
    end
end

function [hall_frame, x, y] = loc_recog(frame)
    global min_h;
    global max_h;
    
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    detect_green = (min_h < h) & (h < max_h);
```

* 픽셀수가 일정 개수보다 적은 연결성분 제거
```
    bw = bwareaopen(detect_green, 1000);
```
* 침식
```
    se = strel('line', 20, 0);
    bw = imerode(bw,se);
```
* 팽창
```
    bw = imdilate(bw, se);
```
* 링의 중앙점 검출
```
    [width, height] = size(bw);
    
    bw(:, 1) = 1;
    bw(:, width) = 1;
    bw(1, :) = 1;
    
    bw2 = imfill(bw, 'holes');
    
    bw3 = bw2 - bw;
    hall_frame = bw3;

    [row, col] = find(bw3);
    row = sort(row);
    col = sort(col);
    y = int16(median(row));
    x = int16(median(col));
end
```
* 입력되는 방향에 따라 드론 이동
```
function rtn = Move(droneObj, dist, dir)
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
* 입력 받은 각도만큼 드론 회전
```
function rtn = Rotate(droneObj,ang)
    turn(droneObj, deg2rad(ang));
    rtn = "";
end
```
* 표식 체크 함수 
  + 빨강 파랑을 h, s값으로 이진화
  + 빨간표식 == 1, 파랑표식 =2, 미인식 == 3
```
function cir_num = Cir_Check(cameraObj)
    [frame,ts] = snapshot(cameraObj);
    hsv = rgb2hsv(frame);
    h = hsv(:,:,1);
    s = hsv(:,:,2);
    detect_red = (0 < h) &(h < 0.05) | (h < 1) & (h > 0.95);
    detect_red_s = (0.5 < s) & (s < 0.8);
    detect_red = detect_red & detect_red_s;

    detect_blue = (h > 0.5) & (h < 0.6);
    detect_blue_s = (0.5 < s) & (s < 0.8);
    detect_blue = detect_blue & detect_blue_s;
    subplot(3, 1, 2); imshow(detect_red);
    subplot(3, 1, 3); imshow(detect_blue);
    if nnz(detect_red) > 50
        cir_num = 1; % red
    elseif nnz(detect_blue) > 50
        cir_num = 2; % blue
    else
        cir_num = 3; % 표식(원) 인식 못할 때
    end
end
```
  
