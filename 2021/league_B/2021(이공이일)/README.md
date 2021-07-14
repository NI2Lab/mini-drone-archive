# '2021(이공이일)' Drone B리그 README


## 참가자
부산대학교 의생명융합공학부 2학년 곽예진

부산대학교 의생명융합공학부 2학년 강준희

부산대학교 의생명융합공학부 1학년 안수범


## 대회 진행 전략

B리그 참가팀들의 알고리즘은 대부분 장애물의 중심을 찾고 중앙 쪽으로 드론을 위치 시킨 다음 장애물을 통과하는 것이었다. 

비슷한 방법끼리의 경쟁에서 이길 수 있는 방법은 시간을 최대한 단축하는 것이기 때문에 최적의 방법을 찾는 것이 2021(이공이일) 팀의 전략이다.


## 알고리즘 설명
*main idea -> 중심을 찾고 중심 쪽으로 드론을 위치 시간 다음 장애물을 통과한다.*

- hovering 후 드론 내장된 카메라로 하나의 이미지를 찍는다. 이때 중심을 (120, 150*) 으로 둔다. 

*드론을 장애물 중앙에 놓고 사진을 찍었을 때 중점의 Y좌표가 147~152정도로 나왔기 때문이다.*

- 그리고 난 후 find_centroid로 찾은 중점을 중심 방향으로 이동할 수 있게 드론을 움직여준다.

- 드론의 위치와 중심사이 거리의 오차를 check_x, check_y 함수를 통해 찾아서 드론이 중심에 있는지 없는지를 판단한다.

- 중심에 도달한 이후에는 아래 조건을 만족할 때까지 한다. -> pass_obstacle

- find_redpoint와 find_purplepoint로 빨간점, 보라점을 찾고 찾은 이후에는 pass_obstacle로 보라점을 찾았을 시에는 착지, 빨간점을 찾았을 시에는 90도 좌회전을 한다. -> pass_obstacle


## 소스 코드 설명
### requirement
```py
e-drone == 21.1.6
numpy == 1.16.2
Pillow == 5.4.1
opencv == 3.2.0
```


### drone.py
드론에 대한 함수를 정의한 파이썬 


**1. initialize**

드론 객체를 생성하고 드론 조작을 시작하기 위한 함수
```py
drone = Drone()
drone.open()
return drone
```

**2. capture_img**

라즈베리파이 카메라 모듈을 카메라로 보이는 장면을 캡쳐해준다. resolution은 (240,240), frame rate는 32이고 찍으면 뒤집혀 찍히기 때문에 rotation을 180으로 설정해준다.
```py
camera = PiCamera()
img = 'img.jpg'
camera.resolution = (240, 240)  # 160, 128
camera.framerate = 32
camera.rotation = 180
camera.capture(img)
camera.close()
return img  # capture img path
```

**3. move_to_center**

- h는 계층의 갯수이고, 초기 설정은 -1로 한다.

h가 2보다 작을 경우에,

<이미지 처리 과정>

- 우선 이미지를 blur처리를 해준다. -> cv2.GaussianBlur

- 이미지의 BGR로 HSV값으로 바꿔준다. -> cv2.COLOR_BGR2HSV

- lower_blue, upper_blue라는 array를 만들어 주고 카메라로 캡쳐한 화면에서 이 범위에 있는 부분을 mask처리한다. -> cv2.inRange

<원 중심  과정>

- 계층 파악을 위해 contour를 이용해서 안의 위치한 원의 무게중심을 파악한다.
```py
cnt = contours[0]
M = cv2.moments(cnt)
```

- zerodivision 에러를 막기 위해 분모에 아주 작은 실수를 더해준다.
```py
cx = int(M['m10'] / (M['m00'] + 0.000000000000001))
cy = int(M['m01'] / (M['m00'] + 0.000000000000001))
```

- 계층 갯수를 print 해준다
```py
h = len(hierarchy[0])
print(h)
```
- print 된 h가 2와 같거나 클 경우 break 한다.

<check_y가 False일때> 

- 중심이 143보다 작을 때 y축으로 0.1 상승한다.

- 중심이 157보다 클 때 y축으로 0.1 하강한다.

- 중심이 143보다 크고 157보다 작을 때 print('y ok y : ', cy)를 해준다.

<check_x가 False일때>

- 중심이 113보다 작을 때 x축으로 0.1 증가한다.

- 중심이 127보다 클 때 x축으로 0.1 감소한다.

- 중심이 113보다 크고 127보다 작을 때 print('x ok x : ', cx)를 해준다.



**4. find_centroid**

- capture_img로 캡쳐된 장면을 이진화한 후 컨투어를 찾는다. (중심에 가까울수록 계층이 작은 RETR_LIST를 옵션으로 넣어 원이 0번 계층으로 잡히게 만듦)
```py
img = cv2.imread(capture_img())
img = cv2.GaussianBlur(img, (9, 9), 3)

hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
mask = cv2.inRange(hsv, lower_blue, upper_blue)

_, contours, hierarchy = cv2.findContours(mask, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
```

