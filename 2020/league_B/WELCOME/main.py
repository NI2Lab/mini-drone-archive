from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2

drone = Drone()
drone.open()


def move(x, y):
    if x <= 60 and x > 0:    # <-
        drone.sendControlPosition16(0, 1, 0, 5, 0, 0)
        print('<-')
        sleep(1)
    elif x >= 100 and x < 160:  # ->
        drone.sendControlPosition16(0, -1, 0, 5, 0, 0)
        print('->')
        sleep(1)
    elif y <= 40 and y > 0:   # up
        drone.sendControlPosition16(0, 0, 1, 5, 0, 0)
        print('^')
        sleep(1)
    elif y > 70 and y < 120:   # down
        drone.sendControlPosition16(0, 0, -1, 5, 0, 0)
        print('v')
        sleep(1)

    elif x == 80 and y == 60:
        pass
    else:
        drone.sendControlPosition16(2, 0, 0, 10, 0, 0)
        print('move forward')
        sleep(1)


try:
    print('take off!!!')
    drone.sendTakeOff()
    for i in range(5, 0, -1):
        print("{0}".format(i))
        sleep(1)

    print('camera connect')
    camera = PiCamera()
    camera.resolution = (160, 120)
    camera.framerate = 8
    rawCapture = PiRGBArray(camera, size=(160, 120))
    th_c = [4, 64, 104]

    bordersize = 1
    mission = 0
    find = 0

    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        img = cv2.GaussianBlur(img, (3, 3), 0)
        hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        g_cent = (80, 60)
        r_cent = (80, 60)
        b_cent = (80, 60)

        ###############################################
        # using mask
        ###############################################
        lower_green = (th_c[1]-12, 50, 50)
        upper_green = (th_c[1]+12, 255, 255)

        bi_H_g = cv2.inRange(hsv, lower_green, upper_green)
        G = np.sum(bi_H_g == 255, axis=None)

        bi_H_g = cv2.copyMakeBorder(bi_H_g, top=bordersize, bottom=bordersize,
                                    left=bordersize, right=bordersize, borderType=cv2.BORDER_CONSTANT, value=[255, 255, 255])

        _, contours_g, _ = cv2.findContours(
            bi_H_g, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

        flag = 0

        for cnt in contours_g:
            epsilon = 0.01*cv2.arcLength(cnt, True)
            approx = cv2.approxPolyDP(cnt, epsilon, True)

            size = len(approx)
            if size == 4 and cv2.contourArea(approx) < 18000 and cv2.contourArea(approx) > 100:
                m = approx.mean(axis=0)
                for point in approx:
                    print(point)
                    if (point[0, 0] < 5 and (point[0, 1] < 5 or point[0, 1] > 115)) or (point[0, 0] > 155 and (point[0, 1] < 5 or point[0, 1] > 115)):
                        flag = 1
                        break
                if flag == 0:
                    g_cent = (int(m[0, 0]) - bordersize,
                              int(m[0, 1]) - bordersize)

                break
        if mission == 0:
            drone.sendControlPosition16(13, 0, 0, 5, 0, 0)
            print('move forward')
            sleep(3)
            mission += 1

        if mission == 1 or mission == 2:
            lower_red = (th_c[0]-12, 100, 110)
            upper_red = (th_c[0]+12, 255, 255)

            bi_H_r_1 = cv2.inRange(hsv, lower_red, upper_red)

            lower_red = (160, 100, 110)
            upper_red = (180, 255, 255)

            bi_H_r_2 = cv2.inRange(hsv, lower_red, upper_red)

            bi_H_r = cv2.bitwise_or(bi_H_r_1, bi_H_r_2)
            R = np.sum(bi_H_r == 255, axis=None)

            r_point = np.where(bi_H_r == 255)

            r_cent = (r_point[1].mean(axis=0, dtype=np.int32),
                      r_point[0].mean(axis=0, dtype=np.int32))

            if sum([R, G]) < 18000:
                print('R : {}, G : {}'.format(R, G))

                if (g_cent[0] == 80 and g_cent[1] == 60) and (r_cent[0] == 80 and r_cent[1] == 60):
                    pass
                elif R >= 125 and R < 2000:
                    print('yaw counterclockwise 90 degree')
                    drone.sendControlPosition16(0, 0, 0, 0, 30, 45)
                    for i in range(2, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                    drone.sendControlPosition16(0, 0, 0, 0, 30, 45)
                    for i in range(2, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                    drone.sendControlPosition16(0, 0, 0, 0, 30, 45)
                    for i in range(2, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                    drone.sendControlPosition16(15, 0, 0, 10, 0, 0)
                    sleep(3)
                    mission += 1

                elif R >= 3 and R < 125:
                    print('r')
                    move(r_cent[0], r_cent[1])

                elif G > 1000:
                    print('g')
                    move(g_cent[0], g_cent[1])

        elif mission == 3:
            if find == 0:
                drone.sendControlPosition16(0, -60, 0, 10, 0, 0)
                for i in range(2, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
                if G > 1000:
                    find = 100
                else:
                    find += 1
            elif find >= 32 and find < 64:
                drone.sendControlPosition16(0, 120, 0, 10, 0, 0)
                for i in range(2, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
                if G > 1000:
                    find = 100
                else:
                    find += 1
            elif find >= 64 and find < 100:
                drone.sendControlPosition16(0, -60, 0, 10, 0, 0)
                for i in range(2, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
                if G > 1000:
                    find = 100
                else:
                    find += 1
            else:
                print('landing')
                drone.sendLanding()
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    sleep(1)
                    drone.close()
                    break

            lower_blue = (th_c[2]-12, 80, 70)
            upper_blue = (th_c[2]+12, 255, 255)

            bi_H_b = cv2.inRange(hsv, lower_blue, upper_blue)
            B = np.sum(bi_H_b == 255, axis=None)

            b_point = np.where(bi_H_b == 255)

            b_cent = (b_point[1].mean(axis=0, dtype=np.int32),
                      b_point[0].mean(axis=0, dtype=np.int32))

            if sum([B, G]) < 18000:
                print('B : {}, G : {}'.format(B, G))

                if (g_cent[0] == 80 and g_cent[1] == 60) and (b_cent[0] == 80 and b_cent[1] == 60):
                    pass

                elif B >= 125 and B < 2000:
                    print('landing')
                    drone.sendLanding()
                    for i in range(5, 0, -1):
                        print("{0}".format(i))
                        sleep(1)
                    drone.close()
                    break

                elif B >= 5 and B < 125:
                    print('b')
                    move(b_cent[0], b_cent[1])

                elif G > 1000:
                    print('g')
                    move(g_cent[0], g_cent[1])

        rawCapture.truncate(0)
        key = cv2.waitKey(1)
        if key == 27:
            break
except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()

drone.sendLanding()
drone.close()
