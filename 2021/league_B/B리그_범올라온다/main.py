from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2

global area2, centerX, centerY, y_flag, red_flag, center2X, center2Y, center3X, center3Y, x_height, real_height, purple, purple_flag, straight_flag

def eventAltitude(altitude):
    global real_height
    real_height = float(altitude.rangeHeight)

drone = Drone()
drone.open()
# 드론 제어 시작!
drone.setEventHandler(DataType.Altitude, eventAltitude)

try:
    camera = PiCamera()
    camera.resolution = (640, 480)  # 이미지 크기
    camera.framerate = 32  # 카메라 fps
    rawCapture = PiRGBArray(camera, size=(640, 480))

    low_b = (100, 200, 30)
    up_b = (170, 255, 255)

    low_r = (0, 59, 62)
    up_r = (13, 255, 201)

    low_purple = (115, 30, 30)
    up_purple = (140, 233, 91)

    # flightevent
    drone.sendTakeOff()
    sleep(5)

    flag = 1
    y_flag = False
    red_flag = False
    x_height = 1.15
    purple = 0
    purple_flag = False
    straight_flag = False

    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):

        centerX = 0
        centerY = 0

        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        HSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        bin_b = cv2.inRange(HSV, low_b, up_b)
        bin_r = cv2.inRange(HSV, low_r, up_r)
        bin_p = cv2.inRange(HSV, low_purple, up_purple)

        rawCapture.truncate(0)

        B = np.sum(bin_b == 255, axis=None)
        R = np.sum(bin_r == 255, axis=None)
        P = np.sum(bin_p == 255, axis=None)

        drone.sendRequest(DeviceType.Drone, DataType.Altitude)

        nlabels, labels, stats, centroids = cv2.connectedComponentsWithStats(bin_b)
        for ida, centroids in enumerate(centroids):
            if stats[ida][0] == 0 and stats[ida][1] == 0:
                continue
            if np.any(np.isnan(centroids)):
                continue
            x, y, width, height, area = stats[ida]
            if (area > 300):
                centerX, centerY = int(centroids[0]), int(centroids[1])

        if flag == 2:
            if P < 200 and straight_flag == False:
                drone.sendControlPosition(0.3, 0, 0, 0.2, 0, 0)
                print("purple_move")
                sleep(1)

            elif P > 200 and P < 2000:
                straight_flag = True
                nlabels3, labels3, stats3, centroids3 = cv2.connectedComponentsWithStats(bin_p)
                for ida, centroids3 in enumerate(centroids3):
                    if stats3[ida][0] == 0 and stats3[ida][1] == 0:
                        continue
                    if np.any(np.isnan(centroids3)):
                        continue
                    x3, y3, width3, height3, area3 = stats3[ida]
                    if (area3 > 10):
                        center3X, center3Y = int(centroids3[0]), int(centroids3[1])

                if purple_flag == False:
                    if center3Y > 250 and center3Y < 280:
                        purple_flag = True
                        print('purple = TRUE')
                    # 상하 조정
                    elif center3Y > 280:
                        drone.sendControlPosition(0, 0, -0.05, 0.05, 0, 0)
                        print('purple down')
                        sleep(0.2)
                    elif center3Y < 250:
                        drone.sendControlPosition(0, 0, 0.05, 0.05, 0, 0)
                        print('purple up')
                        sleep(0.2)
                elif purple_flag == True:
                    if center3X > 305 and center3X < 335:
                        # y_flag = False
                        drone.sendControlPosition(0.3, 0, 0, 0.4, 0, 0)
                        print("purple OK-Go")
                        sleep(1)
                    # 좌우 조정
                    elif center3X > 335:
                        drone.sendControlPosition(0, -0.05, 0, 0.05, 0, 0)
                        print('purple ->')
                        sleep(0.2)
                    elif center3X < 305:
                        drone.sendControlPosition(0, 0.05, 0, 0.05, 0, 0)
                        print('purple <-')
                        sleep(0.2)
            if P > 2000:
                print("Landing")
                drone.sendLanding()
                sleep(5)
                drone.close()
                break

        elif flag == 1:
            if R < 200 and straight_flag == False:
                drone.sendControlPosition(0.3, 0, 0, 0.2, 0, 0)
                print("red_move")
                sleep(1)

            if R > 200 and R < 2000:
                straight_flag = True
                nlabels2, labels2, stats2, centroids2 = cv2.connectedComponentsWithStats(bin_r)
                for ida, centroids2 in enumerate(centroids2):
                    if stats2[ida][0] == 0 and stats2[ida][1] == 0:
                        continue
                    if np.any(np.isnan(centroids2)):
                        continue
                    x2, y2, width2, height2, area2 = stats2[ida]
                    if (area2 > 10):
                        center2X, center2Y = int(centroids2[0]), int(centroids2[1])

                if red_flag == False:
                    if center2Y > 250 and center2Y < 280:
                        red_flag = True
                        print('red_flag = TRUE')
                    # 상하 조정
                    elif center2Y > 280:
                        drone.sendControlPosition(0, 0, -0.05, 0.05, 0, 0)
                        print('red down')
                        sleep(0.3)
                    elif center2Y < 250:
                        drone.sendControlPosition(0, 0, 0.05, 0.05, 0, 0)
                        print('red up')
                        sleep(0.3)
                elif red_flag == True:
                    if center2X > 280 and center2X < 360:
                        drone.sendControlPosition(0.3, 0, 0, 0.4, 0, 0)
                        print("red OK-Go")
                        sleep(1)
                    # 좌우 조정
                    elif center2X > 360:
                        drone.sendControlPosition(0, -0.05 , 0, 0.05, 0, 0)
                        print('red ->')
                        sleep(0.3)
                    elif center2X < 280:
                        drone.sendControlPosition(0, 0.05, 0, 0.05, 0, 0)
                        print('red <-')
                        sleep(0.3)


            if R > 2000:
                drone.sendControlPosition16(0, 0, 0, 0, 88, 17)  # 이전속도 100
                # print("curve")
                sleep(7)  # 이전 = 3
                drone.sendControlPosition16(8, 0, 0, 4, 0, 0)  # 이전속도 100
                # print("50cm go")
                sleep(5)  # 이전 = 3
                round(real_height, 2)
                drone.sendControlPosition(0, 0, round(x_height-real_height, 2), 8, 0, 0)  # 이륙 후, 약간 전진 및 상승
                sleep(3)
                drone.sendControlPosition16(0, -10, 0, 5, 0, 0)
                print('-->>>')
                sleep(5)
                flag = 0
                red_flag = False
                straight_flag = False
                purple += 1


        elif flag == 0:

            if B < 100 :
                drone.sendControlPosition16(0, 10, 0, 5, 0, 0)
                print('<<<--')
                sleep(5)
                round(real_height, 2)
                drone.sendControlPosition(0, 0, round(x_height - real_height, 2), 4, 0, 0)  # 이륙 후, 약간 전진 및 상승
                sleep(3)

            if B > 100: #(640,480)의 반절 (320,240) 240
                # 상하좌우 일치하면 직진
                if y_flag == False:
                    if centerY > 250 and centerY < 280:
                        y_flag = True
                        print('y_flag = TRUE')
                    # 상하 조정
                    elif centerY > 280:
                        drone.sendControlPosition(0, 0, -0.07, 0.5, 0, 0)
                        print('down')
                        sleep(0.3)
                    elif centerY < 250:
                        drone.sendControlPosition(0, 0, 0.07, 0.5, 0, 0)
                        print('up')
                        sleep(0.3)
                if y_flag == True:
                    if centerX > 305 and centerX < 335:
                        #y_flag = False
                        print("OK-Go")
                        y_flag = False
                        if purple < 2:
                            flag = 1
                        elif purple == 2:
                            flag = 2
                    # 좌우 조정
                    elif centerX > 335:
                        drone.sendControlPosition(0, -0.07, 0, 0.5, 0, 0)
                        print('->')
                        sleep(0.3)
                    elif centerX < 305:
                        drone.sendControlPosition(0, 0.07, 0, 0.5, 0, 0)
                        print('<-')
                        sleep(0.3)


    sleep(0.5)
except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()






