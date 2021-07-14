# 미니드론 경진대회 
## 내가 만든 드론 드림
    [⌛ 드론 카메라 기반 리얼타임 영상처리를 통한 드론제어]

***

### [✔ 대회 진행 전략]
- 첫 워크샵 직후 팀 온라인 회의를 통해 개발방향 설정
- 매 워크샵 진행 후 과제 등에 대하여 각자 역할을 분담하는 등 팀 프로젝트 형식으로 수행
- 맡은 역할 마감 시 각자의 Branch를 통해 코드 업로드 및 Pull Request를 요청하여 팀장으로부터 피드백 후 수정
- 작년 대회내용을 기반으로 임의의 맵을 제작하여 미리 드론으로 테스트하면서 본선 준비
- 링 통과여부 체크 및 cut-off 시간체크를 통해 코드의 효율성 확인
- 링 통과 시 최단시간통과 및 다음단계 진행을 위한 코드 최적화 수행

***

### [✔ 알고리즘 설명]
1. ThresHold 임계값 기반 크로마키 컬러 추출
* 크로마키 천, 표식 색깔들에 대한 임계값 범위를 상수값으로 미리설정.
* 드론 카메라로 받은 리얼타임 영상을 프레임단위로 임계값 추출 전처리  

2. 크로마키 틀을 모든 사분면에 골고루 표시되도록 드론이동
* 전처리한 크로마키 추출영상을 사분면 단위로 픽셀개수 추출
* 각 사분면에 골고루 위치하도록 드론이동  
  
3. 통과해야 할 원 추출
* imfill 함수를 통해 원 채우기
* 전처리전 영상과 비교하여 원에 해당하는 부분 추출  
  
4. 원의 중앙값 검출 및 드론 미세조정
* 원이 검출되면 원에 해당하는 픽셀의 좌표의 평균값을 통해 중앙값 검출
* 원이 검출되지 않으면 원이 검출되도록 드론 미세조정  
  
5. 드론 전진 및 링 통과
* 드론이 원의 중앙점 오차허용 범위에 위치하면 드론을 전진
* 표식을 검출할 때까지 전진 후 정지
* 드론이 원의 중앙점 오차허용 범위에 위치하지 않으면 드론 미세조정  
  
6. 표식에 따른 드론 행동 결정
* 검출된 표식의 컬러값에 따라 좌회전 및 착륙 행동 수행  

