****
# 2022 자율주행 드론 대회 
### Team '드론을 잘 만드론': 홍성민, 김호중, 최성준

****
# 최종 대회 코드

## 알고리즘
- **hole 탐지 및 noise 제거**
  1. hsv를 활용한 채도 noise 제거
    ```Matlab
    detect_ring = (0.6<h) & (h<0.66) & (0.55<s) & (s<0.9);
    ```
  2. 탐지한 영역(파란색) 외의 영역 무시(noise 제거)
    ```Matlab
    detect_ring = bwareafilt(detect_ring, 1);
    ```
  3. hole 탐지(탐지한 영역()의 구멍에 해당)를 위한 이진 반전
    ```Matlab
    detect_ring= imcomplement(detect_ring);
    detect_ring = bwareafilt(detect_ring, 2);
    ```
  4. hole, 배경 외의 영역 무시(noise 제거)
    ```Matlab
    detect_ring = bwareafilt(detect_ring, 2);
    ```
  5. 두 영역 중 hole 탐지 (일반적으로 hole이 배경보다 작다고 가정, 추가 예외처리 참조)
    ```Matlab
    detect_ring = bwareafilt(detect_ring, 1, 'smallest');
    ```
 
- **목표지점과 중앙값을 고려한 미세조정**
  1. **프레임의 중앙값**: 960 x 720의 프레임에서 드론이 일직선이 아닌 아래 방향을 촬영한다는 것을 고려하여 y의 중앙값은 720의 절반인 360보다 훨씬 낮춰서 설정
    ```Matlab
    center_x = 480;
    center_y = 200;
    center = [center_x,center_y];
    ```
  2. **객체의 중앙값** 탐지
    ```Matlab
    c = regionprops(detect_ring,'centroid');
    centroids = cat(1,c.Centroid);
    goal = [centroids(:,1), centroids(:,2)];
    ```
  3. **객체의 중앙값과 프레임의 중앙값을 비례**하여 이동 제어
    ```Matlab
    if abs(center_x - centroids(:,1)) >= 350
        adj_x = 0.2;
    elseif abs(center_x - centroids(:,1)) < 350 &&  ( abs(center_x - centroids(:,1)) >= 200 )
       adj_x = 0.1;
    elseif abs(center_x - centroids(:,1)) < 200
       adj_x = 0;
    end

    if norm(center-goal) > distance
        if movelr && (center_x - centroids(:,1)) >= 20
            if nohole == true
                moveleft(droneObj,'distance',0.4 + adj_x,'speed',1) 
            else
                moveleft(droneObj,'distance',0.2 + adj_x,'speed',1) 
            end 
        elseif (center_x - centroids(:,1)) < -20
            if nohole == true
                moveright(droneObj,'distance',0.4 + adj_x,'speed',1) 
            else
                moveright(droneObj,'distance',0.2 + adj_x,'speed',1) 
            end
        else
            movelr = false;
        end
    end
    ```
    4. 객체의 중앙값과 프레임의 **중앙값의 오차가 일정 값 이하**이면 그 방향(상하 or 좌우)으로는 더이상 움직이지 않음.
    ```Matlab
        else
            movelr = false;
        end
    end
    ```
    
     5. 드론이 객체의 중앙과의 거리가 일정 값 이하가 되면 파란색 ring이 보이기 전까지 직진으로만 이동
    ```Matlab
    while(sum(detect_ring,'all') > 10)
        moveforward(droneObj,'distance',0.7,'speed',1)
        frame = snapshot(cameraObj);
        subplot(2,1,1);
        imshow(frame)

        hsv = rgb2hsv(frame);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);
        detect_ring = (0.6<h)&(h<0.66)&(0.55<s)&(s<0.9);
        subplot(2,1,2);
        imshow(detect_ring)
    end
    ```

- **s(채도)까지 고려한 색상값 추출**
    ```Matlab
    detect_ring = (0.6<h) & (h<0.66) & (0.55<s) & (s<0.9);
    ```

- 복잡한 구조가 아닌 **함수를 활용한 이해하기 쉬운 구조**
  ```Matlab
    detect_ring = bwareafilt(detect_ring, 1);
    detect_ring= imcomplement(detect_ring);
    [B,L,N] = bwboundaries(detect_ring);
    c = regionprops(detect_ring,'centroid');
  ```
  - bwareafilt: 이진 영상에서 크기별로 객체를 추출하는 함수
  - imcomplement: 이진 영상 반전
  - bwboundaries: 이진 영상에서 boundary값 추출
  - regionprops: 'centroid' 값을 주어 주어진 영역의 중심값 추출
    
- **테두리와 중심점을 표시하여 가시성을 좋게함**
  > ![image](./img/algorithms.png)
  ```Matlab
  hold on;
  for k=1:length(B)
     boundary = B{k};
     if(k >= N)
       plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
     end
  end
  c = regionprops(detect_ring,'centroid');
  centroids = cat(1,c.Centroid);
  plot(centroids(:,1),centroids(:,2),'b*');
  ```

