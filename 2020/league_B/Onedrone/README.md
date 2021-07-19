# 2020 미니드론 자율비행 경진대회
Onedrone(박정혁)

<br>

## 대회 진행 전략

* 빠른 비행보다 안정적인 완주를 목표로 드론 코딩을 하였다.
* 비행과 동시에 원하는 위치의 좌표를 찾는 것이 아닌 좌표를 찾고 비행을 하는 전략을 사용하였다.

<br>

## 알고리즘 설명
Onedrone 팀의 코드 알고리즘은 다음과 같다.

<br>

### 알고리즘
1. 드론 비행 후 Pi camera를 통해 사진을 받아옴.
2. 사진에서 측정되는 부분의 중심좌표를 분석함.
    
    2-1. 측정이 안될 경우 : x좌표와 y좌표 둘 중 하나라도 값이 0이 나오는 경우로 정확한 측정을 위해 장애물을 향해 좀 더 직진한다.
    
    2-2. 측정이 된 경우 : 일시적으로 Hovering을 실시하고, 사진의 중심 좌표로 0이 아닌 어떠한 값이 나온 경우로 사진의 크기 (920,720)의 중심좌표 (480,360)과 비교하여 일정 범위에 값이 해당되지 않을 경우 드론을 상,하 또는 좌,우로 이동시켜 범위 안에 속하게 한다.
    
3. 초록색 장애물이 인식되지 않고, 빨강색 원이 측정될 경우 ㅡ> 좌회전을 함.
4. 초록색 장애물이 인식되지 않고, 파랑색 원이 측정될 경우 ㅡ> 착지를 함.

<br>

