2021 자율주행 드론 대회
======================
### B리그 NPE 팀(이한성, 김태경)   
**차례** 
- 대회진행전략
- 알고리즘 설명
- 소스코드 설명 


**대회진행 전략**  
-----------------
 본 대회는 영상처리를 활용하여 드론을 제어하는 대회로, 영상처리의 속도/정확성 , 드론제어 수준 등이 중요하다.     
NPE팀은 영상처리의 정확성에 초점을 맞추어 알고리즘을 구축하였다.   

진행해야할 경기장의 경우 사전에 공지되었기 때문에 공지된 규격에 맞추어 빠르게 드론을 이동시킬수 있도록 할 것이다.  

>영상처리의 경우 **RGB to HSV**로 활용하여 색인지를 진행한다.  
그 이유는 RGB는 R,G,B 세가지의 속성을 모두 고려하여 색을 표현하지만,    
HSV의 경우 **H(Hue)** 가 일정한 범위를 가지는 색 정보를 가지고있기에 RGB보다 쉽게 색을 분류 할 수 있다. 

**알고리즘 설명**
-----------------
1. 링의 중점찾기     
  	1. 파란색 사각형의 중점찾기  
  	2. 원의 중점 찾기
  	3. 화면상에 원이 제대로 보이지 않을 때
  	4. 드론 화면상의 중점과 비교   
  		1. 원의 중점좌표에 따른 드론제어 
  
2. 이동을 한 후 상황판단  
  	1. 표식이 안보일 경우 
		1. 표식이 보일때 까지 천천히 직진
		2. 표식이 일정크기보다 크게 보일 시 
  	2. 보라색을 판단  
     

- 정확한 드론제어를 위해 링의 중점을 확인 하는 과정 2번을 거친다.   
첫번째는 파란색 사각형의 중점을 찾고, 두번째로 원의 중점을 찾는다.


**소스코드 설명**
-----------------

*RGB to HSV (RED)*  
1. RGB이미지를 HSV로 변환한다. 
2. th_low/high를 임계값으로 설정하고   
 open cv의 inRange함수를 통해 Red만이 검출된 이미지를 얻는다. 
```python
def red_hsv(image):  
	image_hsv = cvtColor(image, COLOR_BGR2HSV)  
	th_low = (160, 100, 70)  
	th_high = (255, 255, 255)  
	img_th = inRange(image_hsv, th_low, th_high)  
	return img_th  

```
파란색 사각형의 중점 찾기 

```python

bi_blue = blue_hsv(image)
	value_th = np.where(bi_blue[:, :] == 255)   #검출된 파란색의 좌표들을 불러온다. 

	min_x1 = np.min(value_th[1])
	max_x1 = np.max(value_th[1])
	min_y1 = np.min(value_th[0])
	max_y1 = np.max(value_th[0])

	center_x1 = int((min_x1 + max_x1) / 2)
	center_y1 = int((min_y1 + max_y1) / 2)
```
사각형의 중점을 찾은 모습      
<img width="300" height="300" alt="33443" src="https://user-images.githubusercontent.com/54049385/125278881-37ea7a80-e34e-11eb-97d7-7fdd60633c5d.jpg">
<img width="300" height="300" alt="33443" src="https://user-images.githubusercontent.com/54049385/125278642-f1951b80-e34d-11eb-96d0-64c201d2cae5.PNG">


사각형의 중점을 찾았지만 더 정확히 계산하고자, 한번 더 연산을 진행한다. 
```python

center_min_x = 640
center_max_x = 0
center_min_y = 480
center_max_y = 0

#사각형의 중점에서 이동하면서 원의 경계에서 멈춘다.
for i in range(center_x1, max_x1):
if bi_blue[center_y1][i] == 255 and i > center_max_x:
    center_max_x = i
    break              
#원의 경계부분의 연산을 통해 더 정확한 중점을 찾는다.  
#상하좌우 동일 하게 수행 
center_x2 = int((center_min_x + center_max_x) / 2)
center_y2 = int((center_min_y + center_max_y) / 2)
```
원의 중점에서 나아가 경계에서 선이 멈춘것을 확인 할 수 있다.    
<img width="300" height="300" alt="123123" src="https://user-images.githubusercontent.com/54049385/125280065-9bc17300-e34f-11eb-8a85-52ebd1c74d77.PNG">



------------------------------------------------------
##### 아래는 드론제어 중 이상적인 범위에서 벗어날 경우 대비법이다.  
- 화면상에 링이 전부 보이지 않아 실제 원의 중점과는 다른 곳이 중점으로 인식되었다.  
   
<img width="300" height = "300" alt="img6" src="https://user-images.githubusercontent.com/54049385/125398600-7afa2b80-e3ea-11eb-91f5-13743130e6e8.PNG"><img width="300" height = "300" alt="3423432" src="https://user-images.githubusercontent.com/54049385/125398658-906f5580-e3ea-11eb-8f01-9cae5ba75585.PNG">
 
 - 이때, 중점이라 인식한 지점에서부터 상하좌우로 직선을 그었을때의 직선길이를 비교한다.   
 다음 사진은 rad_up이 rad_down보다 긴 상황이므로 드론의 움직임을 위로 제어한다.  
<img width="430" alt="234324324" src="https://user-images.githubusercontent.com/54049385/125404839-1347de80-e3f2-11eb-9435-4c61f60796b8.png">  



------------------------------------------------------
##### 다음으로 표식이 보이지 않을 경우 대비법이다.
- 이동 후 표식이 보이지 않을 경우 표식이 보일때까지 전진한다.
```python
if max_x1_red - min_x1_red < 25:
	sleep(2)
	drone.sendControlPosition16(1, 0, 0, 5, 0, 0)
	red_find = 1
```
- 표식이 일정크기 이상으로 보일 경우 다음 행동을 수행한다.
```python
else:
	sleep(2)
	drone.sendControlPosition16(0, 0, 0, 0, 90, 20)
	sleep(4)
	drone.sendControlPosition16(10, 0, 0, 6, 0, 0)
	sleep(4)
	drone.sendControlPosition16(0, 0, 2, 5, 0, 0)
	sleep(2)
```



------------------------------------------------------
##### 보라색 표식 찾기
- 마지막 링에서 보라색 표식을 확인하여 착륙하여야 하므로 보라색도 빨간색과 같이 HSV를 이용하여 판단한다.
```python
def blue_hsv(image):
    image_hsv = cvtColor(image, COLOR_BGR2HSV)
    th_low = (90, 80, 70)
    th_high = (120, 255, 255)
    img_th = inRange(image_hsv, th_low, th_high)
    return img_th
```
------------------------------------------------------

>위와 같은 영상처리를 통해 정확도 높은 영상처리 및 드론제어를 구현하였고,  
목표지점에 성공적으로 도달하는것을 확인하였다. 
