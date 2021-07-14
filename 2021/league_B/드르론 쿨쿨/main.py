from picamera.array import PiRGBArray
from picamera import PiCamera
import cv2
import numpy as np
import time
from e_drone.drone import *
from e_drone.protocol import *

drone = Drone()
drone.open()

try:
    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(640, 480))

    n = 0


    def find_ring(cnt, hier):
        p = 0  # 링의 컨투어 인덱스 저장하는 변수 선언
        s = cv2.contourArea(cnt[p])
        for i in range(len(hier[0])):  # len(hier[0]) : 컨투어 갯수
            area = cv2.contourArea(cnt[i])
            if hier[0, i, 2] == -1 and hier[0, i, 3] != -1:  # 자식없고 부모 있음
                if area != 0:
                    p = i
                else:  # area==0
                    pass

    def find_red_sq(contours_red):
        p = 0
        s = cv2.contourArea(contours_red[p])
        for i in range(len(contours_red)):
            area = cv2.contourArea(contours_red[i])
            if area > s:
                p = i

        return p


    def focus(x, y):  # 링의 중심을 카메라의 중심으로 이동

        while True:
            if x < 250 or x > 390:
                if x < 250:
                    x_ = +0.08 #8cm씩 이동
                    x = x + 40 #80 픽셀(16cm)

                elif x > 390:
                    x_ = -0.08
                    x = x - 40

                print("locate")
                drone.sendControlPosition(0, x_, 0, 0.2, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
            elif y < 170 or y > 310:
                if y < 170:
                    y_ = -0.08
                    y = y + 40
                elif y > 310:
                    y_ = +0.08
                    y = y - 40
                print("locate")
                drone.sendControlPosition(0, 0, y_, 0.2, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
            else:
                break


    def focus2(cx, cy):  # 모멘트_무게중심으로 초점이동

        while True:
            if cx < 250 or cx > 390:
                if cx < 250:
                    cx_ = -0.08
                    cx = cx + 40

                elif cx > 390:
                    cx_ = 0.08
                    cx = cx - 40

                print("locate")
                drone.sendControlPosition(0, cx_, 0, 0.2, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
            elif cy < 170 or cy > 310:
                if cy < 170:
                    cy_ = 0.08
                    cy = cy + 40
                elif cy > 310:
                    cy_ = -0.08
                    cy = cy - 40
                print("locate")
                drone.sendControlPosition(0, 0, cy_, 0.2, 0, 0)
                for i in range(3, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
            else:
                break


    def shift_ring2(R_pix):  # 링통과 + (좌회전 or 착륙)
        global n
        if n == 2:
            print("move_long")  # 0.9m 이동
            drone.sendControlPosition16(9, 0, 0, 3, 0, 0)
            for i in range(5, 0, -1):
                print("{0}".format(i))
                time.sleep(1)
            print("Landing")
            drone.sendLanding()
            for i in range(5, 0, -1):
                print("{0}".format(i))
                time.sleep(1)
        else:
            if R_pix > 90:  # 0.9m 앞으로 이동+좌회전
                print("move_long")
                drone.sendControlPosition16(9, 0, 0, 3, 0, 0)
                for i in range(5, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
                print("heading")
                drone.sendControlPosition(0, 0, 0, 0, 90, 30)
                for i in range(4, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)
                n += 1


    ##########################################################

    th_blue_h = 109
    th_red_h = 5
    b_pix_thr = 130000  # 1.5m

    print("Take Off")
    drone.sendTakeOff()
    for i in range(5, 0, -1):
        print("{0}".format(i))
        time.sleep(1)

    print("Hovering")
    drone.sendControlWhile(0, 0, 0, 0, 2000)
    for i in range(2, 0, -1):
        print("{0}".format(i))
        time.sleep(1)

    for frame in camera.capture_continuous(rawCapture, format='bgr', use_video_port=True):
        image = frame.array
        image = cv2.flip(image, 0)
        image = cv2.flip(image, 1)
        image = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)

        # blue flag
        img_mask = cv2.inRange(image, (th_blue_h - 10, 20, 20), (th_blue_h + 10, 255, 255))
        B = np.sum(img_mask == 255, axis=None)
        # red square
        img_mask_red = cv2.inRange(image, (th_red_h - 10, 20, 20), (th_red_h + 10, 255, 255))
        R = np.sum(img_mask_red == 255, axis=None)

        # erosion과 dilate를 이용한 외곽 정리
        k = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
        img_mask2 = cv2.erode(img_mask, k)
        img_mask2 = cv2.dilate(img_mask2, k)
        img_mask2 = cv2.dilate(img_mask2, k)
        img_mask2 = cv2.erode(img_mask2, k)

        # contour
        _, contours, hier = cv2.findContours(img_mask2, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)
        _, contours_red, r_hier = cv2.findContours(img_mask_red, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE)

        # main_run
        if B>50:
            idx = find_ring(contours, hier)  # 링의 컨투어 찾아서 인덱스 리턴
            (x, y), radius = cv2.minEnclosingCircle(contours[idx])  # 링의 중심, 반지름 리턴

            if radius < 240:  # 링 존재
                focus(x, y)  # 링 중점 위치 조절
                print("move")  # 30cm 이동
                drone.sendControlPosition16(4, 0, 0, 3, 0, 0)
                for i in range(4, 0, -1):
                    print("{0}".format(i))
                    time.sleep(1)

            else:  # 링 없음
                if n == 2 and R > 80:
                    red_idx = find_red_sq(contours_red)
                    M = cv2.moments(contours_red[red_idx])
                    cx = int(M['m10'] / M['m00'])
                    cy = int(M['m01'] / M['m00'])
                    focus2(cx, cy)
                elif n == 2 and R <= 80:
                    _, labels, stats, centroids = cv2.connectedComponentsWithStats()
                    cx__ = centroids[0]
                    cy__ = centroids[1]
                    focus2(cx__, cy__)
                elif n != 2:
                    red_idx = find_red_sq(contours_red)
                    (Rx, Ry), R_radius = cv2.minEnclosingCircle(contours_red[red_idx])
                    focus(Rx, Ry)

                shift_ring2(R)

        cv2.imshow('img_mask2', img_mask2)
        key = cv2.waitKey(1) & 0xFF
        rawCapture.truncate(0)

        if key == ord("q"):
            print("Landing")
            drone.sendLanding()
            break

except Exception as e:
    print(e)
    drone.sendLanding()

drone.close()