## 소스 코드 설명
Onedrone 팀의 소스 코드는 다음과 같다.

        from e_drone.drone import *
        from picamera.array import PiRGBArray
        from picamera import PiCamera
        from time import sleep
        import numpy as np
        import cv2

        drone = Drone()
        drone.open()
        try:
            drone.sendTakeOff()
            sleep(5)
            camera = PiCamera()
            camera.resolution = (960, 720)      // 카메라의 사이즈는 960 x 720으로 설정
            camera.framerate = 32
            rawCapture = PiRGBArray(camera, size=(960, 720))
            th_c = [2, 61, 112]     // 측정을 통해 R,G,B의 Threshold 값을 설정함.
            drone.sendControlPosition16(10, 0, 0, 6, 0, 0) // 1단계를 빠르게 통과하기 위해 1m 앞으로 진출한다.
            for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):      // 사진을 계속해서 Picam을 통해 받음.
                img = frame.array
                img = cv2.flip(img, 0)
                img = cv2.flip(img, 1)
                img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)      // 받은 사진을 HSV로 전환.
        
                H = img[:, :, 0]
        
                _, bi_H = cv2.threshold(H, th_c[0] - 5, 255, cv2.THRESH_BINARY)
                _, bi_H_ = cv2.threshold(H, th_c[0] + 4, 255, cv2.THRESH_BINARY_INV)
                R = cv2.bitwise_and(bi_H, bi_H_)
        
                _, bi_H = cv2.threshold(H, th_c[1] - 5, 255, cv2.THRESH_BINARY)
                _, bi_H_ = cv2.threshold(H, th_c[1] + 4, 255, cv2.THRESH_BINARY_INV)
                G = cv2.bitwise_and(bi_H, bi_H_)
        
                _, bi_H = cv2.threshold(H, th_c[2] - 5, 255, cv2.THRESH_BINARY)
                _, bi_H_ = cv2.threshold(H, th_c[2] + 4, 255, cv2.THRESH_BINARY_INV)
                B = cv2.bitwise_and(bi_H, bi_H_)  // HSV로 바꾼 R, G, B에 대한 값을 이진화를 실시함.
                G = np.array(G)     // G(초록색)에 대한 numpy array 설정.
        
                index = np.where(G == 255)     // G == 255( 측정된 초록색 부분 )의 좌표를 index로 설정.
                new_A = np.array([])        // y좌표를 위한 임시 numpy array
                real_A = np.array([])       // 구하려는 y좌표에 대한 정보 numpy array
                new_B = np.array([])        // x좌표를 위한 임시 numpy array
                real_B = np.array([])       // 구하려는 x좌표에 대한 정보 numpy array
                rawCapture.truncate(0)
                place_x=0                   // x축기준 중심 좌표보다 오른쪽에 있는지, 왼쪽에 있는지 판단.
                place_y=0                   // y축기준 중심 좌표보다 위쪽에 있는지, 아래쪽에 있는지 판단.
                F_x=0                       // 구하려는 장애물 중심 좌표의 x좌표
                F_y=0                       // 구하려는 장애물 중심 좌표의 y좌표
                direction=0                 // 드론의 동작을 결정하는 direction 변수 설정.
                print("rest")
                drone.sendControlWhile(0, 0, 0, 0, 2000)    // 좌표를 계산하기 전 Hovering을 통해 계산을 준비
                for i in range(np.min(index[0]), np.max(index[0])): // index[0]은 측정된 G의 y좌표들이고 그 최솟값과 최댓값 만큼 반복.
                    if np.count_nonzero(index[0] == i) > 530:       // index[0] 내의 좌표가 530이상 반복될 경우
                        new_A = np.append(new_A, i)                 // 임시 y좌표 numpy array(new_A)에 저장
                for i in range(1, np.size(new_A) - 1):      // new_A 배열을 반복 시킴
                    if (new_A[i] - new_A[i - 1]) > 120:     // new_A 배열 내의 원소간의 차가 120 이상일 경우
                        real_A = np.append(real_A, [new_A[i - 1], new_A[i]])    // 그 두 값을 최종 numpy array(real_A)에 저장
                print("rest")
                drone.sendControlWhile(0, 0, 0, 0, 2000)    // y좌표를 계산하고 x좌표를 계산하기 전 rest.
                for i in range(np.min(index[1]), np.max(index[1])):
                    if np.count_nonzero(index[1] == i) > 400:
                        new_B = np.append(new_B, i)
                for i in range(1, np.size(new_B) - 1):
                    if (new_B[i] - new_B[i - 1]) > 180:
                        real_B = np.append(real_B, [new_B[i - 1], new_B[i]])    // y좌표를 구할 때와 같은 일련의 과정을 통해 x좌표를 위한 두 값 저장
                F_x = int((np.sum(real_B) // 2))        // real_B 두 값을 합친 것의 중간값을 원하는 좌표의 x좌표로 설정
                F_y = int((np.sum(real_A) // 2))        // real_A 두 값을 합친 것의 중간값을 원하는 좌표의 y좌표로 설정
        
                R_s = np.sum(R == 255, axis=None)       
                G_s = np.sum(G == 255, axis=None)
                B_s = np.sum(B == 255, axis=None)       // R,G,B에 대한 각각 배열의 총 합을 저장.
        
                if F_x == 0 and F_y == 0:       // 만약 구한 중심의 좌표가 (0,0)일 경우
                    direction = 0               // 직진
                elif (F_x != 0 and F_y == 0) or (F_x == 0 and F_y != 0):      // x좌표와 y좌표 중 하나만 0일 경우
                    direction = 3               // 조금 직진
                else:                           // 중심의 좌표가 둘 다 0이 아닐 경우
                    direction = -1              // 멈춤
        
                if F_x < 460 and direction == -1:   // 측정된 x좌표가 460보다 작고 멈춘 상태면
                    place_x = -1                    // place_x에 -1 저장
                elif F_x > 500 and direction == -1: // 측정된 x좌표가 500보다 크고 멈춘 상태면
                    place_x = 1                     // place_x에 1 저장
        
                if F_y < 340 and direction == -1:   // 측정된 x좌표가 340보다 작고 멈춘 상태면
                    place_y = -1                    // place_y에 -1 저장
                elif F_y > 380 and direction == -1: // 측정된 x좌표가 380보다 크고 멈춘 상태면
                    place_y = 1                     // place_y에 1 저장
        
                if 460 <= F_x <= 500:               // x좌표가 460에서 500사이일 경우
                    place_x = 0                     // place_x에 0 저장
                if 340 <= F_y <= 380:               // y좌표가 340에서 380사이일 경우
                    place_y = 0                     // place_y에 0 저장
                if place_x == 0 and place_y == 0:   // place_x와 place_y가 둘다 0일 경우
                    direction = 0                   // 직진
        
                if G_s < 50000 and R_s > 5500 and direction == 0 : // 초록색이 충분히 측정되지 않고, 빨강색이 측정되면서 직진 상태이면
                    direction = 1   // 90도 좌회전
        
                if G_s < 50000 and B_s >5500 and direction == 0 :  // 초록색이 충분히 측정되지 않고, 파랑색이 측정되면서 직진 상태이면
                    direction= 2    // 착지
        
                if direction == 0:  // 직진
                    drone.sendControlPosition16(15, 0, 0, 7, 0, 0)
                elif direction == -1 :  // Hovering
                    drone.sendControlWhile(0, 0, 0, 0, 5000)
                elif direction == 1:    // 90도 좌회전
                    drone.sendControlPosition16(0, 0, 0, 0, 90, 30)
                elif direction == 2:    // 착지
                    drone.sendLanding()
                    drone.close()
                    break
                elif direction == 3:    // 조금 직진
                    drone.sendControlPosition16(4, 0, 0, 5, 0, 0)
        
                if place_x == -1:   // 우측 이동
                    drone.sendControlPosition16(0, -3, 0, 5, 0, 0)
                elif place_x == 1:  // 좌측 이동
                    drone.sendControlPosition16(0, 3, 0, 5, 0, 0)
        
                if place_y == -1:   // 상승 이동
                    drone.sendControlPosition16(0, 0, 3, 5, 0, 0)
                elif place_y == 1:  // 하강 이동
                    drone.sendControlPosition16(0, 0, -3, 5, 0, 0)
        
        except Exception as e:  // 오류 발생시 드론 착지 후 종료
            print(e)
            drone.sendLanding()
            drone.close()
            
## 코드 설계 중 고려 사항
1. 중심 좌표를 알기위해 기준 상수값을 정하는 것이 까다로웠다.
2. 빨강, 초록, 파랑을 어느정도 거리에서 얼만큼 인식하는지를 추가적으로 조사하여야 했다.
3. 중심 좌표를 구하는 부분이 오래 걸리기 때문에 Hovering을 통해 불시착하지 않도록 주기적으로 명령을 했다.
4. 중심 좌표를 구하는 부분을 최적화 하는 것이 필수적이었다.
5. cut off time 내에 장애물을 통과하기 위해서 드론 비행 속도 조절이 필요했다.

## 애로 사항
* 드론 대회 준비 중 막바지에 드론의 모터가 손상이 되어 코드 점검으로만 대회를 준비할 수 밖에 없었다.