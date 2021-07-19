from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2

global area2, centerX, centerY

drone = Drone()
drone.open()
# 드론 제어 시작!

try:
    camera = PiCamera()
    camera.resolution = (640, 480)  # 이미지 크기
    camera.framerate = 32  # 카메라 fps
    rawCapture = PiRGBArray(camera, size=(640, 480))

    low_g = (39, 223, 38)
    up_g = (75, 255, 221)

    low_r1 = (176, 165, 56)
    up_r1 = (180, 255, 255)

    low_r2 = (0, 175, 38)
    up_r2 = (4, 255, 98)

    low_b = (93, 211, 44)
    up_b = (111, 255, 96)

    # flightevent
    drone.sendTakeOff()
    sleep(5)

    drone.sendControlPosition16(7, 0, 2, 10, 0, 0)  # 이륙 후, 약간 전진 및 상승
    sleep(3)

    flag = 0
    R_cnt = 0
    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):

        centerX = 0
        centerY = 0

        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        HSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        bin_g = cv2.inRange(HSV, low_g, up_g)

        bin_r1 = cv2.inRange(HSV, low_r1, up_r1)
        bin_r2 = cv2.inRange(HSV, low_r2, up_r2)
        sum_red = cv2.bitwise_or(bin_r1, bin_r2)

        bin_b = cv2.inRange(HSV, low_b, up_b)

        rawCapture.truncate(0)

        R = np.sum(sum_red == 255, axis=None)
        G = np.sum(bin_g == 255, axis=None)
        B = np.sum(bin_b == 255, axis=None)

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
                            drone.sendControlPosition16(19, 0, 0, 7, 0, 0)
                            sleep(6)
                        else:
                            print("OK Go straight...")
                            drone.sendControlPosition16(18, 0, 0, 7, 0, 0)
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


        # 적색 표시 검출시 좌회전 후 약간 직진
        if flag == 1:
            if R > 800:
                print("It's RED!!! turn left")
                R_cnt += 1
                drone.sendControlPosition16(0, 0, 0, 0, 88, 30)  # 이전속도 100
                sleep(4)  # 이전 = 3
                drone.sendControlPosition16(12, -2, 0, 10, 0, 0)
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

except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()