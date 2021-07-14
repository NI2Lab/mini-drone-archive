# 대회 진행 전략
 우선 드론이 이륙하여 파랑색 천을 찾는다. 천 중앙 온전한 원이 보이지 않을 경우 원이 짤린 부분으로 드론을 이동한다. 이동 후 온전한 원이 보이는지 확인 후 보이지 않으면 일정거리를 움직인다. 온전한 원이 보일 경우 원의 중심을 찾고 원의 중심으로 드론을 움직인다. 
원의 중심을 찾고 일정거리를 움직이면서 온전한 원이 사라지는 것을 확인한다. 온전한 원이 사라지게 되면 링과 빨간색 네모 3분의 2지점정도 위치까지 직진한다. 빨간색 네모를 찾고 왼쪽방향으로 90도 회전 한다.
회전 후 2단계의 원을 찾고 위의 방법을 반복한다. 3단계의 원도 위와 같이 동작한다.
마지막 3단계 링까지 통과후 보라색 네모를 찾고 착지를 한다.
 
# 알고리즘 설명
1. 1단계 링의 센터 찾기
2. 구한 센터 좌표와 카메라 센터 좌표 비교 후, 드론 위치 이동
3. 중심을 찾았으면 카메라에서 원 모양이 잘리기 전까지 앞으로 조금씩 이동하다가 원이 한쪽이라도 잘리게 보이면 앞으로 직진
4. 드론이 링과 빨간색 표식 사이에 위치하게 되면 90도 회전한 후 1미터 직진
5. 2단계 링의 센터 찾기
6. 구한 센터 좌표와 카메라 센터 좌표 비교 후, 드론 위치 이동
7. 중심을 찾았으면 카메라에서 원 모양이 잘리기 전까지 앞으로 조금씩 이동하다가 원이 한쪽이라도 잘리게 보이면 앞으로 직진
8. 드론이 링과 빨간색 표식 사이에 위치하게 되면 90도 회전한 후 1미터 직진
9. 3단계 링의 센터 찾기
10. 구한 센터 좌표와 카메라 센터 좌표 비교 후, 드론 위치 이동
11. 중심을 찾았으면 카메라에서 원 모양이 잘리기 전까지 앞으로 조금씩 이동하다가 원이 한쪽이라도 잘리게 보이면 앞으로 직진
12. 드론이 링과 보라색 표식 사이에 위치하게 되면 그 자리에 착지

# 소스 코드 설명 

#### 링의 중심좌표를 찾는 코드

1.링의 중심좌표를 찾는 함수 정의
 
    def find_center(img_hsv):
       img_mask_blue = cv2.inRange(img_hsv, lower_blue, upper_blue)
       img_blue = cv2.medianBlur(img_mask_blue, 15)
       value_th = np.where(img_blue[:, :] == 255)

2.먼저 파란색 천의 중심좌표를 찾기

       min_x = np.min(value_th[1])
       max_x = np.max(value_th[1])
       min_y = np.min(value_th[0])
       max_y = np.max(value_th[0])
       center_x = (min_x + max_x) / 2
       center_y = (min_y + max_y) / 2

3.그다음 링의 중심좌표를 찾기. 원이 잘려서 보이는 경우, 원이 다 보일 수 있도록 드론의 위치를 이동시키기

       if (np.where(image_th[int(center_y), int(center_x):])==''): #원의 오른쪽이 안보이는 경우
           return 0,-1
       elif (np.where(image_th[int(center_y), int(center_x)::-1])==''): #원의 왼쪽이 안보이는 경우
           return 0,-2
       elif (np.where(image_th[int(center_y)::-1, int(center_x)])==''): #원의 위쪽이 안보이는 경우
           return -1,0
       elif (np.where(image_th[int(center_y):, int(center_x)])==''): #원의 아래쪽이 안보이는 경우
           return -2,0
       else :
           right = int(center_x) + np.min(np.where(image_th[int(center_y), int(center_x):]))
           left = int(center_x) - np.min(np.where(image_th[int(center_y), int(center_x)::-1]))
           up = int(center_y) - np.min(np.where(image_th[int(center_y)::-1, int(center_x)]))
           down = int(center_y) + np.min(np.where(image_th[int(center_y):, int(center_x)]))

           center_x = int((right + left) / 2)
           center_y = int((up + down) / 2)

           return center_x, center_y
           
#### 링의 센터 좌표와 카메라 중심 좌표가 일치하도록 드론의 위치를 이동시키는 코드

      if cx < 320-50 : 
                drone.sendControlPosition16(0, 1, 0, 5, 0, 0) #왼쪽으로 이동
                sleep(1)
                if cy < 240-30 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+30 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)                    
            elif cx > 320+50 :
                drone.sendControlPosition16(0, -1, 0, 5, 0, 0) #오른쪽으로 이동
                sleep(1)
                if cy < 240-30 :
                    drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                    sleep(1)
                elif cy > 240+30 :
                    drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                    sleep(1)
            elif cy > 240+30 :
                drone.sendControlPosition16(0, 0, -1, 5, 0, 0) #아래로 이동
                sleep(1)
            elif cy < 240-30 :
                drone.sendControlPosition16(0, 0, 1, 5, 0, 0) #위로 이동
                sleep(1)
            else :
                know_center = 1
                
링의 센터 좌표와 카메라 중심 좌표가 일치하면 조금씩 앞으로 이동하다가, 카메라에 원이 잘려서 보이는 순간 앞으로 전진한다 

         if know_center==1 :
                
                while():
                    a,b = check_position(img_hsv)
                    if a,b == 0,0:
                        drone.sendControlPosition16(2, 0, 0, 5, 0, 0) #앞으로 0.2미터 이동
                        sleep(1)
                        continue
                    else :
                        drone.sendControlPosition16(10, 0, 0, 5, 0, 0) #앞으로 1미터 이동 
                        sleep(2)
                        know_center = 0
                        step = 2
                        break                       

#### 드론이 링과 빨간색 표식 사이에 위치하게 되면 90도 회전한 후 직진하는 코드 
            drone.sendControlWhile(0,0,0,0,1000) #호버링
            sleep(1)

            drone.sendControlPosition16(0, 0, 0, 0, 90, 30) #왼쪽으로 90도 회전
            sleep(3)

            drone.sendControlPosition16(10, 0, 0, 5, 0, 0) #앞으로 1미터 이동
            sleep(2)
            
            step = 3
            find = True
            
#### 드론이 링과 보라색 표식 사이에 위치하게 되면 그 자리에 착지하는 코드 
           drone.sendControlWhile(0,0,0,0,1000) #호버링
           sleep(1)

           drone.sendLanding()
           sleep(5)
           drone.close()
           break
