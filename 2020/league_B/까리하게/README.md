# Bleague_Karihage
KIEE 2020 Mini Drone Flight Competition B_League Karihage_Team


2020 미니드론자율비행 경진대회 B리그 까리하게 팀의 Github repository입니다.

## 대회 진행 전략
* **초록색 링 검출 및 중점 찾기**
1. 초록색 HSV 설정
1. 초록색 HSV 인식  
    > 컬러 RGB 영상을 HSV로 변환후 설정된 HSV값에 의해 이진화된 이미지 출력
![까리하게](/README_image/threshold.png)
1. 인식된 초록색 픽셀들의 중점 찾기   
    > cv2.connectedComponentsWithStats 함수를 사용하여 중점을 찾음
![까리하게](/README_image/greedetect_Total.PNG)

* **드론 이동**
> 드론 카메라의 화면 중점과 화면 안에서 검출된 초록색 링의 픽셀들 중점을 비교
1. 상승 & 하강 제어 
 ![까리하게](/README_image/up&down.PNG)  
1. 좌 이동 & 우 이동 제어
 ![까리하게](/README_image/left&right.PNG)
* **빨간색 / 파란색 색상 검출**
1. 빨간색 HSV 설정
   > 인식된 빨간색 픽셀의 총량 > 800 보다 클 경우 동작  
    ![까리하게](/README_image/red_pixel2.PNG)
1. 파란색 HSV 설정
   > 인식된 파란색 픽셀의 총량 > 600 보다 클경우 동작   
    ![까리하게](/README_image/blue_pixel2.PNG)


## 알고리즘 설명
![까리하게](/README_image/flowchart.JPG)  
1. 드론 연결 및 이륙
2. 영상수신
3. 전처리
> 입력영상에서 원하는 색상만을 사용하기 위한 과정
    초록색의 통과할 링, 1,2차의 빨간 표식 그리고 3차의 파란 표식의 HSV값을 미리 저장한 후, 
    원본영상을 HSV 색영상으로 변환, 이진화하여 필요한 색상만을 찾는다.    
    
4.픽셀개수 계산  
> 드론과 표식과의 거리를 판단하기 위한 방법  
    드론이 표식과 가까워지면 이진화된 입력영상에서 들어오는 픽셀의 개수가 커진다.  
    이를 이용하여 드론이 링을 통과한 후 표식과 가까워졌는지를 판단한다.  
5. 링 중점 좌표 계산  
> 드론이 링을 통과할 수 있도록 입력영상에서 링의 중점 좌표를 찾는다.  
6. 드론 위치 제어  
> 앞서 찾은 링의 중점좌표로 드론의 현재 위치를 판단하고 링의 중앙에 드론이 위치하고록 제어한다. 중앙에 위치되면 직진한다.  
7. 직진 후, 표식 확인  
> 드론이 직진한 후에 입력영상에서 표식색상의 픽셀개수를 통해 표식을 확인한다. 찾지 못하면 상하,전후진 이동을 통해 표식을 탐색한다.  
8. 회전 및 착륙  
> 빨간 표식이 확인되면 드론을 회전시키고 파란 표식이 확인되면 드론을 착륙시킨다.  


## 소스코드 설명

**표식 픽셀개수 계산**
```python
        R = np.sum(sum_red == 255, axis=None)
        G = np.sum(bin_g == 255, axis=None)
        B = np.sum(bin_b == 255, axis=None)
```
**링 중점 계산**
```python
        # 초록 중심 찾기
        nlabels2, labels2, stats2, centroids2 = cv2.connectedComponentsWithStats(bin_g)
        for ida, centroids2 in enumerate(centroids2):
            if stats2[ida][0] == 0 and stats2[ida][1] == 0:
                continue
            if np.any(np.isnan(centroids2)):
                continue
            x2, y2, width2, height2, area2 = stats2[ida]
            if (area2 > 300): #previous 800
                centerX, centerY = int(centroids2[0]), int(centroids2[1])
```
**드론 위치제어**
```python
        if flag == 0:
            #링 검출시
            if G > 100:
                # 상하좌우 일치하면 직진
                if centerY > 225 and centerY < 275:
                    if centerX > 305 and centerX < 335:
                        if R_cnt == 2:
                            print("LAST Go straight...")
                            flag = 1
                            R_cnt = 3
                            drone.sendControlPosition16(21, 0, 0, 7, 0, 0)
                            sleep(6)
                        else:
                            print("OK Go straight...")
                            drone.sendControlPosition16(20, 0, 0, 7, 0, 0)
                            sleep(6)
                            flag = 1
                        # 좌우 조정
                    elif centerX > 335:
                        if R_cnt == 2 and centerX > 540:
                            drone.sendControlPosition16(0, -5, 0, 10, 0, 0)
                            print('-->>>')

                            sleep(1.5)
                        else:
                            drone.sendControlPosition(0, -0.05, 0, 0.5, 0, 0)
                            print('->')
                            sleep(0.1)
                    elif centerX < 305:
                        if R_cnt == 2 and centerX < 100:
                            drone.sendControlPosition16(0, 5, 0, 10, 0, 0)
                            print('<<<--')
                            sleep(1.5)
                        else:
                            drone.sendControlPosition(0, 0.05, 0, 0.5, 0, 0)
                            print('<-')
                            sleep(0.1)
                # 상하 조정
                elif centerY > 275:
                    print('down')
                    drone.sendControlPosition(0, 0, -0.05, 0.5, 0, 0)
                    sleep(0.1)
                elif centerY < 225:
                    print('up')
                    drone.sendControlPosition(0, 0, 0.05, 0.5, 0, 0)
                    sleep(0.1)

            elif R_cnt == 2 and G == 0:
                drone.sendControlPosition16(0, 12, 0, 10, 0, 0)
                print('??? <<<--')
```
**표식 검출 후, 드론 이동 제어**
```python
        # 적색 표시 검출시 좌회전
        if flag == 1:
            if R > 800:
                print("It's RED!!! turn left")
                R_cnt += 1
                drone.sendControlPosition16(0, 0, 0, 0, 88, 50)
                sleep(3)  # 이전 = 3
                drone.sendControlPosition16(10, -2, 0, 10, 0, 0)
                sleep(3)
                drone.sendControlPosition16(0, -6, 0, 10, 0, 0)
                sleep(3)
                flag = 0

            # 청색표시 검출시 착륙
            elif R_cnt == 3 and B > 600:
                print("It's BLUE!!! Landing...")
                drone.sendLanding()
                drone.close()
                break

            # sleep(0.5)


    sleep(0.1)
```



