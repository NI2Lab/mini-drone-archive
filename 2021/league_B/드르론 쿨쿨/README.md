# DrroneCoolCool
<p align="center"><img src="https://user-images.githubusercontent.com/57785792/88495612-69f7b500-cff5-11ea-8d13-9d8f5b3f7260.PNG"(http://www.kiee.or.kr/)><img src="https://user-images.githubusercontent.com/80773720/125616834-fe81d087-0787-482b-80c4-9267e1db2afe.jpg"(https://www.khu.ac.kr/kor/main/index.do)></p></br>

# 2021 미니드론 자율비행 경진대회

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![License](https://img.shields.io/badge/Raspberry%20pi%20zero-pass-blue)        
![License](https://img.shields.io/badge/python-v3.8.5-brightgreen) ![License](https://img.shields.io/badge/e_drone-v21.1.6-brightgreen) ![License](https://img.shields.io/badge/numpy-v1.16.2-brightgreen) ![License](https://img.shields.io/badge/pillow-v5.4.1-brightgreen) ![License](https://img.shields.io/badge/opencv-v3.2.0-brightgreen)  
<br></br>

## 목차 

>**1. 대회 진행 전략**    
>**2. 알고리즘 설명**   
>**3. 소스 코드 설명**   
>**4. 코드론 데이터시트**   
>**5. 팀원**   
>**6. 라이센스**   

</br>
</br>

## 1. 대회 진행 전략
### 1-a. 파이썬의 이해
> * Beautiful is better than ugly
> * Explicit is better than implicit
> * Simple is better than complex
> * Complex is better than complicated
> * Flat is better than nested
> * [More](https://en.wikipedia.org/wiki/Zen_of_Python)

### 1-b. 라즈베리 파이와의 통신에 대한 이해
   * 라즈베리 파이를 통해 PC로 드론 제어
   [구성도 사진 첨부]

### 1-c. Practicing of using programs for contest
  
   ### 사용 프로그램

   #### < vscode 첨부 >
   * 파이썬 코드 편집
   * [Guide] (링크 첨부)  
   
   #### <img src="https://user-images.githubusercontent.com/57785792/87244515-e5475b80-c478-11ea-9177-7aef730dd40a.jpg" width="20" height="20"> PyCharm Community Edition 2020
   * 파이썬 코드 편집
   * [Guide](https://dora-guide.com/pycharm-install/)

   #### <img src="https://user-images.githubusercontent.com/57785792/87244655-9221d880-c479-11ea-9f17-bd71250f5528.jpg" width="20" height="20"> WinSCP
   * 데이터 파일 전송
   * [Guide](http://blog.naver.com/PostView.nhn?blogId=websarang_&logNo=100052630947&viewDate=&currentPage=1&listtype=0)


   ####  <img src="https://user-images.githubusercontent.com/57785792/87244362-a95fc680-c477-11ea-9a8d-75ccf17f3cb1.png" width="20" height="20"> VNC viewer 
   * 라즈베리 파이를 PC로 디스플레이
   * [Guide](https://itgroovy.tistory.com/549)

   #### <img src="https://user-images.githubusercontent.com/57785792/87244698-052b4f00-c47a-11ea-9a52-2520feb5dfed.png" width="20" height="20"> Sourcetree
   * github 업데이트
   * [Guide](https://ux.stories.pe.kr/181)
   

### 1-d. 드론의 비행에 대한 이론적 이해
   * 드론의 위치 제어를 위한 throttle, pitch, row 및 yaw 제어
<p align="center"><img src="https://user-images.githubusercontent.com/80773720/125615967-07c93d2a-8bd2-4bce-b583-1f65e8ede5ca.png" width="443" height="333"></p>

### 1-e. Position codes of drone and application codes
   ```python
   def sendControlPosition(self, positionX, positionY, positionZ, velocity, heading, rotationalVelocity):
   ```
   | Variable name | form | range | unit | explain |
   |:---------:|:----:|:----:|:---:|:---:|
   |position X|float|-10.0 ~ 10.0|meter|forward(+), behind(-)|
   |position Y|float|-10.0 ~ 10.0|meter|left(+), right(-)|
   |position Z|float|-10.0 ~ 10.0|meter|up(+), down(-)|
   |velocity|float|0.5 ~ 2.0|meter|moving velocity|
   |heading|Int16|-360 ~ 360|degree|left turn(+), right turn(-)|
   |rotationalVelocity|Int16|10 ~ 360|degree/s|rotational velocity|
   * Reference code : http://dev.byrobot.co.kr/documents/kr/products/e_drone/library/python/e_drone/

### 1-f. 맵
[트랙 사진 첨부]
[트랙 규격 수치화 그림판 사진 첨부]

   * 규격 설명
   * 변경 가능 범위 설명
 
### 1-g. Error handling
#### Hardware problem
    Use sensor reset in controller for H.W problem
    Setting trim for stable hovering
    Check the whole manual 
  Go to "[manual](http://www.roboworks.co.kr/web/home.php?mid=10&go=pds.list&pds_type=1&start=0&num=23&s_key1=&s_que=) "
   
#### Software problem
    Used the try catch grammer for landing that you have any errors in flight
#
#
___
#
#
## 2. 알고리즘
알고리즘 설명
   [순서도 사진 첨부]
#
#
___
#
#
## 3. 소스 코드 설명

 <img src="https://user-images.githubusercontent.com/57785792/87419185-05f4ea00-c60e-11ea-8a12-afb6386b9094.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87418485-b8c44880-c60c-11ea-9531-df2a25db001e.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87418488-b9f57580-c60c-11ea-8c97-bb9fb3afe7ec.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87418488-b9f57580-c60c-11ea-8c97-bb9fb3afe7ec.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87418494-ba8e0c00-c60c-11ea-9446-05676e2bf838.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87418496-bbbf3900-c60c-11ea-9cc4-01175ab64b2e.jpg" width="320" height="240"> 
   | **original** | **HSV** |
   |:--------:|:--------:|
   |**mask_green**|**morphology**|
   |**median**|**result**|
   
***
***
   ### 함수 정의  
   ---
   #### 카메라를 통한 이미지 처리
   ##### 컨투어 검출
   * 자식 계층이 없고 부모 계층이 있는 컨투어 중 면적이 가장 큰 컨투어 검출
   * 링의 컨투어 인덱스를 반환
   ```python
        def find_ring(cnt, hier):
            p=0 # 링의 컨투어 인덱스 저장하는 변수 선언
            s = cv2.contourArea(cnt[0])
            for i in range(len(hier[0])):  # len(hier[0]) : 컨투어 갯수
                area = cv2.contourArea(cnt[i])
                if hier[0, i, 2] == -1 and hier[0, i, 3] != -1:  # 자식없고 부모 있음
                    if area != 0 :
                        p = i
                    else:  # area==0
                        pass
                elif hier[0, i, 2] != -1 and hier[0, i, 3] != -1:  # 자식 있고 부모 있음
                    if area < s:
                        s = area
                        p = i
            return p
   ```
   [ 링 컨투어 사진 첨부 (Step 1 / Step 2) ]
   #### 검출된 컨투어를 통한 드론 제어
   ##### 링의 중심을 검출하여 드론 이동
   * The function of find the circle
   * Return value is center of circle
   ```python
        def focus(x, y): #링의 중심을 카메라의 중심으로 이동
            x_= x - 320
            y_= y - 240

            if x<280 or x>360 or y<200 or y>280 :
                x__= x_ * 0.0229
                y__= y_ * 0.0204
                px = round(x__, 3)
                py = round(y__, 3)
                print("locate")
                drone.sendControlPosition16(0, px, py, 1, 0, 0)
                for i in range(4, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
   ```
   ##### 사각형 표식의 중심을 검출하여 드론 이동
   * 함수 설명1
   * 함수 설명2
```python
        def focus2(cx, cy): #사각형 표식의 중점 카메라와 맞추기
            cx_= 320 - cx
            cy_= 240 - cy

            if cx<280 or cx>360 or cy<200 or cy>280 :
                cx__= cx_ * 0.0229
                cy__= cy_ * 0.0204
                px = round(cx__, 3)
                py = round(cy__, 3)
                print("locate")
                drone.sendControlPosition16(0, px, py, 1, 0, 0)
                for i in range(4, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
```
  
  ##### 검출된 링의 컨투어에 따른 드론 비행 조정
   * 함수 설명1
   * 함수 설명2
```python
        def shift_ring1(b_pix, b_pix_thr, R_pix): #링 앞까지 전진_링 안잘렸을 때
            global n
            if n==2:
                print("move")
                drone.sendControlPosition16(9, 0, 0, 3, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
                print("move")
                drone.sendControlPosition16(8, 0, 0, 3, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
                print("Landing")
                drone.sendLanding()
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
            else:
                if b_pix< b_pix_thr:
                    print("move")
                    drone.sendControlPosition16(3, 0, 0, 3, 0, 0) #20cm 씩 이동
                    for i in range(1, 0, -1):
                        print("{0}".format(i))
                        time.sleep(1)
                else:
                    if R_pix > 80:  # 1.8m 앞으로 이동 후, turn left
                        print("move")
                        drone.sendControlPosition16(10, 0, 0, 3, 0, 0)
                        for i in range(3, 0, -1):
                            print("{0}".format(i))
                            time.sleep(1)
                        print("move")
                        drone.sendControlPosition16(8, 0, 0, 3, 0, 0)
                        for i in range(3, 0, -1):
                            print("{0}".format(i))
                            time.sleep(1)
                        print("heading")
                        drone.sendControlPosition(0, 0, 0, 0, 90, 30)
                        for i in range(4, 0, -1):
                            print("{0}".format(i))
                            time.sleep(1)
                        n+=1
```
  ##### shift_ring2 설명
   * 함수 설명1
   * 함수 설명2
```python
        def shift_ring2(R_pix): #링 앞까지 전진_링 잘렸을 때
            global n
            if n==2:
                print("move")
                drone.sendControlPosition16(10, 0, 0, 3, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
                print("move")
                drone.sendControlPosition16(5, 0, 0, 3, 0, 0)
                for i in range(1, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
                print("Landing")
                drone.sendLanding()
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
            else:
                if R_pix>90 : # 1.5m 앞으로 이동
                    print("move")
                    drone.sendControlPosition16(10, 0, 0, 3, 0, 0)
                    for i in range(3, 0, -1):
                        print("{0}".format(i))
                        time.sleep(1)
                    print("move")
                    drone.sendControlPosition16(5, 0, 0, 3, 0, 0)
                    for i in range(1, 0, -1):
                        print("{0}".format(i))
                        time.sleep(1)
                    n+=1
```
---
  ##### 색상 및 픽셀의 임계값 선언
   * 알고리즘 설명1
   * 알고리즘 설명2
```python
        th_blue_h=104
        th_red_h=5
        b_pix_thr=130000

        print("Take Off")
        drone.sendTakeOff()
        for i in range(5, 0, -1):
            print("{0}".format(i))
            time.sleep(1)
        
        print("Hovering")
        drone.sendControlWhile(0, 0, 0, 0, 2000)
        for i in range(2, 0, -1):
            print("{0}".format(i))
            time.sleep(1)
```
<img src="https://user-images.githubusercontent.com/57785792/87421845-90d7e380-c612-11ea-82bb-f9ac96bb3489.png" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87421847-92091080-c612-11ea-83de-7477b3c74693.png" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87421849-92091080-c612-11ea-9955-6d8fe7c361ef.png" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87421851-92a1a700-c612-11ea-973b-3cd6551b83aa.png" width="320" height="240"> <img src="https://user-images.githubusercontent.com/57785792/87421852-92a1a700-c612-11ea-88c5-3e11347e3141.png" width="320" height="240"> 
  | **img_mask_blue** | **morphology** |
  |:--------:|:-------:|
  | **dilate** | **medianBlur** |
  |  **result** |  |
  ***
  ##### 사진 찍음
   * 알고리즘 설명1
   * 알고리즘 설명2
```python
for frame in camera.capture_continuous(rawCapture, format='bgr', use_video_port=True):
            image=frame.array
            image=cv2.flip(image, 0)
            image=cv2.flip(image, 1)
            image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

            #blue flag
            img_mask=cv2.inRange(image, (th_blue_h-10,20, 20), (th_blue_h+10, 255, 255))
            B=np.sum(img_mask==255, axis=None)
            #red square
            img_mask_red=cv2.inRange(image, (th_red_h-10, 20, 20), (th_red_h+10, 255, 255))
            R=np.sum(img_mask_red==255, axis=None)
```
  ### Inside of try
  * After take off, go forward for 0.7m & begin mode 2
  ```python 
try:
    drone.sendTakeOff()
    sleep(5)
    camera = PiCamera()
    camera.resolution = (640, 480)  # (2592,1944)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(640, 480))

    circle_color = 'red'
    mode1 = False
    mode2 = True
    mode3 = False

    ring_range = 40
    
    i = 0
    no_ring_cnt = 0
    drone.sendControlPosition16(7, 0, 0, 5, 0, 0)
    sleep(3)
    
    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)  
        img = cv2.flip(img, 1)  
        img_hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        cv2.imwrite("total_capture/{}.jpg".format(i), img)
        i = i + 1

        rawCapture.truncate(0)  
  ```
  * mode 1 : go forward for 1.3m & change to mode 2
   ```python 
       if mode1:  # 1.3m
            drone.sendControlPosition16(13, 0, 0, 5, 0, 0)
            sleep(5)
            mode1 = False
            mode2 = True
            
  ```
  
   * mode 2 : Control left right and degree adjustment (watch the camera straight forward) & change to mode 3 
   ```python 
        
        elif mode2:
            if 'fail' == detect_rect(img_hsv):
                continue
            else:
                pt_temp, left_length, right_length = detect_rect(img_hsv)
                if pt_temp[1] > 480 - 90+20:
                    drone.sendControlPosition16(0, 0, -7, 5, 0, 0)
                    sleep(3)
                elif pt_temp[1] < 90+20:
                    drone.sendControlPosition16(0, 0, 7, 5, 0, 0)
                    sleep(3)
                else:
                    if pt_temp[1] > 480 - 130+20:
                        drone.sendControlPosition16(0, 0, -3, 5, 0, 0)
                        sleep(1)
                    elif pt_temp[1] < 130+20:
                        drone.sendControlPosition16(0, 0, 3, 5, 0, 0)
                        sleep(1)
                    elif pt_temp[0] < 100:
                        drone.sendControlPosition16(0, 11, 0, 5, 0, 0)
                        sleep(5)
                    elif pt_temp[0] > 640 - 100:
                        drone.sendControlPosition16(0, -11, 0, 5, 0, 0)
                        sleep(5)
                    else:
                        if pt_temp[1] > 240 + ring_range + 30:
                            drone.sendControlPosition16(0, 0, -1, 5, 0, 0)
                            sleep(0.5)
                        elif pt_temp[1] < 240 - ring_range + 30:
                            drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
                            sleep(0.5)
                        elif pt_temp[0] > 320 + ring_range:
                            drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
                            sleep(0.5)
                        elif pt_temp[0] < 320 - ring_range:
                            drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
                            sleep(0.5)
                        else: #각도 미세조정
                            if left_length - right_length > 25:
                                drone.sendControlPosition16(0, 0, 0, 0, 10, 20)
                                sleep(3)
                            elif right_length - left_length > 25:
                                drone.sendControlPosition16(0, 0, 0, 0, -10, 20)
                                sleep(3)
                            else:
                                drone.sendControlPosition16(8, 0, 0, 5, 0, 0)
                                sleep(3)
                                mode2 = False
                                mode3 = True
  ``` 
  * mode 3 : go forward after find a color of the circle and find cirle   (Blue color is Landing, Red color is rotate for 90 degrees to counter clockwise) 
   ```python 
        elif mode3:
            circle_color = detect_color(img_hsv)
            circle_x, circle_y = detect_circle(img_hsv, circle_color)
            if circle_x == 0:
                continue
            else:   
                    drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
                    sleep(0.5)
                elif circle_x < 320 - 40:
                    drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
                    sleep(0.5)
                else:
                    sleep(1)
                    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)
                    sleep(6)
                    if circle_color == 'blue':
                        sleep(1)
                        drone.sendLanding()
                        drone.close()
                        break
                    elif circle_color == 'red':
                        drone.sendControlPosition16(0, 0, 0, 0, 90, 20)
                        sleep(6)
                        mode3 = False
                        mode1 = True
```
   
   * If there is errors just landing (prevention of collision)
   ```python 
except Exception as e:
    drone.sendLanding()
    drone.close()
   ```
   
  
  
## 4. Data sheet of humming bird 
[드론 데이터시트 사진 첨부]

* Go to [Details](http://www.roboworks.co.kr/web/home.php?go=page_view&gubun=1&mid=10)
## 5. Author
### Team leader: [Kang Hwan Kwon](https://github.com/Raagnar)    
### Team members: [Seong Ha Park](https://github.com/seonghigh), [Eun Sun Park](https://github.com/eunsun53)
## 6. License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/yeongin1230/Bleague_drronedrrone/blob/master/LICENSE) file for details
