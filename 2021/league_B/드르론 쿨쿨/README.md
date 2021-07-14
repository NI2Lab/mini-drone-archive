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
>**4. 코드론 DIY 데이터시트**   
>**5. 팀원**   
>**6. 라이센스**   

</br>

***

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
   <img src="https://user-images.githubusercontent.com/80773720/125619108-a85eeacd-5cf7-4958-b2ce-bddc18303eca.png" width="770" height="320">
   
### 1-c. 사용 프로그램

   #### <img src="https://user-images.githubusercontent.com/80773720/125631159-07308196-8eeb-4243-a0a6-310778457c86.jpg" width="20" height="20"> Visual Studio Code
   * 파이썬 코드 편집
   * [Guide](https://dora-guide.com/visual-studio-code-%ec%82%ac%ec%9a%a9%eb%b2%95/) 
   
   #### <img src="https://user-images.githubusercontent.com/57785792/87244515-e5475b80-c478-11ea-9177-7aef730dd40a.jpg" width="20" height="20"> PyCharm Community Edition 2020
   * 파이썬 코드 편집
   * [Guide](https://dora-guide.com/pycharm-install/)
   
   #### <img src="https://user-images.githubusercontent.com/80773720/125631831-fad253a8-22ed-416a-84e5-f5b0d63b41bc.jpg" width="20" height="20"> PuTTY
   * 라즈베리 파이와 연동
   * [Guide](https://dora-guide.com/putty-%eb%8b%a4%ec%9a%b4%eb%a1%9c%eb%93%9c/)

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
   * 드론의 위치 제어를 위한 throttle, pitch, roll 및 yaw 제어
<p align="center"><img src="https://user-images.githubusercontent.com/80773720/125615967-07c93d2a-8bd2-4bce-b583-1f65e8ede5ca.png" width="443" height="333"></p>

### 1-e. 드론 위치 및 방향 제어 코드
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
   * [Reference code](http://dev.byrobot.co.kr/documents/kr/products/e_drone/library/python/e_drone/)

### 1-f. 맵
<img src="https://user-images.githubusercontent.com/80773720/125621958-9d7fec98-0e9f-4aba-a2b6-8fabb089fb0e.png" width="400" height="350"><img src="https://user-images.githubusercontent.com/80773720/125623648-cfdc4571-6647-4003-8e82-11dc6d6ccdc9.jpg" width="550" height="350">

 
### 1-g. 오류 처리
#### 하드웨어 오류
    컨트롤러를 사용하여 센서를 리셋
    안정적인 호버링을 위한 트림 설정
* Go to [manual](http://www.roboworks.co.kr/web/home.php?mid=10&go=pds.list&pds_type=1&start=0&num=23&s_key1=&s_que=)
   
#### 소프트웨어 오류
    try-exception 구문을 사용하여 소프트웨어 오류 발생 시 드론이 Landing하도록 설정
    
   ```python
        except Exception as e:
          print(e)
          drone.sendLanding()

   ```
</br>

***

</br>

## 2. 알고리즘
알고리즘 순서도 설명

<img src="https://user-images.githubusercontent.com/80773720/125624947-423a7171-8cc0-4ad0-95e4-c936da923dd5.png" width="450" height="500">

</br>

***

</br>

## 3. 소스 코드 설명

</br>

   ## 함수 정의  
   
   </br>
   
   #### 카메라를 통한 이미지 처리
   ##### 컨투어 검출
   * 자식 계층이 없고 부모 계층이 있는 컨투어 중 면적이 가장 큰 컨투어 검출
   * 링의 컨투어 인덱스를 반환
   >```python
   >     def find_ring(cnt, hier):
   >         p=0 # 링의 컨투어 인덱스 저장하는 변수 선언
   >         s = cv2.contourArea(cnt[0])
   >         for i in range(len(hier[0])):  # len(hier[0]) : 컨투어 개수
   >             area = cv2.contourArea(cnt[i])
   >             if hier[0, i, 2] == -1 and hier[0, i, 3] != -1:  # 자식없고 부모 있음
   >                 if area != 0 :
   >                     p = i
   >                 else:  # area==0
   >                     pass
   >             elif hier[0, i, 2] != -1 and hier[0, i, 3] != -1:  # 자식 있고 부모 있음
   >                 if area < s:
   >                     s = area
   >                     p = i
   >         return p
   >```
   <img src="https://user-images.githubusercontent.com/80773720/125632649-663a7a83-8fd2-4837-a9e3-5f5b1d0c6d96.jpg" width="320" height="240"><img src="https://user-images.githubusercontent.com/80773720/125632827-92284f59-19ff-4dd6-938f-8416f5ffc886.jpg" width="320" height="240">
   | **1단계 링 컨투어** | **1단계 표식 컨투어** |
   |:--------:|:--------:|

</br>

   #### 검출된 컨투어를 통한 드론 제어
   ##### 1. 링의 중심을 검출하여 드론 이동
   * 링의 중심을 컨투어 처리
   * 링의 중심으로 카메라 중심 이동
   >```python
   >     def focus(x, y): #링의 중심을 카메라의 중심으로 이동
   >         x_= x - 320
   >         y_= y - 240>
   >
   >         if x<280 or x>360 or y<200 or y>280 :
   >             x__= x_ * 0.0229
   >             y__= y_ * 0.0204
   >             px = round(x__, 3)
   >             py = round(y__, 3)
   >             print("locate")
   >             drone.sendControlPosition16(0, px, py, 1, 0, 0)
   >             for i in range(4, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >```

   ##### 2. 사각형 표식의 중심을 검출하여 드론 이동
   * 사각형 표식(4cm x 4cm)을 컨투어 처리
   * 표식의 중심으로 카메라 중심 이동
   >```python
   >     def focus2(cx, cy): #사각형 표식의 중점 카메라와 맞추기
   >         cx_= 320 - cx
   >         cy_= 240 - cy
   >
   >         if cx<250 or cx>390 or cy<170 or cy>310 : # 140*140
   >             cx__= cx_ * 0.0229
   >             cy__= cy_ * 0.0204
   >             px = round(cx__, 3)
   >             py = round(cy__, 3)
   >             print("locate")
   >             drone.sendControlPosition16(0, px, py, 1, 0, 0)
   >             for i in range(4, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >         else :
   >             pass
   >```
  
  <img src="https://user-images.githubusercontent.com/80773720/125632827-92284f59-19ff-4dd6-938f-8416f5ffc886.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/80773720/125632943-d3683c42-19ba-4e38-ac5b-e0b39502cdab.jpg" width="320" height="240"> 
   |**1단계 표식 컨투어**|**2단계 표식 컨투어**|
   |:--------:|:--------:|
   
  ##### 3. 검출된 링의 컨투어에 따른 드론 비행 조정
   * radius < 240인 경우 ring 앞까지 전진 후 n에 1을 더함
   >```python
   >     def shift_ring1(b_pix, b_pix_thr, R_pix): #링 앞까지 전진_링 안잘렸을 때
   >         global n
   >         if n==2:
   >             print("move")
   >             drone.sendControlPosition16(9, 0, 0, 3, 0, 0)
   >             for i in range(3, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >             print("move")
   >             drone.sendControlPosition16(9, 0, 0, 3, 0, 0)
   >             for i in range(3, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >             print("Landing")
   >             drone.sendLanding()
   >             for i in range(5, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >         else:
   >             if b_pix < b_pix_thr:
   >                 print("move")
   >                 drone.sendControlPosition16(3, 0, 0, 3, 0, 0) #20cm 씩 이동
   >                 for i in range(1, 0, -1):
   >                     print("{0}".format(i))
   >                     time.sleep(1)
   >             else:
   >                 if R_pix > 80:  # 1.8m 앞으로 이동 후, turn left
   >                     print("move")
   >                     drone.sendControlPosition16(10, 0, 0, 3, 0, 0)
   >                     for i in range(3, 0, -1):
   >                         print("{0}".format(i))
   >                         time.sleep(1)
   >                     print("move")
   >                     drone.sendControlPosition16(8, 0, 0, 3, 0, 0)
   >                     for i in range(3, 0, -1):
   >                         print("{0}".format(i))
   >                         time.sleep(1)
   >                     print("heading")
   >                     drone.sendControlPosition(0, 0, 0, 0, 90, 30)
   >                     for i in range(4, 0, -1):
   >                         print("{0}".format(i))
   >                         time.sleep(1)
   >                     n+=1
   >```
   
  ##### 4. shift_ring2 설명
   * ring이 잘려서 검출되므로 ring과 가깝기 때문에 표식 인식 후 전진
   >```python
   >     def shift_ring2(R_pix): # 링통과 + (좌회전 or 착륙)
   >         global n
   >         if n==2:
   >             print("move")
   >             drone.sendControlPosition16(10, 0, 0, 3, 0, 0)
   >             for i in range(3, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >             drone.sendControlPosition16(5, 0, 0, 3, 0, 0)
   >             for i in range(1, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >             print("Landing")
   >             drone.sendLanding()
   >             for i in range(5, 0, -1):
   >                 print("{0}".format(i))
   >                 time.sleep(1)
   >         else:
   >             if R_pix>90 : # 1.5m 앞으로 이동 + 좌회전
   >                 print("move")
   >                 drone.sendControlPosition16(10, 0, 0, 3, 0, 0)
   >                 for i in range(3, 0, -1):
   >                     print("{0}".format(i))
   >                     time.sleep(1)
   >                 drone.sendControlPosition16(5, 0, 0, 3, 0, 0)
   >                 for i in range(1, 0, -1):
   >                     print("{0}".format(i))
   >                     time.sleep(1)
   >                 print("heading")
   >                 drone.sendControlPosition(0, 0, 0, 0, 90, 30)
   >                 for i in range(4, 0, -1):
   >                      print("{0}".format(i))
   >                      time.sleep(1)
   >
   >                 n+=1
   >```

</br>

  ## Running Code
  
  </br>
  
  #### 이미지 이진화
   * 파란색 크로마키 천 임계값의 최소값과 최대값을 HSV 차원에서 inRange를 이용하여 이진화
   * 빨간색 사각 표식 임계값의 최소값과 최대값을 HSV 차원에서 inRange를 이용하여 이진화
>```python
>        # blue flag
>        img_mask = cv2.inRange(image, (th_blue_h - 10, 20, 20), (th_blue_h + 10, 255, 255))
>        B = np.sum(img_mask == 255, axis=None)
>        # red square
>        img_mask_red = cv2.inRange(image, (th_red_h - 10, 20, 20), (th_red_h + 10, 255, 255))
>        R = np.sum(img_mask_red == 255, axis=None)
>```

<img src="https://user-images.githubusercontent.com/80773720/125632538-d1d99330-59be-4a4a-9bc7-545c1d9bc482.jpg" width="320" height="240"> <img src="https://user-images.githubusercontent.com/80773720/125632770-202b4522-0bb6-4ac6-aba9-0056031c54b2.jpg" width="320" height="240">
   |**1단계 링 이진화**|**1단계 표식 이진화**|
   |:--------:|:--------:|
   
  #### 외곽 정리
  * erode는 노이즈로 인한 불규칙한 외곽선을 침식
  * dilate는 erode로 인한 데이터 손실을 복구
 > ```python 
 ># erosion과 dilate를 이용한 외곽 정리
 >       k = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
 >       img_mask2 = cv2.erode(img_mask, k)
 >       img_mask2 = cv2.dilate(img_mask2, k)
 >
 >       img_mask2 = cv2.dilate(img_mask2, k)
 >       img_mask2 = cv2.erode(img_mask2, k)
 > ```
 
  #### 컨투어
  * 이미지 컨투어 처리
 >  ```python 
 >       # contour
 >       _, contours, hier = cv2.findContours(img_mask2, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
 >       _, contours_red, _ = cv2.findContours(img_mask_red, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)          
 > ```
  
  #### main run
  * 파란색 깃발이 보이면 find_ring 함수로 ring의 contour 인덱스 반환
  * idx < 240이면 ring이 카메라에 검출됨
  * radiux > 240이면 focus함수로 moment를 이용해 무게중심 반환
  >  ```python 
  >      # main_run
  >      if B>20:
  >          idx = find_ring(contours, hier)  # 링의 컨투어 찾아서 인덱스 리턴
  >          (x, y), radius = cv2.minEnclosingCircle(contours[idx])  # 링의 중심, 반지름 리턴
  >          M = cv2.moments(contours[idx])
  >          cx = int(M['m10'] / M['m00'])
  >          cy = int(M['m01'] / M['m00'])
  >          if radius < 240:  # 링이 안잘렸을때
  >              focus(x, y)  # 링 중점 위치 조절
  >              print("move") #20cm 이동
  >              drone.sendControlPosition16(3, 0, 0, 3, 0, 0)
  >              for i in range(1, 0, -1):
  >                  print("{0}".format(i))
  >                  time.sleep(1)
  >#                shift_ring1(B, b_pix_thr, R)
  >          else:  # 링이 잘렸을 때
  >              focus(cx, cy)  # 모멘트 무게중심으로 초점 잡기
  >              shift_ring2(R)
  > ```
  
</br>

***

</br>
  
## 4. 코드론 DIY 데이터시트
<img src="https://user-images.githubusercontent.com/80773720/125628430-0118ba0f-d5bf-4ce9-b3ea-da43bdcea2f2.png" width="450" height="450">

* Go to [Details](http://www.roboworks.co.kr/web/home.php?go=page_view&gubun=1&mid=10)

</br>

***

</br>

## 5. 팀원
### Team leader: [Kang Hwan Kwon](https://github.com/Raagnar)    
### Team members: [Seong Ha Park](https://github.com/seonghigh), [Eun Sun Park](https://github.com/eunsun53)

</br>

***

</br>

## 6. License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/yeongin1230/Bleague_drronedrrone/blob/master/LICENSE) file for details