### 1m 이동
![알고리즘1](https://user-images.githubusercontent.com/81687612/125638041-55f6e877-8ce2-4065-93ff-6fb73f6a908d.png)
### 2m 이동
![알고리즘2](https://user-images.githubusercontent.com/81687612/125638099-4525e1dd-8d75-4b55-9b29-aafff0d566c3.png)
### 3m 이동
![알고리즘3](https://user-images.githubusercontent.com/81687612/125638118-ee06ffd8-167e-4b9b-9602-5b69fdd5d9ad.png)
***

### [✔ 소스 코드 설명]
```
    % HSV Convert
    disp('----------------- HSV Converting --------------------');
    frame = snapshot(cameraObj);
    src_hsv = rgb2hsv(frame);
    src_h = src_hsv(:,:,1);
    src_s = src_hsv(:,:,2);
    src_v = src_hsv(:,:,3);
    [rows, cols, channels] = size(src_hsv);

    % Image Preprocessing
    bw1 = (0.5 < src_h) & (src_h < 0.75); % 파란색 검출 
    if sum(bw1, 'all') == 0
        bw1 = double(zeros(size(src_hsv)));
    end
```
1. ThresHold 임계값 기반 크로마키 컬러 추출
* 크로마키 천, 표식 색깔들에 대한 임계값 범위를 상수값으로 미리설정.
* 드론 카메라로 받은 리얼타임 영상을 프레임단위로 임계값 추출 전처리  
* 드론 카메라 리얼타임 영상 HSV 변환 및 ThresHold 임계값 검출(크로마키 검출)

```
    % Move To Center
    sumUp = sum(bw1(1:rows/2, :), 'all');             % 상단 절반
    sumDown = sum(bw1(rows/2:end, :), 'all');         % 하단 절반
    sumLeft = sum(bw1(:, 1:cols/2), 'all');           % 좌측 절반
    sumRight = sum(bw1(:, cols/2:end), 'all');        % 우측 절반
    
    if(sumUp == 0)                                  % 상단에 크로마키가 없으면
        movedown(droneObj, 'distance', 0.5);        % 하단으로 이동
    elseif(sumDown == 0)                            % 하단에 크로마키가 없으면
        moveup(droneObj, 'distance', 0.5);          % 상단으로 이동
    elseif(sumLeft == 0)                            % 좌측에 크로마키가 없으면
        moveright(droneObj, 'distance', 0.5);       % 우측으로 이동
    elseif(sumRight == 0)                           % 우측에 크로마키 없으면
        moveleft(droneObj, 'distance', 0.5);        % 좌측으로 이동
    else                                            % 4개의 사분면 모두에 크로마키가 존재하면 원 검출
        % 구멍을 채우기 전후를 비교, 원이 아닌부분 0(검은색), 원 부분 1(흰색)
        bw2 = imfill(bw1,'holes');                  % 파란색 배경 안 원을 채움(내부가 채워진 사각형)        
        for row = 1:rows
            for col = 1:cols
                if bw1(row, col) == bw2(row, col)
                    bw2(row, col) = 0;
                end
            end
        end
```
2. 크로마키 틀을 모든 사분면에 골고루 표시되도록 드론이동
* 전처리한 크로마키 추출영상을 프레임의 사분면 단위로 픽셀개수 추출
* 모든 사분면에 크로마키 HSV값이 골고루 위치하도록 드론이동
  
3. 통과해야 할 원 추출
* imfill 함수를 통해 원 채우기
* 전처리전 영상과 비교하여 원에 해당하는 부분 추출  
* 원이 검출되면 해당 부분을 채우고 이전 이미지와 비교하여 원 부분에 해당하는 픽셀을 흰색으로 추출

```
        if sum(bw2, 'all') > 20000
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
            
            disp('Calculating Circle Center');
            moveRow = center_row - camera_mid_row;
            moveCol = center_col - camera_mid_col;  
        else
            disp('Move Cromakey To Center');
            if(sumUp > sumDown)                         % 상단 크로마키 > 하단 크로마키
                disp('MoveUp');
                moveup(droneObj, 'distance', 0.2);      % 상단으로 이동
            else                                        % 상단 크로마키 < 하단 크로마키
                disp('MoveDown');
                movedown(droneObj, 'distance', 0.2);    % 하단으로 이동
            end
            
            if(sumLeft > sumRight)                      % 좌측 크로마키 > 우측 크로마키
                disp('MoveLeft');
                moveleft(droneObj, 'distance', 0.2);	% 좌측으로 이동
            else                                        % 좌측 크로마키 < 우측 크로마키
                disp('MoveRight');
                moveright(droneObj, 'distance', 0.2);   % 우측으로 이동
            end
        end     
    end
```
4. 원의 중앙값 검출 및 드론 미세조정
* 원이 검출되면 원에 해당하는 흰색픽셀의 좌표의 평균값을 통해 중앙값 검출
* 원이 검출되지 않으면 각 사분면에 분포하는 크로마키 픽셀값을 비교하여 원이 검출되도록 드론 미세조정  

```
    try
        disp('Move Drone Very Carefully!!!');
        if (-100 < moveRow && moveRow < 100) && (-100 < moveCol && moveCol < 100)
            movedown(droneObj, 'distance', 0.2);
            bw2_pix_num = sum(bw2, 'all')
            if (150000 < bw2_pix_num) && (bw2_pix_num < 300000)
                moveforward(droneObj, 'distance', 1.4);
                frame = snapshot(cameraObj);
                src_hsv = rgb2hsv(frame);
                src_h = src_hsv(:,:,1);
                src_s = src_hsv(:,:,2);
                src_v = src_hsv(:,:,3);
                
                % Image Preprocessing
                bw_red = ((thdown_red1(1) < src_h) & (src_h < thup_red1(1))) ...        % 빨간색1범위 검출
                       + ((thdown_red2(1) < src_h) & (src_h < thup_red2(1)));           % 빨간색2범위 검출
                bw_purple = (thdown_purple(1) < src_h) & (src_h < thup_purple(1));      % 보라색범위 검출
                % 빨간색 혹은 보라색 검출할 때까지 전진
                if (sum(bw_red, 'all') > 4000)                          % 빨간색이 검출되면
                    disp('RED Color Detected!!! Drone Turn Left');
                    turn(droneObj, deg2rad(-90));                       % Turn Left, 다음동작 크로마키 검출, 지난 링을 건드리지 않도록 일정거리 전진
                    moveforward(droneObj, 'distance', 1.25);            % 맵에 따라서(크로마키의 앞뒤 위치에 따라서) 없애야 할 수도 있음
                    break;
                elseif(sum(bw_purple, 'all') > 4000)                    % 보라색이 검출되면
                    disp('Purple Color Detected!!! Drone Landing');
                    land(droneObj);                                     % Landing
                    return;                                             % 프로그램 종료
                end
            elseif (bw2_pix_num < 180000)
                moveforward(droneObj, 'distance', 0.5);                 % 맵에 따라서 1m단위로 링을 배치한다면 0.5, 아니라면 0.2 or 0.25
            end   
        elseif moveRow < -100
            disp('MoveUp');
            moveup(droneObj, 'Distance', 0.2)
        elseif 100 < moveRow
            disp('MoveDown');
            movedown(droneObj, 'Distance', 0.2)
        elseif moveCol < -100
            disp('MoveLeft');
            moveleft(droneObj, 'Distance', 0.2)
        elseif 100 < moveCol
            disp('MoveRight');
            moveright(droneObj, 'Distance', 0.2)
        end
```
5. 드론 전진 및 링 통과
* 드론이 원의 중앙점 오차허용 범위에 위치하면 드론을 전진
* 전진하면서 표식의 픽셀 개수를 탐색
* 표식의 픽셀개수가 일정개수 이상일 때까지 전진 후 정지
* 드론이 원의 중앙점 오차허용 범위에 위치하지 않으면 드론 미세조정  

6. 표식에 따른 드론 행동 결정
* 검출된 표식의 컬러값에 따라 좌회전 및 착륙 행동 수행  
* 검출된 표식이 빨간색이라면 좌회전 수행
* 검출된 표식이 보라색이라면 착륙 수행
 
```
        disp('There is Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 3), imshow(bw1); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        subplot(2, 2, 4), imshow(bw2); hold on;
        plot(center_col, center_row, 'r*'); hold off;
        clear center_col;
        clear center_row;
   catch exception
        disp('There is no Circle Center Coordinates');
        subplot(2, 2, 1), imshow(frame);
        subplot(2, 2, 2), imshow(frame);
        subplot(2, 2, 3), imshow(bw1);
    end
    pause(1);
end
```
디버깅 및 결과 이미지 출력을 위한 영상출력 코드