- 만약 계층개수가 1개거나 0개이면 드론을 뒤로 움직여서 다시 find_centroid를 사용한다. 장애물이미지가 잘리지 않았을 때, 즉 컨투어가 2개일 때 중심의 좌표를 반환한다.
```py
print("go back")
# cv2.imshow('mask', mask)
# cv2.waitKey(0)
drone.sendControlPosition(-0.3, 0, 0, 1, 0, 0)
```

-  두번째 장애물부터는 장애물의 일부가 보이면 보인 부분의 무게중심을 구해 이동을 반복한다. (장애물이 상하좌우로 움직이기에 뒤로만 가서는 중점을 찾기에 한계가 존재) 
```py
drone.sendControlPosition(-0.3, 0, 0, 1, 0, 0)
move_to_center(drone)
```    
    
-  장애물이 다 보이는 위치로 이동을 하면 앞에서와 똑같이 중심을 리턴해준다. 
```py
cnt = contours[0]
img = cv2.drawContours(img, contours, 0, (255, 255, 0), 3)
M = cv2.moments(cnt)
cx = int(M['m10'] / (M['m00'] + 0.000000000000001))
cy = int(M['m01'] / (M['m00'] + 0.000000000000001))
print(cx, cy)
# cv2.imshow('mask', mask)
# cv2.waitKey(0)
return cx, cy
``` 


**5.match_center**

find_centroid에서 반환받은 중심점으로의 이동명령을 주는 함수이다.

<check_y가 False일때> 

- 중심(cy)이 143보다 작을 때 y축으로 0.1 상승한다.

- 중심이 157보다 클 때 y축으로 0.1 하강한다.

- 중심이 143보다 크고 157보다 작을 때 print('y ok y : ', cy)를 해준다.

<check_x가 False일때>

- 중심(cx)이 113보다 작을 때 x축으로 0.1 증가한다.

- 중심이 127보다 클 때 x축으로 0.1 감소한다.

- 중심이 113보다 크고 127보다 작을 때 print('x ok x : ', cx)를 해준다.
```py
cy = find_centroid(drone)[1]
...        
drone.sendControlWhile(0, 0, 0, 0, 1000)
...
cx = find_centroid(drone)[0]
...
drone.sendControlWhile(0, 0, 0, 0, 1000)
```

- pass_obstacle를 실행시준다.


**6.check_x**

- check_x는 match_center에서 이동명령을 줄 때 드론이 중심에 있는지 없는지를 판별해주는 함수이다.

- find_centroid 와 동일한 과정을 통해 중심값을 찾고 오차를 계산하여 True, False를 반환한다.
```py
if abs(cx - 120) <= 10:
    print('x true')
    return True
else:
    return False
```        


**7.check_y**

- check_x와 동일하게 match_center에서 이동명령을 줄 때 드론이 중심에 있는지 없는지를 판별해주는 함수이다.

- find_centroid 와 동일한 과정을 통해 중심값을 찾고 오차를 계산하여 True, False를 반환한다.
```py
if abs(cy - 150) <= 10:
    print('y true')
    return True
else:
    return False
```


**8. find_redpoint**

<이미지 처리 과정>

- 우선 이미지를 blur처리를 해준다. ->cv2.GaussianBlur

- lower_red, upper_red라는 array를 만들어 주고 카메라로 캡쳐한 화면에서 이 범위에 있는 부분을 mask처리한다. -> cv2.inRange 

- mask 처리된 것에서 np.nonzero의 갯수를 알아내서 return 해준다.

```py
point_red = np.nonzero(mask)
num_point_red = np.size(point_red)
return num_point_red
```


**9. find_purplepoint**

<이미지 처리 과정>

- 우선 이미지를 blur처리를 해준다. ->cv2.GaussianBlur

- lower_purple, upper_purple라는 array를 만들어 주고 카메라로 캡쳐한 화면에서 이 범위에 있는 부분을 mask처리한다. -> cv2.inRange

- mask 처리된 것에서 np.nonzero의 갯수를 알아내서 return 해준다.

```py
point_purple = np.nonzero(mask)
num_point_purple = np.size(point_purple)
return num_point_purple
```


**10. pass_obstacle**

- find_purplepoint의 값이 1000보다 작을시에는 드론을 착륙시키고 드론 객체를 종료시킨다.

- find_redpoint의 값이 1000보다 작을 시에는 드론을 x축으로 0.5 이동시킨 다음 pass_obstacle를 다시 실행시켜본다.

- find_redpoint의 값이 1000보다 클 시에는 드론을 90도로 좌회전을 시켜준다.


### main.py
드론이 이동 할 수 있도록 drone.py에 만든 함수를 나열한 파일

- drone이라는 객체를 생성한 다음 drone을 이륙하도록 하게 함 -> drone.sendTakeoff()

- 차례로 check_distance(drone), move_to_center(drone, x, y)이라는 함수를 실행시켜준다.

- 3차례 반복 뒤 드론이 착륙을 하게 하도록 함. -> drone.sendLanding()
