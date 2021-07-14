from e_drone.drone import *
from picamera.array import PiRGBArray
from picamera import PiCamera
from time import sleep
import numpy as np
import cv2

def findcenter():
    return F_x, F_y # 링 중점 좌표

R_x, R_y = None, None # 링 중점 좌표와 현재 드론 위치와의 차이 (현재 드론 좌표값에서 링 중점 좌표값을 뺀다.)

drone = Drone()
drone.open()

try:
    drone.sendTakeOff()
    sleep(5)

    camera = PiCamera()
    camera.resolution = (640, 480)
    camera.framerate = 32
    rawCapture = PiRGBArray(camera, size=(640, 480))
    th_c = [5, 52, 102]
    drone.sendControlPosition16(10, 0, 0, 5, 0, 0)

    for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
        img = frame.array
        img = cv2.flip(img, 0)
        img = cv2.flip(img, 1)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

        H = img[:, :, 0]

        _, bi_H = cv2.threshold(H, th_c[0] - 5, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[0] + 4, 255, cv2.THRESH_BINARY_INV)
        R = cv2.bitwise_and(bi_H, bi_H_)

        _, bi_H = cv2.threshold(H, th_c[1] - 5, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[1] + 4, 255, cv2.THRESH_BINARY_INV)
        G = cv2.bitwise_and(bi_H, bi_H_)

        _, bi_H = cv2.threshold(H, th_c[2] - 12, 255, cv2.THRESH_BINARY)
        _, bi_H_ = cv2.threshold(H, th_c[2] + 12, 255, cv2.THRESH_BINARY_INV)
        B = cv2.bitwise_and(bi_H, bi_H_)

        rawCapture.trucate(0)

        R_pixel = np.sum(R == 255, axis=None)
        G_pixel = np.sum(G == 255, axis=None)  # Purple로 대체
        B_pixel = np.sum(B == 255, axis=None)

        print('R: {}, G: {}, B: {}'.format(R, G, B))

        direction = -1

        if R_x < -106 and direction == -1: # 현재 드론 위치가 링 중점보다 왼쪽에 위치할 때
            place_x = 1
        elif R_x > 106 and direction == -1: # 현재 드론 위치가 링 중점보다 오른쪽에 위치할 때
            place_x = -1
        if R_y < -106 and direction == -1: # 현재 드론 위치가 링 중점보다 아래에 위치할 때
            place_y = 1
        elif R_y > 106 and direction == -1:  # 현재 드론 위치가 링 중점보다 위에 위치할 때
            place_y = -1
        if -160 <= R_x <= 160:
            place_x = 0
        if -160 <= R_y <= 160:
            place_y = 0
        if place_x == 0 and place_y == 0:
            drone.sendControlPosition16(5, 0, 0, 5, 0, 0)

        if B_pixel < 50000 and R_pixel > 5500 and direction == 0: # 링 배경 픽셀이 50000개 이하, 빨간 원 픽셀이 5500개 이상, Hovering 상태
            direction = 1
        if B_pixel < 50000 and G_pixel > 5500 and direction == 0:  # G_pixel은 Purple값으로 바꿀 예정
            direction = 2   

        elif direction == -1: # Hovering
            drone.sendControlWhile(0, 0, 0, 0, 5000)
        elif direction == 1: # 좌회전 후 1m 직진
            drone.sendControlPosition16(0, 0, 0, 0, 90, 30)
            drone.sendControlPosition16(10, 0, 0, 5, 0, 0)
        elif direction == 2: # Landing
            drone.sendLanding()
            drone.close()
            break

        if place_x == 1:
            drone.sendControlPosition16(0, 1, 0, 5, 0, 0) # 오른쪽으로 10cm
        elif place_x == -1:
            drone.sendControlPosition16(0, -1, 0, 5, 0, 0) # 왼쪽으로 10cm
        if place_y == 1:
            drone.sendControlPosition16(0, 0, 1, 5, 0, 0) # 위로 10cm
        elif place_y == -1:
            drone.sendControlPosition16(0, 0, -1, 5, 0, 0) # 아래로 10cm

    sleep(3)

except Exception as e:
    print(e)
    drone.sendLanding()
    drone.close()