## 예외처리
- **hole의 크기가 배경보다 큰 경우**: hole 탐지를 위한 테두리 생성
  - 이 경우 배경의 무게중심을 목표점으로 하는 문제점이 발생
  - hole은 파란색 크로마키 내부에 있다는 것을 이용
    1. **[hole이 테두리를 벗어나는 경우]** 파란색 크로마키 영역을 따기 위한 테두리 형성 (첫 번째 행 & 마지막 행)  
    > ![image](./img/예외처리1.png)
    > ```Matlab
    > for i = 1:960
    >     find_circle(1,i) = 1;
    > end
    > for i = 1:960
    >     find_circle(720,i) = 1;
    > end
    > ```
    2. **[hole이 모서리에 나있는 경우]** 크로마키의 중심 x좌표가 왼쪽과 오른쪽 중 가까운 쪽 테두리도 채워줌. 
      - 다음 그림처럼 hole이 모서리에 나있는 경우 행의 테두리만 형성해서는 크로마키 영역을 만들 수 없기에, 크로마키의 중심 x좌표가 왼쪽과 오른쪽 중 어디에 가까운지에 따라서 열의 테두리도 채워줌. 
    > ![image](./img/예외처리2.png)
    >   ```Matlab
    >   // ring_center: 크로마키의 중심 좌표
    >   [row, col] = find(pass);
    >   locmin = min(col);
    >   locmax = max(col);
    >   ring_center = (locmin + locmax) / 2;
    >   ```
    >   ```Matlab
    >   if ring_center <= 480
    >       for i = 1:720
    >           find_circle(i,1) = 1;
    >       end
    >   else
    >       for i = 1:720
    >           find_circle(i,960) = 1;
    >       end
    >   end
    >   ```
    3. 크로마키 영역의 구멍을 채워줌
    ```Matlab
    find_circle = imfill(find_circle,'holes');
    ```
    4. 무게중심이 파란색 크로마키 내부에 형성되지 않으면 큰 영역(hole)을 탐지
    ```Matlab
    a = round(centroids(:,1));
    b = round(centroids(:,2));
    if find_circle(b,a) == 1
        break
    else
        detect_ring = store;
        detect_ring = bwareafilt(detect_ring, 1); 
    ```

- **객체의 중앙값과 프레임의 중앙값을 비교**시 크로마키 홀의 크기에 따라 허용오차값 조절
    ```Matlab
    if level == 2
        distance = 90;
    elseif level == 3
        distance = 60;
    end
    ```

- **이동 과정**: 파란색 링이나 마커가 안 보일 경우 (드론이 관심영역 바깥에 있을 경우)
    ```Matlab
    moveback(droneObj,'distance',0.3) 
    ```
    
- **hole 탐지 실패했을 경우**
  > ![image](./img/예외처리3.png)
  1. hole 탐지 판별 변수 설정 
    ```Matlab
    compare = bwareafilt(detect_ring, 1, 'largest');
    detect_ring = bwareafilt(detect_ring, 1, 'smallest');
    ```
  2. hole 탐지 실패했을 경우(hole 없어서 오차 영역이 관심영역으로 지정되거나 배경이 관심영역으로 지정될 경우) 파란색 영역 자체를 관심영역으로 지정
    ```Matlab
    if (sum(detect_ring,'all') < 100) || isequal(compare, detect_ring)
        disp("test");
        detect_ring = store;
        detect_ring = bwareafilt(detect_ring, 1);
        detect_ring= imcomplement(detect_ring);
        continue
    end
    ```
  3. 파란색 영역의 무게중심을 목표점으로 지정하면 nohole 변수를 이용해서 드론이 더 많은 거리(0.4m씩)를 이동하면서 중점을 찾도록 지정
    ```Matlab
    if norm(center-goal) > distance
      if movelr && (center_x - centroids(:,1)) >= 20
          if nohole == true
              moveleft(droneObj,'distance',0.4,'speed',1) 
          else
              moveleft(droneObj,'distance',0.2,'speed',1) 
          end 
      elseif (center_x - centroids(:,1)) < -20
          if nohole == true
              moveright(droneObj,'distance',0.4,'speed',1) 
          else
              moveright(droneObj,'distance',0.2,'speed',1) 
          end
      else
          movelr = false;
    end
    ```
    4. 이 경우에는 상하좌우 이동이 고정되지 않도록 stopmove 변수 사용
    ```Matlab
    if (sum(detect_ring,'all') < 100) || isequal(compare, detect_ring)
        disp("test");
        detect_ring = store;
        detect_ring = bwareafilt(detect_ring, 1);
        detect_ring= imcomplement(detect_ring);
        stopmove = false;
        nohole = true;
        continue
    end
    
    if stopmove == false
        movelr = true;
        moveud = true;
    end
    '''
    
****
### 추가
**1차 워크샵 과제**: first_workshop_hw.m</br>
**2차 워크샵 과제**: 2차 과제/</br>
**3차 워크샵 과제**: 3차 과제/
