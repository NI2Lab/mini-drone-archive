2020 Mini-Drone 자율비행 경진대회
=================================
## Team Name : Na Honza Nanda (나 혼자 난다)
##### 팀장 : 민채현 팀원 : 심선하 오현택
----------------------------------
## 1.대회 진행 전략

### -드론의 구조 이해 
#### 1)드론의 방향 조절
![drone](https://user-images.githubusercontent.com/65802048/87393289-e5feff80-c5e8-11ea-86f3-0c7f0af9518d.PNG)
#### 2)e-drone 매뉴얼의 이해   
드론의 좌우이동에 대한 함수의 이해      
<http://dev.byrobot.co.kr/documents/kr/products/e_drone/library/python/e_drone/>
#### 3)PiCamera 메뉴얼의 이해    
카메라의 capture, write 등에 대한 함수에 대한 이해      
<https://picamera.readthedocs.io/en/release-1.10/api_camera.html>                                 
           
### -openCV 함수의 이해 및 활용
      
#### 1)이미지 변환
* cvtColor : 이미지의 색공간을 변경하는 것      
* BGR->HSV    
<div>
<img src = "https://user-images.githubusercontent.com/65802048/87399342-3a5aad00-c5f2-11ea-807c-3908fadd841d.jpg" width="45%">
<img src = "https://user-images.githubusercontent.com/65802048/87401381-046af800-c5f5-11ea-9751-fd80eb26e375.jpg" width="45%">
</div>

* Image Mask->GRAY        
<div>
<img src = "https://user-images.githubusercontent.com/65802048/87415606-45203c80-c608-11ea-9cc7-6b167e35e59e.jpg" width="45%">
<img src = "https://user-images.githubusercontent.com/65802048/87415608-46ea0000-c608-11ea-8716-9577d1d6c6b3.jpg" width="45%">
</div>

#### 2)이미지 보정     

* threshold binary   
threshold보다 크면 value값으로 아닌 경우에는 0으로 바꿈.
<div>     
<img src = "https://user-images.githubusercontent.com/65802048/87402676-df778480-c5f6-11ea-8808-42c530f503c1.jpg" width="45%">    
<img src = "https://user-images.githubusercontent.com/65802048/87423854-f4afdb80-c615-11ea-87bf-ff717a835350.PNG" width="45%">           
</div>      



* canny         
경계선을 찾는 알고리즘 함수
<img src = "https://user-images.githubusercontent.com/65802048/87402869-1cdc1200-c5f7-11ea-8919-773644e9bbac.jpg" width="45%">   
      
* median blur    
nonlinear filter로 central 이웃 값들을 정렬한 상태에서 middle 값을 선택한 것    
<div>              
 <img src = "https://user-images.githubusercontent.com/65802048/87404208-d1c2fe80-c5f8-11ea-977a-fba242d8c183.jpg" width="45%">          
<img src = "https://user-images.githubusercontent.com/65802048/87404206-d091d180-c5f8-11ea-86dd-4c44bb28fbaf.jpg" width="45%">               
</div>         



#### 3)링(사각형) 판별               
링(사각형)을 판단할 경우 링이 전부 찍히는 경우와 부분만 찍히는 경우, 링의 끝부분만 찍히는 경우만 찍히는 경우가 발생             
> **A.링이 전체적으로 나오는 경우**         
<div>          
<img src = "https://user-images.githubusercontent.com/65802048/87403388-c4594480-c5f7-11ea-9994-d77f34016904.jpg" width="45%">            
<img src = "https://user-images.githubusercontent.com/65802048/87407920-c58d7000-c5fd-11ea-99f5-c4c5d74ccc99.jpg" width="45%"> 
</div>        
       
> **B.링의 부분만 찍히는 경우**         
<div>          
<img src = "https://user-images.githubusercontent.com/65802048/87406095-3b440c80-c5fb-11ea-86e9-e47bf2b8522e.jpg" width="45%">        
<img src = "https://user-images.githubusercontent.com/65802048/87407924-c6be9d00-c5fd-11ea-9a08-9a621f8b4e8e.jpg" width="45%">             
</div>       
      
> **C.링의 끝부분만 찍히는 경우**          
<div>  
<img src = "https://user-images.githubusercontent.com/65802048/87414153-4d777800-c606-11ea-9e01-8bf1e22cc131.jpg" width="45%">          
<img src = "https://user-images.githubusercontent.com/65802048/87414149-4b151e00-c606-11ea-9b0f-1547a23b7be2.jpg" width="45%">            
</div>   
                     
             
> **D.링의 하단 부분의 예외 처리**      
<div>      
<img src = "https://user-images.githubusercontent.com/65802048/87422560-d2b55980-c613-11ea-9b2d-ffb440435021.jpg" width="45%">     
</div>                   
-링의 하단 부분인 경우 그림과 같이 원하는 부분이 잡히지 않아 예외로 잡아 처리함.      

> **E.2단계 링에서 예외 처리**         
<div>          
<img src = "https://user-images.githubusercontent.com/65802048/87520073-6db63e00-c6bd-11ea-916c-95935d983d8c.jpg" width="45%">         
<img src = "https://user-images.githubusercontent.com/65802048/87520080-6f800180-c6bd-11ea-9122-1688d6c96b62.jpg" width="45%">                
</div>     
2단계 링의 중심을 찾을 경우 옆에 있는 3단계 링이 보이게 되어 오류가 발생함.                             
따라서 코드적으로 수정하여 오류를 처리.    

#### 4)원 판별  
BGR->HSV->mask값 추출-> 이진화 ->  Canny Edge -> houghcircles로 원 검출

<div> 
<img src = "https://user-images.githubusercontent.com/65802048/87406855-4fd4d480-c5fc-11ea-98f5-27b9106a0a60.jpg" width="45%">           
<img src = "https://user-images.githubusercontent.com/65802048/87406865-519e9800-c5fc-11ea-9137-64e7ddd6354d.jpg" width="45%"> 
</div>     
<div> 
<img src = "https://user-images.githubusercontent.com/65802048/87407049-932f4300-c5fc-11ea-890f-578ff9b2c05c.jpg" width="45%">                
<img src = "https://user-images.githubusercontent.com/65802048/87407084-a04c3200-c5fc-11ea-82a8-dec50e1a1777.jpg" width="45%">    
</div>   
<div> 
<img src = "https://user-images.githubusercontent.com/65802048/87407104-a7734000-c5fc-11ea-8ba3-ed99741fc474.jpg" width="45%">              
<img src = "https://user-images.githubusercontent.com/65802048/87407112-ab06c700-c5fc-11ea-9fe8-9229d0d45950.jpg" width="45%"> 
</div>



### -트랙 구현         
실제 경기장과 유사하게 만들어 모의 시뮬레이션 진행
<div>        
<img src = "https://user-images.githubusercontent.com/65802048/87395103-be5d6680-c5eb-11ea-87ae-4a84474df230.jpg" width="45%">
<img src = "https://user-images.githubusercontent.com/65802048/87395105-bef5fd00-c5eb-11ea-9cfe-aa75e778efa0.jpg" width="45%">
</div>       

******************************

## 2.알고리즘     

![algorithm](https://user-images.githubusercontent.com/65802048/87422071-ef9d5d00-c612-11ea-937d-0f1f88b9680d.PNG)

******************************    
 
## 3.소스코드 설명           
### 1)링(사각형) 검출 코드       
* #### 테두리에 링이 닿는 부분이 있는지 검출하는 코드 
          
<pre>
<code>
    N = 7
    direction = np.zeros((4, N))
    px_x = np.ones((N, 1))
    px_y = np.ones((N, 1))
    px_w = np.linspace(0, w - 1, N).reshape(N, 1)
    px_h = np.linspace(0, h - 1, N).reshape(N, 1)

    px_up = tuple(map(tuple, np.hstack([px_y * 0, px_w]).astype(np.int64)))
    px_down = tuple(map(tuple, np.hstack([px_y * (h - 1), px_w]).astype(np.int64)))
    px_left = tuple(map(tuple, np.hstack([px_h, px_x * 0]).astype(np.int64)))
    px_right = tuple(map(tuple, np.hstack([px_h, px_x * (w - 1)]).astype(np.int64)))

    for i in range(N):
        if gray[px_up[i]] > 0:
            direction[0, i] = 1
        if gray[px_down[i]] > 0:
            direction[1, i] = 1
        if gray[px_left[i]] > 0:
            direction[2, i] = 1
        if gray[px_right[i]] > 0:
            direction[3, i] = 1
</code>
</pre>       

* #### 이진화 & Canny Edge & Countour / Coutour 함수에서 일정 길이 이상인 것만 다시 저장
<pre>
<code>

    dst = cv2.medianBlur(gray, 9)  # Median Blur
    ret, thr = cv2.threshold(dst, 1, 255, cv2.THRESH_BINARY)
    img_canny = cv2.Canny(thr, 50, 150)
    _, contours, hierarchy = cv2.findContours(img_canny, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    p = w / 4
    a = []
    for i in contours:
        length = cv2.arcLength(i, closed=True)
        if length > p:
            a += [i]
            
    img = cv2.drawContours(img, a, -1, (0, 255, 255), 1)
    a = np.array(a)
</code>
</pre>

* #### Coutour 함수 내에서 다시 저장한 것중에 가장 넓이 작은 거 선택
<pre>
<code>
    min_area = w * h
    min_index = 0
    change = False
    for i in range(len(a)):
        contourArea = cv2.contourArea(a[i])
        if contourArea > (min_area / 10):
            if min_area > contourArea:
                min_area = contourArea
                min_index = i
                change = True
</code>
</pre>

* #### Coutour 함수의 사각형으로 중심 찾기/2단계 링에서 3단계 링 검출 예외 처리
<pre>
<code>
        if second:       # 2단계에서만 왼쪽에 인식한 컨투어는 제외
            b = []
            if not change:
                for i in range(a.shape[0]):
                    xx, yy, ww, hh = cv2.boundingRect(a[i])
                    # 오른쪽에 잡히는것만 다시 저장
                    if int(xx + ww / 2) > x:
                        b += [a[i]]
            min_area2 = w * h
            min_index2 = 0
            for i in range(len(b)):
                contourArea = cv2.contourArea(b[i])
                if min_area2 > contourArea:
                    min_area2 = contourArea
                    min_index2 = i

            xx, yy, ww, hh = cv2.boundingRect(b[min_index2])
            cv2.rectangle(img, (xx, yy), (xx + ww, yy + hh), (0, 255, 255), 2)
            c_x = int(xx + ww / 2)
            c_y = int(yy + hh / 2)
            cv2.circle(img, (c_x, c_y), 5, (255, 255, 0), -1)
            print(c_x, c_y)
            print(x - c_x, y - c_y)

        else:               # 1, 3단계
            xx, yy, ww, hh = cv2.boundingRect(a[min_index])
            cv2.rectangle(img, (xx, yy), (xx + ww, yy + hh), (0, 255, 0), 2)
            c_x = int(xx + ww / 2)
            c_y = int(yy + hh / 2)
            cv2.circle(img, (c_x, c_y), 5, (255, 0, 0), -1)

            # 하단부 검출일때
            if 'u' in result:
                if 'd' not in result:
                    if a.shape[0] == 2:
                        if not change and min_index == 0:  # 바뀌지 않고 0번째 인덱스일 때
                            xx, yy, ww, hh = cv2.boundingRect(a[1])
                            cv2.rectangle(img, (xx, yy), (xx + ww, yy + hh), (0, 0, 255), 2)
                            c_x = int(xx + ww / 2)
                            c_y = int(yy + hh / 2)
                            cv2.circle(img, (c_x, c_y), 5, (255, 0, 0), -1)

</code>
</pre>





### 2)원 검출 코드           
* #### HoughCircles를 통한 원 검출 코드       

<pre>
<code>
    # 이진화 & Canny Edge
    gray = cv2.cvtColor(img_result_blue, cv2.COLOR_BGR2GRAY)
    dst = cv2.medianBlur(gray, 9)  # Median Blur
    ret, thr = cv2.threshold(dst, 1, 255, cv2.THRESH_BINARY)
    img_canny = cv2.Canny(thr, 50, 150)

    # 원 검출
    circles = cv2.HoughCircles(img_canny, cv2.HOUGH_GRADIENT, 1, 100, param1=250, param2=10, minRadius=15, maxRadius=40)
    # (이미지,방법,해상도비율,최소거리,캐니에지 임계값,중심임계값, 최소반지름,최대반지름)
</code>
</pre>           
     
### 3)구동 코드 
* #### sendControlWhile과 sendControlPosition16 사용     
 sendControlPosition16의 경우 최소 10cm 밖에 움직이지 않아 미세한 조정 어려움.       
 따라서 sendControlWhile문을 이용해 5cm로도 움직이게 만들어 중심점을 찾기 더 수월하게 함.
<pre>
<code>
drone.sendControlPosition16(0, 0, 1, 5, 0, 0)  //위로 10cm 이동
drone.sendControlWhile(0, 0, 0, 5, 1000)       //위로 5cm 이동
</code>
</pre>






