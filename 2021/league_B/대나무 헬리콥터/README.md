Mini Drone, B 리그, 대나무헬리콥터
=================================
## 1. 대회 진행 전략
### 1-1 대회 규정
대회 규정은 다음 두 이미지로 요약할 수 있다.


![22](https://user-images.githubusercontent.com/44136881/125604647-c0044a79-f8e4-417b-be68-91b637c9bd97.PNG)
<그림 1>

드론은 그림 1과 같은 링을 통과하여야 하며, 링 뒤의 표식에 따른 동작을 수행해야 한다. 
빨간색은 90도 좌회전, 보라색은 착륙을 의미한다.

![11](https://user-images.githubusercontent.com/44136881/125604492-692e0a5d-f271-4f82-9b80-5d7f308c5f7e.PNG)
<그림 2>

통과해야할 링은 총 세 개이며, 링의 위치는 첫 번쨰 링은 앞뒤, 두 번째 세 번째링은 앞뒤, 상하, 좌우로 변동가능하다.
앞뒤는 1~3m 범위 내, 상하는 0~150cm 범위 내, 좌우는 +- 2m 범위 내 변돈된다.

### 1-2 대회 규정에 따른 전략

수행해야할 과제는 그림 1과 같은 파란색 링을 통과하고, 빨간색 혹은 보라색 점을 찾아, 그에 해당하는 다음 행동을 수행하는 것이다.
이러한 과제를 수행하기 위한 전략을 다음과 같은 단계로 나눌 수 있다.

* 1단계, 파란색 링 감지

드론의 카메라에서 촬영하는 영상을 획득한다.

![image](https://user-images.githubusercontent.com/44136881/125608495-6f12fcaa-3ff0-4f79-aa36-5d58fd8b4b50.PNG)
<그림 3>

영상에서 색상을 탐지하는데 있어 RGB 영상보다 H 데이터가 유리하므로 영상을 HSV로 변환한다. 

![HSV](https://user-images.githubusercontent.com/44136881/125608173-9bc2a05f-7e00-42dc-a5ca-318107edd8fb.PNG)
<그림 4>

변환된 3장의 영상 중 H 데이터에 대해, 일정 범위로 threshold를 지정해 파란색 링에 해당하는 값만을 얻는다.

![H](https://user-images.githubusercontent.com/44136881/125608131-c8fafc3c-a201-48ae-aa7e-1cadbd82e1e3.PNG)
<그림 5>

이상적으로는 H값만으로 색상을 구분할 수 있지만, 실제로는 그림4와 같이 H값 또한 채도와 명도에 영향을 받기 때문에, 더 정확한 파란색의 구분을 위해
S, V 또한 임계 범위를 설정하여 결과를 얻는다.

![S](https://user-images.githubusercontent.com/44136881/125608143-239a6464-4ec0-4b7e-a625-1607e61e6667.PNG)
<그림 6>

![V](https://user-images.githubusercontent.com/44136881/125607909-9a8e1861-cb29-4c74-8372-8c646b67007b.PNG)
<그림 7>

H,S,V 결과를 결합하고, 영상의 품질을 위해 팽창(그림 8)하고, 침식(그림 9)한다. 팽창은 작은 빈 공간을 없애기 위해, 침식은 작은 점을 없애기 위해 사용되며, 
파란색 링을 검출하는 상황에서는 팽창 후 침식을 해야 더 좋은 영상을 얻을 수 있다.

![dil](https://user-images.githubusercontent.com/44136881/125607914-fb95b783-fac8-453b-8678-b58aecf7a885.PNG)
<그림 8>

![erode](https://user-images.githubusercontent.com/44136881/125607918-13474441-03f7-4f61-b07f-fd17446da69a.PNG)
<그림 9>

* 2단계, 링의 중심 좌표 찾기

그림 9 처럼, 파랑색 링을 검출했다면, 드론이 링의 중심을 안전히 통과할 수 있도록, 링의 중심을 찾는 과정이 필요하다.
그 과정은 다음과 같다.

그림 9의 영상에서 값이 있는 최하점, 최고점, 최좌점, 최우점을 찾고 그 4점으로 구할 수 있는 중앙 좌표 값을 구한다.
구한 중앙 좌표에서 y 위 아래 방향, x 왼쪽 오른쪽 방향, 총 4방향으로 탐지하여 처음으로 밝은 값을 갖는 좌표를 4곳 구한다.
구한 좌표는 각각 새로운 최하점, 최고점, 최좌점, 최우점이 되며, 이 4점으로 링의 중심 좌표를 구한다. 
찾은 중심좌표를 통해 얻은 링의 영상은 그림 10과 같다.

![cut](https://user-images.githubusercontent.com/44136881/125607923-90264f4f-9208-464e-baf2-afc40dbc0b1a.PNG)
<그림 10>

* 3단계 드론 제어

찾은 원의 중심좌표와 영상의 중심좌표를 비교해, 영상의 중심 좌표와 링의 중심좌표가 일치할 수 있도록 드론을 제어한다.

* 4단계, 링을 찾지 못했을 때 

1단계와 2단계는 드론이 이륙하고, 파란색 링을 잘 감지한 경우이다.
그렇지 않은 경우의 대비도 필요하며, 그 경우를 두 가지르 나눌 수 있다.

> 경우 1, 링 내부 원의 일부가 안 보이는 경우

이 경우는 빈공간의 중심좌표를 산출하는 1, 2단계를 수행하고 3단계 드론제어를 수행하면 드론이 원이 잘 보이는 위치로 이동하게 된다.

> 경우 2, 원이 안보이며, 파란색만 보이는 경우

이 경우는 링의 끄트머리만 보여서, 원이 안보여 드론이 이동을 해야 원의 일부가 보이기 시작하는 경우이다.
드론이 어느 방향으로 움직일지를 결정하기 위해, 영상을 9분할한다. 원래 영상에서 네 모서리에 해당하는 4개의 데이터의 값을 구하여
어느 모서리에 파란색이 보이는지 파악한다. 파악한 모서리의 방향으로 드론을 이동시킨다.

> 경우 3, 파란색이 없는 경우

이 경우는 링의 어느부분도 감지하지 못한 경우이다. 드론은 90도로 구성된 각 링의 배치를 고려해 자율주행해야 하기 때문에, 
회전을 사용하지 않는다. 드론은 평면과 1m 간격에 위치할 때, 가로 1.2m 정도를 볼 수 있고, 대회 규정에 링은 좌우 +-2m를 움직이며,
링은 가로 약1.5m 이므로 +- 1m 좌우 수평이동으로 파란색이 감지되는 위치로 이동한다.

![drone left2right](https://user-images.githubusercontent.com/44136881/125626731-3ec265d7-33cf-47eb-880b-4adc4f251750.PNG)

* 5단계, 링을 통과하고 빨간색 혹은 보라색 점을 탐지

마지막 단계는 링을 통과한 후, 빨간색 혹은 보라색을 탐지했을 경우이다. 빨간색은 90도 좌회전을 의미하고, 보라색은 착륙을 의미한다.
HSV로 변환하고, 임계값 범위로 특정 색을 검출한 후, 영상 데이터의 합계를 구하면 0 혹은 어떤 양의 수를 얻을 수 있는데,
어떤 수라도 0이 아닌 수를 얻으면 특정 색을 검출했음을 의미한다.

## 2. 알고리즘 설명
### 2-1 Flowchart

알고리즘의 흐름은 아래 그림 11과 같다. 앞서 설명한 전략과 일치한다.

![drone_flowchart](https://user-images.githubusercontent.com/44136881/125631916-1b438455-bcfc-4922-8799-d122ccbccc65.PNG)
<그림 11>

이륙 후, 파란색의 여부, 온전한 원을 찾았는지 여부, 마지막 검출한 색이 빨간색인지 여부를 기준으로 반복이 수행된다.
유일하게 흐름도에 생략된 것은, 검출한 색 행동을 한 후 약 1m의 직진을 수행한다는 것이다. 그림 2를 살펴보면, 링을 통과한 후
1m 뒤에 빨간색 or 보라색 표식이 있으며, 90도 각도로 다음 링이 위치하는데, 표식을 검출하자마자 링을 찾는 과정을 수행하면 
이미 통과한 링에 부딪히는 경우가 발생할 수 있기 때문에, 약간의 직진을 수행한 후, 다음 루틴이 진행되어야 한다. 

## 3. 소스 코드 설명
### 3-1 영상처리, HSV 변환 및 임계 범위 적용

* HSV 변환

      img_HSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
      img_H = img_HSV[:, :, 0]
      img_S = img_HSV[:, :, 1]
      img_V = img_HSV[:, :, 2]
    
cvtColor 함수에 인자로 cv2.COLOR_BGR2HSV를 주어 HSV로 변환한다. BGR인 것은 opencv 모듈이 데이터를 BGR 순서로 관리하기 때문이다. 

* 임계 범위 적용

      _, bi_h1 = cv2.threshold(img_H, 100 - 6, 179, cv2.THRESH_BINARY)
      _, bi_h2 = cv2.threshold(img_H, 100 + 6, 179, cv2.THRESH_BINARY_INV)
      bi_h = cv2.bitwise_and(bi_h1, bi_h2)

      _, bi_s1 = cv2.threshold(img_S, 217 - 40, 255, cv2.THRESH_BINARY)
      _, bi_s2 = cv2.threshold(img_S, 217 + 40, 255, cv2.THRESH_BINARY_INV)
      bi_s = cv2.bitwise_and(bi_s1, bi_s2)

      _, bi_v1 = cv2.threshold(img_V, 180 - 76, 255, cv2.THRESH_BINARY)
      _, bi_v2 = cv2.threshold(img_V, 180 + 76, 255, cv2.THRESH_BINARY_INV)
      bi_v = cv2.bitwise_and(bi_v1, bi_v2)

      th_r = cv2.bitwise_and(bi_h, bi_s)
      th_r = cv2.bitwise_and(th_r, bi_v)

threshold 함수를 사용해 임계 범위를 적용한다. cv2.THRESH_BINARY는 이미지를 받아, 두 번째 인자값 이상의 값을 세 번째 인자값으로 대체, 이하의 값을
0으로 대체하며, cv2.THRESH_BINARY_INV는 두 번째 인자값 이상을 0으로, 이하를 세 번재 인자값으로 대체한다. 
그 후, cv2.bitwise_and로 두 이미지의 공통된 값을 가지는 영상을 얻는다

* 팽창, 침식

      # dilate, erode ------------------------------------------------------------------------------------------------
      kernel = np.ones((10, 10), np.uint8)
      th_r = cv2.dilate(th_r, kernel, iterations=4)
      th_r = cv2.erode(th_r, kernel, iterations=5)
      
팽창을 적용하는 cv2.dilate 함수와 침식을 적용하는 cv2.erode 함수를 사용한다. kernel이 클수록 더 큰 효과를 볼 수 있고, iteration이 커져도 더 큰 효과를 
볼 수 있다. kernel은 한번에 적용하는 크기를 의미하며, iteration은 반복 횟수를 의미한다.

### 3-2 영상처리, 중앙 좌표 찾기 및 원이 얼마나 보이는지 검출

* 중앙 좌표 찾기

        # get center1 of blue ------------------------------------------------------------------------------------------
        where_white = np.where(th_r > 0)  # np.where is return y,x cordinates
        x_min = np.min(where_white[1])
        x_max = np.max(where_white[1])
        y_min = np.min(where_white[0])
        y_max = np.max(where_white[0])
        center1_x, center1_y = (x_min + x_max) // 2, (y_min + y_max) // 2  #
        
np.where는 주어진 기준을 충족하는 값의 인덱스를 반환한다. 2차원의 경우 y 좌표와 x좌표를 반환한다. 때문에, 0보다 큰 값의 좌표들 중에서
최대 최소를 구하면 파란색의 최좌, 최우, 최하, 최상점을 찾을 수 있다.

* 원이 얼마나 보이는지 찾기

        # find for perfect circle. ===============================================================================
        y_value_of_hori = th_r[center1_y, :]  # center1_y
        y_index_of_hori = np.where(y_value_of_hori > 0)
        flag_y_cut = 0
        flag_x_cut = 0
        flag_y_unblue = 0
        if len(y_index_of_hori[0]) == 0:
            flag_y_unblue = 1
            print("no blue with left2right")
            pass

        else:
            y_index_old = y_index_of_hori[0][0]
            for idx, y_index in enumerate(y_index_of_hori[0]):
                if abs(y_index - y_index_old) > 1:  # center1_y
                    flag_y_cut = 1
                    print("left2right circle checked")
                y_index_old = y_index
            if flag_y_cut == 0:
                pass


        x_value_of_hori = th_r[:, center1_x]  # center1_x
        x_index_of_hori = np.where(x_value_of_hori > 0)
        flag_x_unblue = 0
        if len(x_index_of_hori[0]) == 0:
            flag_x_unblue = 1
            print("no blue with up2down")

        else:
            x_index_old = x_index_of_hori[0][0]
            for x_index in x_index_of_hori[0]:
                if abs(x_index - x_index_old) > 1:  # center1_x
                    flag_x_cut = 1
                    print("up2down circle checked")
                x_index_old = x_index
            if flag_x_cut == 0:
                pass
                
파란색의 중심 좌표를 찾았다면, 그 좌표를 지나가는 y축과 평행한 선, x 축과 평행한 선에 끊어짐이 있었는지의 여부로 원의 형태를 알 수 있다.
만약 y축, x축에 평행한 두 선이 모두 끊어짐이 있다면 온전한 원이 보인것이다. 둘 중 한 선에서만 끊어짐을 발견했다면 반 원이 보이는 것이다.
둘 다 끊어지지 않았다면 링의 끄트머리만 보이는 상황이다. 

### 3-3 영상처리, 원의 중앙 좌표 찾기

                # 왼쪽
                step_1 = 0
                step_result_x = 0  # step을 추가한 결과. 이미지의 크기를 넘어가면 안된다.
                step_result_y = 0
                while (1):
                    step_1 += 1
                    step_result_x = center1_x - step_1
                    if step_result_x <= 0:  # 0보다 작으면 멈춤
                        step_result_x = 0
                        break
                    xx = th_r[center1_y, step_result_x]
                    if xx > 0:
                        break
                mm.append(step_result_x)

파란색의 중심 좌표가 빈공간일 때, 원이 온전하거나, 반원으로 판단 될 수 있다. 곧, 원이 온전하거나 반원으로 판단되었다면 파란색의 중심좌표는 빈공간에 있는 것이다. 때문에, 그 좌표를 기준으로 상,하,좌,우로 픽셀을 이동해가며 처음으로 0보다 큰 좌표를 찾아 새로운 최좌, 최우, 최하, 최상점을 만든다. 이 점들을 기준으로 중심 좌표를 새롭게 구하면, 그 좌표가 드론이 이동해야할 목표가 된다.

이 후, 남은 영상처리는 빨간색 혹은 보라색을 검출하는 것인데, 그것은 파란색을 검출하는 것과 동일하다.

### 3-4 드론제어

    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)  
    for i in range(3, 0, -1):
        print("{0}".format(i))
        sleep(1)

sendControlPosition16 함수는 순서대로 x거리, y거리, z거리, 이동속도, 회전각도, 회전속도를 인자로 받는다. x거리는 전진이 +, y거리는 왼쪽이 +, z거리는 위가 +, 회전각도는 좌회전이 +의 값으로 정해져 있다. 
