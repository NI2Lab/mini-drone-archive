🌈무지개색 종이빨대🌈
=================

대회 진행 전략
--------------

#### 영상 처리 순서

  ##### 원본 이미지 ➡️ 모폴로지 연산 ➡️ 구멍 채우기 ➡️ 영상 간 뺄셈 ➡️ 잡음 제거 ➡️ 중앙 좌표 표시    
  
  
  ![image_processing](https://user-images.githubusercontent.com/60953739/87312030-01bbc480-c55b-11ea-855b-3af9bb259c1f.gif)
  
  
#### 차별적인 전략 
    
       
1. 정확한 판단을 하기 위해서 전방 카메라의 화각이 약간 아래쪽을 보는 것을 고려하여  
  판단해야 하는 물체보다 높은 높이에서 판단하도록 개발하였습니다.
      
     
![드론 카메라의 시야각](https://user-images.githubusercontent.com/60953739/87366636-26905600-c5b4-11ea-9506-939f0c8fcef3.png)
     
       
          
2. 경기장 규칙 중 2단계와 3단계의 높이가 서로 반대라는 점을 이용하여     
   'readHeight' 함수를 사용하여 현재 높이를 측정하고       
    3단계 링을 탐색할 때 반영하여 탐색 시간을 줄였습니다.
        
![rule](https://user-images.githubusercontent.com/50540673/87462559-18414900-c64b-11ea-966b-d04ef1c4c6fb.png)
      
      
![search_reduce](https://user-images.githubusercontent.com/60953739/87370778-da96de80-c5be-11ea-85f6-8814ccc46a23.png)
               
          
         
알고리즘 설명
-------------
      
      
![flow_chart](https://user-images.githubusercontent.com/60953739/87413379-2ec4b180-c605-11ea-98fc-ecb7e99eb1da.png)


코드 설명
---------
    
     
1.  first square through
    
    
    1번 함수를 이용하여 초록색 과녁의 중앙값을 계산하여 카메라의 중앙값과의 비교를 통해 드론을 상하좌우로 움직여 오차범위 내에 드론이 위치할 경우 앞으로 전진한다.
    
     
    ```
    if img_mid(2) - hole_mid(2) > 35
        moveleft(droneObj, 'Distance', 0.2);
    elseif img_mid(2) - hole_mid(2) < -35
        moveright(droneObj, 'Distance', 0.2);
    elseif img_mid(1) - hole_mid(1) > 35
        moveup(droneObj, 'Distance', 0.2);
    elseif img_mid(1) - hole_mid(1) < -35
        movedown(droneObj, 'Distance', 0.2);
    else
        movedown(droneObj, 'Distance', 0.5);
        moveforward(droneObj, 'Distance', 2.5, 'Speed', 0.6);
        break;
    end
    ```
    
     
     
2.  first red dot detect
    
    
    hsv를 이용하여 빨간색을 인식하여 일정 수 이상의 빨간색이 검출되면 좌측으로 90도 회전한다.
    
    
    ```
    detect_red = (h > 1) + (h < 0.05);
    
    sum_r = sum(detect_red, 'all');
    if sum_r >= 15000
        turn(droneObj, deg2rad(-90));
        pause(1);
        moveforward(droneObj, 'Distance', 1);
    end
    ```
    
    
    
3.  second square through

    
    초록색 과녁의 중앙값을 인식할 수 있는 경우 page1과 같이 1번 함수를 이용하여 비교하고 
    과녁의 중앙값을 찾을 수 없는 경우 2번 함수를 이용하여 캡처한 이미지에서 초록색이 
    많은 방향으로 드론을 이동시킨다. 드론이 오차범위 내에 들어오면 전진한다.
    
    
    ```
    if isnan(hole_mid)
        median = GreenTracking(img);
        row_median = median(1);
        col_median = median(2);
        
        if img_mid(2) - col_median > 35
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - col_median < -35
            moveright(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median > 35
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median < -35
            movedown(droneObj, 'Distance', 0.2);
        else
            movedown(droneObj, 'Distance', 0.4);
            moveforward(droneObj, 'Distance', 2.0);
            break;
        end
    else
    ```
     
    
    
4.  second red dot detect

    
    2와 동일한 작업 후 지금의 높이를 기준으로 마지막 초록색 과녁의 높이를 예측하여 위, 아래로 이동한다.
    
    
    ```
    [height, time] = readHeight(droneObj)
        
        if height >= 0.9
            movedown(droneObj, 'Distance', 0.4);
        else
            moveup(droneObj, 'Distance', 0.6);
        end
    ```
      
    
    
5.  search green color
    
    
    마지막 과녁은 좌우로 1.2미터씩 이동할 수 있기에 좌우로 움직이며 일정 수 이상의 초록색이 검출될 때까지 탐색한다.
    
    
     
    ```
    if sum(detect_green, 'all') >= 60000
        % green color detected
        break;
    else
        if flag1 > 3
            moveup(droneObj, 'Distance', 0.5); 
            moveleft(droneObj, 'Distance', 1.5);
            flag1 = 0;
        else
            moveright(droneObj, 'Distance', 0.3);
            flag1 = flag1 + 1;
        end
    end
    ```
     
    
    
6.  last square through
    
    
    page3와 동일한 작업을 수행하여 드론을 전진시킨다. 
     
    
    
    ```
    if isnan(hole_mid)
        median = GreenTracking(img);
        row_median = median(1);
        col_median = median(2);
        
        if img_mid(2) - col_median > 35
            moveleft(droneObj, 'Distance', 0.2);
        elseif img_mid(2) - col_median < -35
            moveright(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median > 35
            moveup(droneObj, 'Distance', 0.2);
        elseif img_mid(1) - row_median < -35
            movedown(droneObj, 'Distance', 0.2);
        else
            movedown(droneObj, 'Distance', 0.4);
            moveforward(droneObj, 'Distance', 2.0);
            break;
        end
    else
    ```     
    
    
7.  blue dot detect 
      
    
    hsv를 이용하여 빨간색을 인식하여 일정 수 이상의 파란색이 검출되면 착지한다.
       
    
    
    ```
    detect_blue = (h>0.575)+(h<0.625);

    if sum(detect_blue, 'all') >= 15000
        % blue color detected
        land(droneObj);
        break;
    end
    ```
    
    
          
  function 1.
    
   
  * 초록색 과녁의 중앙값을 검출해내는 함수
    
    
    
    ```
    bw = imdilate(bw,se);
    bw = imdilate(bw,se);
    bw = imerode(bw,se);
    bw = imerode(bw,se);
    
    bw = bwareaopen(detect_green, 1000);
    %figure, imshow(bw)
   
    bw2 = imfill(bw, 'holes');
    
    bw3 = bw2 - bw;
    ```
     
    
    
  function 2.
     
    
  * 초록색 과녁의 중앙을 찾지 못할 경우 화면에 보이는 초록색 영역의 위치 검출 
    
    
      
    ```
    [row, col] = find(bw2);

    row = unique(row);
    col = unique(col);

    row_size = size(row, 1);
    col_size = size(col, 1);

    row_median = round(sum(row)/row_size);
    col_median = round(sum(col)/col_size);
    
    ans = [row_median col_median];
    ```
    

